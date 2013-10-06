package sequoia.report.utility
{
	[Bindable]
	public dynamic class AssetsProvider {
		public function AssetsProvider() {
		}
		
		[Embed(source="/../assets/sequoia_big.jpg")]
		public static var sequoia_logo : Class;
	}
}