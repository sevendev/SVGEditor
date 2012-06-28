package svgeditor.parser 
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import svgeditor.parser.IParser;
	import svgeditor.parser.model.Data;
	import svgeditor.parser.filters.*;
	import svgeditor.parser.utils.StyleUtil;
	import svgeditor.parser.model.PersistentData;
	
	public class FilterSet implements IParser
	{
		public static var LOCALNAME:String = "filter";
		
		private static const FPARSERS:Array = [ GaussianBlur , ColorMatrix, DisplacementMap ];
		
		public var id:String;
		public var _x:Number;
		public var _y:Number;
		public var _width:Number;
		public var _height:Number;
		
		public var filters:Vector.<IFilter> = new Vector.<IFilter>();
		
		public function parse( data:Data ):void 
		{
			id = data.currentXml.@id.toString();
			_x = StyleUtil.toNumber( data.currentXml.@x );
			_y = StyleUtil.toNumber( data.currentXml.@y );
			_width = StyleUtil.toNumber( data.currentXml.@width );
			_height = StyleUtil.toNumber( data.currentXml.@height );
			
			var fs:XMLList = data.currentXml.children();
			for each( var f:XML in fs ) {
				var current:IFilter =  getFilter( f );
				if( current ) filters.push( current );
			}
			data.addFilter( this );
		}
		
		public function addFilter( f:IFilter ):void 
		{
			filters.push( f );
		}
		
		public function removeFilter( f:IFilter ):void 
		{
			var length:int = filters.length;
			for ( var i:int = 0; i < length ; i++ ) 
				if ( filters[i] == f ) 
					filters.splice( i, 1);
			
			if ( filters.length <= 0 )
				PersistentData.getInstance().removeFilter( this );
		}
		
		public function setSourceGraphic( d:DisplayObject ):void {
			for each( var f:IFilter in filters )
				f.setSourceGraphic( d );
		}
		
		public function getAllFilters():Array 
		{
			var sets:Array = [];
			for each( var f:IFilter in filters ) 
				sets.push( f.getFlashFilter() );
			return sets;
		}
		
		public function hasFilter():Boolean 
		{
			return ( filters.length > 0 );
		}
		
		public static function getFilter( xml:XML ):IFilter 
		{
			for each( var Fl:Class in FPARSERS ) 
				if ( xml.localName() == Fl["LOCALNAME"] ) return new Fl( xml );
			return null;
		}
		
		public function newPrimitive():void
		{
			_x = -1;
			_y = -1;
			_width = 3;
			_height = 3;
		}
		
		public function getSvg():XML 
		{
			var node:XML =<{FilterSet.LOCALNAME} />;
			node.@id = id;
			node.@x = _x;
			node.@y = _y;
			node.@width = _width;
			node.@height = _height;
			for each( var f:IFilter in filters ) 
				node.appendChild( f.getSvg() );

			return node;
		}
	}
}