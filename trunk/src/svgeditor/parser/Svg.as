package svgeditor.parser 
{
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import svgeditor.parser.IParser;
	import svgeditor.Constants;
	import svgeditor.parser.model.Data;
	import svgeditor.parser.style.Style;
	import svgeditor.parser.abstract.AbstractEditable;
	import svgeditor.parser.model.PersistentData;
	
	public class Svg extends AbstractEditable implements IParser 
	{
		
		public static var LOCALNAME:String = "svg";
		
		public function Svg() { }
		
		public function parse( data:Data ):void 
		{
			style = new Style( data.currentXml );
			if ( !style.display ) return;
			this.name = style.id;
			applyStyle( this );
			drawCanvas( style.viewBox );
			data.currentCanvas.addChild( this );
			var svgXML:XML = data.currentXml.copy();
			svgXML.setLocalName(  "_svg" );	
			SvgFactory.parseData( data.copy( svgXML , this ) );
		}
		
		override public function getSvg():XML 
		{
			var node:XML = <{Svg.LOCALNAME} xmlns="http://www.w3.org/2000/svg" />;
			node.addNamespace( Constants.svg );
			node.addNamespace( Constants.xlink );
			node.@version = Constants.SVG_VERSION;
			style.setAttr( node, "id" , "viewBox" );
			var children:Vector.<IEditable> = this.getChildren();
			for each ( var item:IEditable in children ) 
				node.appendChild( item.getSvg() );
			return node;
		}
		
		override public function outline( f:Boolean ):void
		{
			var children:Vector.<IEditable> = this.getChildren();
			for each ( var item:IEditable in children ) 
				item.outline( f );
		}
		
		private function drawCanvas( box:Rectangle ):void 
		{
			if ( !box ) box = new Rectangle( 0 , 0, 600, 800 );
			this.graphics.lineStyle( 1, 0xcccccc, 1 );
			this.graphics.beginFill( 0xffffff, 1 );
			this.graphics.drawRect( box.x, box.y , box.width - 1, box.height - 1 );
			this.graphics.endFill();
			this.scrollRect = null;
		}
		
		override public function getNumChildren():int 
		{
			return numChildren;
		}
		override public function redraw():void {}
		override public function edit():void { }
		override public function exit():void { }
		
	}

}