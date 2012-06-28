package svgeditor.parser.model 
{
	import flash.display.DisplayObjectContainer ;
	import flash.display.DisplayObject;
	import svgeditor.parser.style.Style;
	import svgeditor.parser.SvgFactory;
	import svgeditor.parser.FilterSet;
	import svgeditor.parser.IGradient;
	
	public class Data
	{
		private var _currentXML:XML;
		private var _currentCanvas:DisplayObjectContainer;
		private var _persistent:PersistentData;
		
		public function Data( xml:XML, canvas:DisplayObjectContainer ) 
		{
			_persistent = PersistentData.getInstance();
			_currentXML = _persistent.rootXML =  xml;
			_currentCanvas = _persistent.rootCanvas = canvas;
		}
		
		public function copy( xml:XML = null , canvas:DisplayObjectContainer = null):Data	
		{	
			if ( !xml ) xml = _currentXML;
			if ( !canvas ) canvas = _currentCanvas;
			return new Data( xml, canvas );
		}

		public function getGradientById( id:String ):IGradient { 
			return _persistent.getGradientById( id );
		}
		public function addGradient(value:IGradient):void 
		{
			_persistent.addGradient( value );
		}
		
		public function getFilterById( id:String ):FilterSet {
			return _persistent.getFilterById( id );
		}
		public function addFilter(value:FilterSet):void 
		{
			_persistent.addFilter( value );
		}
		
		public function getClipPathById( id:String ):DisplayObject {
			return _persistent.getClipPathById( id );
		}
		
		public function addClipPath(value:DisplayObject):void 
		{
			_persistent.addClipPath( value );
		}
		
		public function get xml():XML { return _persistent.rootXML; }
		public function get canvas():DisplayObjectContainer { return _persistent.rootCanvas; }
		
		public function get currentCanvas():DisplayObjectContainer  { return _currentCanvas; }
		public function set currentCanvas( value:DisplayObjectContainer ):void {
			_currentCanvas = value;
		}
		public function get currentXml():XML { return _currentXML; }
		public function set currentXml( value:XML ):void {
			_currentXML = value;
		}
		
		public function exit():void 
		{
			_persistent = null;
			_currentCanvas = null;
			_currentXML = null;
		}
	}

}