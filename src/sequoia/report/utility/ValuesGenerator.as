package sequoia.report.utility
{
	import mx.collections.ArrayCollection;
	
	import org.jok.flex.utility.date.DateCalculationUtil;
	
	import sequoia.report.model.BreakdownToken;
	import sequoia.report.model.QuantitativeToken;
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
		
		public static function computeStatistics(product : ArrayCollection, benchmark : ArrayCollection, yearly : ArrayCollection, benchYearly : ArrayCollection) : QuantitativeToken {
			var result : QuantitativeToken = new QuantitativeToken();
			var months : Number = 0.0;
			
			var negativeMonths : Number = 0.0;
			var positiveMonths : Number = 0.0;
			var positiveMean : Number = 0.0;
			var negativeMean : Number = 0.0;
			
			result.avgMonthlyReturn = 0.0;
			result.avgAnnualReturn = 0.0;
			result.avgMonthlyAlpha = 0.0;
			result.avgAnnualAlpha = 0.0;
			result.last12Month = 0.0;
			result.totalReturn = 0.0;
			result.volatility = 0.0;	
			result.downsideVolatility = 0.0;
			result.upsideVolatility = 0.0;
			result.monthToDate = product.getItemAt(product.length-1).value;
			
			for(var i : Number = 0;i<product.length;i++) {
				if (product.getItemAt(i).value<0.0) {
					negativeMonths += 1.0;
					negativeMean -= product.getItemAt(i).value;
				} else {
					positiveMonths += 1.0;
					positiveMean += product.getItemAt(i).value;
				}
				if (i>=product.length-12) {
					result.last12Month = ((result.last12Month + 1.0) * (product.getItemAt(i).value + 1.0)) - 1.0
				}
				result.totalReturn = ((result.totalReturn + 1.0) * (product.getItemAt(i).value + 1.0)) - 1.0
			}
			
			positiveMean /= positiveMonths;
			negativeMean /= negativeMonths;
			
			for each(var yt : YearToken in yearly) {
				result.avgAnnualReturn += yt.ytd;
				for each (var m : String in YearToken.MONTHS) {
					if (yt.hasOwnProperty(m)) {
						months += 1.0;
						result.avgMonthlyReturn += yt[m];
					}
					
				}
			}
			
			for each(yt in benchYearly) {
				result.avgAnnualAlpha += yt.ytd;
				for each(m in YearToken.MONTHS) {
					if (yt.hasOwnProperty(m)) {
						result.avgMonthlyAlpha += yt[m];
					}
				}
			}
			
			result.avgMonthlyReturn /= months;
			result.avgAnnualReturn /= yearly.length;
			result.avgMonthlyAlpha /= months;
			result.avgAnnualAlpha /= yearly.length;
			result.avgMonthlyAlpha = result.avgMonthlyReturn - result.avgMonthlyAlpha;
			result.avgAnnualAlpha = result.avgAnnualReturn - result.avgAnnualAlpha;
			
			for each(var vt : ValueToken in product) {
				result.volatility += Math.pow(vt.value - result.avgMonthlyReturn,2);
				if (vt.value<0.0) {
					result.downsideVolatility += Math.pow(vt.value - negativeMean,2);
				} else {
					result.upsideVolatility += Math.pow(vt.value - positiveMean,2);
				}
			}
			
			result.volatility /= months;
			result.upsideVolatility/= positiveMonths;
			result.downsideVolatility/= negativeMonths;
			
			result.volatility = Math.sqrt(result.volatility);
			result.upsideVolatility = Math.sqrt(result.upsideVolatility);
			result.downsideVolatility = Math.sqrt(result.downsideVolatility);
			
			
			result.yearToDate = YearToken(yearly.getItemAt(yearly.length-1)).ytd;
			return result;
		}
		
	}
}