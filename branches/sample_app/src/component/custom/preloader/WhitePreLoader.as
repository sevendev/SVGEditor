package component.custom.preloader 
{
	import flash.display.*;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.events.*;
	import mx.events.*;
	import mx.preloaders.Preloader;
	import mx.preloaders.DownloadProgressBar;

	public class WhitePreLoader extends DownloadProgressBar {
		
		private var _mask:Sprite;
		
		public function WhitePreLoader() {
			var bar:Sprite = new Sprite();
			var mat:Matrix = new Matrix();
			mat.createGradientBox( 5, 5, Math.PI/180 * 270, 0, 0 );
			bar.graphics.beginGradientFill( GradientType.LINEAR , [ 0xbbbbbb , 0xeaeaea ] , [1, 1], [0, 255] , mat, SpreadMethod.PAD );
			bar.graphics.drawRect( 0, 0, 215, 5 );
			bar.graphics.endFill();
			_mask = new Sprite();
			_mask.graphics.beginFill( 0xffffff, 1 );
			_mask.graphics.drawRoundRect( 0 , 0 , 210 , 4 , 4, 4 );
			_mask.graphics.endFill();
			var panel:Sprite = new Sprite();
			panel.graphics.beginFill( 0xffffff , 1 );
			panel.graphics.drawRoundRect( 0, 0, 220 , 15, 15 , 15 );
			panel.graphics.endFill();
			bar.x = panel.width / 2 - bar.width / 2;
			bar.y = panel.height / 2 - bar.height / 2;
			_mask.x = bar.x + bar.width / 2 - _mask.width / 2 ;
			_mask.y = bar.y + bar.height / 2 - _mask.height / 2 ;
			panel.addChild( _mask );
			panel.addChild( bar );
			bar.mask = _mask;
			this.addChild( panel );
			panel.filters = [ new DropShadowFilter( 2 ,45,0x000000, .5 , 5 , 4  , .5) ];
			_mask.scaleX = 0;
			super();
		}
		override public function set preloader( Preloader:Sprite ):void {
			Preloader.addEventListener( ProgressEvent.PROGRESS , SWFDownloadProgress );
			Preloader.addEventListener( FlexEvent.INIT_COMPLETE , FlexInitComplete );

			onResizeHandler(null);
			this.stage.addEventListener("resize",onResizeHandler);
		}
		private function SWFDownloadProgress( event:ProgressEvent ):void {
			var Per:Number = event.bytesLoaded/event.bytesTotal;
			var perLoaded:Number = Math.round(Per*100);
			_mask.scaleX = Per;
		}
		private function SWFDownloadComplete( event:Event ):void {
		}
		private function FlexInitProgress( event:Event ):void {
		}
		private function FlexInitComplete( event:Event ):void {
			closeScreen();
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		public function closeScreen():void {
			this.parent.removeChild(this);
		}
		public function onResizeHandler(event:Event):void {
			if (this.stage != null) {
				this.x = this.stage.stageWidth/2 - this.width/2;
				this.y = this.stage.stageHeight/2 - this.height/2;
			}
		}
	}
}