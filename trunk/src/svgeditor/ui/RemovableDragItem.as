package svgeditor.ui 
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	public class RemovableDragItem extends DragItem
	{
		
		private var _callback:Function;
		
		public function RemovableDragItem( item:DisplayObject, callback:Function = null ) 
		{
			super( item);
			_stage.addEventListener( MouseEvent.MOUSE_UP, release );
			_callback = callback;
		}
		
		private function release( e:MouseEvent = null ):void {
			if ( _stage )
				_stage.removeEventListener( MouseEvent.MOUSE_UP, release );
			if ( _callback != null ) 
			{
				_callback();
				_callback = null;
			}
			exit();
		}
		
	}

}