package svgeditor.parser.path 
{
	import flash.display.GraphicsPath;
	import flash.display.GraphicsPathCommand;
	import flash.geom.Point;
	import svgeditor.parser.utils.GeomUtil;
	
	public class LineCurve implements ICurve
	{
		
		public var p1:IEditPoint;
		public var p2:IEditPoint;
		
		public function LineCurve( p1:IEditPoint =null , p2:IEditPoint = null )
		{ 
			this.p1 = p1;
			this.p2 = p2;
		}
		
		public function get id():int { return p1.id; }
		
		public function getCommand():GraphicsPath 
		{
			var command:Vector.<int> = Vector.<int>([ p1.command , p2.command ]);
			var vertices:Vector.<Number> = Vector.<Number>([ p1.ax , p1.ay, p2.ax, p2.ay ]);
			return new GraphicsPath( command, vertices );
		}
		
		public function getSvgAttr():String
		{
			return com2str( p2.command ) + p2.ax + "," + p2.ay;
		}
		
		public function exit():void 
		{
			p1 = p2 = null;
		}
		
		public function hitTestCurve( pt:Point ):Boolean 
		{ 
			return Math.abs( GeomUtil.getAngle( p1.asPoint , pt  ) - GeomUtil.getAngle( pt , p2.asPoint ) ) < 0.05; //appx.+-3degree
		}
		
		public function get editPoints():Vector.<IEditPoint> 
		{
			return Vector.<IEditPoint>( [ p1, p2 ] );
		}
		
		public function get lastPoint():IEditPoint
		{
			return p2;
		}
		
		private function com2str( command:int ):String 
		{
			return ( command == GraphicsPathCommand.MOVE_TO ) ? "M" : "L";
		}
		
	}

}