package svgeditor.parser.style 
{
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import svgeditor.parser.utils.GeomUtil;
	
	public class Transform
	{
		
		public var type:String;
		private var vals:Array;
		private var _matrix:Matrix;
		
		public function Transform( str:String = null ) 
		{
			_matrix = new Matrix();
			if( str != null ) parse( str );
		}
		
		public function parse( str:String ):void 
		{
			type = str.replace( /(.+)\(.+\)/, "$1" );
			if( str.indexOf(",") != -1 ) vals = str.replace( /.+\((.+)\)/ , "$1" ).split(",");
			else if ( str.indexOf(" ") != -1 ) vals = str.replace( /.+\((.+)\)/ , "$1" ).split(" ");
			else  vals = [ Number( str.replace( /.+\((.+)\)/ , "$1" ) ) ];
			switch( type ) {
				case "matrix" :
					_matrix = new Matrix( vals[0], vals[1], vals[2], vals[3], vals[4], vals[5] );
				break;
				case "translate" :
					_matrix.translate( vals[0], vals[1] );
				break;
				case "scale" :
					if ( vals.length < 2 ) vals.push( vals[0] );
					_matrix.scale( vals[0], vals[1] );
				break;
				case "rotate":
					_matrix.rotate( GeomUtil.degree2radian( vals[0] ) );
				break;
				case "skewX":
					_matrix.c = Math.tan( GeomUtil.degree2radian( vals[0] ) );
				break;
				case "skewY":
					_matrix.b = Math.tan( GeomUtil.degree2radian( vals[0] ) );
				break;
			}
		}
		
		public function getSvgAttr():String 
		{
			return "matrix(" + _matrix.a + "," + _matrix.b + "," + _matrix.c + "," + _matrix.d + "," + _matrix.tx + "," + _matrix.ty +")";
		}
		
		public function addMatrix( m:Matrix ):void 
		{
			_matrix.concat( m.clone() );
		}
		
		public function setMatrix( m:Matrix ):void 
		{
			_matrix =  m.clone();
		}
		
		public function getMatrix():Matrix 
		{
			return _matrix.clone();
		}
	}

}