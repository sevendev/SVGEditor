package svgeditor.parser.filters 
{
	import flash.filters.ColorMatrixFilter;
	import flash.filters.BitmapFilter;
	import flash.display.DisplayObject;
	import svgeditor.parser.filters.IFilter;
	import svgeditor.parser.utils.GeomUtil;
	
	public class ColorMatrix implements IFilter
	{
		public static var LOCALNAME:String = "feColorMatrix";
		
		public var id:String;
		
		private var _matrix:Array;
		private var _result:String;
		private var _in:String;
		private var _in2:String;
		
		public function ColorMatrix( xml:XML=null) 
		{
			if( xml ) parse( xml );
		}
		
		public function parse( xml:XML ):void 
		{
			id = xml.@id;
			if ( xml.@values ) {
				var values:Array;
				var valuestr:String = xml.@values.toString();
				if ( valuestr.indexOf( " " ) != -1 ) values = valuestr.split(" ");
				else if ( valuestr.indexOf( "," ) != -1 ) values = valuestr.split(",");
				_matrix = values;
			}
			if ( xml.@type ) {
				var type:String = xml.@type.toString();
				_matrix = getMatrixByType( type, xml.@values.toString() );
			}
		}
		
		public function getFlashFilter():BitmapFilter 
		{
			return new ColorMatrixFilter( _matrix ) as BitmapFilter;
		}
		
		public function setSourceGraphic( d:DisplayObject ):void { }
		
		public function getSvg():XML 
		{
			var node:XML = <{ColorMatrix.LOCALNAME} />;
			node.@id = id;
			node.@values = _matrix.a + "," + _matrix.b + "," + _matrix.c + "," + _matrix.d + "," + _matrix.tx + "," + _matrix.ty;
			return node;
		}
		
		private function getMatrixByType( type:String, values:String ):Array 
		{
			switch( type ) {
				case "luminanceToAlpha" : return [	0,	0,	0,	0,	0, 
													0,	0,	0,	0,	0, 
													0,	0,	0,	0,	0,
													0.2125, 0.7154, 0.0721, 0,0];
				break;
				case "saturate" :
					var v:Number  = Number( values );
					var i:Number= 1 - v;
					var ir:Number= i * 0.3086;
					var ig:Number= i * 0.6094;
					var ib:Number= i * 0.0820;
					return [ir + v,ig,ib,0,0,ir,ig + v,ib,0,0,ir,ig,ib + v,0,0,0,0,0,1,0];
				break;
				case "hueRotate" :
					var angle:Number = GeomUtil.degree2radian( Number( values ));
					var c:Number=Math.cos(angle);
					var s:Number=Math.sin(angle);
					var f1:Number=0.213;
					var f2:Number=0.715;
					var f3:Number=0.072;
					return [(f1 + (c * (1 - f1))) + (s * ( -f1)), (f2 + (c * ( -f2))) + (s * ( -f2)), (f3 + (c * ( -f3))) + (s * (1 - f3)), 0, 0,
							(f1 + (c * ( -f1))) + (s * 0.143), (f2 + (c * (1 - f2))) + (s * 0.14), (f3 + (c * ( -f3))) + (s * -0.283), 0, 0, 
							(f1 + (c * ( -f1))) + (s * ( -(1 - f1))), (f2 + (c * ( -f2))) + (s * f2), (f3 + (c * (1 - f3))) + (s * f3), 0, 0, 
							0, 0, 0, 1, 0, 0, 0, 0, 0, 1];
				break;
				default :
					return values.replace(/\s$/ , "" ).split( " " );
				break;
			}
			return [];
		}
	}

}