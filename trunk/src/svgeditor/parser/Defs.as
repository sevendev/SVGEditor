package svgeditor.parser 
{
	import flash.display.DisplayObject;
	import svgeditor.parser.IParser;
	import svgeditor.parser.model.Data;
	import svgeditor.parser.style.Style;
	import flash.display.Sprite;

	public class Defs implements IParser
	{
		public static var LOCALNAME:String = "defs";
		
		public function Defs() { }
		
		public function parse( data:Data ):void {
			var style:Style = new Style( data.currentXml );
			var group:Sprite = new Sprite();
			group.name = style.id;
			var groupXML:XML = data.currentXml.copy();
			groupXML.setLocalName(  "_defs" );	
			SvgFactory.parseData( data.copy( groupXML, group ) );
			group = null;
		}
	}

}