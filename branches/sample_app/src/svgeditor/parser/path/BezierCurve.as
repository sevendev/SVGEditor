package svgeditor.parser.path 
{
	import flash.display.GraphicsPath;
	import flash.geom.Point;
	import svgeditor.Constants;
	import flash.display.GraphicsPathCommand;
	
	public class BezierCurve implements ICurve
	{
		
		public var bp1:IEditPoint;
		public var bp2:IEditPoint;
		
		private var _cx1:Number;
		private var _cy1:Number;
		private var _cx:Number;
		private var _cy:Number;
		
		public function BezierCurve( bp1:IEditPoint=null, bp2:IEditPoint=null ) 
		{
			this.bp1 = bp1;
			this.bp2 = bp2;
		}
		
		public function get id():int { return bp1.id; }
		
		public function getCommand():GraphicsPath 
		{
			setControlPoints();
			return _bezierCurve( bp1.ax, bp1.ay, _cx1, _cy1 , _cx, _cy , bp2.ax, bp2.ay   );
		}
		
		public function getSvgAttr():String
		{
			setControlPoints();
			return "C" + _cx1 + "," + _cy1 + " " + _cx + "," + _cy + " " + bp2.ax + "," + bp2.ay;
		}
		
		public function exit():void 
		{
			bp1 = null;
			bp2 = null;
		}
		
				
		public function hitTestCurve( pt:Point ):Boolean
		{
			setControlPoints();
			return _hitTestBezier( bp1.ax, bp1.ay, _cx1, _cy1 , _cx, _cy , bp2.ax, bp2.ay , pt );
		}
		
		public function get editPoints():Vector.<IEditPoint> 
		{
			return Vector.<IEditPoint>( [ bp1 , bp2  ] );
		}
		
		public function get firstPoint():IEditPoint
		{
			return bp1;
		}
		
		public function get lastPoint():IEditPoint
		{
			return bp2;
		}
		
		public function set lastPoint( value:IEditPoint ):void
		{
			bp2 = value;
		}
		
		private function setControlPoints():void 
		{
			_cx1 = ( isNaN( bp1.cx1 ) || bp1.cx1 == 0 ) ? bp1.ax : bp1.cx1;
			_cy1 = ( isNaN( bp1.cy1 ) || bp1.cy1 == 0 ) ? bp1.ay : bp1.cy1;
			_cx = ( isNaN( bp2.cx ) || bp2.cx == 0 ) ? bp2.ax : bp2.cx;
			_cy = ( isNaN( bp2.cy ) || bp2.cy == 0 ) ? bp2.ay : bp2.cy;
		}
		
		private function _hitTestBezier( x0:Number, y0:Number, cx0:Number, cy0:Number, cx1:Number, cy1:Number, x:Number, y:Number , pt:Point ):Boolean
		{
			var k:Number = 1.0/ Constants.BEZIER_DETAIL;
			var t:Number = 0;
			var tp:Number;
			for ( var i:int = 1; i <= Constants.BEZIER_DETAIL; i++ )
			{
				t += k;
				tp = 1.0-t;
				var c:Point = new Point( 	x0 * tp * tp * tp + 3 * cx0 * t * tp * tp + 3 * cx1 * t * t * tp + x * t * t * t , 
											y0 * tp * tp * tp + 3 * cy0 * t * tp * tp + 3 * cy1 * t * t * tp + y * t * t * t );
											
				var dist:Number = pt.subtract( c ).length;
				if ( dist < Constants.EDIT_LINE_CLICKABLE_WIDTH )
					return true;
			}
			return false;
		}
		
		private function _bezierCurve( x0:Number, y0:Number, cx0:Number, cy0:Number, cx1:Number, cy1:Number, x:Number, y:Number ):GraphicsPath
		{
			var _commands:Vector.<int> = new Vector.<int>();
			var _vertices:Vector.<Number> = new Vector.<Number>();
			
			var k:Number = 1.0/ Constants.BEZIER_DETAIL;
			var t:Number = 0;
			var tp:Number;
			for ( var i:int = 1; i <= Constants.BEZIER_DETAIL; i++ )
			{
				t += k;
				tp = 1.0-t;
				_commands.push( GraphicsPathCommand.LINE_TO );
				_vertices.push( x0 * tp * tp * tp + 3 * cx0 * t * tp * tp + 3 * cx1 * t * t * tp + x * t * t * t , 
								y0 * tp * tp * tp + 3 * cy0 * t * tp * tp + 3 * cy1 * t * t * tp + y * t * t * t );
			}
			
			return new GraphicsPath( _commands, _vertices );
		}
	}

}