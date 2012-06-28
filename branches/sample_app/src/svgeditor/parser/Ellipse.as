package svgeditor.parser 
{

	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import svgeditor.parser.style.Style;
	import svgeditor.parser.model.Data;
	import svgeditor.parser.abstract.AbstractPaint;
	import svgeditor.parser.utils.StyleUtil;
	import svgeditor.parser.path.EditPoint;
	import svgeditor.event.PathEditEvent;
	import svgeditor.parser.utils.GeomUtil;
	
	public class Ellipse extends AbstractPaint implements IParser
	{
		public static var LOCALNAME:String = "ellipse";
		
		private var _cx:Number;
		private var _cy:Number;
		private var _rx:Number;
		private var _ry:Number;
		
		private var pt1:EditPoint;
		private var pt2:EditPoint;
		
		public function Ellipse() {}
		
		/* IEditable methods*/
		override public function redraw():void 
		{ 
			paint( this , style );
		}
		
		override public function edit():void 
		{
			createControl();
			pt1 = new EditPoint( _controlLayer, _pathLayer , 0 , _cx, _cy );
			pt2 = new EditPoint( _controlLayer, _pathLayer , 1, _cx + _rx, _cy + _ry );
			pt1.addEventListener( PathEditEvent.PATH_EDIT , onPathEdit );
			pt1.addEventListener( PathEditEvent.PATH_EDIT_FINISH , onPathEditFinish );
			pt2.addEventListener( PathEditEvent.PATH_EDIT , onPathEdit );
			pt2.addEventListener( PathEditEvent.PATH_EDIT_FINISH , onPathEditFinish );
			drawEditLine();
		}
		
		override public function exit():void
		{
			pt1.removeEventListener( PathEditEvent.PATH_EDIT , onPathEdit );
			pt1.removeEventListener( PathEditEvent.PATH_EDIT_FINISH , onPathEditFinish );
			pt1.exit();
			pt2.removeEventListener( PathEditEvent.PATH_EDIT , onPathEdit );
			pt2.removeEventListener( PathEditEvent.PATH_EDIT_FINISH , onPathEditFinish );
			pt2.exit();
			removeControl();
		}
		
		override public function getSvg():XML 
		{
			var node:XML = <{Ellipse.LOCALNAME} />;
			node.@cx = _cx;
			node.@cy = _cy;
			node.@rx = _rx;
			node.@ry = _ry;
			setPaintAttr( node );
			return node;
		}
		
		override protected function onCreationUpdate( e:Event ):void
		{
			_rx = _creationBox.rect.width / 2;
			_ry = _creationBox.rect.height / 2;
			_cx = _creationBox.rect.x + _rx;
			_cy = _creationBox.rect.y + _ry;
			redraw();
		}
		
		override public function get convertible():Boolean { return true ; };
		
		/* IParser methods*/
		public function parse( data:Data ):void 
		{
			_style = new Style( data.currentXml );
			
			_cx = StyleUtil.toNumber( data.currentXml.@cx );
			_cy = StyleUtil.toNumber( data.currentXml.@cy );
			_rx = StyleUtil.toNumber( data.currentXml.@rx );
			_ry = StyleUtil.toNumber( data.currentXml.@ry );
			
			data.currentCanvas.addChild( this );
			paint( this, style, data );
		}
		
		override protected function draw( graphics:Graphics ):void {
			graphics.drawEllipse( _cx - _rx, _cy -_ry , _rx * 2, _ry * 2 );
		}
		
		override protected function getPathString():String 
		{ 
			var r:Rectangle = new Rectangle( _cx - _rx , _cy - _ry ,  _rx * 2 , _ry * 2   );
			var pts:Vector.<Point> = GeomUtil.getBezierPointsOnCircle( r , 1.8 );
			var d:String = "M";
			pts.forEach( function ( pt:Point, index:Number, vec:Vector.<Point> ):void {
				var s:String = ( index % 3 == 0 ) ? ( index == vec.length-1 ) ? "Z" :"C" : " ";
				d += pt.x + "," + pt.y + s;
			});
			return d;
		}
		
		private function onPathEdit( e:PathEditEvent ):void 
		{
			_cx = pt1.ax;
			_cy = pt1.ay;
			_rx = pt2.ax - pt1.ax;
			_ry = pt2.ay - pt1.ay;
			drawEditLine();
		}
		
		private function onPathEditFinish( e:PathEditEvent ):void 
		{
			redraw();
		}
		
	}

}