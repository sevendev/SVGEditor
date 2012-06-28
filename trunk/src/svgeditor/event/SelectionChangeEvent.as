package svgeditor.event 
{
	import flash.events.Event;
	
	public class SelectionChangeEvent extends Event 
	{
		
		
		public static const SELECTION_CHANGE:String = "selectionChange";
		
		public var itemName:String;
		public var itemType:String;
		public var editMode:String;
		
		public function SelectionChangeEvent( bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super( SELECTION_CHANGE , bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new SelectionChangeEvent( bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("SelectionChangeEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}