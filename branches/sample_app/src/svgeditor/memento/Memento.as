package svgeditor.memento 
{
	import svgeditor.parser.IEditable;
	public class Memento
	{
		
		private var _instance:IEditable;
		private var _xml:XML;
		
		public function Memento( instance:IEditable , xml:XML ) 
		{
			_instance = instance;
			_xml = xml;
		}
		
		public function validate( m:Memento ):Boolean
		{
			return !( m.xml == _xml );
		}

		public function get instance():IEditable { return _instance; }
		public function get xml():XML { return _xml; }
		
		
	}

}