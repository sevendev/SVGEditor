package svgeditor.ui 
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.LineScaleMode;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import svgeditor.Constants;
	import svgeditor.parser.utils.GeomUtil;

	public class CreationBox extends Sprite
	{
		protected var _canvas:DisplayObjectContainer;
		protected var _virtual:DisplayObjectContainer;
		protected var _rect:Rectangle;
		
		public function CreationBox( canvas:DisplayObjectContainer ,virtual:DisplayObjectContainer ) 
		{ 
			this._canvas = canvas;
			this._virtual = virtual;
			_canvas.addChild( this );
			this.stage.addEventListener( MouseEvent.MOUSE_DOWN, init );
			_rect = new Rectangle();
		}
		
		public function exit():void 
		{
			this.stage.removeEventListener( MouseEvent.MOUSE_DOWN, init );
			this.stage.removeEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
			this.stage.removeEventListener( MouseEvent.MOUSE_UP, release );
			_canvas.removeChild( this );
			_canvas = null;
			_virtual = null;
		}
		
		protected function init( e:MouseEvent ):void 
		{
			//_rect = new Rectangle( _canvas.mouseX , _canvas.mouseY , Constants.MINIMUM_ITEM_SIZE , Constants.MINIMUM_ITEM_SIZE  );
			_rect = new Rectangle( _canvas.mouseX , _canvas.mouseY , 0 , 0 );
			this.removeEventListener( Event.ADDED_TO_STAGE , init );
			this.stage.addEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
			this.stage.addEventListener( MouseEvent.MOUSE_UP, release );
		}
		
		protected function onMouseMove( e:MouseEvent ):void 
		{
			var width:Number =  _canvas.mouseX - _rect.x;
			var height:Number = _canvas.mouseY - _rect.y;

			if ( e.shiftKey ) //uniform scaling
				height = width;
				
			_rect.size = new Point( width , height );
			drawRectangle();
			dispatchEvent( new Event( Event.CHANGE ) );
		}
		
		protected function release( e:MouseEvent ):void 
		{
			if ( _rect.width >= Constants.MINIMUM_ITEM_SIZE || _rect.height >= Constants.MINIMUM_ITEM_SIZE )
			{
				creationComplete();
				return;
			}
			
			var timer:Timer = new Timer( Constants.AUTO_CREATION_DELAY  , 1 );
			timer.addEventListener( TimerEvent.TIMER_COMPLETE, function( e:TimerEvent):void
			{
				timer.removeEventListener(  TimerEvent.TIMER_COMPLETE, arguments.callee );
				_rect.width = _rect.height = Constants.AUTO_CREATION_ITEM_SIZE ;
				creationComplete();
			} );
			timer.start();
		}
		
		protected function creationComplete():void 
		{
			dispatchEvent( new Event( Event.CHANGE ) );
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		protected function drawRectangle():void 
		{
			this.graphics.clear();
			this.graphics.lineStyle( 1, Constants.EDIT_LINE_COLOR, .5 , false, LineScaleMode.NONE );
			this.graphics.drawRect( _rect.x, _rect.y, _rect.width , _rect.height );
			this.graphics.endFill();
		}
		
		public function get rect():Rectangle 
		{ 
			var topLeft:Point = GeomUtil.getActualPosition( this.parent , _virtual , _rect.x , _rect.y );
			var size:Point = GeomUtil.getActualPosition( this.parent , _virtual , _rect.bottomRight.x , _rect.bottomRight.y );
			return new Rectangle( topLeft.x, topLeft.y , size.x - topLeft.x , size.y - topLeft.y ); 
		}
	}

}