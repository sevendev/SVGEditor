package svgeditor.parser.path 
{
	import flash.display.GraphicsPath;
	import flash.display.GraphicsPathCommand;
	import flash.geom.Point;
	
	public class ArcCurve implements ICurve
	{
		
		public var cp1:IEditPoint;
		public var cp2:IEditPoint;
		
		private var _path:GraphicsPath;
		
		public function ArcCurve( cp1:IEditPoint =null , cp2:IEditPoint = null )
		{ 
			this.cp1 = cp1;
			this.cp2 = cp2;
		}
		
		public function get id():int { return cp2.id; }

		public function getCommand():GraphicsPath
		{
			var arc:ArcPoint = cp2 as ArcPoint;
			_path = new GraphicsPath( new Vector.<int>(), new Vector.<Number>() );
			_arc_curve( cp1.ax, cp1.ay, arc.ax, arc.ay , arc.cx, arc.cy, arc.large_arc_flag , arc.sweep_flag, arc.x_axis_rotation );
			return _path;
		}
		
		public function getSvgAttr():String
		{
			var arc:ArcPoint = cp2 as ArcPoint;
			var rot:Number = arc.x_axis_rotation * 180 / Math.PI;
			return "A" + arc.cx + "," + arc.cy + " " + rot + " " +  ( arc.large_arc_flag ? 1 : 0 ) + " " + ( arc.sweep_flag ? 1 : 0 ) + " " + arc.ax + "," + arc.ay ;
		}
		
		public function exit():void 
		{
			cp1 = cp2 = null;
		}
		
		public function hitTestCurve( pt:Point ):Boolean { return true; }
		
		public function get editPoints():Vector.<IEditPoint> 
		{
			return Vector.<IEditPoint>( [ cp1, cp2 ] );
		}
		
		public function get lastPoint():IEditPoint
		{
			return cp2;
		}
		
		private function _arc_curve( x0:Number, y0:Number, x:Number, y:Number, rx:Number, ry:Number,
									large_arc_flag:Boolean, sweep_flag:Boolean, x_axis_rotation:Number ):void
		{	
			var e:Number  = rx/ry;
			var dx:Number = (x - x0)*0.5;
			var dy:Number = (y - y0)*0.5;
			var mx:Number = x0 + dx;
			var my:Number = y0 + dy;
			var rc:Number;
			var rs:Number;
			
			if( x_axis_rotation!=0 )
			{
				rc = Math.cos(-x_axis_rotation);
				rs = Math.sin( -x_axis_rotation);
				var dx_tmp:Number = dx*rc - dy*rs; 
				var dy_tmp:Number = dx*rs + dy*rc;
				dx = dx_tmp;
				dy = dy_tmp;
			}
			
			//transform to circle
			dy *= e;
			
			var len:Number = Math.sqrt( dx*dx + dy*dy );
			var begin:Number;
			
			if( len<rx )
			{
				//center coordinates the arc
				var a:Number  = ( large_arc_flag!=sweep_flag ) ? Math.acos( len/rx ) : -Math.acos( len/rx );
				var ca:Number = Math.tan( a );
				var cx:Number = -dy*ca;
				var cy:Number = dx*ca;
				
				//draw angle
				var mr:Number = Math.PI - 2 * a;
				
				//start angle
				begin = Math.atan2( -dy - cy, -dx - cx );
				
				//deformation back and draw
				cy /= e;
				rc  = Math.cos(x_axis_rotation);
				rs  = Math.sin(x_axis_rotation);
				_arc( mx + cx*rc - cy*rs, my + cx*rs + cy*rc, rx, ry, begin, (sweep_flag) ? begin+mr : begin-(2*Math.PI-mr), x_axis_rotation );
			}
			else
			{
				//half arc
				rx = len;
				ry = rx/e;
				begin = Math.atan2( -dy, -dx );
				_arc( mx, my, rx, ry, begin, (sweep_flag) ? begin+Math.PI : begin-Math.PI, x_axis_rotation );
			}
		}
		
		private function _arc( x:Number, y:Number, rx:Number, ry:Number, begin:Number, end:Number, rotation:Number ):void
		{
			var segmentNum:int = Math.ceil( Math.abs( 4*(end-begin)/Math.PI ) );
			var delta:Number   = (end - begin)/segmentNum;
			var ca:Number      = 1.0/Math.cos( delta*0.5 );
			var t:Number       = begin;
			var ctrl_t:Number  = begin - delta*0.5;
			var i:int;
			
			if( rotation==0 )
			{
				for( i=1 ; i<=segmentNum ; i++ )
				{
					t += delta;
					ctrl_t += delta;
					_path.commands.push( GraphicsPathCommand.CURVE_TO );
					_path.data.push( x + rx * ca * Math.cos(ctrl_t), y + ry * ca * Math.sin(ctrl_t), x + rx * Math.cos(t), y + ry * Math.sin(t) );
				}
			}
			else
			{
				var rc:Number = Math.cos(rotation);
				var rs:Number = Math.sin(rotation);
				var xx:Number;
				var yy:Number;
				var cxx:Number;
				var cyy:Number;
				for( i=1 ; i<=segmentNum ; i++ )
				{
					t += delta;
					ctrl_t += delta;
					xx  = rx*Math.cos(t);
					yy  = ry*Math.sin(t);
					cxx = rx*ca*Math.cos(ctrl_t);
					cyy = ry*ca*Math.sin(ctrl_t);
					_path.commands.push( GraphicsPathCommand.CURVE_TO );
					_path.data.push( x + cxx * rc - cyy * rs, y + cxx * rs + cyy * rc , x + xx * rc - yy * rs, y + xx * rs + yy * rc );
				}
			}
		}
		
	}

}