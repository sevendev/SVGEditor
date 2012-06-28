package svgeditor.parser 
{
	import svgeditor.parser.model.Data;
	
	public interface IParser 
	{
		function parse(  data:Data ):void;
	}
	
}