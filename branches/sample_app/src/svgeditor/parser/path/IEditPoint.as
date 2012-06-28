package svgeditor.parser.path 
{
	import flash.events.IEventDispatcher;
	import flash.display.DisplayObjectContainer;
	import flash.display.GraphicsPath;
	import flash.geom.Point;
	
	public interface IEditPoint extends IEventDispatcher
	{
		function get id():int;
		function get ax():Number;
		function get ay():Number;
		function set ax( value:Number ):void;
		function set ay( value:Number ):void;
		function get cx():Number;
		function get cy():Number;
		function set cx( value:Number ):void;
		function set cy( value:Number ):void;
		function get cx1():Number;
		function get cy1():Number;
		function set cx1( value:Number ):void;
		function set cy1( value:Number ):void;
		function get asPoint():Point;
		
		function hasControl1():Boolean;
		function hasControl2():Boolean;
		function setControl1( x:Number, y:Number ):void;
		function setControl2( x:Number, y:Number ):void;
		function deleteControl1():void;
		function deleteControl2():void;
		
		function setCanvas( canvas:DisplayObjectContainer, virtual:DisplayObjectContainer = null ):void;
		function createPoint():void;
		function exit( remove:Boolean = false ):void ;
		function setSlave( p:IEditPoint ):void;
		function hasSlaves():Boolean;
		function getSlaves():Vector.<IEditPoint>;
		function resize( zoom:Number ):void;
		function showIndicator( f:Boolean = true  ):void;
		function setSelected( f:Boolean = true ):void;
		function get editable():Boolean;
		function set editable(value:Boolean):void;
		
		function isMoveTo():Boolean;
		function isEditablePoint():Boolean;
		function get command():int;
		function set command(value:int):void;
	}
	
}