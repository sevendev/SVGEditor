package svgeditor.ui 
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.LineScaleMode;
	import flash.display.GraphicsPathCommand;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.events.Event;
	import svgeditor.parser.IEditable;
	import svgeditor.parser.path.*;
	import svgeditor.ui.CreationPoint;
	import svgeditor.Constants;
	import svgeditor.parser.utils.GeomUtil;
	
	public class PathCreationPoint extends Sprite
	{
		protected var _canvas:DisplayObjectContainer;
		protected var _virtual:DisplayObjectContainer;
		protected var _bpoints:Vector.<BezierPoint>;
		protected var _currentPoint:BezierPoint;
		protected var _firstPoint:BezierPoint;
		protected var _firstPathIcon:Sprite
		protected var _count:int = 0;
		protected var _closed:Boolean = false;
		
		public function PathCreationPoint( canvas:DisplayObjectContainer , virtual:DisplayObjectContainer ) 
		{
			this._canvas = canvas;
			this._virtual = virtual;
			_canvas.addChild( this );
			this.stage.addEventListener( MouseEvent.MOUSE_DOWN, onClick );
			this.doubleClickEnabled = true;
		}
		
		public function exit():void 
		{
			for each( var p:BezierPoint in _bpoints )
			{
				p.exit( true );
				p.removeEventListener( MouseEvent.MOUSE_DOWN , onDoubleClick );
			}
			this.stage.removeEventListener( MouseEvent.MOUSE_DOWN, onClick );
			_canvas.removeChild( this );
			
			_canvas = null;
			_virtual = null;
			_bpoints = null;
			_currentPoint = null;
		}
		
		public function getPathManager():PathManager
		{
			var pm:PathManager = new PathManager();
			for ( var i:int = 0; i < _bpoints.length; i++ )
			{
				var a:Point = GeomUtil.getActualPosition( this.parent, _virtual , _bpoints[i].ax , _bpoints[i].ay );
				var c:Point = GeomUtil.getActualPosition( this.parent, _virtual , _bpoints[i].cx , _bpoints[i].cy );
				var c1:Point = GeomUtil.getActualPosition( this.parent, _virtual , _bpoints[i].cx1 , _bpoints[i].cy1 );
				
				if ( i == 0 )
					pm.addPoint( a.x, a.y , GraphicsPathCommand.MOVE_TO );
				else if ( !_bpoints[i].hasControl() ) 
					pm.addPoint( a.x, a.y , GraphicsPathCommand.LINE_TO );
				else 
				{
					var last:IEditPoint = _bpoints[i - 1];
					var cx1:Number = ( isNaN( last.cx1 ) || last.cx1 == 0 ) ? last.ax : last.cx1;
					var cy1:Number = ( isNaN( last.cy1 ) || last.cy1 == 0 ) ? last.ay : last.cy1;
					var lc1:Point =  GeomUtil.getActualPosition( this.parent, _virtual , cx1 , cy1 );
					pm.addBezierCurve( lc1.x, lc1.y, c.x, c.y , a.x, a.y );
				}
			}
			if ( _closed ) pm.closePath() ;
			return pm;
		}
		
		public function get closed():Boolean { return _closed; }
		public function set closed(value:Boolean):void { _closed = value; }
		
		protected function onClick( e:MouseEvent ):void 
		{
			if ( !_bpoints ) 
				_bpoints = new Vector.<BezierPoint>();
			if ( _currentPoint ) 
				_currentPoint.removeEventListener( MouseEvent.MOUSE_DOWN , onDoubleClick );
			
			_currentPoint = new BezierPoint( _count++ , this.mouseX, this.mouseY  );
			_currentPoint.setCanvas( this );
			_currentPoint.createPointForCreation();
			this.stage.addEventListener( MouseEvent.MOUSE_MOVE , onMouseMove );
			this.stage.addEventListener( MouseEvent.MOUSE_UP , onMouseUp );
			_currentPoint.addEventListener( MouseEvent.MOUSE_DOWN , onDoubleClick );
			_bpoints.push( _currentPoint );
			
			if ( _count == 1 ) 
			{
				_firstPoint = _currentPoint;
				_firstPoint.addEventListener( MouseEvent.MOUSE_OVER, showFirstIcon );
				_firstPoint.addEventListener( MouseEvent.MOUSE_OUT, hideFirstIcon );
				_firstPoint.addEventListener( MouseEvent.MOUSE_DOWN, closePath );
			}
			
			dispatchEvent( new Event( Event.CHANGE ) );
		}
		
		protected function onMouseMove( e:MouseEvent ):void 
		{
			_currentPoint.setControlForCreation( this.mouseX - _currentPoint.ax , this.mouseY - _currentPoint.ay , 2 );
			dispatchEvent( new Event( Event.CHANGE ) );
		}
		
		protected function onMouseUp( e:MouseEvent ):void 
		{
			this.stage.removeEventListener( MouseEvent.MOUSE_MOVE , onMouseMove );
			this.stage.removeEventListener( MouseEvent.MOUSE_UP , onMouseUp );
		}
			
		protected function onDoubleClick( e:MouseEvent ):void 
		{
			if ( _bpoints.length <= 1 ) 
				dispatchEvent( new Event( Event.CANCEL ) );
			dispatchEvent( new Event( Event.CHANGE ) );
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		protected function showFirstIcon( e:MouseEvent ):void 
		{
			_firstPoint.showIndicator( true );
		}
		
		protected function hideFirstIcon( e:MouseEvent ):void 
		{
			_firstPoint.showIndicator( false );
		}
		
		protected function closePath( e:MouseEvent ):void 
		{
			if ( !_currentPoint )
			{
				dispatchEvent( new Event( Event.CANCEL ) );
				return;
			}

			_currentPoint = new BezierPoint( _count++ , _firstPoint.ax, _firstPoint.ay, 
														_firstPoint.cx , _firstPoint.cy, 
														_firstPoint.cx1 , _firstPoint.cy1  );
			_currentPoint.setCanvas( this );
			_bpoints.push( _currentPoint );
			_closed = true;
			dispatchEvent( new Event( Event.CHANGE ) );
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
	}

}