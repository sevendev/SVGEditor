package svgeditor.parser.path 
{
	import flash.display.GraphicsPath;
	import svgeditor.Constants;
	import flash.display.GraphicsPathCommand;
	import flash.geom.Point;
	
	public class CurveFactory implements ICurve
	{
		
		public var bp1:IEditPoint;
		public var bp2:IEditPoint;
		
		private var _curve:ICurve;
		
		public function CurveFactory( bp1:IEditPoint=null, bp2:IEditPoint=null ) 
		{
			this.bp1 = bp1;
			this.bp2 = bp2;
			
			_curve = getCurve();
		}
		
		public function get id():int { return bp1.id; }
		
		public function getCommand():GraphicsPath 
		{
			
			return _curve.getCommand();
		}
		
		public function getSvgAttr():String
		{
			return _curve.getSvgAttr();
		}
		
		public function exit():void 
		{
			bp1 = null;
			bp2 = null;
		}
		
		public function hitTestCurve( pt:Point ):Boolean 
		{ 
			return _curve.hitTestCurve( pt );
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
		
		private function getCurve():ICurve
		{
			if ( bp2 is ArcPoint )
			 return new ArcCurve( bp1 , bp2 );
			if ( bp2.hasControl1() || bp1.hasControl2() )
			 return new BezierCurve( bp1, bp2 );
			if ( bp1 is QuadPoint && bp2 is QuadPoint )
			 return new QuadCurve( bp1 , bp2 );

			return new LineCurve( bp1 , bp2 );
		}
		
	}

}