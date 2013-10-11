package sequoia.report.helper
{
	import flash.events.MouseEvent;
	
	import mx.charts.chartClasses.IAxis;
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.formatters.DateFormatter;
	import mx.managers.CursorManager;
	import mx.printing.FlexPrintJob;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import spark.collections.Sort;
	import spark.collections.SortField;
	import spark.components.gridClasses.GridColumn;
	import spark.formatters.DateTimeFormatter;
	import spark.formatters.NumberFormatter;
	
	import org.jok.flex.application.helper.DataSelectionDependingViewHelper;
	import org.jok.flex.application.model.FaultToken;
	import org.jok.flex.application.model.RemoteHandlerDescription;
	import org.jok.flex.utility.date.DateCalculationUtil;
	
	import sequoia.report.model.ValueToken;
	import sequoia.report.model.YearToken;
	import sequoia.report.utility.ValuesGenerator;
	
	[Bindable]
	public dynamic class SimpleOnePageReportViewHelper extends DataSelectionDependingViewHelper {
		
		//
		// VIEW DATA FIELDS
		//
		
		public var investmentTeam : String;
		
		public var contact : String;
		
		public var investmentService : HTTPService = new HTTPService();
		
		public var contactService : HTTPService = new HTTPService();
		
		public var historicalPerformancesValues : ArrayCollection = new ArrayCollection();
		
		public var yearlyPerformancesValues : ArrayCollection = new ArrayCollection();
		
		public var historicalNAVValues : ArrayCollection = new ArrayCollection();
		
		public var benchmarkPerformancesValues : ArrayCollection = new ArrayCollection();
		
		public var benchmarkNAVValues : ArrayCollection = new ArrayCollection();
		
		public var yearlyBenchmarkValues : ArrayCollection = new ArrayCollection();
		
		public var statisticInfo : ArrayCollection = new ArrayCollection();
		
		public var volatilityInfo : ArrayCollection = new ArrayCollection();
		
		public var marketInfo : ArrayCollection = new ArrayCollection();
		
		//
		// WORKING GLOBAL VARIABLES
		//		
		
		public var startDate : Date;
		
		public var endDate : Date;
		
		public var associatedIndex : Number;
		
		//
		// UTILITY FIELDS
		//
		
		public var percentFormatter : NumberFormatter = new NumberFormatter();
		
		public var dateFormatter : DateTimeFormatter = new DateTimeFormatter();
		
		public var monthFormatter : DateTimeFormatter = new DateTimeFormatter();
		
		public var djangoDateFormatter : DateTimeFormatter = new DateTimeFormatter();
		
		//
		// CONSTRUCTION AND INITIALIZATION
		//
		
		
		public function SimpleOnePageReportViewHelper(helperName:String) {
			super(helperName);
			initializeHTTPServices();
			initializeFormatters();
		}
		
		private function initializeHTTPServices() : void {
			investmentService.resultFormat = "text";
			investmentService.url = "review.txt";
			investmentService.addEventListener(ResultEvent.RESULT,investmentServiceResultHandler);
			
			contactService.resultFormat = "text";
			contactService.url = "review.txt";
			contactService.addEventListener(ResultEvent.RESULT,contactServiceResultHandler);
		}

		private function initializeFormatters() : void {
			percentFormatter.fractionalDigits = 2;
			percentFormatter.decimalSeparator = ".";
			percentFormatter.groupingSeparator = ",";
			percentFormatter.useGrouping = true;
			percentFormatter.errorText = "";
			
			dateFormatter.dateTimePattern = "MMM-yy";
			
			monthFormatter.dateTimePattern = "MMMM yyyy";
			
			djangoDateFormatter.dateTimePattern = "yyyy-MM-dd";
		}
		
		//
		// PRESENTATIONS FUNCTIONS
		//
		
		public function portfolioLabelFunction(pf : Object) : String {
			return pf.fields.portfolio_name;
		}
		
		public function indexLabelFunction(pf : Object) : String {
			return pf.fields.security_name;
		}
		
		public function renderPercentage(data : YearToken, column : GridColumn) : String {
			var result : String = percentFormatter.format(data[column.dataField] * 100.0);
			if (result=="") {
				return result;
			}
			return result + "%";
		}
		
		public function renderStatistic(data : Object, column : GridColumn) : String {
			var result : String = percentFormatter.format(data[column.dataField] * 100.0);
			if (result=="") {
				return result;
			}
			return result + "%";
		}
		
		public function renderDate(labelValue:Object, previousLabelValue:Object, axis:IAxis, labelItem:Object) : String {
			return dateFormatter.format(labelValue);
		}
		
		public function computeStatistics() : void {
			var allStatistics : Array = ValuesGenerator.computeStatistics(historicalPerformancesValues, benchmarkPerformancesValues,yearlyPerformancesValues, yearlyBenchmarkValues).toArray();
			
			statisticInfo.removeAll();
			statisticInfo.addAll(new ArrayCollection(allStatistics.slice(0,6)));
			
			volatilityInfo.removeAll();
			volatilityInfo.addAll(new ArrayCollection(allStatistics.slice(6,9)));
			
			marketInfo.removeAll();
			marketInfo.addAll(new ArrayCollection(allStatistics.slice(9,11)));
		}
		
		public function assignDisplaySort() : void {
			var sortField : SortField = new SortField();
			sortField.name = "year";
			sortField.numeric = true;
			sortField.descending = true;
			var yearSort: Sort = new Sort();
			yearSort.fields = [sortField];
			yearlyPerformancesValues.sort = yearSort;
			yearlyPerformancesValues.refresh();
		}
		
		//
		// USERS INTERACTIONS
		//
		public function printClickHandler(event:MouseEvent) : void {
			var printJob : FlexPrintJob = new FlexPrintJob();
			printJob.start();
			printJob.addObject(myView()["printArea"]);
			printJob.send();
		}
		
		
		public function selectionChanged(portfolioId : Number, indexId : Number, userDate : Date) : void {
			associatedIndex = indexId;
			startDate = new Date(userDate.fullYear - 5, 0, 31);
			endDate = DateCalculationUtil.getEndOfMonth(userDate);
			this.callRemote("portfolioPerformances", null, onPortfolioPerformancesResult, onAnyPerformancesFault, djangoDateFormatter.format(startDate), djangoDateFormatter.format(endDate), portfolioId);
		}
		
		//
		// EVENTS HANDLERS
		//
		
		protected function onPortfolioPerformancesResult(result : Object, handler : RemoteHandlerDescription = null) : void {
			trace(result);
			CursorManager.removeAllCursors();
			historicalPerformancesValues.removeAll();
			for each(var item : Object in result) {
				historicalPerformancesValues.addItem(new ValueToken(DateFormatter.parseDateString(item.fields.quote_date), item.fields.quote_value));
			}
			yearlyPerformancesValues.removeAll();
			yearlyPerformancesValues.addAll(ValuesGenerator.makeYearlyInformation(historicalPerformancesValues));
			historicalPerformancesValues.refresh();
			
			historicalNAVValues.removeAll();
			var previousToken : ValueToken = new ValueToken(DateCalculationUtil.getEndOfPreviousMonth(startDate),100.0);
			for each (var token : ValueToken in historicalPerformancesValues) {
				var navToken : ValueToken = new ValueToken(token.date, previousToken.value * (1.0 + token.value));
				historicalNAVValues.addItem(navToken);
				previousToken = navToken;
			}
			this.callRemote("securityPerformances", null, onSecurityPerformancesResult, onAnyPerformancesFault, djangoDateFormatter.format(startDate), djangoDateFormatter.format(endDate), associatedIndex);
		}
		
		protected function onSecurityPerformancesResult(result : Object, handler : RemoteHandlerDescription = null) : void {
			trace(result);
			CursorManager.removeAllCursors();
			yearlyPerformancesValues.sort = null;
			benchmarkPerformancesValues.removeAll();
			for each(var item : Object in result) {
				benchmarkPerformancesValues.addItem(new ValueToken(DateFormatter.parseDateString(item.fields.quote_date), item.fields.quote_value));
			}
			yearlyBenchmarkValues.removeAll();
			yearlyBenchmarkValues.addAll(ValuesGenerator.makeYearlyInformation(benchmarkPerformancesValues));
			benchmarkPerformancesValues.refresh();
			
			benchmarkNAVValues.removeAll();
			var previousToken : ValueToken = new ValueToken(DateCalculationUtil.getEndOfPreviousMonth(startDate),100.0);
			for each (var token : ValueToken in benchmarkPerformancesValues) {
				var navToken : ValueToken = new ValueToken(token.date, previousToken.value * (1.0 + token.value));
				benchmarkNAVValues.addItem(navToken);
				previousToken = navToken;
			}
						
			computeStatistics();
			assignDisplaySort();

		}
		
		protected function onAnyPerformancesFault(fault : FaultToken, handler : RemoteHandlerDescription = null) : void {
			CursorManager.removeAllCursors();
			Alert.show("Could not load historical data");
		}
		
		protected function investmentServiceResultHandler(event:ResultEvent) : void {
			investmentTeam = event.result as String;
		}
		
		protected function contactServiceResultHandler(event:ResultEvent) : void {
			contact = event.result as String
		}
		
		protected function httpServiceFaultHandler(event:FaultEvent) : void {
			Alert.show("Could not load text");
		}
		
	}
}