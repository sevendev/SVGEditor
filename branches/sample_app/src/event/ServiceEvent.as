package event 
{
	import flash.events.Event;
	
	public class ServiceEvent extends Event 
	{
		
		public static const LOAD:String = "load";
		public static const SAVE:String = "save";
		public static const FAILED:String = "failed";
		
		public var result:Object;
		public var message:String;
		
		public function ServiceEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new ServiceEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("ServiceEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}