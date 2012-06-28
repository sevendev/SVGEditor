package svgeditor.parser 
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.LineScaleMode;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import svgeditor.parser.IParser;
	import svgeditor.parser.model.Data;
	import svgeditor.parser.style.Style;
	import svgeditor.parser.utils.StyleUtil;
	import svgeditor.parser.abstract.AbstractEditable;
	import svgeditor.Constants;
	
	public class Group extends AbstractEditable implements IParser
	{
		
		public static var LOCALNAME:String = "g";
		
		private var _x:Number;
		private var _y:Number;
		private var _width:Number;
		private var _height:Number;
		
		public function Group() { }
		
		override public function redraw():void 
		{
			this.transform.matrix = new Matrix();
			applyStyle( this );
		}

		public function parse( data:Data ):void {
			_style = new Style( data.currentXml );
			if ( !style.display ) return;
			this.name = style.id;
			
			_x = StyleUtil.toNumber( data.currentXml.@x );
			_y = StyleUtil.toNumber( data.currentXml.@y );
			_width = StyleUtil.toNumber( data.currentXml.@width );
			_height = StyleUtil.toNumber( data.currentXml.@height );
			
			data.currentCanvas.addChild( this );
			var groupXML:XML = data.currentXml.copy();
			groupXML.setLocalName(  "_g" );	
			SvgFactory.parseData( data.copy( groupXML, this ) );
			
			if( _x != 0 )this.x = _x;
			if( _y != 0 )this.y = _y;
			if( _width != 0 ) this.width = _width;
			if( _height != 0 ) this.height = _height;
			
			applyStyle( this );
		}
		
		override public function getSvg():XML 
		{
			var node:XML = <{Group.LOCALNAME} />;
			style.setAttr( node, "id" , "viewBox", "transform", "clip_path", "filter" , "opacity" );
			var children:Vector.<IEditable> = this.getChildren();
			for each ( var item:IEditable in children ) 
				node.appendChild( item.getSvg() );
			return node;
		}
		
		override public function getNumChildren():int 
		{
			return numChildren;
		}
		
		override public function outline( f:Boolean ):void
		{
			var children:Vector.<IEditable> = this.getChildren();
			for each ( var item:IEditable in children ) 
				item.outline( f );
			if ( f ) 
			{
				this.filters = [];
				this.mask = null;
			}
			else
			redraw();
			
		}
		
		override public function newPrimitive():void 
		{
			style = new Style();
		}
		
		public function setChildren( children:Vector.<IEditable> ):void
		{
			for each( var child:IEditable in children )
				this.addChild( child as DisplayObject );
		}
		
		override public function edit():void 
		{ 
			var rect:Rectangle = this.getBounds( this );
			this.graphics.lineStyle( 1, Constants.EDIT_LINE_COLOR , .5 , false, LineScaleMode.NONE );
			this.graphics.drawRect( rect.x, rect.y , rect.width , rect.height );
		}
		
		override public function exit():void 
		{ 
			this.graphics.clear();
		}
	}

}