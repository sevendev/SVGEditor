package svgeditor.ui 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.GraphicsPathCommand;
	import flash.display.Sprite;
	import flash.display.LineScaleMode;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.display.BlendMode;
	import flash.events.MouseEvent;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import svgeditor.Constants;
	import svgeditor.ui.RemovableDragItem;
	import svgeditor.parser.utils.GeomUtil;
	import svgeditor.parser.IEditable;
	import svgeditor.parser.model.PersistentData;
	import svgeditor.event.ZoomEvent;

	public class BoundingBox extends Sprite
	{
		public var parentLayer:DisplayObjectContainer;
		public var editItem:IEditable;
		
		protected var itemRect:Rectangle;
		protected var scaleIcon:Sprite;
		protected var rotateIcon:Sprite;
		protected var rotatePoint:Point;
		protected var drag:DragItem;
		private var _sIconSize:Number;
		private var _rIconSize:Number;
		private var _zoomValue:Number = 1;
		
		public function BoundingBox( parentLayer:DisplayObjectContainer, editItem:IEditable , isDraggable:Boolean = true ) 
		{
			this.parentLayer = parentLayer;
			this.editItem = editItem;
			resetGeometries();
			this.blendMode = BlendMode.HARDLIGHT;
			create();
			if ( isDraggable ) draggable();
			this.stage.addEventListener( MouseEvent.MOUSE_UP, reset );
			PersistentData.getInstance().addEventListener( ZoomEvent.ZOOM_VALUE_CHANGE, laytouIcons );
		}
		
		public function create():void {
			parentLayer.addChild( this );
			itemRect = editItem.asObject.getBounds(this);
			
			scaleIcon = new Sprite();
			addChild( scaleIcon );
			scaleIcon.addEventListener( MouseEvent.MOUSE_DOWN, resize );
			
			rotateIcon = new Sprite();
			addChild( rotateIcon);
			rotateIcon.addEventListener( MouseEvent.MOUSE_DOWN, rotate );
			
			drawRect( itemRect );

			this.stage.addEventListener( MouseEvent.MOUSE_UP, reset );
		}
		
		public function draggable():void
		{
			new RemovableDragItem( this as DisplayObject );
			drag = new DragItem( editItem as DisplayObject );
		}
		
		public function exit():void 
		{
			if ( this.stage ) 
				this.stage.removeEventListener( MouseEvent.MOUSE_UP, reset );
			
			if ( parentLayer.contains( this ) ) 
				parentLayer.removeChild( this as DisplayObject );
				
			parentLayer = null;
			editItem = null;
		}
		
		protected function drawRect( rect:Rectangle ):void {
			this.graphics.clear();
			this.graphics.lineStyle( 1, Constants.BOUNDING_BOX_COLOR , 1 , false, LineScaleMode.NONE );
			this.graphics.drawRect( rect.x, rect.y, rect.width, rect.height );
			laytouIcons();
		}
		
		protected function laytouIcons( e:ZoomEvent = null ):void 
		{
			_zoomValue = 1 / PersistentData.getInstance().currentZoom;
			_sIconSize = Constants.SCALE_ICON_SIZE * _zoomValue;
			_rIconSize = Constants.ROTATE_ICON_SIZE * _zoomValue;
			
			var sCommand:Vector.<int> = Vector.<int>([ GraphicsPathCommand.MOVE_TO, GraphicsPathCommand.LINE_TO, GraphicsPathCommand.LINE_TO ]);
			var sVertice:Vector.<Number> = Vector.<Number>([ _sIconSize , 0, 0, _sIconSize, _sIconSize , _sIconSize]);
			scaleIcon.graphics.clear();
			scaleIcon.graphics.beginFill( Constants.BOUNDING_BOX_COLOR , 1 );
			scaleIcon.graphics.drawPath( sCommand, sVertice );
			scaleIcon.graphics.endFill();
			scaleIcon.x = itemRect.x +  itemRect.width - _sIconSize;
			scaleIcon.y = itemRect.y + itemRect.height - _sIconSize;
			
			rotateIcon.graphics.clear();
			rotateIcon.graphics.beginFill( Constants.BOUNDING_BOX_COLOR, 1 );
			rotateIcon.graphics.drawCircle( 0, 0, _rIconSize );
			rotateIcon.graphics.endFill();
			rotateIcon.x = itemRect.x +  itemRect.width - _rIconSize - 2;
			rotateIcon.y = itemRect.y + _rIconSize + 2;
		}
		
		protected function reset( e:MouseEvent = null ):void 
		{
			if ( !itemRect || !editItem ) return;

			editItem.applyMatrix();
			resetGeometries();
			drawRect( itemRect );
			if( drag ) drag.exit();
		}
		
		protected function resetGeometries():void 
		{
			itemRect = editItem.getBounds(this);
		}
		
		protected function resize( e:MouseEvent ):void 
		{
			new RemovableDragItem( scaleIcon as DisplayObject );
			scaleIcon.stage.addEventListener( MouseEvent.MOUSE_MOVE, resizeRect );
			scaleIcon.stage.addEventListener( MouseEvent.MOUSE_UP, resizeFinish );
		}
		
		protected function resizeRect( e:MouseEvent ):void 
		{
			var newRect:Rectangle = itemRect.clone();
			newRect.width = scaleIcon.x - newRect.x + _sIconSize;
			newRect.height = scaleIcon.y - newRect.y + _sIconSize;

			drawRect( newRect );

			editItem.resize( newRect.size.x / itemRect.size.x, newRect.size.y / itemRect.size.y  );
			itemRect = newRect.clone();
		}
		
		protected function resizeFinish( e:MouseEvent ):void 
		{
			scaleIcon.stage.removeEventListener( MouseEvent.MOUSE_MOVE, resizeRect );
			scaleIcon.stage.removeEventListener( MouseEvent.MOUSE_UP, resizeFinish );
			
			reset();
			drawRect( itemRect );
		}
		
		
		protected function rotate( e:MouseEvent ):void 
		{
			resetGeometries();
			var bounds:Rectangle = this.getBounds( this.parent );
			rotatePoint = new Point( bounds.x + bounds.width / 2 , bounds.y + bounds.height / 2 );
			
			rotateIcon.stage.addEventListener( MouseEvent.MOUSE_MOVE, rotateItem );
			rotateIcon.stage.addEventListener( MouseEvent.MOUSE_UP, rotateFinish );
		}
		
		protected function rotateItem( e:MouseEvent ):void 
		{
			var angle:Number = Math.atan2(  this.mouseY - rotatePoint.y  , this.mouseX - rotatePoint.x );
			var iconAngle:Number = Math.atan2(  rotateIcon.y - rotatePoint.y  , rotateIcon.x - rotatePoint.x );
			angle -= iconAngle;
			
			var matrix:Matrix = this.transform.matrix.clone();
			matrix.translate( -rotatePoint.x  , -rotatePoint.y  );
			matrix.rotate( angle );
			matrix.translate( rotatePoint.x  , rotatePoint.y  );
			this.transform.matrix = matrix;

			editItem.rotate( angle );
			reset();
		}
		
		protected function rotateFinish( e:MouseEvent ):void 
		{
			this.transform.matrix = new Matrix();

			rotateIcon.stage.removeEventListener( MouseEvent.MOUSE_MOVE, rotateItem );
			rotateIcon.stage.removeEventListener( MouseEvent.MOUSE_UP, rotateFinish );

			resetGeometries();
			drawRect( itemRect );
		}
		
	}

}