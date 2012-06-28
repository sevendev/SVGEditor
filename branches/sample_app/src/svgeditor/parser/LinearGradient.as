package svgeditor.parser 
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	import svgeditor.Constants;
	import svgeditor.parser.IParser;
	import svgeditor.parser.IGradient;
	import svgeditor.parser.RadialGradient;
	import svgeditor.parser.style.Style;
	import svgeditor.parser.style.Transform;
	import svgeditor.parser.utils.StyleUtil;
	import svgeditor.parser.utils.GeomUtil;
	import svgeditor.parser.model.Data;
	import svgeditor.parser.model.PersistentData;
	
	public class LinearGradient implements IParser , IGradient
	{
		public static var LOCALNAME:String = "linearGradient";
		
		public var id:String;
		
		protected static const GRADIENT_UNIT:String = "userSpaceOnUse";
		
		protected var _type:String = GradientType.LINEAR;
		protected var _colors:Array = [];
		protected var _alphas:Array = [];
		protected var _ratios:Array = [];
		protected var _matrix:Matrix = new Matrix();
		protected var _method:String = SpreadMethod.PAD;
		protected var _style:Style;
		
		private var _x1:Number;
		private var _x2:Number;
		private var _y1:Number;
		private var _y2:Number;
		
		protected var pts:Vector.<Point>;
		
		public function LinearGradient() { }
		
		public function setId( val:String ):void { id = _style.id = val;  }
		public function getId():String { return id; }
		
		public function newPrimitive():void 
		{
			_style = new Style();
			id = _style.id =  PersistentData.getInstance().gradientId;
			_style.gradientUnits = GRADIENT_UNIT;
			_colors = [0x000000, 0xffffff ];
			_alphas = [ 1 , 1 ];
			_ratios = [ 0 , 255 ];
		}
		
		public function copy():IGradient
		{
			var g:IGradient = ( type == GradientType.LINEAR ) ? new LinearGradient() :  new RadialGradient();
			return duplicateParams( g );
		}
		
		public function convert():IGradient 
		{
			var g:IGradient = ( type == GradientType.LINEAR )  ? new RadialGradient() : new LinearGradient();
			return duplicateParams( g );
		}
		
		public function getSvg():XML 
		{
			var node:XML =<{LinearGradient.LOCALNAME} />;
			if ( _x1 && _x2 && _y1 && _y2 ) 
			{
				node.@x1 = _x1;
				node.@x2 = _x2;
				node.@y1 = _y1;
				node.@y2 = _y2;
			}
			setStopNode( node );
			_style.setAttr( node, "id" , "gradientTransform" , "gradientUnits" );
			return node;
		}
		
		public function parse( data:Data ):void 
		{
			_style = new Style( data.currentXml );
			this.id = _style.id;
			
			_x1 = getValue( data.currentXml.@x1 );
			_x2 = getValue( data.currentXml.@x2 );
			_y1 = getValue( data.currentXml.@y1 );
			_y2 = getValue( data.currentXml.@y2 );
			
			createGradient();
			
			var svg:Namespace = Constants.svg;
			var stops:XMLList = data.currentXml.svg::stop;
			for each( var stop:XML in stops )
				parseStop( stop );
				
			data.addGradient( this );
		}
		
		public function createGradient():void 
		{
			pts = new Vector.<Point>();
			pts.push( new Point( _x1, _y1 ) );
			pts.push( new Point( _x2, _y2 ) );
			
			var distance:Number = GeomUtil.getDistance( pts[0], pts[1] );
			var boxheight:Number = Math.max( Math.abs(pts[0].x - pts[1].x ), Math.abs(pts[0].y - pts[1].y ));
			var angle:Number = GeomUtil.getAngle(pts[0], pts[1]);
			var topleft:Point = new Point( pts[0].x , pts[0].y  );

			_matrix.createGradientBox( distance , boxheight , 0, topleft.x, topleft.y );
			_matrix.translate( - topleft.x , - topleft.y  );
			_matrix.rotate( angle );
			_matrix.translate( topleft.x, topleft.y  );
			
			if ( _style.gradientTransform ) _matrix.concat( _style.gradientTransform.getMatrix() );
		}

		protected function parseStop( stop:XML ):void 
		{
			var style:Style = new Style( stop );
			_colors.push( style.stop_color );
			_alphas.push( style.stop_opacity );
			_ratios.push( style.offset * 255 );
		}
		
		protected function getValue( val:String ):Number {
			return StyleUtil.toNumber( val );
		}
		
		protected function setStopNode( node:XML ):void 
		{
			var length:int = _colors.length;
			for ( var i:int = 0; i < length ; i++ ) 
			{
				var stop:XML = <stop />;
				var color:String = StyleUtil.fromColor( _colors[i] );
				var opacity:Number = _alphas[i];
				var offset:Number = _ratios[i] / 255;
				stop.@style = "stop-color:" + color + ";stop-opacity:" + opacity;
				stop.@offset = offset;
				node.appendChild( stop );
			}
		}
		
		protected function duplicateParams( g:IGradient ):IGradient
		{
			g.newPrimitive();
			g.colors = colors;
			g.alphas = alphas;
			g.ratios = ratios;
			g.matrix = matrix;
			return g;
		}
		
		//Getter Setter
		public function get type():String { return _type; }
		public function get colors():Array { return _colors.concat(); }
		public function get alphas():Array { return _alphas.concat(); }
		public function get ratios():Array { return _ratios.concat(); }
		public function get matrix():Matrix { return _matrix.clone(); }
		public function get method():String { return _method; }
		public function get linked():String { return _style.href; }
		public function get transform():Transform { return _style.gradientTransform; }
		public function get unit():String { return _style.gradientUnits; }
		
		public function set colors(value:Array):void 
		{
			_colors = value;
		}
		public function set alphas(value:Array):void 
		{
			_alphas = value;
		}
		public function set ratios(value:Array):void 
		{
			_ratios = value;
		}
		
		public function set matrix(value:Matrix):void 
		{
			_matrix = value;
		}
		
		public function get x1():Number { return _x1; }
		public function set x1(value:Number):void 
		{
			_x1 = value;
		}
		
		public function get x2():Number { return _x2; }
		public function set x2(value:Number):void 
		{
			_x2 = value;
		}
		
		public function get y1():Number { return _y1; }
		public function set y1(value:Number):void 
		{
			_y1 = value;
		}
		
		public function get y2():Number { return _y2; }
		public function set y2(value:Number):void 
		{
			_y2 = value;
		}
	}
}