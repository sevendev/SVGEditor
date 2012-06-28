package svgeditor.parser.path 
{
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	import flash.display.GraphicsPath;
	import flash.display.GraphicsPathCommand;
	import flash.geom.Point;
	import svgeditor.ui.RemovableDragItem;
	import svgeditor.event.PathEditEvent;
	import svgeditor.event.ZoomEvent;
	import svgeditor.Constants;
	
	public class PathPoint extends AbstractEditPoint implements IEditPoint, ICurve
	{
		
		public var command:int;
		
		public function PathPoint( id:int , x:Number, y:Number, command:int ) 
		{
			_id = id;
			_ax = x;
			_ay = y;
			this.command = command;
		}
		
		override public function setCanvas( canvas:DisplayObjectContainer, virtual:DisplayObjectContainer = null ):void
		{
			super.setCanvas( canvas , virtual );
			var pt:Point = getVirtualPosition( this.parent , ax, ay );
			this.x = pt.x;
			this.y = pt.y;
		}
		
		override public function createPoint():void 
		{
			super.createPoint();
			this.addEventListener( MouseEvent.MOUSE_DOWN , dragPoint );
		}
		
		override public function exit( remove:Boolean = false ):void 
		{
			if ( remove )
			{
				this.removeEventListener( MouseEvent.MOUSE_DOWN , dragPoint );
				if ( this.stage )
				{
					this.stage.removeEventListener( MouseEvent.MOUSE_MOVE, onEdit );
					this.stage.removeEventListener( MouseEvent.MOUSE_UP, onEditFinish );
				}
				this.parent.removeChild( this );
			}
		}
		
		public function isMoveTo():Boolean 
		{
			return ( command == GraphicsPathCommand.MOVE_TO );
		}
		
		public function getCommand():GraphicsPath
		{
			var commands:Vector.<int> = Vector.<int>([ command ]);
			var vertices:Vector.<Number> = Vector.<Number>([ ax, ay ]);
			return new GraphicsPath( commands, vertices );
		}
		
		public function getSvgAttr():String
		{
			var commStr:String = isMoveTo() ? "M" : "L";
			return commStr + ax + "," + ay;
		}
		
		public function get editPoints():Vector.<IEditPoint> 
		{
			return Vector.<IEditPoint>( [this] );
		}
		
		public function get lastPoint():IEditPoint
		{
			return this;
		}
		
		private function dragPoint( e:MouseEvent ):void 
		{
			new RemovableDragItem( e.currentTarget as DisplayObject );
			this.stage.addEventListener( MouseEvent.MOUSE_MOVE, onEdit );
			this.stage.addEventListener( MouseEvent.MOUSE_UP, onEditFinish );
		}
		
		private function onEdit( e:MouseEvent ):void 
		{
			var pt:Point = getActualPosition( this.parent , this.x , this.y );
			ax = pt.x;
			ay = pt.y;
			dispatchEvent( new PathEditEvent( PathEditEvent.PATH_EDIT ,_id ) );
		}
		
		private function onEditFinish( e:MouseEvent ):void 
		{
			this.stage.removeEventListener( MouseEvent.MOUSE_MOVE, onEdit );
			this.stage.removeEventListener( MouseEvent.MOUSE_UP, onEditFinish );
			dispatchEvent( new PathEditEvent( PathEditEvent.PATH_EDIT_FINISH , _id ) );
		}

	}

}