package svgeditor.parser.path 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.SpreadMethod;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.events.MouseEvent;
	import flash.display.GraphicsPathCommand;
	import flash.display.GraphicsPath;
	import svgeditor.ui.RemovableDragItem;
	import svgeditor.event.PathEditEvent;
	import svgeditor.event.ZoomEvent;
	import svgeditor.Constants;
	
	public class ArcPoint extends AbstractEditPoint implements IEditPoint
	{
		private var _cx:Number;
		private var _cy:Number;
		private var _large_arc_flag:Boolean;
		private var _sweep_flag:Boolean;
		private var _x_axis_rotation:Number;

		private var _mainPt:Sprite;
		private var _cont:Sprite;
		private var isControlEditMode:Boolean = false;
		
		public function ArcPoint( id:int , _x:Number, _y:Number, rx:Number, ry:Number, large_arc_flag:Boolean, sweep_flag:Boolean, x_axis_rotation:Number ) 
		{
			this._ax = _x;
			this._ay = _y;
			this._cx = rx;
			this._cy = ry;
			this._large_arc_flag = large_arc_flag;
			this._sweep_flag = sweep_flag;
			this._x_axis_rotation = x_axis_rotation;
		}
		
		override public function get cx():Number { return _cx; }
		override public function get cy():Number { return _cy; }
		override public function set cx( value:Number ):void { _cx = value; }
		override public function set cy( value:Number ):void { _cy = value; }
		public function get large_arc_flag():Boolean { return _large_arc_flag; }
		public function set large_arc_flag(value:Boolean):void 
		{
			_large_arc_flag = value;
		}
		public function get sweep_flag():Boolean { return _sweep_flag; }
		public function set sweep_flag(value:Boolean):void 
		{
			_sweep_flag = value;
		}
		public function get x_axis_rotation():Number { return _x_axis_rotation; }
		public function set x_axis_rotation(value:Number):void 
		{
			_x_axis_rotation = value;
		}
		
		override public function createPoint():void 
		{
			_mainPt = new Sprite();
			drawMainPt();
			_mainPt.cacheAsBitmap = true;
			addChild(_mainPt);
			_mainPt.addEventListener( MouseEvent.MOUSE_DOWN , showControl );
		}
		
		override public function setCanvas( canvas:DisplayObjectContainer, virtual:DisplayObjectContainer = null ):void
		{
			super.setCanvas( canvas , virtual );
			var pt:Point = getVirtualPosition( this.parent , ax, ay );
			this.x = pt.x;
			this.y = pt.y;
		}
		
		public function showControl( e:MouseEvent = null ):void 
		{
			createControl();
			if( !isControlEditMode )
				new RemovableDragItem( this as DisplayObject );
			else
				isControlEditMode = false;
		}
		
		override public function exit( remove:Boolean = false ):void 
		{
			if ( _mainPt )
				_mainPt.removeEventListener( MouseEvent.MOUSE_DOWN , showControl );
			if( _cont )
				_cont.removeEventListener( MouseEvent.MOUSE_DOWN, moveControl);
			if ( this.stage )
			{
				this.stage.removeEventListener( MouseEvent.MOUSE_MOVE, onEdit );
				this.stage.removeEventListener( MouseEvent.MOUSE_UP, onEditFinish );
			}
			
			if ( remove )
			{
				this.removeEventListener( MouseEvent.MOUSE_DOWN , showControl );
				this.parent.removeChild( this );
			}
		}
		
		override public function resize( value:Number ):void 
		{
			_zoomValue = 1 / value;
			if ( _mainPt ) drawMainPt();
			if ( _cont ) drawControl();
		}
		
		private function createControl():void 
		{
			if ( !_editable || _cont ) return;
			
			_cont = new Sprite();
			addChild( _cont );
			var rpt:Point = getVirtualPosition( this.parent, cx , cy );
			_cont.x = rpt.x;
			_cont.y = rpt.y;
			
			drawControl();
			
			_cont.cacheAsBitmap = true;
			_cont.addEventListener( MouseEvent.MOUSE_DOWN, moveControl);
			this.stage.addEventListener( MouseEvent.MOUSE_UP, onEditFinish );
			this.stage.addEventListener( MouseEvent.MOUSE_MOVE, onEdit );
		}
		
		private function drawMainPt():void 
		{
			_mainPt.graphics.clear();
			_mainPt.graphics.lineStyle();
			_mainPt.graphics.beginFill( Constants.EDIT_LINE_COLOR , 1 );
			_mainPt.graphics.drawCircle( 0, 0 , Constants.EDIT_POINT_SIZE * _zoomValue );
			_mainPt.graphics.endFill();
		}
		
		private function drawControl():void 
		{
			_cont.graphics.clear();
			_cont.graphics.lineStyle( 1, Constants.EDIT_LINE_COLOR , 2 , false, LineScaleMode.NONE );
			_cont.graphics.beginFill( 0 , 0 );
			_cont.graphics.drawCircle( 0, 0 , Constants.EDIT_POINT_SIZE * _zoomValue );
			_cont.graphics.endFill();
		}
		
		private function onEdit( e:MouseEvent ):void 
		{
			var apt:Point = getActualPosition( this.parent , this.x, this.y );
			var rpt:Point = getActualPosition( this.parent ,  _cont.x   ,  _cont.y  );
			ax = apt.x;
			ay = apt.y;
			cx = rpt.x;
			cy = rpt.y;
			dispatchEvent( new PathEditEvent( PathEditEvent.PATH_EDIT ,_id , this , true , true ) );
		}
		
		private function moveControl( e:MouseEvent ):void 
		{
			isControlEditMode = true;
			new RemovableDragItem( e.currentTarget as DisplayObject );
		}
		
		private function onEditFinish( e:MouseEvent ):void 
		{
			dispatchEvent( new PathEditEvent( PathEditEvent.PATH_EDIT_FINISH , _id , this , true , true ) );
		}

	}

}