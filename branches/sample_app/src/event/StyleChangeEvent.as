package event 
{
	import flash.events.Event;
	import svgeditor.StyleObject;
	
	public class StyleChangeEvent extends Event 
	{
		
		public static const STYLE_CHANGE:String = "styleChange";
		
		public var styleobj:StyleObject;
		
		public function StyleChangeEvent( styleobj:StyleObject , bubbles:Boolean = false, cancelable:Boolean = false) 
		{ 
			super(STYLE_CHANGE, bubbles, cancelable);
			this.styleobj = styleobj;
		} 
		
		public override function clone():Event 
		{ 
			return new StyleChangeEvent(styleobj, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("StyleChangeEvent", "styleobj", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}