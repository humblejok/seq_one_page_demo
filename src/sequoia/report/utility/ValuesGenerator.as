package sequoia.report.utility
{
	import mx.collections.ArrayCollection;
	
	import org.jok.flex.utility.date.DateCalculationUtil;
	
	import sequoia.report.model.BreakdownToken;
	import sequoia.report.model.ValueToken;
	import sequoia.report.model.YearToken;

	public class ValuesGenerator {
		
		public static var STYLES : Array = ['Event Driven', 'Convertible Arbitrage','Emerging markets','Dedicated Short Bias', 'Global Macro','Managed Futures', 'Long/Short Equity', 'Real Estate', 'Commodities', 'Fixed Income Arbitrage'];
		public static var STRATEGIES : Array = ['Volatility Arbitrage','Statistical Arbitrage','Credit Arbitrage','Market Neutral','Convertible Arbitrage'];
		public static var REGIONS : Array = ['Europe','Asia','LATAM', 'Japan', 'North America', 'USA', 'Africa', 'India','Italy','Greece'];
		
		
		public static function generateHistory(startDate : Date, endDate : Date) : ArrayCollection {
			var results : ArrayCollection = new ArrayCollection()
			var workDate : Date = DateCalculationUtil.getEndOfMonth(startDate);
			while (workDate<=endDate) {
				
				var value : Number = Math.random();
				var sign : Number = Math.random()<0.5?-1.0:1.0;
				while (value>0.25) {
					value = Math.random();
				}
				results.addItem(new ValueToken(workDate, sign * value));
				workDate = DateCalculationUtil.getEndOfNextMonth(workDate);
			}
			return results;
		}
		
		public static function makeYearlyInformation(data : ArrayCollection) : ArrayCollection {
			var result : ArrayCollection = new ArrayCollection();
			var year : YearToken = null;
			for each (var token : ValueToken in data) {
				if (year==null || year.year!=token.date.fullYear) {
					if (year!=null) {
						result.addItem(year)
					}
					year = new YearToken();
					year.year = token.date.fullYear;
				}
				year[YearToken.MONTHS[token.date.month]] = token.value;
				year.ytd = ((year.ytd + 1.0) * (token.value + 1.0)) - 1.0;
			}
			result.addItem(year);
			return result;
		}
		
		public static function generateBreakdown(source : Array) : ArrayCollection {
			var result : ArrayCollection = new ArrayCollection();
			var size : Number = Math.random() * source.length;
			var sum : Number = 0.0;
			var token : BreakdownToken;
			for (var i : Number = 0;i<size-1;i++) {
				token = new BreakdownToken();
				token.label = source[i];
				token.value = Math.random();
				while (sum+token.value>1.0) {
					token.value = Math.random();
				}
				sum = sum + token.value;
				result.addItem(token);
			}
			token = new BreakdownToken();
			token.label = source[result.length];
			token.value = 1.0 - sum;
			result.addItem(token);
			return result;
		}
		
	}
}