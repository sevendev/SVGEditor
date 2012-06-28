package svgeditor.ui 
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.GraphicsPathCommand;
	import flash.geom.Point;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import svgeditor.parser.path.PathManager;
	import svgeditor.parser.utils.GeomUtil;
	import svgeditor.Constants;
	
	public class DrawingCanvas extends Sprite
	{
		public var ds:Sprite;
		public var canvas:DisplayObjectContainer;
		public var virtual:DisplayObjectContainer;
		private var points:Vector.<Point>;
		private var reduced:Vector.<Point>;
		private var _closed:Boolean = false;
		
		public function DrawingCanvas( canvas:DisplayObjectContainer ,virtual:DisplayObjectContainer=null  ) 
		{
			this.canvas = canvas;
			this.virtual = virtual;
			canvas.addChild( this );
			ds = new Sprite();
			addChild( ds );
			this.stage.addEventListener( MouseEvent.MOUSE_DOWN, startDraw );
			this.stage.addEventListener( MouseEvent.DOUBLE_CLICK, cancel );
		}
		
		public function getPathManager():PathManager
		{
			var pm:PathManager = new PathManager();
			for ( var i:int = 0; i < reduced.length; i++ )
			{
				if ( i == 0 )
					pm.addPoint( reduced[i].x,  reduced[i].y, GraphicsPathCommand.MOVE_TO );
				else 
					pm.addPoint( reduced[i].x,  reduced[i].y, GraphicsPathCommand.LINE_TO );
			}
			if ( _closed ) pm.closePath() ;
			return pm;
		}
		
		public function exit():void
		{
			canvas.removeChild( this );
			canvas = null;
			virtual = null;
		}
		
		private function startDraw( e:MouseEvent ):void
		{
			this.stage.addEventListener( MouseEvent.MOUSE_MOVE , drawing );
			this.stage.addEventListener( MouseEvent.MOUSE_UP , drawFinish );
			
			points = new Vector.<Point>();
			
			ds.graphics.lineStyle( 1, Constants.DRAWING_LINE_COLOR , 1 );
			ds.graphics.moveTo( canvas.mouseX, canvas.mouseY );
		}
		
		private function drawing( e:MouseEvent ):void
		{
			ds.graphics.lineTo( canvas.mouseX, canvas.mouseY );
			points.push( new Point( canvas.mouseX, canvas.mouseY  ) );
		}
			
		private function drawFinish( e:MouseEvent ):void
		{
			this.stage.removeEventListener( MouseEvent.MOUSE_DOWN, startDraw );
			this.stage.removeEventListener( MouseEvent.MOUSE_MOVE , drawing );
			this.stage.removeEventListener( MouseEvent.MOUSE_UP , drawFinish );
			
			drawAgain();
		}
		
		private function drawAgain():void
		{
			if ( !points.length ) return;
			ds.graphics.clear();
			
			//angle based reduction
			var angle:Number;
			reduced = points.filter( function( p:Point, i:int, v:Vector.<Point> ):Boolean {
				if ( i == 0 )
				{
					angle = GeomUtil.getAngle(  p , v[i + 1] );
					return true;
				}
				if ( i == v.length -1  ) return true;
				
				var currentAngle:Number = GeomUtil.getAngle(  p , v[i - 1] );
				var lastAngle:Number = angle;
				angle = currentAngle;
				
				if (  Math.round( currentAngle   ) != Math.round( lastAngle  )) 
					return true;
					
				return false;
			});
			
			//distance based reduction
			reduced = reduced.filter( function( p:Point, i:int, v:Vector.<Point> ):Boolean {
				if ( i == 0 || i == v.length -1  ) return true;
				
				return GeomUtil.getDistance( p , v[ i -1 ] ) > Constants.DRAWING_POINT_MIN_DISTANCE;
			});
			
			if ( GeomUtil.getDistance( reduced[0] , reduced[ reduced.length -1 ] ) < Constants.DRAWING_POINT_MIN_DISTANCE ) 
			{
				reduced[ reduced.length -1 ].x = reduced[0].x;
				reduced[ reduced.length -1 ].y = reduced[0].y;
				_closed = true;
			}
			
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		private function cancel( e:MouseEvent ):void
		{
			if ( this.stage )
			{
				this.stage.removeEventListener( MouseEvent.MOUSE_DOWN, startDraw );
				this.stage.removeEventListener( MouseEvent.DOUBLE_CLICK, cancel );
			}
			dispatchEvent( new Event( Event.CANCEL ) );
		}
		
	}

}