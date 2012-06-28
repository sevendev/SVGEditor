package svgeditor.parser 
{
	import flash.display.*;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import svgeditor.parser.abstract.AbstractPaint;
	import svgeditor.parser.model.Data;
	import svgeditor.parser.style.Style;
	import svgeditor.parser.utils.StyleUtil;
	import svgeditor.parser.path.EditPoint;
	import svgeditor.ui.RemovableDragItem;
	import svgeditor.event.PathEditEvent;
	
	public class Rect extends AbstractPaint implements IParser
	{
		public static var LOCALNAME:String = "rect";
		
		public function Rect() { }
		
		private var _x:Number;
		private var _y:Number;
		private var _width:Number;
		private var _height:Number;
		
		private var regPt:EditPoint;
		private var sizePt:EditPoint;
		
		/* IEditable methods*/
		override public function redraw():void 
		{ 
			paint( this , style );
		}
		
		override public function edit():void 
		{
			createControl();
			regPt = new EditPoint( _controlLayer, _pathLayer ,0, _x, _y );
			sizePt = new EditPoint( _controlLayer, _pathLayer , 1, _x + _width , _y + _height );
			regPt.addEventListener( PathEditEvent.PATH_EDIT , onPathEdit );
			sizePt.addEventListener( PathEditEvent.PATH_EDIT , onPathEdit );
			regPt.addEventListener( PathEditEvent.PATH_EDIT_FINISH , onPathEditFinish );
			sizePt.addEventListener( PathEditEvent.PATH_EDIT_FINISH , onPathEditFinish );
			drawEditLine(); 
		}
		override public function exit():void
		{
			regPt.exit();
			sizePt.exit();
			removeControl();
		}
		
		override public function getSvg():XML 
		{
			var node:XML = <{Rect.LOCALNAME} />;
			node.@x = _x;
			node.@y = _y;
			node.@width = _width;
			node.@height = _height;
			setPaintAttr( node );
			return node;
		}
		
		override public function get convertible():Boolean { return true ; };
		
		/* IParser methods*/
		public function parse( data:Data ):void 
		{
			var xml:XML = data.currentXml;
			_style = new Style( xml );
			
			_x = StyleUtil.toNumber( xml.@x );
			_y = StyleUtil.toNumber( xml.@y );
			_width = StyleUtil.toNumber( xml.@width.toString() );
			_height = StyleUtil.toNumber( xml.@height.toString() );

			data.currentCanvas.addChild( this );
			paint( this , style, data );
		}
		
		override protected function draw( graphics:Graphics ):void 
		{
			graphics.drawRect( _x, _y, _width, _height );
		}
		
		override protected function onCreationUpdate( e:Event ):void
		{
			_x = _creationBox.rect.x;
			_y = _creationBox.rect.y;
			_width = _creationBox.rect.width;
			_height = _creationBox.rect.height;
			redraw();
		}
		
		override protected function getPathString():String 
		{ 
			var r:Rectangle = new Rectangle( _x, _y , _width, _height );
			var d:String = 	"M" +	r.x + "," + r.y + "L" + 
									r.right +"," + r.top + " " + 
									r.right + "," + r.bottom + " " + 
									r.left + "," + r.bottom + " " + 
									r.x + "," + r.y + "Z" ;
			return d;
		}
		
		private function onPathEdit( e:PathEditEvent ):void 
		{
			_x = regPt.ax;
			_y = regPt.ay;
			_width = sizePt.ax - _x;
			_height = sizePt.ay - _y;
			
			drawEditLine();
		}
		
		private function onPathEditFinish( e:PathEditEvent ):void 
		{
			redraw();
		}
		
	}

}