package svgeditor.parser.path 
{
	import flash.display.Sprite;
	import flash.display.DisplayObjectContainer;
	import flash.display.GraphicsPathCommand;
	import flash.events.Event;
	import flash.geom.Point;
	import svgeditor.Constants;
	import svgeditor.event.PathEditEvent;
	import svgeditor.parser.utils.GeomUtil;

	public class AbstractEditPoint extends Sprite implements IEditPoint
	{
		protected var _id:int;
		protected var _ax:Number;
		protected var _ay:Number;
		protected var _command:int;
		protected var _virtualLayer:DisplayObjectContainer;
		protected var _editable:Boolean = true;
		protected var _slavePoints:Vector.<IEditPoint>;
		protected var _selected:Boolean = false;
		protected var _zoomValue:Number = 1;
		
		public function AbstractEditPoint() {}
		
		public function setCanvas( canvas:DisplayObjectContainer, virtual:DisplayObjectContainer = null ):void
		{
			canvas.addChild( this );
			_virtualLayer = virtual ? virtual : canvas;
			this.doubleClickEnabled = true;
			this.addEventListener( Event.REMOVED_FROM_STAGE, remove );
		}
		
		public function createPoint():void 
		{
			if ( !_editable ) return;
			var color:uint = _selected ? Constants.EDIT_LINE_SELECTED_COLOR : Constants.EDIT_LINE_COLOR;
			this.graphics.clear();
			this.graphics.lineStyle();
			this.graphics.beginFill( color , 1 );
			this.graphics.drawCircle( 0, 0 , Constants.EDIT_POINT_SIZE * _zoomValue );
			this.graphics.endFill();
			this.cacheAsBitmap = true;
		}
		
		public function resize( value:Number ):void 
		{
			_zoomValue = 1 / value;
			createPoint();
		}
		
		public function exit( remove:Boolean = false ):void 
		{
			if ( remove ) this.parent.removeChild( this );
		}
		
		public function setSlave( p:IEditPoint ):void 
		{
			if ( !_slavePoints ) _slavePoints = new Vector.<IEditPoint>();
			_slavePoints.push( p );
			p.editable = false;
		}
		
		public function showIndicator( f:Boolean = true  ):void { }
		
		public function setSelected( f:Boolean = true ):void 
		{ 
			_selected = f;
			createPoint();
		}
		
		public function hasSlaves():Boolean
		{
			return ( _slavePoints && _slavePoints.length );
		}
		
		public function getSlaves():Vector.<IEditPoint>
		{
			return _slavePoints;
		}
		
		public function setControl1( x:Number, y:Number ):void
		{
			cx = x;
			cy = y;
		}
		public function setControl2( x:Number, y:Number ):void
		{
			cx1 = x;
			cy1 = y;
		}
		
		public function hasControl1():Boolean 
		{
			return ( !isNaN( cx ) && !isNaN( cy ) && cx != 0 && cy != 0 );
		}
		
		public function hasControl2():Boolean 
		{
			return ( !isNaN( cx1 ) && !isNaN( cy1 ) && cx1 != 0 && cy1 != 0 );
		}
		
		public function deleteControl1():void { }
		public function deleteControl2():void { }
		
		public function isMoveTo():Boolean 
		{
			return ( command == GraphicsPathCommand.MOVE_TO );
		}
		
		public function isEditablePoint():Boolean
		{
			return false;
		}
		
		protected function getVirtualPosition( _parent:DisplayObjectContainer , _x:Number , _y:Number ):Point 
		{
			if ( !_parent ) _parent = this;
			return GeomUtil.getVirtualPosition( _parent, _virtualLayer , _x , _y );
		}
		
		protected function getActualPosition( _parent:DisplayObjectContainer , _x:Number , _y:Number ):Point 
		{
			if ( !_parent ) _parent = this;
			return GeomUtil.getActualPosition( _parent, _virtualLayer , _x , _y );
		}
		
		protected function remove( e:Event ):void
		{
			this.removeEventListener( Event.REMOVED_FROM_STAGE, remove );
			try{  exit(); } catch( e:Error ){}
		}
		
		public function get id():int { return _id; }
		public function get ax():Number { return _ax; }
		public function get ay():Number { return _ay; }
		public function set ax( value:Number ):void 
		{ 
			_ax = value; 
			for each ( var p:IEditPoint in _slavePoints)
				p.ax = value;
		}
		public function set ay( value:Number ):void 
		{ 
			_ay = value; 
			for each ( var p:IEditPoint in _slavePoints)
				p.ay = value;
		}
		public function get editable():Boolean { return _editable; }
		public function set editable(value:Boolean):void 
		{ 
			_editable = value; 
			exit( true );
		}
		public function get cx():Number { return NaN; }
		public function get cy():Number { return NaN; }
		public function set cx( value:Number ):void{}
		public function set cy( value:Number ):void { }
		public function get cx1():Number { return NaN; }
		public function get cy1():Number { return NaN; }
		public function set cx1( value:Number ):void{}
		public function set cy1( value:Number ):void{}
		public function get asPoint():Point { return new Point( ax, ay ); }
		public function get command():int { return ( _command ) ? _command : GraphicsPathCommand.LINE_TO ; }
		public function set command(value:int):void { _command = value; }
		

	}

}