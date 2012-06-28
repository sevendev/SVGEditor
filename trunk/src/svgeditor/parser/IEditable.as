package svgeditor.parser 
{
	import flash.events.IEventDispatcher;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import svgeditor.parser.path.PathManager;
	import svgeditor.parser.style.Style;
	
	public interface IEditable extends IEventDispatcher
	{
		function get style():Style;
		function set style( s:Style ):void;
		function redraw():void;
		function edit():void;
		function exit():void;
		function getSvg():XML;
		
		function outline( f:Boolean ):void;
		
		function newPrimitive():void;
		function cancelCreation():void;
		function convertToPath():Path;
		function get convertible():Boolean;
		
		function getPathManager():PathManager;
		
		function getParentMatrix():Matrix;
		function getRegistrationPoint():Point;
		function getChildren():Vector.<IEditable>;
		function getNumChildren():int;
		function resize( scaleX:Number , scaleY:Number , center:Point = null):void;
		function rotate( angle:Number , center:Point = null):void;
		function translate( x:Number , y:Number ):void;
		function applyMatrix():void;
		function addMatrix( m:Matrix ):void;
		function setMatrix( m:Matrix ):void;
		function getMatrix():Matrix;
		function getGlobalMatrix():Matrix;
		function getBounds (targetCoordinateSpace:DisplayObject) : Rectangle;
		
		function get asContainer():DisplayObjectContainer;
		function get asObject():DisplayObject;
	}
	
}