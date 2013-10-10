package sequoia.report.utility
{
	[Bindable]
	public dynamic class AssetsProvider {
		public function AssetsProvider() {
		}
		
		[Embed(source="/../assets/sequoia_big.jpg")]
		public static var sequoia_logo : Class;
		
		[Embed(source="/../assets/logoSequoiaWhite.png")]
		public static var sam_logo : Class;
	}
}