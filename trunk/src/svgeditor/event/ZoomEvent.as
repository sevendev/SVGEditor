package svgeditor.event 
{
	import flash.events.Event;
	
	public class ZoomEvent extends Event 
	{
		
		
		public static const ZOOM_VALUE_CHANGE:String = "zoomValueChange";
		public var value:Number;
		
		public function ZoomEvent(value:Number,  bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(ZOOM_VALUE_CHANGE, bubbles, cancelable);
			this.value = value;
		} 
		
		public override function clone():Event 
		{ 
			return new ZoomEvent( value,  bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("ZoomEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}