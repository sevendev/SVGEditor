package svgeditor 
{
	import flash.geom.Matrix;
	import svgeditor.parser.IGradient;

	public class StyleObject
	{
		
		public var id:String;
		public var fillColor:uint = 0xffffffff;
		public var strokeColor:uint = 0xffffffff;
		public var fill_opacity:Number;
		public var stroke_opacity:Number;
		public var stroke_width:Number;
		public var opacity:Number;
		public var matrix:Matrix;
		public var fillGradient:IGradient;
		public var StrokeGradient:IGradient;
		public var blur:Number;
		public var noFill:Boolean = false;
		
		public var stroke_miterlimit:Number;
		public var stroke_linecap:String;
		public var stroke_linejoin:String;
		
		public var font_size:Number;
		public var font_style:String;
		public var font_family:String;
		public var font_weight:String;
		public var font_stretch:String;
		public var letter_spacing:Number;
		public var kerning:Number;
		public var text_align:String;
		public var line_height:Number;
		
		public var href:String;
		
	}

}