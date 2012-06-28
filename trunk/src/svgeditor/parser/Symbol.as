package svgeditor.parser 
{
	import flash.display.DisplayObject;
	import svgeditor.parser.IParser;
	import svgeditor.parser.model.Data;
	import svgeditor.parser.style.Style;
	import flash.display.Sprite;
	
	public class Symbol implements IParser
	{
		public static var LOCALNAME:String = "symbol";
		
		public function Symbol() { }
		public function parse( data:Data ):void { }
		
		public function getSvg():XML 
		{
			var node:XML =<{Symbol.LOCALNAME} />;
			return node;
		}
	}
}