package component.custom.preloader
{
	import mx.core.mx_internal;
	import mx.controls.ProgressBar;
	
	public class CenterProgressBar extends ProgressBar
	{
		
		
		public function CenterProgressBar() {
		}
		
		override public function validateDisplayList():void {
			super.validateDisplayList();
			setCenter();
		}
		
		public function setCenter():void {
			if( mx_internal::_labelField )
				mx_internal::_labelField.x = this.width / 2 - mx_internal::_labelField.width / 2 ;
        }
		
		
		
	}
	
}