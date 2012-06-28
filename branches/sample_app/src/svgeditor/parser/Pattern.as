package svgeditor.parser
{

	public class Pattern implements IParser
	{
		public static var LOCALNAME:String = "pattern";
		public function Pattern() { }
		
		public function getSvg():XML 
		{
			var node:XML =<{Pattern.LOCALNAME} />;
			return node;
		}
	}

}