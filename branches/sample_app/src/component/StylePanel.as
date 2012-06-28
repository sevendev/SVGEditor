package component 
{
	import mx.core.IFlexDisplayObject;
	import svgeditor.StyleObject;
	
	public interface StylePanel extends IFlexDisplayObject
	{
		function setItemStyle( o:StyleObject ):void ;
		function setItemType( t:String ):void ;
	}
	
}