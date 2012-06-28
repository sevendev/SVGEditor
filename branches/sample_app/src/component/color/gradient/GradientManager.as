package component.color.gradient 
{
	import flash.utils.Dictionary;
	public class GradientManager extends Dictionary
	{
		
		public function GradientManager() {
			super();
		}
		
		public function getNextId(): uint 
		{
			var id:uint = 0;
			for each( var gr:GradientVo in this )
				id = Math.max( gr.id );
			return id;	
		}
		
		public function getColors():Array 
		{
			var g:Array = getSortedArray();
			var a:Array = [];
			for each( var gr:GradientVo in g )
				a.push( gr.color );
			return a;
		}
		
		public function getAlphas():Array 
		{
			var g:Array = getSortedArray();
			var a:Array = [];
			for each( var gr:GradientVo in g )
				a.push( gr.alpha );
			return a;
		}
		
		public function getRatios():Array 
		{
			var g:Array = getSortedArray();
			var a:Array = [];
			for each( var gr:GradientVo in g )
				a.push( gr.offset );
			return a;
		}
		
		private function getSortedArray():Array 
		{
			var a:Array = [];
			for each( var gr:GradientVo in this )
				a.push( gr);
			a.sortOn( "offset" , Array.NUMERIC );
			return a;
		}
		
	}

}