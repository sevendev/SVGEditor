package svgeditor.memento 
{

	import svgeditor.Constants;
	public class Caretaker
	{
		
		protected var _states:Vector.<Memento>;
		protected var _currentIndex:int = 0;
		
		public function Caretaker() 
		{
			reset();
		}
		
		public function addMemento( m:Memento ):void
		{
			if ( lastIndex >= Constants.UNDO_LIMIT ) reset();
			if ( lastIndex && ! _states[lastIndex - 1].validate( m ) ) return;
			_states.push( m );
				
			_currentIndex = lastIndex;
		}
		
		public function getMemento( index:int ):Memento
		{
			if ( index <= 0 || index >= lastIndex ) return null;
			_currentIndex = index;
			return _states[ index ];
		}
		
		public function reset():void
		{
			_states = new Vector.<Memento>();
			_currentIndex = 0;
		}
		
		public function get lastIndex():int 
		{
			return _states.length;
		}
		
		public function get prevIndex():int 
		{ 
			return ( 0 < _currentIndex ) ? _currentIndex - 1 : _currentIndex; 
		}
		
		public function get nextIndex():int 
		{ 
			return ( lastIndex - 1 > _currentIndex ) ? _currentIndex + 1 : _currentIndex; 
		}
		
		public function get currentIndex():int { return _currentIndex; }
		
		public function get hasItems():Boolean { return ( _states.length > 0 ); }
		
	}

}