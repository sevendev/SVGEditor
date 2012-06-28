package component.custom.button 
{

	import mx.controls.Button;
	import flash.events.KeyboardEvent;
	
	public class IgnoreKeyButton extends Button
	{
		
		public function IgnoreKeyButton() 
		{
			super();
		}
		
		override protected function keyDownHandler(event:KeyboardEvent):void{}
		
	}

}