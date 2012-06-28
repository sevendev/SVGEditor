package svgeditor.parser.filters 
{
	import flash.filters.BlurFilter;
	import flash.filters.BitmapFilter;
	import flash.display.DisplayObject;
	import svgeditor.Constants;
	
	public class GaussianBlur implements IFilter
	{
		public static var LOCALNAME:String = "feGaussianBlur";
		
		public var id:String;
		public var amount:Number;
		private var quality:int = Constants.BLUR_QUALITY;
		private var _result:String;
		private var _in:String;
		private var _in2:String;
		
		public function GaussianBlur( xml:XML=null ) 
		{
			if( xml ) parse( xml );
		}
		
		public function parse( xml:XML ):void 
		{
			id = xml.@id;
			amount = Number ( xml.@stdDeviation ) * 2.55;
		}
		
		public function getFlashFilter():BitmapFilter 
		{
			return new BlurFilter( amount , amount , quality ) as BitmapFilter;
		}
		
		public function setSourceGraphic( d:DisplayObject ):void { }
		
		public function getSvg():XML 
		{
			var node:XML = <{GaussianBlur.LOCALNAME} />;
			node.@id = id;
			node.@stdDeviation = amount / 2.55;
			return node;
		}

		
	}

}