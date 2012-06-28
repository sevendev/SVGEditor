package svgeditor.parser.path 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.events.MouseEvent;
	import flash.display.GraphicsPathCommand;
	import flash.display.GraphicsPath;
	import flash.display.LineScaleMode;
	import svgeditor.event.ZoomEvent;
	import svgeditor.parser.IEditable;
	import svgeditor.ui.RemovableDragItem;
	import svgeditor.event.PathEditEvent;
	import svgeditor.Constants;
	import svgeditor.parser.model.PersistentData;
	
	public class BezierPoint extends AbstractEditPoint implements IEditPoint
	{
		private var _cx:Number;
		private var _cy:Number;
		private var _cx1:Number;
		private var _cy1:Number;
		
		private var mainPt:Sprite;
		private var cont1:Sprite;
		private var cont2:Sprite;
		private var line:Sprite;
		private var indicator:Sprite;
		private var currentCont:Sprite;
		private var isControlEditMode:Boolean = false;
		private var isRelativePoint:Boolean = false;
		
		public function BezierPoint( id:int,  x:Number, y:Number, cx:Number = 0 , cy:Number = 0, cx1:Number = 0, cy1:Number = 0  ):void
		{
			this._id = id;
			this.ax = x;
			this.ay = y;
			this.cx = cx;
			this.cy = cy;
			this.cx1 = cx1;
			this.cy1 = cy1;
			checkRelative();
		}
		
		override public function setCanvas( canvas:DisplayObjectContainer, virtual:DisplayObjectContainer = null ):void
		{
			super.setCanvas( canvas, virtual );
			var pos:Point = getVirtualPosition( this.parent , _ax, _ay );
			this.x = pos.x;
			this.y = pos.y;
		}
		
		override public function createPoint():void 
		{
			if ( !_editable ) return;
			mainPt = new Sprite();
			addChild( mainPt );
			drawMainPt();
			this.addEventListener( MouseEvent.MOUSE_DOWN , showControl );
			mainPt.addEventListener( MouseEvent.DOUBLE_CLICK, switchMode );
			mainPt.doubleClickEnabled = true;
		}
		
		
		override public function setSlave( p:IEditPoint ):void {
			super.setSlave( p );
			if ( p is BezierPoint ) 
			{
				var b:BezierPoint = p as BezierPoint;
				cx = ( isNaN( cx ) || cx == 0 ) ? b.cx : cx;
				cy = ( isNaN( cy ) || cy == 0 ) ? b.cy : cy;
				cx1 = ( isNaN( cx1 ) || cx1 == 0 ) ? b.cx1 : cx1;
				cy1 = ( isNaN( cy1 ) || cy1 == 0 ) ? b.cy1 : cy1;
			}
			checkRelative();
			p.ax = ax;
			p.ay = ay;
		}
		
		override public function setControl1( x:Number, y:Number ):void
		{
			super.setControl1( x, y);
			checkRelative();
			onEditFinish();
		}
		
		override public function setControl2( x:Number, y:Number ):void
		{
			super.setControl2( x, y);
			checkRelative();
			onEditFinish();
		}
		
		public function showControl( e:MouseEvent = null ):void    
		{
			if( !isControlEditMode )
				new RemovableDragItem( this as DisplayObject );
			else
				isControlEditMode = false;
			
			createControls();
			
			this.stage.addEventListener( MouseEvent.MOUSE_MOVE, drawControlLine);
			this.stage.addEventListener( MouseEvent.MOUSE_UP, onEditFinish );
		}
		
		override public function setSelected( f:Boolean = true ):void 
		{ 
			_selected = f;
			drawMainPt();
		}
		
		override public function exit( remove:Boolean = false ):void 
		{
			setSelected( false );
			
			if ( cont1 ) 
			{
				cont1.removeEventListener( MouseEvent.MOUSE_DOWN, moveControl);
				removeChild( cont1 );
				cont1 = null;
			}
			if ( cont2 ) 
			{
				cont2.removeEventListener( MouseEvent.MOUSE_DOWN, moveControl);
				removeChild( cont2 );
				cont2 = null;
			}
			if ( line )
			{
				removeChild( line );
				line = null;
			}
			if ( this.stage) 
			{
				this.stage.removeEventListener( MouseEvent.MOUSE_MOVE, drawControlLine);
				this.stage.removeEventListener( MouseEvent.MOUSE_UP, onEditFinish );
			}
			
			currentCont = null;
			isControlEditMode = false;
			
			if ( remove )
			{
				this.removeEventListener( MouseEvent.MOUSE_DOWN , showControl );
				if ( mainPt ) {
					mainPt.removeEventListener( MouseEvent.DOUBLE_CLICK, switchMode );
					removeChild( mainPt );
					mainPt = null;
				}
				if ( this.parent )
					this.parent.removeChild( this );
			}
		}
		
		override public function resize( value:Number ):void 
		{
			_zoomValue = 1 / value;
			if ( mainPt ) drawMainPt();
			if ( cont1 ) drawControl( cont1 );
			if ( cont2 ) drawControl( cont2 );
		}
		
		override public function showIndicator( f:Boolean = true  ):void
		{
			if( !indicator ) createIndicator();
			indicator.visible = f;
		}
		
		public function hasControl():Boolean 
		{
			return ( hasControl1() || hasControl2() );
		}
		
		public function hasBothControl():Boolean 
		{
			return ( hasControl1() && hasControl2() );
		}
		
		override public function deleteControl1():void 
		{ 
			if ( !cont1 ) return;
			cx = cy = NaN;
			removeChild( cont1 );
			cont1 = null;
			onEditFinish();
		}
		
		override public function deleteControl2():void 
		{ 
			if ( !cont2 ) return;
			cx1 = cy1 = NaN;
			removeChild( cont2 );
			cont2 = null;
			onEditFinish();
		}
		
		override public function isEditablePoint():Boolean
		{
			return true;
		}
		
		public function createPointForCreation():void //For PathCreationPoint
		{
			mainPt = new Sprite();
			drawMainPt();
			addChild( mainPt );
		}
		
		public function setControlForCreation( x:Number , y:Number , cid:int=1 ):void    //For PathCreationPoint
		{
			if ( x == 0 || y == 0 ) return;
			cx = cx1 = x;
			cy = cy1 = y;
			if ( !cont1 )
			{
				cont1 = createControl( x , y );
				cont2 = createControl( x , y );
				line = new Sprite();
				addChild( line );
				currentCont = this["cont"+ cid];
			}
			isRelativePoint = true;
			this["cont"+ cid].x = x;
			this["cont"+ cid].y = y;
			drawControlLine();
		}

		//Private
		private function drawMainPt():void 
		{
			if ( !_editable || !mainPt ) return;
			var color:uint = _selected ? Constants.EDIT_LINE_SELECTED_COLOR : Constants.EDIT_LINE_COLOR;
			mainPt.graphics.clear();
			mainPt.graphics.lineStyle(8, 0, 0);
			mainPt.graphics.beginFill( color , 1 );
			if ( !hasBothControl() || isRelativePoint ) 
				mainPt.graphics.drawCircle( 0, 0 , Constants.EDIT_POINT_SIZE * _zoomValue );
			else 
			{
				var size:Number = Constants.EDIT_POINT_SIZE * _zoomValue;
				var pCommand:Vector.<int> = Vector.<int>([ GraphicsPathCommand.MOVE_TO, GraphicsPathCommand.LINE_TO, GraphicsPathCommand.LINE_TO ]);
				var pVertice:Vector.<Number> = Vector.<Number>([ -size, -size, size , -size , 0, size ]);
				mainPt.graphics.drawPath( pCommand, pVertice );
			}
			mainPt.graphics.endFill();
			mainPt.cacheAsBitmap = true;
			if ( contains( mainPt ) ) setChildIndex( mainPt, numChildren-1 );
		}
		
		private function createControls():void
		{
			if ( !cont1 && hasControl1() )
				cont1 = createControl( cx, cy );
				
			if ( !cont2 && hasControl2() ) 
				cont2 = createControl( cx1 , cy1 );
			
			if ( !line ) 
			{
				line = new Sprite();
				addChild( line );
				drawControlLine();
			}
		}
		
		private function createIndicator():void
		{
			if ( !_editable ) return;
			indicator = new Sprite();
			indicator.graphics.lineStyle( 1, Constants.EDIT_LINE_COLOR , 1 , false, LineScaleMode.NONE );
			indicator.graphics.drawCircle( 0 , 0 , 8 );
			mainPt.addChild( indicator );
		}
		
		private function createControl(  _x:Number , _y:Number ):Sprite 
		{
			var cont:Sprite = new Sprite();
			drawControl( cont );
			addChild( cont );
			var pos:Point = getVirtualPosition( this , _x, _y );
			cont.x = pos.x;
			cont.y = pos.y;
			cont.cacheAsBitmap = true;
			cont.addEventListener( MouseEvent.MOUSE_DOWN, moveControl);
			return cont;
		}
		
		private function drawControl( cont:Sprite ):void 
		{
			cont.graphics.clear();
			cont.graphics.lineStyle( 8, 0, 0 ,false );
			cont.graphics.beginFill( Constants.EDIT_LINE_COLOR , 1 );
			cont.graphics.drawCircle( 0 , 0  , ( Constants.EDIT_POINT_SIZE * .7 ) * _zoomValue );
			cont.graphics.endFill();
		}
		
		private function moveControl( e:MouseEvent = null ):void 
		{
			isControlEditMode = true;
			currentCont = e.currentTarget as Sprite;
			new RemovableDragItem( e.currentTarget as DisplayObject );
		}
		
		private function drawControlLine( e:MouseEvent = null ):void 
		{
			if ( !line ) return;
			line.graphics.clear();
			line.graphics.lineStyle( 1, Constants.EDIT_LINE_COLOR , 1 , false, LineScaleMode.NONE  );
			line.graphics.moveTo( 0, 0 );
			
			if ( hasBothControl() && isRelativePoint && currentCont ) 
			{
				var target:Sprite = ( currentCont == cont1 ) ? cont2 : cont1;
				target.x = -currentCont.x;
				target.y = -currentCont.y;
			}
			
			if ( hasControl1() && cont1 ) 
			{
				line.graphics.lineTo( cont1.x , cont1.y );
				var cpos:Point = getActualPosition( this.parent , cont1.x + this.x ,  cont1.y + this.y);
				cx = cpos.x;
				cy = cpos.y;
			}

			if ( hasControl2() && cont2 ) 
			{
				line.graphics.moveTo( 0, 0 );
				line.graphics.lineTo( cont2.x , cont2.y );
				var cpos2:Point = getActualPosition( this.parent , cont2.x + this.x  , cont2.y + this.y );
				cx1 = cpos2.x;
				cy1 = cpos2.y;
			}
			
			var apos:Point = getActualPosition( this.parent , this.x , this.y );
			ax = apos.x;
			ay = apos.y;

			dispatchEvent( new PathEditEvent( PathEditEvent.PATH_EDIT , _id , this,  true  , true ) );
		}
		
		private function onEditFinish( e:MouseEvent = null ):void 
		{
			dispatchEvent( new PathEditEvent( PathEditEvent.PATH_EDIT , _id , this,  true  , true ) );
			dispatchEvent( new PathEditEvent( PathEditEvent.PATH_EDIT_FINISH , _id , this,  true , true ) );
		}
		
		private function switchMode( e:MouseEvent ):void 
		{
			if ( !hasBothControl() )
			{
				cx  = ax + Constants.DEFAULT_CONTROL_DISTANCE;
				cx1 = ax - Constants.DEFAULT_CONTROL_DISTANCE;
				cy = cy1 = ay;
				isRelativePoint = true;
				createControls();
				onEditFinish();
				return;
			}
			
			isRelativePoint = Boolean( !isRelativePoint );
			drawMainPt();
			drawControlLine();
			onEditFinish();
		}
		
		private function checkRelative():void 
		{
			if ( 	Math.round( cx - _ax ) == -Math.round( cx1 - _ax ) && 
					Math.round( cy - _ay ) == -Math.round( cy1 - _ay ) )
				isRelativePoint = true;
		}
		
		//Getter Setter
		override public function get cx():Number { return _cx; }
		override public function get cy():Number { return _cy; }
		override public function set cx( value:Number ):void 
		{ 
			_cx = value; 
			for each ( var p:IEditPoint in _slavePoints) {
				p.cx = value;
			}
		}
		override public function set cy( value:Number ):void 
		{ 
			_cy = value; 
			for each ( var p:IEditPoint in _slavePoints) {
				p.cy = value;
			}
		}
		
		override public function get cx1():Number { return _cx1; }
		override public function set cx1(value:Number):void 
		{
			_cx1 = value;
			for each ( var p:IEditPoint in _slavePoints) {
				p.cx1= value;
			}
		}
		
		override public function get cy1():Number { return _cy1; }
		override public function set cy1(value:Number):void 
		{
			_cy1 = value;
			for each ( var p:IEditPoint in _slavePoints) {
				p.cy1 = value;
			}
		}
	}

}