package sequoia.report.model
{
	public class QuantitativeToken {
		
		public var date : Date;
		
		public var monthToDate : Number;
		
		public var yearToDate : Number;
		
		public var last12Month : Number;
		
		public var totalReturn : Number;
		
		public var avgAnnualReturn : Number;
		
		public var avgMonthlyReturn : Number;
		
		public var volatility : Number;
		
		public var upsideVolatility : Number;
		
		public var downsideVolatility : Number;
		
		public var avgMonthlyAlpha : Number;		
		
		public var avgAnnualAlpha : Number;
		
		public function QuantitativeToken() {
		}
		
		public function toArray() : Array {
			var result : Array = new Array();
			result.push({"label":"Month-to-date", "value":monthToDate});
			result.push({"label":"Year-to-date", "value":yearToDate});
			result.push({"label":"Last 12 months", "value":last12Month});
			result.push({"label":"Total Return", "value":totalReturn});
			result.push({"label":"Ave. Ann. Return", "value":avgAnnualReturn});
			result.push({"label":"Ave. Mon. Return", "value":avgMonthlyReturn});
			result.push({"label":"Volatility", "value":volatility});
			result.push({"label":"Upside Volatility", "value":upsideVolatility});
			result.push({"label":"Downside Volatility", "value":downsideVolatility});
			result.push({"label":"Ave. Mon. Excess Return", "value":avgMonthlyAlpha});
			result.push({"label":"Ave. Ann. Excess Return", "value":avgAnnualAlpha});
			return result;
		}
		
	}
}