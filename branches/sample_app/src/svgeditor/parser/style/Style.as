package svgeditor.parser.style 
{
	import flash.display.DisplayObject;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.engine.FontWeight;
	//import svgeditor.event.StyleChangeEvent;
	import svgeditor.parser.filters.GaussianBlur;
	import svgeditor.parser.filters.IFilter;
	import svgeditor.parser.IGradient;
	import svgeditor.parser.model.Data;
	import svgeditor.parser.style.Transform;
	import svgeditor.parser.FilterSet;
	import svgeditor.parser.utils.StyleUtil;
	import svgeditor.Constants;
	import svgeditor.parser.model.PersistentData;
	import svgeditor.StyleObject;
	
	public class Style
	{
		public var id:String = "untitled";
		public var opacity:Number = 1.0;
		public var display:Boolean = true;
		public var rotate:Number;
		public var visibility:String;
		public var transform:Transform;
		public var viewBox:Rectangle;
		
		//paint
		public var stroke:uint = Constants.STROKE_COLOR;
		public var fill:uint = Constants.FILL_COLOR;
		public var stroke_opacity:Number = 1.0;
		public var stroke_width:Number = 1.0;
		public var stroke_miterlimit:Number = 3.0;
		public var stroke_linecap:String = CapsStyle.NONE;
		public var stroke_linejoin:String = JointStyle.ROUND;
		public var fill_opacity:Number = 1.0;
		public var fill_rule:String;
		public var marker:String;
		
		//text
		public var font_size:Number = Constants.FONT_SIZE;
		public var font_style:String;
		public var font_family:String = Constants.FONT_FAMILY;
		public var font_weight:String = Constants.FONT_WEIGHT;
		public var font_size_adjust:Number;
		public var font_stretch:String;
		public var font_variant:String;
		public var direction:String;
		public var letter_spacing:Number;
		public var word_spacing:Number;
		public var text_decoration:String;
		public var alignment_baseline:String;
		public var baseline_shift:Number;
		public var dominant_baseline:String;
		public var glyph_orientation_horizontal:int;
		public var glyph_orientation_vertical:int;
		public var kerning:Number;
		public var text_align:String;
		public var writing_mode:String;
		public var line_height:Number;
		public var fontLookup:String = Constants.FONT_LOOKUP;  // for FontConverter
		
		//gradation
		public var stop_color:uint = 0;
		public var stop_opacity:Number = 1;
		public var offset:Number = 0;
		public var href:String;
		public var gradientUnits:String;
		public var gradientTransform:Transform;
		
		//link id
		public var stroke_id:String;
		public var fill_id:String;
		public var filter_id:String;
		public var mask_id:String;
		public var clipPath_id:String;
		public var filter:*;
		public var clip_path:*;
		
		private var _hasStroke:Boolean = false;
		private var _hasFill:Boolean = true;
		private var _hasGradientStroke:Boolean = false;
		private var _hasGradientFill:Boolean = false;
		//private var _hasClipPath:Boolean = false;
		
		private var _xmls:XMLList = new XMLList();
		
		public function Style( xml:XML = null ) {
			if ( xml ) parse( xml );
		}
		
		//Event
		public function parseStyleObj( e:StyleObject ):void 
		{
			if ( e.id != null ) id = e.id;
			
			if ( e.fillColor < 0xffffff ) 
			{
				fill = e.fillColor;
				fill_id = null;
				_hasFill = true;
				_hasGradientFill = false;
			}
			
			if ( e.strokeColor < 0xffffff || e.stroke_width > 0 ) 
			{
				_hasStroke = true;
				if ( e.strokeColor < 0xffffff )
				{
					stroke =  e.strokeColor;
					stroke_id = null;
					_hasGradientStroke = false;
				}
			}
			
			if ( e.fillGradient ) 
			{
				PersistentData.getInstance().addGradient( e.fillGradient );
				fill_id = e.fillGradient.getId();
				_hasGradientFill = true;
			}
			
			if ( e.StrokeGradient ) 
			{
				PersistentData.getInstance().addGradient( e.StrokeGradient );
				stroke_id = e.StrokeGradient.getId();
				_hasGradientStroke = true;
			}
			
			if ( e.noFill ) {
				fill_id = null;
				_hasFill = false;
				_hasGradientFill = false;
			}
			
			if ( e.matrix ) setMatrix( e.matrix );
			blurAmount = e.blur;

			setIfAvailable( "fill_opacity" , e );
			setIfAvailable( "stroke_opacity" , e );
			setIfAvailable( "stroke_width" , e );
			setIfAvailable( "stroke_linecap" , e );
			setIfAvailable( "stroke_linejoin" , e );
			setIfAvailable( "stroke_miterlimit" , e );
			setIfAvailable( "opacity" , e );
			setIfAvailable( "font_size" , e );
			setIfAvailable( "font_family" , e );
			setIfAvailable( "kerning" , e );
			setIfAvailable( "letter_spacing" , e );
			setIfAvailable( "href" , e );
		}
		
		public function getStyleObj():StyleObject
		{
			var o:StyleObject = new StyleObject();
			o.id = id;
			o.fillColor = fill;
			o.strokeColor = stroke;
			o.matrix = getMatrix();
			o.fillGradient = getGradientFill();
			o.StrokeGradient = getGradientStroke();
			o.blur = blurAmount;
			o.noFill = !hasFill;
			o.fill_opacity = fill_opacity;
			o.stroke_opacity = stroke_opacity;
			o.stroke_width = stroke_width;
			o.opacity = opacity;
			o.stroke_miterlimit = stroke_miterlimit;
			o.stroke_linecap = stroke_linecap;
			o.stroke_linejoin = stroke_linejoin;
			o.font_size = font_size;
			o.font_style = font_style;
			o.font_family = font_family;
			o.font_weight = font_weight;
			o.font_stretch = font_stretch;
			o.letter_spacing = letter_spacing;
			o.kerning = kerning;
			o.text_align = text_align;
			o.line_height = line_height;
			o.href = href;
			return o;
		}
		
		//Export ( attributes )
		public function setAttr( ... rest ):void	 // ( node:XML , prop:String ... )
		{
			var node:XML = XML( rest.shift() );
			for each( var prop:String in rest )
			{	
				if ( prop == "href" ) 
				{
					var xlink:Namespace = Constants.xlink;
					if( href ) node.@xlink::href = "#" + href;
					continue;
				}
				
				if ( prop == "clip_path" )
				{
					if ( hasClipPath ) 
						node.@["clip-path"] = StyleUtil.fromURL( clipPath_id );
				}
				
				if (prop == "filter" ) 
				{
					if( hasFilter )
						node.@filter = getNodeAttrByName( prop );
				}
				
				if ( !this[ prop.replace( /-/g, "_" ) ] ) continue;
				var attr:String = getNodeAttrByName( prop );
				if( attr != null )
					node.@[prop] = attr;
			}
		}
		
		//Export ( style attributes )
		public function setStyleAttr( ... rest ):void	 // ( node:XML , prop:String ... )
		{
			var styleStr:String = "";
			var node:XML = XML( rest.shift() );
			for each( var prop:String in rest )
			{
				var propName:String = prop + ":";
				var propValue:String = getNodeAttrByName( prop );
				if( propValue != "" )
					styleStr += propName + propValue + ";";
			}
			node.@style = styleStr;
		}
		
		//Import
		public function parse( xml:XML ):void 
		{
			_xmls += xml;
			var attr:XMLList = xml.@*;
			for each( var item:XML in attr )
				setStyle( item.name() , item.toString() );
		}
		
		public function copy():Style {
			var style:Style = new Style();
			for each ( var xml:XML in _xmls ) style.addStyle( xml );
			return style;
		}
		
		public function addStyle( xml:XML ):void 
		{
			parse( xml );
		}

		public function getGradientFill():IGradient 
		{
			if ( hasGradientFill ) 
				return PersistentData.getInstance().getGradientById( fill_id );
			return null;
		}
		
		public function getGradientStroke():IGradient 
		{
			if ( hasGradientStroke ) 
				return PersistentData.getInstance().getGradientById( stroke_id );
			return null;
		}
		
		public function getFilterSet():FilterSet
		{
			if ( hasFilter ) 
			{
				var fl:FilterSet = PersistentData.getInstance().getFilterById( filter_id );
				if ( fl && fl.hasFilter() ) return fl;
			}
			return new FilterSet();
		}
		
		public function addMatrix( m:Matrix ):void 
		{
			if ( !hasTransform ) 
				transform = new Transform();
			
			transform.addMatrix( m );
		}
		
		public function setMatrix( m:Matrix ):void 
		{
			if ( !hasTransform ) 
				transform = new Transform();
			
			transform.setMatrix( m );
		}
		
		public function getMatrix():Matrix 
		{	
			if ( hasTransform )
				return transform.getMatrix();
			return new Matrix();
		}
		
		public function clearColors():void
		{
			_hasGradientFill = _hasGradientStroke = _hasStroke = false;
		}
		
		public function makeUniqueLinkedItems():Boolean
		{
			if ( hasGradientFill )
			{
				var g:IGradient = PersistentData.getInstance().getGradientById( fill_id ).copy();
				fill_id = g.getId()
				PersistentData.getInstance().addGradient( g );
			}
			if ( hasGradientStroke )
			{
				g = PersistentData.getInstance().getGradientById( stroke_id ).copy();
				stroke_id = g.getId();
				PersistentData.getInstance().addGradient( g );
			}
			return ( hasGradientFill || hasGradientStroke );
		}
		
		//Event private
		private function setIfAvailable( prop:String , e:StyleObject ):void 
		{
			if ( 	( typeof( this[prop] ) == "string" && e[prop] ) || 
					( typeof( this[prop] ) == "number" && !isNaN( e[prop] ) ) 
				) 
				this[prop] = e[prop];
			else
				this[prop] = Boolean( e[prop] )?  e[prop] : this[prop];
		}

		//Import ( style attributes )
		private function parseStyles( st:String ):void 
		{
			var styles:Array = st.split(";");
			for each( var item:String in styles ) {
				var val:Array = item.split(":");
				setStyle( val[0] , val[1] );
			}
		}
		
		private function setStyle( key:String , val:String ):void 
		{
			key = key.replace( /-/g, "_" );
			if ( key.indexOf( "http://") != -1 ) key = StyleUtil.removeNameSpace( key );
			switch( key ) {
				case "stroke" : 
					if ( val.indexOf("url") == -1 ) {
						stroke = StyleUtil.toColor( val ); 	
					} else {
						stroke_id = StyleUtil.toURL( val );
						_hasGradientStroke = true;
					}
					_hasStroke = ( val != "none" );
				break;
				case "fill" : 
					if ( val == "none" ) _hasFill = false;
					else if ( val.indexOf("url") == -1 ) {
						fill = StyleUtil.toColor( val );
						_hasFill = true;
					} else {
						fill_id = StyleUtil.toURL( val );
						_hasGradientFill = true;
					}
				break;
				case "stroke_width": stroke_width = StyleUtil.toNumber( val );
				break;
				case "stroke_linecap": stroke_linecap = ( val == CapsStyle.SQUARE || val == CapsStyle.ROUND ) ? val: CapsStyle.NONE;
				break;
				case "font_family" : font_family = val.replace(/\'/g , "" );
				break;
				case "font_size" : font_size = StyleUtil.toNumber( val );
				break;
				case "font_weight" :
					font_weight = ( val != FontWeight.NORMAL && val != FontWeight.BOLD  ) ? FontWeight.NORMAL : val;
				break;
				case "display" : display = ( val.toString() != "none" );
				break;
				case "transform" : transform = new Transform( val );
				break;
				case "style" : parseStyles( val );
				break;
				case "filter" : filter_id = StyleUtil.toURL( val );
				break;
				case "clip_path" :  
					clipPath_id = StyleUtil.toURL( val );
					//_hasClipPath = true;
				break;
				case "viewBox" : 
					var values:Array = val.split( " " );
					viewBox = new Rectangle( values[0], values[1], values[2], values[3] );
				break;
				case "text_align" : text_align = val;
				break;
				//Gradients
				case "stop_color" : stop_color = StyleUtil.toColor( val );
				break;
				case "href" : href = val.replace(/^#/ , "" );
				break;
				case "gradientTransform" : gradientTransform = new Transform( val );
				break;
				case "gradientUnits" : gradientUnits = val;
				break;
				default: 
					if ( this.hasOwnProperty( key ) ) {
						switch( typeof( this[key] )) {
							case "string" : this[key] = val; 
							break;
							case "number" : this[key] = StyleUtil.toNumber( val );
							break;
						}
					}
				break;
			}
		}
		
		//Export
		private function getNodeAttrByName( prop:String ):String 
		{
			var thisProp:String = prop.replace( /-/g, "_" );
			if ( !this.hasOwnProperty( thisProp ) ) return "";
			switch( prop ) 
			{
				case "transform" :
				case "gradientTransform" :
					return this[thisProp].getSvgAttr();
				break;
				
				case "viewBox" :
					return viewBox.x + " " + viewBox.y + " " + viewBox.width + " " + viewBox.height;
				break;
				
				case "clip-path" :
					return StyleUtil.fromURL( clipPath_id );
				break;
				
				case "fill" :
					if ( hasFill )
						return ( hasGradientFill ) ? StyleUtil.fromURL( fill_id ) : StyleUtil.fromColor( fill );
					else
						return "none";
				break;
				
				case "stroke" :
					if ( hasStroke ) 
						return ( hasGradientStroke ) ? StyleUtil.fromURL( stroke_id ) : StyleUtil.fromColor( stroke );
					else
						return "none";
				break;
					
				case "filter" :
					if ( filter_id != null ) 
						return StyleUtil.fromURL( filter_id );
				break;
				
				case "font-size" :
					return StyleUtil.fromNumber( font_size , "px" );
				break;
				
				default:
					if (( typeof( this[thisProp] ) == "string" && this[thisProp] ) || 
						( typeof( this[thisProp] ) == "number" && !isNaN( this[thisProp] ) ) 
					) 
					return this[thisProp];
				break;
			}
			return "";
		}
		
		public function get blurAmount():Number
		{
			if ( hasFilter && getFilterSet() ) 
			{
				var filters:Vector.<IFilter> = getFilterSet().filters;
				for each( var f:IFilter in filters ) 
					if ( f is GaussianBlur ) return GaussianBlur(f).amount;
			}
			return NaN;
		}
		
		public function set blurAmount( value:Number ):void 
		{
			if ( isNaN( value ) ) return;
			if ( hasFilter ) 
			{
				var filters:Vector.<IFilter> = getFilterSet().filters;
				for each( var f:IFilter in filters ) 
				{
					if ( f is GaussianBlur ) {
						if ( value <= 0 ) 
						{
							getFilterSet().removeFilter( f );
							filter_id = null;
						}
						else 
							GaussianBlur(f).amount = value;
						return;
					}
				}
			}
			
			if ( value <= 0 ) return;
			var fs:FilterSet = new FilterSet();
			fs.newPrimitive();
			var b:GaussianBlur = new GaussianBlur();
			b.amount = value;
			fs.filters.push( b );
			fs.id = filter_id = PersistentData.getInstance().filterId;
			PersistentData.getInstance().addFilter( fs );
		}
		
		public function get hasStroke():Boolean { return _hasStroke && stroke_width != 0 ; }
		public function set hasStroke(value:Boolean):void {_hasStroke = value;}
		public function get hasFill():Boolean { return _hasFill; }
		public function set hasFill(value:Boolean):void {_hasFill = value;}
		public function get hasGradientStroke():Boolean { return _hasGradientStroke; }
		public function get hasGradientFill():Boolean { return _hasGradientFill; }
		public function get hasFilter():Boolean { return ( filter_id != null ); }
		public function get hasTransform():Boolean { return ( transform != null ); }
		public function get hasClipPath():Boolean { return ( clipPath_id != null || clipPath_id == "" ); }
		
	}

}