package event 
{
	import flash.events.Event;
	
	public class PanelEvent extends Event 
	{
		
		public static const EDIT_FILL_GRADIENT:String = "editFillGradient";
		public static const EDIT_STROKE_GRADIENT:String = "editStrokeGradienet";
		
		public function PanelEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new PanelEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("PanelEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}