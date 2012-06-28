package svgeditor.parser.path 
{
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	import flash.geom.Point;
	import svgeditor.event.PathEditEvent;
	import svgeditor.parser.model.PersistentData;
	import svgeditor.event.ZoomEvent;
	import svgeditor.Constants;

	public class EditPoint extends AbstractEditPoint
	{
		protected var _parent:DisplayObjectContainer;
		protected var _clickPoint:Point;
		
		public function EditPoint( canvas:DisplayObjectContainer, virtual:DisplayObjectContainer  , id:int , x:Number , y:Number ) 
		{
			_id = id;
			_parent = canvas;
			_ax = x;
			_ay = y;
			
			setCanvas( canvas, virtual );
			createPoint();
			
			var pt:Point = getVirtualPosition( canvas, _ax , _ay );
			this.x = pt.x;
			this.y = pt.y;
			
			this.addEventListener( MouseEvent.MOUSE_DOWN , dragPoint );
			PersistentData.getInstance().addEventListener( ZoomEvent.ZOOM_VALUE_CHANGE, resizeByZoom );
			resize( PersistentData.getInstance().currentZoom );
		}
		
		override public function exit( remove:Boolean = false ):void 
		{
			this.removeEventListener( MouseEvent.MOUSE_DOWN , dragPoint );
			PersistentData.getInstance().removeEventListener( ZoomEvent.ZOOM_VALUE_CHANGE, resizeByZoom );
			
			if ( this.stage ) 
			{
				this.stage.removeEventListener( MouseEvent.MOUSE_MOVE, dragging );
				this.stage.removeEventListener( MouseEvent.MOUSE_UP, dragStop );
			}

			if ( _parent && _parent.contains( this ) )
				_parent.removeChild( this );
				
			_parent = null;
			_virtualLayer = null;
			_clickPoint = null;
			_slavePoints = null;
		}
		
		override public function setSlave( p:IEditPoint ):void {
			if ( !_slavePoints ) _slavePoints = new Vector.<IEditPoint>();
			_slavePoints.push( p );
			p.editable = false;
		}
		
		override public function set editable(value:Boolean):void 
		{
			_editable = value;
			if ( !value && parent.contains( this ) ) 
			{
				parent.removeChild( this );
			}
		}

		private function dragPoint( e:MouseEvent ):void 
		{
			_clickPoint = new Point( this.mouseX, this.mouseY );
			this.stage.addEventListener( MouseEvent.MOUSE_MOVE, dragging );
			this.stage.addEventListener( MouseEvent.MOUSE_UP, dragStop );
		}
		
		private function dragging( e:MouseEvent ):void 
		{
			this.x += this.mouseX - _clickPoint.x;
			this.y += this.mouseY - _clickPoint.y;
			
			var pt:Point = getActualPosition( _parent , this.x , this.y );
			_ax = pt.x;
			_ay = pt.y;
			
			if ( _slavePoints ) 
			{
				for each( var ep:IEditPoint in _slavePoints ) 
				{
					ep.ax = _ax;
					ep.ay = _ay;
					Sprite( ep ).x = this.x;
					Sprite( ep ).y = this.y;
				}
			}
			
			dispatchEvent( new PathEditEvent( PathEditEvent.PATH_EDIT, _id , this,  true ) );
		}
		
		private function dragStop( e:MouseEvent ):void 
		{
			if ( !this.stage ) return;
			this.stage.removeEventListener( MouseEvent.MOUSE_MOVE, dragging );
			this.stage.removeEventListener( MouseEvent.MOUSE_UP, dragStop );
			dispatchEvent( new PathEditEvent( PathEditEvent.PATH_EDIT_FINISH , _id , this , true ) );
		}
		
		private function resizeByZoom( e:ZoomEvent ):void 
		{
			resize( e.value );
		}
		
	}

}