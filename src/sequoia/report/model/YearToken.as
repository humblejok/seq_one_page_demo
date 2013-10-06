package sequoia.report.model
{
	public dynamic class YearToken {
		
		public static var MONTHS : Array = ['jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec'] 
		
		public var year : Number = Number.NaN;

		public var ytd : Number = 0.0;
		
		public function YearToken() {
		}
	}
}