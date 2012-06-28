package svgeditor.parser.path 
{
	import flash.display.GraphicsPath;
	import flash.geom.Point;
	
	public interface ICurve 
	{
		function get id():int;
		function get editPoints():Vector.<IEditPoint>;
		function get lastPoint():IEditPoint;
		function hitTestCurve( pt:Point ):Boolean;
		function getCommand():GraphicsPath;
		function getSvgAttr():String;
	}
	
}