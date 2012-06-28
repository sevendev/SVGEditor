package event 
{
	import flash.events.Event;
	
	public class ToolPaletteEvent extends Event 
	{
		
		public static const CREATE_ITEM:String = "createItem";
		public static const DRAW_PATH:String = "drawPath";
		public static const SHOW_CODE:String = "showCode";
		public static const CANCEL_ALL:String = "cancelAll";
		
		public var itemType:String;
		
		public function ToolPaletteEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new ToolPaletteEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("ToolPaletteEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}