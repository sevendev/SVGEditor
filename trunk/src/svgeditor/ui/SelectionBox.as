package svgeditor.ui 
{
	import flash.display.Sprite;
	import flash.display.DisplayObjectContainer;
	import flash.display.LineScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import svgeditor.Constants;
	
	public class SelectionBox extends Sprite
	{
		public var parentLayer:DisplayObjectContainer;
		
		protected var _clickPoint:Point;
		
		public function SelectionBox(  parentLayer:DisplayObjectContainer ) 
		{
			this.parentLayer = parentLayer;
			parentLayer.addChild( this );
			_clickPoint = new Point( this.mouseX, this.mouseY );
			this.stage.addEventListener( MouseEvent.MOUSE_UP, onSelect );
			this.stage.addEventListener( MouseEvent.MOUSE_MOVE, draw );
		}
		
		public function exit():void
		{
			this.stage.removeEventListener( MouseEvent.MOUSE_MOVE, draw );
			this.stage.removeEventListener( MouseEvent.MOUSE_UP, onSelect );
			parentLayer.removeChild( this );
			parentLayer = null;
			_clickPoint = null;
		}
		
		private function onSelect( e:MouseEvent ):void
		{
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		private function draw ( e:MouseEvent ):void 
		{
			this.graphics.clear();
			this.graphics.lineStyle( 1, Constants.SELECTION_BOX_COLOR, .5, false, LineScaleMode.NONE );
			this.graphics.beginFill( 0, 0 );
			this.graphics.drawRect( _clickPoint.x, _clickPoint.y , this.mouseX - _clickPoint.x , this.mouseY - _clickPoint.y );
			this.graphics.endFill();
		}
		
	}

}