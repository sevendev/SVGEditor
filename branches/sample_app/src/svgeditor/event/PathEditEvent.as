package svgeditor.event 
{
	import flash.events.Event;
	import svgeditor.parser.path.IEditPoint;
	
	public class PathEditEvent extends Event 
	{
		
		public static const PATH_EDIT:String = "pathEdit";
		public static const PATH_EDIT_FINISH:String = "pathEditFinish";
		public var id:int;
		public var editPoint:IEditPoint;
		
		public function PathEditEvent( type:String , id:int , editPoint:IEditPoint,  bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super( type, bubbles, cancelable);
			this.id = id;
			this.editPoint = editPoint;
		} 
		
		public override function clone():Event 
		{ 
			return new PathEditEvent( type, id , editPoint,  bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("PathEditEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}