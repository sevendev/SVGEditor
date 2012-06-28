package svgeditor.parser.utils 
{
	import flash.geom.Point;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Rectangle;
	
	public class GeomUtil
	{
		public static function getAngle(  pt1:Point , pt2:Point ):Number 
		{
			var dx:Number = pt2.x - pt1.x;
			var dy:Number = pt2.y - pt1.y;
			var angleRadian:Number = Math.atan2( dy , dx );
			return  angleRadian;
		}
		
		public static function getDistance( pt1:Point , pt2:Point ):Number 
		{
			var dx:Number = pt2.x - pt1.x;
			var dy:Number = pt2.y - pt1.y;
			return Math.sqrt( dx * dx + dy * dy );
		}
		
		public static function degree2radian( degree:Number ):Number {
			return degree * Math.PI / 180;
		}
		
		public static function radian2degree( radian:Number ):Number {
			return radian * 180 / Math.PI;
		}
		
		public static function getVirtualPosition( _parent:DisplayObjectContainer , _virtual:DisplayObjectContainer , _x:Number , _y:Number ):Point 
		{
			return _parent.globalToLocal(  _virtual.localToGlobal( new Point( _x, _y ) ) );
		}
		
		public static function getActualPosition( _parent:DisplayObjectContainer , _virtual:DisplayObjectContainer , _x:Number , _y:Number ):Point 
		{
			return  _virtual.globalToLocal( _parent.localToGlobal( new Point( _x, _y ) ) );
		}
		
		public static function getBezierPointsOnCircle( rect:Rectangle , q:Number = 1.8 ):Vector.<Point>
		{
			var rx:Number = rect.width / 2;
			var ry:Number = rect.height / 2;
			var qrx:Number = rx / q;
			var qry:Number = ry / q;
			var top:Point = new Point( rect.x + rx , rect.y );
			var right:Point = new Point( rect.right , rect.top + ry );
			var bottom:Point = new Point( rect.x + rx ,rect.bottom  );
			var left:Point = new Point( rect.left , rect.top + ry );
			var tr:Point = new Point( top.x + qrx  , top.y );
			var tl:Point = new Point( top.x - qrx  , top.y );
			var br:Point = new Point( bottom.x + qrx  , bottom.y );
			var bl:Point = new Point( bottom.x - qrx  , bottom.y );
			var rt:Point = new Point( right.x  , right.y - qry );
			var rb:Point = new Point( right.x  , right.y + qry );
			var lt:Point = new Point( left.x  , left.y - qry );
			var lb:Point = new Point( left.x  , left.y + qry );
			return Vector.<Point>([ top , tr , rt, right , rb, br , bottom , bl ,lb , left , lt ,tl , top ]);
		}
		
	}

}