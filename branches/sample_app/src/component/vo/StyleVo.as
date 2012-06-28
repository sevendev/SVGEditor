package component.vo 
{
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import svgeditor.parser.IGradient;
	
	[Bindable]
	public class StyleVo
	{
		public var itemType:String = "Path";
		
		public var fillColorValue:uint;
		public var fillAlphaValue:Number;
		public var strokeColorValue:uint;
		public var strokeAlphaValue:Number;
		public var strokeWidthValue:Number;
		
		public var fillGradation:IGradient;
		public var strokeGradation:IGradient;
		
		public var strokeMiterlimitValue:Number;
		public var strokeLinecap:String;
		public var strokeLineJoin:String;
		
		public var textColorValue:uint;
		public var fontSizeValue:Number;
		public var letterSpacingValue:Number;

		public var alphaValue:Number = 1;
		public var blurValue:Number = 0;
		
		public var href:String;
		
		public static const CAP_STYLES:Array = [ CapsStyle.NONE , CapsStyle.ROUND , CapsStyle.SQUARE ] ;
		public static const JOINT_STYLES:Array = [ JointStyle.BEVEL , JointStyle.MITER , JointStyle.ROUND ] ;
		
	}

}