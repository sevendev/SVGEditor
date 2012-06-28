package svgeditor.parser.filters 
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.filters.DisplacementMapFilter;
	import flash.filters.BitmapFilter;
	import flash.display.BitmapDataChannel;
	import flash.geom.Point;
	import svgeditor.Constants;
	
	public class DisplacementMap implements IFilter
	{
		public static var LOCALNAME:String = "feDisplacementMap";
		
		public var id:String;
		public var scale:Number;
		
		private var xChannelSelector:uint;
		private var yChannelSelector:uint;
		private var sourceGraphic:DisplayObject;
		private var _result:String;
		private var _in:String;
		private var _in2:String;
		
		public function DisplacementMap( xml:XML=null ) 
		{
			if( xml ) parse( xml );
		}
		
		public function parse( xml:XML ):void 
		{
			id = xml.@id;
			scale = Number(  xml.@scale.toString() );
			xChannelSelector = getChannel( xml.@xChannelSelector.toString() );
			yChannelSelector = getChannel( xml.@yChannelSelector.toString() );
		}
		
		public function getFlashFilter():BitmapFilter 
		{
			var bdata:BitmapData = new BitmapData( sourceGraphic.width, sourceGraphic.height, false );
			bdata.draw( sourceGraphic );
			var filter:DisplacementMapFilter = new DisplacementMapFilter( bdata, new Point(), xChannelSelector, yChannelSelector, scale, scale );
			sourceGraphic = null;
			return filter as BitmapFilter;
		}
		
		public function setSourceGraphic( d:DisplayObject ):void 
		{ 
			sourceGraphic = d;
		}
		
		public function getSvg():XML 
		{
			var node:XML = <{DisplacementMap.LOCALNAME} />;
			node.@id = id;
			node.@scale = scale;
			return node;
		}
		
		private function getChannel( str:String ):uint {
			switch( str) {
				case "a" : return BitmapDataChannel.ALPHA;
				break;
				case "b" : return BitmapDataChannel.BLUE;
				break;
				case "g" : return BitmapDataChannel.GREEN;
				break;
				case "r" : return BitmapDataChannel.RED;
				break;
			}
			return BitmapDataChannel.ALPHA;
		}
		
	}

}