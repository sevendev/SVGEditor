package svgeditor.parser.model 
{
	import flash.display.DisplayObjectContainer;
	import flash.events.EventDispatcher;
	import svgeditor.event.ZoomEvent;
	import svgeditor.parser.FilterSet;
	import svgeditor.parser.IGradient;
	import flash.display.DisplayObject;
	import svgeditor.parser.style.Style;
		
	public class PersistentData extends EventDispatcher
	{
		private var _rootXML:XML;
		private var _rootCanvas:DisplayObjectContainer;
		private var _controlCanvas:DisplayObjectContainer;
		private var _gradients:Array = [];
		private var _filters:Array = [];
		private var _clippaths:Array = [];
		private var _currentZoom:Number = 1;
		private var _gradientCount:int = 0;
		private var _filterSetCount:int = 0;
		private var _clippathCount:int = 0;
		private var _currentStyle:Style;
		
		public function PersistentData( enforcer:SingletonEnforcer ) { }
		
		private static var _instance:PersistentData;
		public static function getInstance():PersistentData 
		{
			if ( _instance == null )
				_instance = new PersistentData( new SingletonEnforcer() );
				
			return _instance;
		}
	   	
		public function get rootXML():XML { return _rootXML; }
		public function set rootXML(value:XML):void 
		{
			if( !_rootXML ) _rootXML = value;
		}
		
		public function get rootCanvas():DisplayObjectContainer { return _rootCanvas; }
		public function set rootCanvas(value:DisplayObjectContainer):void 
		{
			if( !_rootCanvas ) _rootCanvas = value;
		}
		
		public function get controlCanvas():DisplayObjectContainer { return _controlCanvas; }
		public function set controlCanvas(value:DisplayObjectContainer):void 
		{
			_controlCanvas = value;
		}
		
		public function get currentZoom():Number { return _currentZoom; }
		public function set currentZoom(value:Number):void 
		{
			_currentZoom = value;
			dispatchEvent( new ZoomEvent( value ) );
		}
		
		public function get currentStyle():Style 
		{ 
			if ( !_currentStyle ) 
				_currentStyle = new Style();
			return _currentStyle; 
		}
		public function set currentStyle(value:Style):void 
		{
			if ( !_currentStyle ) 
				_currentStyle = new Style();
			_currentStyle = value;
		}
		
		//Gradients
		public function get gradients():Array { return _gradients; }
		
		public function get gradientId():String 
		{ 
			return "Gradient-" + _gradientCount++; 
		}
		
		public function getGradientById( id:String ):IGradient { 
			for each( var grad:IGradient in _gradients ) 
				if ( grad.getId() == id ) return grad;
			return null; 
		}
		public function addGradient(value:IGradient):void 
		{
			for each( var grad:IGradient in _gradients ) 
				if ( grad.getId() == value.getId() ) return;
			_gradients.push( value );
		}
		public function removeGradient(value:IGradient):void 
		{
			for ( var index:String in _gradients ) 
				if ( _gradients[index].getId() == value.getId() ) 
					_gradients.splice( index , 1 );
		}
		
		//Filters
		public function get filters():Array { return _filters; }
		
		public function get filterId():String 
		{ 
			return "Filter-" + _filterSetCount++; 
		}
		
		public function getFilterById( id:String ):FilterSet {
			for each( var fl:FilterSet in _filters ) 
				if ( fl.id == id ) return fl;
			return null; 
		}
		public function addFilter(value:FilterSet):void 
		{
			for each( var fl:FilterSet in _filters ) 
				if ( fl.id == value.id ) return;
			_filters.push( value );
		}
		public function removeFilter(value:FilterSet):void 
		{
			for ( var index:String in _filters ) 
				if ( _filters[index].id == value.id ) 
					_filters.splice( index , 1 );
		}
		
		//ClipPaths
		public function get clippaths():Array { return _clippaths; }
		
		public function get clippathId():String 
		{ 
			return "Clippath-" + _clippathCount++; 
		}
		
		public function getClipPathById( id:String ):DisplayObject {
			for each( var cp:DisplayObject in _clippaths ) 
				if ( cp.name == id ) return cp;
			return null;
		}
		
		public function addClipPath(value:DisplayObject):void 
		{
			for each( var cp:DisplayObject in _clippaths ) 
				if ( cp.name == value.name ) return;
			_clippaths.push( value );
		}
		public function removeClipPath( id:String ):void 
		{
			for ( var index:String in _clippaths ) 
				if ( _clippaths[index].name == id ) 
					_clippaths.splice( index , 1 );
		}
		
		public function reset():void 
		{
			_rootXML = null;
			_rootCanvas = null;
			_gradients = [];
			_filters = [];
			_clippaths = [];
			currentZoom = 1;
		}
	}

}

class SingletonEnforcer {}