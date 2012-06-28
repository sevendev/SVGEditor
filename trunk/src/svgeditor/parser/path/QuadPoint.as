package svgeditor.parser.path 
{
	import flash.display.Sprite;
	import flash.display.DisplayObjectContainer;
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.display.GraphicsPath;
	import flash.display.GraphicsPathCommand;
	import svgeditor.ui.RemovableDragItem;
	import svgeditor.event.PathEditEvent;
	import svgeditor.event.ZoomEvent;
	import svgeditor.Constants;
	
	public class QuadPoint extends AbstractEditPoint implements IEditPoint
	{
		
		public function QuadPoint( id:int, ax:Number, ay:Number ) 
		{
			_id = id;
			_ax = ax;
			_ay = ay;
		}
		
		override public function createPoint():void 
		{
			super.createPoint();
			this.addEventListener( MouseEvent.MOUSE_DOWN , dragPoint );
		}
		
		override public function setCanvas( canvas:DisplayObjectContainer, virtual:DisplayObjectContainer = null ):void
		{
			super.setCanvas( canvas , virtual );
			var pt:Point = getVirtualPosition( this.parent , _ax, _ay );
			this.x = pt.x;
			this.y = pt.y;
		}
		
		override public function exit( remove:Boolean = false ):void 
		{
			if ( remove )
			{
				this.removeEventListener( MouseEvent.MOUSE_DOWN , dragPoint );
				this.stage.removeEventListener( MouseEvent.MOUSE_MOVE, onEdit );
				this.parent.removeChild( this );
			}
		}
		
		private function dragPoint( e:MouseEvent ):void 
		{
			new RemovableDragItem( e.currentTarget as DisplayObject );
			this.stage.addEventListener( MouseEvent.MOUSE_MOVE, onEdit );
		}
		
		private function onEdit( e:MouseEvent ):void 
		{
			var pt:Point = getActualPosition( this.parent , this.x , this.y );
			_ax = pt.x;
			_ay = pt.y;
			dispatchEvent( new PathEditEvent( PathEditEvent.PATH_EDIT , _id , this,  true , true ) );
		}
		
	}

}