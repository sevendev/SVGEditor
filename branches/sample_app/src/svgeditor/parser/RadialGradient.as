package svgeditor.parser 
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	import svgeditor.Constants;
	import svgeditor.parser.style.Transform;
	import svgeditor.parser.IParser;
	import svgeditor.parser.IGradient;
	import svgeditor.parser.model.Data;
	import svgeditor.parser.style.Style;
	import svgeditor.parser.utils.GeomUtil;
	import svgeditor.parser.model.PersistentData;
	
	public class RadialGradient extends LinearGradient implements IParser , IGradient
	{
		public static var LOCALNAME:String = "radialGradient";
		
		protected var _cx:Number;
		protected var _cy:Number;
		protected var _r:Number;
		protected var _fx:Number;
		protected var _fy:Number;

		public function RadialGradient() {
			_type = GradientType.RADIAL;
		}
		
		override public function newPrimitive():void 
		{
			_style = new Style();
			id = _style.id = PersistentData.getInstance().gradientId;
			_style.gradientUnits = GRADIENT_UNIT;
			_colors = [0x000000, 0xffffff ];
			_alphas = [ 1 , 1 ];
			_ratios = [ 0 , 255 ];
		}
		
		override public function getSvg():XML 
		{
			var node:XML =<{RadialGradient.LOCALNAME} />;
			if ( _cx && _cy && _fx && _fy && _r ) 
			{
				node.@cx = _cx;
				node.@cy = _cy;
				node.@r  = _r;
				node.@fx = _fx;
				node.@fy = _fy;
			}
			setStopNode( node );
			_style.setAttr( node, "id" , "gradientTransform" , "gradientUnits" );
			return node;
		}
		
		override public function parse( data:Data ):void 
		{
			_style = new Style( data.currentXml );
			this.id = _style.id;
			
			_cx = getValue( data.currentXml.@cx );
			_cy = getValue( data.currentXml.@cy );
			_r =  getValue( data.currentXml.@r  );
			_fx = data.currentXml.@fx ? getValue( data.currentXml.@fx ) : _cx ;
			_fy = data.currentXml.@fy ? getValue( data.currentXml.@fy ) : _cy ;

			createGradient();
			
			var svg:Namespace = Constants.svg;
			var stops:XMLList = data.currentXml.svg::stop;
			for each( var stop:XML in stops ) 
				parseStop( stop );
			
			data.addGradient( this );
		}
		
		override public function createGradient():void 
		{
			_matrix.createGradientBox( 	_r * 2  , _r * 2  , 
										GeomUtil.getAngle( new Point(_cx, _cy ) , new Point(_fx, _fy ) ) , 
										_cx - _r , _cy - _r  );
			if ( _style.gradientTransform ) _matrix.concat( _style.gradientTransform.getMatrix() );
		}
		
		//Getter Setter
		public function get cx():Number { return _cx; }
		public function set cx(value:Number):void 
		{
			_cx = value;
		}
		
		public function get cy():Number { return _cy; }
		public function set cy(value:Number):void 
		{
			_cy = value;
		}
		
		public function get r():Number { return _r; }
		public function set r(value:Number):void 
		{
			_r = value;
		}
		
		public function get fx():Number { return _fx; }
		public function set fx(value:Number):void 
		{
			_fx = value;
		}
		
		public function get fy():Number { return _fy; }
		public function set fy(value:Number):void 
		{
			_fy = value;
		}
		
	}

}