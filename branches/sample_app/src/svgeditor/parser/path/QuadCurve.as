package svgeditor.parser.path 
{
	import flash.display.GraphicsPath;
	import flash.display.GraphicsPathCommand;
	import flash.geom.Point;
	
	public class QuadCurve implements ICurve
	{
		
		public var cp1:IEditPoint;
		public var cp2:IEditPoint;
		
		public function QuadCurve( cp1:IEditPoint =null , cp2:IEditPoint = null )
		{ 
			if( cp1 && cp2 )
				addQuadPoints( cp1, cp2 );
		}
		
		public function get id():int { return cp1.id; }
		
		public function addQuadPoints( cp1:IEditPoint, cp2:IEditPoint ):void 
		{
			this.cp1 = cp1;
			this.cp2 = cp2;
		}
		
		public function getCommand():GraphicsPath 
		{
			var command:Vector.<int> = Vector.<int>([ GraphicsPathCommand.CURVE_TO ]);
			var vertices:Vector.<Number> = Vector.<Number>([ cp1.ax , cp1.ay, cp2.ax, cp2.ay ]);
			return new GraphicsPath( command, vertices );
		}
		
		public function getSvgAttr():String
		{
			return "Q" + cp1.ax + "," + cp1.ay + " " + cp2.ax + "," + cp2.ay;
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
		
	}

}