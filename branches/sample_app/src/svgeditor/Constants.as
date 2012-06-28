package svgeditor 
{

	import flash.filters.BitmapFilterQuality;
	import flash.text.engine.FontLookup;
	import flash.text.engine.FontWeight;
	import flash.display.LineScaleMode;
	
	public class Constants
	{
		//namespaces
		public static const svg:Namespace = new Namespace( "svg", "http://www.w3.org/2000/svg" );
		public static const xlink:Namespace = new Namespace( "xlink", "http://www.w3.org/1999/xlink" );
		
		public static const SVG_VERSION:Number = 1.2;
		
		public static const EDIT_MODE:int = 2;
		public static const SELECT_MODE:int = 1;
		public static const IDLE_MODE:int = 0;
		
		//Parser Default Settings
		public static const FONT_FAMILY:String = "_sans";
		public static const FONT_SIZE:Number = 30;
		public static const FONT_WEIGHT:String = FontWeight.NORMAL;
		public static const FONT_LOOKUP:String = FontLookup.DEVICE;
		public static const FILL_COLOR:uint = 0x000000;
		public static const STROKE_COLOR:uint = 0x000000;
		public static const LINE_PIXEL_HINTING:Boolean = false;
		public static const LINE_SCALE_MODE:String = LineScaleMode.NORMAL;
		public static const BLUR_QUALITY:int = BitmapFilterQuality.HIGH;
		public static const BEZIER_DETAIL:uint = 20;
		
		//Editing
		public static const EDIT_LINE_COLOR:uint = 0x92c5c1;
		public static const EDIT_LINE_SELECTED_COLOR:uint = 0x4b88d1;
		public static const BOUNDING_BOX_COLOR:uint = 0xd1535c;
		public static const GRADIENT_BOX_COLOR:uint = 0x5BD287;
		public static const SELECTION_BOX_COLOR:uint = 0xcccccc;
		public static const EDIT_LINE_CLICKABLE_WIDTH:Number = 8;
		
		public static const EDIT_POINT_SIZE:Number = 5;
		public static const SCALE_ICON_SIZE:Number = 15;
		public static const ROTATE_ICON_SIZE:Number = 7;
		
		//Creation
		public static const DEFAULT_LINE_WIDTH:Number = 1;
		public static const MINIMUM_ITEM_SIZE:Number = 2;
		public static const AUTO_CREATION_ITEM_SIZE:Number = 100;
		public static const DEFAULT_CONTROL_DISTANCE:Number = 20;
		public static const DRAWING_LINE_COLOR:uint = 0xcccccc;
		public static const DRAWING_POINT_MIN_DISTANCE:Number = 5;
		public static const OUTLINE_COLOR:uint = 0x333333;
		public static const AUTO_CREATION_DELAY:int = 20;
		
		//History
		public static const UNDO_LIMIT:int = 10;

	}

}