package svgeditor.parser.filters 
{
	import flash.display.DisplayObject;
	import flash.filters.BitmapFilter;
	public interface IFilter 
	{
		function parse( xml:XML ):void;
		function getFlashFilter():BitmapFilter;
		function setSourceGraphic( d:DisplayObject ):void;
		function getSvg():XML;
	}
	
}