package svgeditor.parser 
{
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.display.GraphicsPathCommand;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import svgeditor.parser.IParser;
	import svgeditor.parser.abstract.AbstractPaint;
	import svgeditor.parser.model.Data;
	import svgeditor.parser.style.Style;
	import svgeditor.parser.utils.StyleUtil;
	import svgeditor.parser.utils.GeomUtil;
	import svgeditor.parser.path.EditPoint;
	import svgeditor.event.PathEditEvent;
	import svgeditor.ui.CreationBox;

	public class Circle extends AbstractPaint implements IParser
	{
		public static var LOCALNAME:String = "circle";
		
		private var _cx:Number;
		private var _cy:Number;
		private var _r:Number;
		
		private var posPt:EditPoint;
		private var rPt:EditPoint;
		
		public function Circle() { }
		
		/* IEditable methods*/
		override public function redraw():void 
		{ 
			paint( this , style );
		}
		
		override public function edit():void 
		{
			createControl();
			posPt = new EditPoint( _controlLayer, _pathLayer , 0, _cx, _cy );
			rPt = new EditPoint( _controlLayer, _pathLayer , 1, _cx + _r, _cy );
			posPt.addEventListener( PathEditEvent.PATH_EDIT , onPathEdit );
			posPt.addEventListener( PathEditEvent.PATH_EDIT_FINISH , onPathEditFinish );
			rPt.addEventListener( PathEditEvent.PATH_EDIT , onPathEdit );
			rPt.addEventListener( PathEditEvent.PATH_EDIT_FINISH , onPathEditFinish );
			drawEditLine();
		}
		
		override public function exit():void
		{
			posPt.removeEventListener( PathEditEvent.PATH_EDIT , onPathEdit );
			posPt.removeEventListener( PathEditEvent.PATH_EDIT_FINISH , onPathEditFinish );
			posPt.exit();
			rPt.removeEventListener( PathEditEvent.PATH_EDIT , onPathEdit );
			rPt.removeEventListener( PathEditEvent.PATH_EDIT_FINISH , onPathEditFinish );
			rPt.exit();
			removeControl();
		}
		
		override public function getSvg():XML 
		{
			var node:XML = <{Circle.LOCALNAME} />;
			node.@cx = _cx;
			node.@cy = _cy;
			node.@r = _r;
			setPaintAttr( node );
			return node;
		}
		
		override public function get convertible():Boolean { return true ; };
		
		/* IParser methods*/
		public function parse( data:Data ):void 
		{
			style = new Style( data.currentXml );

			_cx = StyleUtil.toNumber ( data.currentXml.@cx );
			_cy = StyleUtil.toNumber ( data.currentXml.@cy );
			_r =  StyleUtil.toNumber ( data.currentXml.@r );
			
			data.currentCanvas.addChild( this );
			paint( this, style, data );
		}
		
		override protected function onCreationUpdate( e:Event ):void
		{
			_r = _creationBox.rect.width / 2;
			_cx = _creationBox.rect.x + _r;
			_cy = _creationBox.rect.y + _r;
			redraw();
		}
		
		override protected function draw( graphics:Graphics ):void {
			graphics.drawCircle( _cx, _cy, _r );
		}
		
		override protected function getPathString():String 
		{ 
			var r:Rectangle = new Rectangle( _cx - _r , _cy - _r ,  _r * 2 ,  _r * 2  );
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
			_cx = posPt.ax;
			_cy = posPt.ay;
			_r = GeomUtil.getDistance( new Point( _cx, _cy ) , new Point( rPt.ax, rPt.ay ) );
			drawEditLine();
		}
		
		private function onPathEditFinish( e:PathEditEvent ):void 
		{
			redraw();
		}
	}

}