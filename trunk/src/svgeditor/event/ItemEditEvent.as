package svgeditor.event 
{
	import flash.events.Event;
	
	public class ItemEditEvent extends Event 
	{
		
		public static const CREATION_COMPLETE:String = "creationComplete";
		public static const CREATION_CANCELED:String = "creationCanceled";
		
		public function ItemEditEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new ItemEditEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("ItemEditEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}