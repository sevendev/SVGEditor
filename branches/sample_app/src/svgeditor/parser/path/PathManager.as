package svgeditor.parser.path 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.GraphicsPath;
	import flash.display.GraphicsPathCommand;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import svgeditor.event.PathEditEvent;
	import svgeditor.parser.IEditable;
	import svgeditor.parser.model.PersistentData;
	import svgeditor.event.ZoomEvent;
	import svgeditor.parser.utils.GeomUtil;
	
	public class PathManager extends EventDispatcher
	{
		private var _editPoints:Vector.<IEditPoint>;
		private var _closed:Boolean = false;
		private var _canvas:DisplayObjectContainer;
		private var _virtual:DisplayObjectContainer;
		private var _currentSelection:IEditPoint;
		private var count:int = 0;

		public function PathManager() 
		{
			_editPoints = new Vector.<IEditPoint>();
		}
		
		public function addPoint( x:Number, y:Number, command:int ):void 
		{
			var pt:IEditPoint = new BezierPoint( count++ , x, y  );
			pt.command = command;
			_editPoints.push( pt );
		}
		
		public function addQuadPoints( cx:Number, cy:Number, x:Number, y:Number ):void 
		{
			var cpt1:QuadPoint = new QuadPoint( count++, cx, cy );
			var cpt2:QuadPoint = new QuadPoint( count++, x, y ) ;
			_editPoints.push( cpt1 );
			_editPoints.push( cpt2 );
		}
		
		
		public function addBezierCurve( cx:Number , cy:Number , cx1:Number , cy1:Number , x:Number , y:Number ):void
		{
			var last:IEditPoint = getLastPoint();
			last.setControl2( cx, cy );
			_editPoints.push( new BezierPoint( count++ , x, y, cx1 , cy1 ) );
		}
		
		public function addArcPoint( 	x:Number, y:Number, rx:Number, ry:Number, 
										large_arc_flag:Boolean, sweep_flag:Boolean, x_axis_rotation:Number ) :void
		{
			var apt:ArcPoint = new ArcPoint( count++, x, y, rx, ry, large_arc_flag, sweep_flag, x_axis_rotation );
			_editPoints.push( apt );
		}
		
		public function closePath():void 
		{
			var first:IEditPoint = getFirstPoint();
			var last:IEditPoint = getLastPoint();
			if ( 	Math.round( first.ax ) == Math.round(last.ax) && 
					Math.round( first.ay ) == Math.round(last.ay) )
				last.setSlave( first );
			
			_closed = true;
		}

		public function createPoints( canvas:DisplayObjectContainer , matrixLayer:DisplayObjectContainer ):void 
		{
			_canvas = canvas;
			_virtual = matrixLayer;
			for each( var ept:IEditPoint in _editPoints )
				setPoint( ept );
			_canvas.addEventListener( PathEditEvent.PATH_EDIT, enterEditMode );
			_canvas.addEventListener( PathEditEvent.PATH_EDIT, onPathEdit );
			_canvas.addEventListener( PathEditEvent.PATH_EDIT_FINISH, onPathEdit );
			PersistentData.getInstance().addEventListener( ZoomEvent.ZOOM_VALUE_CHANGE, resizeAll );
		}
		
		public function getFirstPoint():IEditPoint
		{
			return _editPoints[0];
		}
		
		public function getLastPoint():IEditPoint
		{
			if ( !( _editPoints.length > 0) ) return null;
			return _editPoints[ _editPoints.length - 1 ];
		}

		public function getCommands():GraphicsPath 
		{
			if ( !_editPoints.length ) return new GraphicsPath();
			var commands:Vector.<int> = Vector.<int>( [ GraphicsPathCommand.MOVE_TO ] );
			var vertices:Vector.<Number> = Vector.<Number>( [ getFirstPoint().ax, getFirstPoint().ay ]);
			var last:IEditPoint;
			for each ( var p:IEditPoint in _editPoints ) 
			{
				if ( last ) 
				{
					var pCommand:GraphicsPath = new CurveFactory( last , p ).getCommand();
					commands = commands.concat( pCommand.commands );
					vertices = vertices.concat( pCommand.data );
				}
				last = p;
			};
			
			return new GraphicsPath( commands, vertices );
		}
		
		public function getSvgAttr():String 
		{
			var str:String = "M" + getFirstPoint().ax + "," + getFirstPoint().ay + " ";
			var last:IEditPoint;
			for each ( var p:IEditPoint in _editPoints ) 
			{
				if ( last ) str += new CurveFactory( last , p ).getSvgAttr();
				last = p;
			};
			if ( _closed ) str += "Z";
			return str;
		}
		
		public function exit():void {
			PersistentData.getInstance().removeEventListener( ZoomEvent.ZOOM_VALUE_CHANGE, resizeAll );
			for each( var ept:IEditPoint in _editPoints ) 
				ept.exit( true );
			_canvas.removeEventListener( PathEditEvent.PATH_EDIT, enterEditMode );
			_canvas.removeEventListener( PathEditEvent.PATH_EDIT, onPathEdit );
			_canvas.removeEventListener( PathEditEvent.PATH_EDIT_FINISH, onPathEdit );
			_canvas = null;
			_virtual = null;
		}
		
		public function addNewPoint( x:Number , y:Number  ):void
		{
			var pt:IEditPoint = new BezierPoint( count++ , x, y  );
			pt.command = GraphicsPathCommand.LINE_TO;
			setPoint( pt );
			
			var index:int = findClosestPoint( x, y );
			_editPoints.splice( index , 0 , pt );
			dispatchChange( index );
		}
		
		public function deleteCurrentPoint():void
		{
			if ( _editPoints.length <= 2  ) return;
			var index:int = _editPoints.indexOf( _currentSelection );
			if ( index == -1 ) return;
			if ( _closed && _currentSelection.hasSlaves() )
			{
				var slaves:Vector.<IEditPoint> = _currentSelection.getSlaves();
				for each ( var slave:IEditPoint in slaves )
					_editPoints[ index -1 ].setSlave( slave );
			}
			
			var pts:Vector.<IEditPoint> = _editPoints.splice( index , 1 );
			_currentSelection.exit( true );
			dispatchChange( index );
		}
		
		public function deleteCurrentControl( id:int = 0 ) :void
		{
			if ( id == 1 ) _currentSelection.deleteControl1();
			if ( id == 2 ) _currentSelection.deleteControl2();
			if ( id == 0 )
			{
				_currentSelection.deleteControl1();
				_currentSelection.deleteControl2();
			}
			dispatchChange( id );
		}
		
		public function convetToGlobal( local:DisplayObjectContainer , global:DisplayObjectContainer ):void
		{
			for each( var p:IEditPoint in _editPoints )
			{
				var a:Point = GeomUtil.getVirtualPosition( global, local , p.ax, p.ay );
				p.ax = a.x;
				p.ay = a.y;
				if ( p.hasControl1() )
				{
					var c:Point = GeomUtil.getVirtualPosition( global, local , p.cx, p.cy );
					p.cx = c.x;
					p.cy = c.y;
				}
				if ( p.hasControl2() )
				{
					var c1:Point = GeomUtil.getVirtualPosition( global, local , p.cx1, p.cy1 );
					p.cx1 = c1.x;
					p.cy1 = c1.y;
				}
			}
		}
		
		private function setPoint( p:IEditPoint ):void
		{
			p.createPoint();
			p.setCanvas( _canvas , _virtual );
			p.resize( PersistentData.getInstance().currentZoom  );
		}
		
		private function findClosestPoint( x:Number, y:Number ):int
		{
			var p:Point = new Point( x, y );
			var dist:Array = [];
			var length:int = _editPoints.length - 1;
			for ( var i:int = 0; i < length ; i++ )
			{
				var current:IEditPoint = _editPoints[i];
				var next:IEditPoint = _editPoints[i + 1];
				
				var hit:Boolean = new CurveFactory( current, next ).hitTestCurve( p );
				var cx1:Number = ( isNaN( current.cx1 ) || current.cx1 == 0 ) ? current.ax : current.cx1;
				var cy1:Number = ( isNaN( current.cy1 ) || current.cy1 == 0 ) ? current.ay : current.cy1;
				var cx:Number = ( isNaN( next.cx ) || next.cx == 0 ) ? next.ax : next.cx;
				var cy:Number = ( isNaN( next.cy ) || next.cy == 0 ) ? next.ay : next.cy;
				var distance:Number  = 	GeomUtil.getDistance( p , new Point( cx , cy )  ) + 
										GeomUtil.getDistance( p , new Point( cx1 , cy1 ));
										
				dist.push( { index:i+1 , distance:distance , hit:hit  } );
			}
			
			dist.sortOn( "distance" ,  Array.NUMERIC );
			var hits:Array = dist.filter( function( elem:Object, index:int, arr:Array ):Boolean {
				return elem.hit;
			});
			return hits.length ? hits[0].index : dist[0].index ;
		}
		
		private function setFirstPoint():void
		{
			if ( _closed ) return;
			getFirstPoint().addEventListener( MouseEvent.MOUSE_MOVE , showIndicator );
			getLastPoint().addEventListener( MouseEvent.MOUSE_MOVE , showIndicator );
			getFirstPoint().addEventListener( MouseEvent.MOUSE_UP , endEdgePointEdit );
			getLastPoint().addEventListener( MouseEvent.MOUSE_UP , endEdgePointEdit );
		}
		
		private function showIndicator( e:MouseEvent = null ):Boolean
		{
			var connect:Boolean = ( DisplayObject( getLastPoint() ).hitTestObject( getFirstPoint() as DisplayObject ) );
			getFirstPoint().showIndicator( connect );
			return connect;
		}
		
		private function endEdgePointEdit( e:MouseEvent ):void
		{
			if ( showIndicator() )
			{
				 getLastPoint().setSlave( getFirstPoint() );
				_closed = true;
				getFirstPoint().showIndicator( false );
			}
			getFirstPoint().removeEventListener( MouseEvent.MOUSE_MOVE , showIndicator );
			getLastPoint().removeEventListener( MouseEvent.MOUSE_MOVE , showIndicator );
			getFirstPoint().removeEventListener( MouseEvent.MOUSE_UP , endEdgePointEdit );
			getLastPoint().removeEventListener( MouseEvent.MOUSE_UP , endEdgePointEdit );
			dispatchChange( getFirstPoint().id );
		}
		
		private function enterEditMode( e:PathEditEvent ):void {
			for each( var ept:IEditPoint in _editPoints ) 
			{
				if (  e.id == ept.id ) continue;
				ept.exit();
			}
			_currentSelection = e.editPoint;
			_currentSelection.setSelected();
			setFirstPoint();
		}
		
		private function resizeAll( e:ZoomEvent ):void 
		{
			for each( var ept:IEditPoint in _editPoints )
				ept.resize( e.value );
		}
		
		private function dispatchChange( id:int ):void
		{
			if ( !_currentSelection ) _currentSelection = getFirstPoint();
			dispatchEvent( new PathEditEvent( PathEditEvent.PATH_EDIT , id, _currentSelection , true , true ) );
			dispatchEvent( new PathEditEvent( PathEditEvent.PATH_EDIT_FINISH , id, _currentSelection  , true , true) );
		}
		
		private function onPathEdit( e:PathEditEvent ):void 
		{
			dispatchEvent( e );
		}
		
		public function get editPoints():Vector.<IEditPoint> { return _editPoints; }
		public function set editPoints(value:Vector.<IEditPoint>):void 
		{
			_editPoints = value;
		}

	}

}