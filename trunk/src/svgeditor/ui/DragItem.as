package svgeditor.ui 
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	public class DragItem
	{
		protected var _item:DisplayObject;
		protected var _clickPoint:Point;
		protected var _stage:Stage;
		
		public function DragItem( item:DisplayObject  ) 
		{
			_item = item;
			_stage = item.stage;
			_clickPoint = new Point( _item.mouseX, _item.mouseY );
			_stage.addEventListener( MouseEvent.MOUSE_MOVE, doDrag );
		}
		
		public function exit():void {
			if ( _stage )
				_stage.removeEventListener( MouseEvent.MOUSE_MOVE, doDrag );
			_clickPoint = null;
			_item = null;
			_stage = null;
		}
		
		protected function doDrag(e:MouseEvent = null ):void {
			if ( !_item ) {
				exit();
				return;
			}
			var matrix:Matrix = new Matrix();
			matrix.translate( _item.mouseX - _clickPoint.x, _item.mouseY - _clickPoint.y );
			matrix.concat( _item.transform.matrix.clone() );
			_item.transform.matrix = matrix;
		}
		
		public function get item():DisplayObject { return _item; }
		public function get clickPoint():Point { return _clickPoint; }
		
	}

}