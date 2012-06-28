package event 
{
	import flash.events.Event;
	
	public class InfoPanelEvent extends Event 
	{
		
		public static const ON_SAVE_CLICK:String = "onSaveClick";
		public static const ON_CODE_CHANGE:String = "onCodeChange";
		public static const ON_CREATE:String = "onCreate";
		public static const ON_CLOSE:String = "onClose";
		
		public var title:String;
		public var code:String;
		public var documentWidth:Number;
		public var documentHeight:Number;
		
		public function InfoPanelEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event 
		{ 
			return new InfoPanelEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("InfoPanelEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}