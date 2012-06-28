package svgeditor.parser 
{
	import flash.geom.Matrix;
	import svgeditor.parser.style.Transform;

	public interface IGradient 
	{
		function getId():String;
		function setId( val:String ):void;
		function newPrimitive():void ;
		function copy():IGradient;
		function convert():IGradient ;
		function getSvg():XML ;
		function set colors(value:Array):void ;
		function set alphas(value:Array):void ;
		function set ratios(value:Array):void ;
		function set matrix(value:Matrix):void;
		function get type():String;
		function get colors():Array;
		function get alphas():Array;
		function get ratios():Array;
		function get matrix():Matrix;
		function get method():String;
		function get linked():String;
		function get transform():Transform;
		function get unit():String;
	}
	
}