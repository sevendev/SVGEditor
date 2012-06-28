package svgeditor.parser {
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import svgeditor.Constants;
	import svgeditor.parser.model.Data;
	import svgeditor.parser.model.PersistentData;
	
	public class SvgFactory extends EventDispatcher
	{
		private static const PARSERS:Array = [ 	Svg , Group , Defs,  FlowRoot , Path , Polyline, Polygon,
												Ellipse, Rect, Text, Image, Line, Circle, ClipPath, Symbol, 
												Marker, LinearGradient, RadialGradient , FilterSet ];
		
		public function SvgFactory() { }
		
		//import
		public function parse( xml:XML , target:Sprite ):void 
		{
			XML.ignoreWhitespace = false;
			xml.removeNamespace( Constants.svg );
			xml.removeNamespace( Constants.xlink );
			
			parseXlink( xml );
			parseData( new Data( xml , target ) );
			
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		public static function parseData( data:Data ):void 
		{
			getParser( data.currentXml  ).parse( data );
		}
		
		private static function getParser( xml:XML  ):IParser 
		{
			for each( var Ps:Class in PARSERS ) 
				if ( xml.localName() == Ps["LOCALNAME"] ) return new Ps();
			return new ComplexTree();
		}
		
		private static function parseXlink( xml:XML ):void 
		{
			var xlink:Namespace = Constants.xlink;
			var children:XMLList = xml..*.@xlink::href;
			for each( var c:XML in children ) 
			{
				var parent:XML = c.parent();
				var linkid:String = c.toString().replace( /#/, "");
				
				if ( xml..*.( attribute("id") == linkid ).length() == 0 )  //image url
					continue;
					
				var linked:XML = xml..*.( attribute("id") == linkid )[0].copy();
				delete parent.@xlink::href;
				
				if ( parent.localName() == "use" && linked.localName() != "symbol" ) 
				{
					var attrs:XMLList = parent.@*;
					for each( var attr:XML in attrs ) 
					{
						if( !linked.attribute( attr.name() ).toString() ) 
							linked.@[ attr.name() ] = attr.toString();
					}
					parent.appendChild( linked );
				}
				else 
				{
					attrs = linked.@*;
					for each( attr in attrs ) 
					{
						if( !parent.attribute( attr.name() ).toString() ) 
							parent.@[ attr.name() ] = attr.toString();
					}
					parent.setChildren( linked.children() );
				}
				
				if ( parent.localName() == "use" )
						parent.setLocalName( "g" );
			}
		}
		
		//export
		public function export( svg:Svg ):XML 
		{
			var xml:XML = svg.getSvg();
			var xmlStr:String = xml.toXMLString();
			var def:XML = <{Defs.LOCALNAME} />;

			while ( xml..clipPath.length() )
				delete xml..clipPath[0];
			
			var gradients:Array = PersistentData.getInstance().gradients;
			for each( var gradient:IGradient in gradients ) 
				if( xmlStr.indexOf( gradient.getId() ) != -1 )
					def.appendChild( gradient.getSvg() );
				
			var filters:Array = PersistentData.getInstance().filters;
			for each( var filter:FilterSet in filters ) 
				if( xmlStr.indexOf( filter.id ) != -1 )
					def.appendChild( filter.getSvg() );
				
			var clippaths:Array = PersistentData.getInstance().clippaths;
			for each( var clippath:ClipPath in clippaths ) 
				if( xmlStr.indexOf( clippath.name ) != -1 )
					def.appendChild( clippath.getSvg() );
			
			if( def.children().length() )
				xml.prependChild( def );
			xml.normalize();
			return xml;
		}
		
	}
	
}