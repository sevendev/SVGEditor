package svgeditor.ui 
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.LineScaleMode;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.events.MouseEvent;
	import svgeditor.parser.path.EditPoint;
	import svgeditor.Constants;
	import svgeditor.parser.utils.GeomUtil;
	
	public class CreationPoint extends Sprite
	{
		protected var _canvas:DisplayObjectContainer;
		protected var _virtual:DisplayObjectContainer;
		protected var _epoints:Vector.<EditPoint>;
		protected var _currentPoint:EditPoint;
		protected var _count:int = 0;
		
		public function CreationPoint( canvas:DisplayObjectContainer , virtual:DisplayObjectContainer ) 
		{ 
			this._canvas = canvas;
			this._virtual = virtual;
			_canvas.addChild( this );
			this.stage.addEventListener( MouseEvent.MOUSE_DOWN, onClick );
			this.doubleClickEnabled = true;
		}
		
		public function get points():Vector.<Point> 
		{ 
			var pts:Vector.<Point> = new Vector.<Point>();
			for each( var p:EditPoint in _epoints )
				pts.push( GeomUtil.getActualPosition( this.parent , _virtual , p.ax , p.ay ) );
			return pts;
		}
		
		public function exit():void 
		{
			for each( var p:EditPoint in _epoints )
			{
				p.exit( true );
				p.removeEventListener( MouseEvent.MOUSE_DOWN , onDoubleClick );
			}
			this.stage.removeEventListener( MouseEvent.MOUSE_DOWN, onClick );
			_canvas.removeChild( this );
		}
		
		protected function onClick( e:MouseEvent ):void 
		{
			if ( !_epoints ) 
				_epoints = new Vector.<EditPoint>();
			if ( _currentPoint ) 
				_currentPoint.removeEventListener( MouseEvent.MOUSE_DOWN , onDoubleClick );
				
			_currentPoint = new EditPoint( this, this, _count++ , this.mouseX, this.mouseY );
			_currentPoint.addEventListener( MouseEvent.MOUSE_DOWN , onDoubleClick );
			_epoints.push( _currentPoint );
			drawLine();
			dispatchEvent( new Event( Event.CHANGE ) );
		}
		
		protected function onDoubleClick( e:MouseEvent ):void 
		{
			if ( !_epoints || _epoints.length <= 1 ) 
			{
				dispatchEvent( new Event( Event.CANCEL ) );
				return;
			}
			var p:EditPoint = _epoints.pop();
			p.exit( true );
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		protected function drawLine():void 
		{
			this.graphics.lineStyle( 1, Constants.EDIT_LINE_COLOR, 1, false, LineScaleMode.NONE );
			var pt:EditPoint = _epoints[ _epoints.length - 1 ];
			if ( _epoints.length <= 1 )
				this.graphics.moveTo( pt.ax, pt.ay );
			else
				this.graphics.lineTo( pt.ax, pt.ay );
		}

	}

}