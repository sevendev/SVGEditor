package svgeditor.parser
{
	import flash.display.DisplayObjectContainer ;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.LineScaleMode;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import svgeditor.parser.abstract.AbstractEditable;
	import svgeditor.parser.IParser;
	import svgeditor.parser.IEditable;
	import svgeditor.parser.model.Data;
	import svgeditor.parser.path.EditPoint;
	import svgeditor.event.PathEditEvent;
	import svgeditor.Constants;
	import svgeditor.parser.style.Style;
	import svgeditor.parser.utils.StyleUtil;
	
	public class Image extends AbstractEditable implements IParser, IEditable
	{
		public static var LOCALNAME:String = "image";
		
		private var _x:Number;
		private var _y:Number;
		private var _width:Number;
		private var _height:Number;
		private var _href:String;
		private var _binaryData:String;
		
		private var _loader:Loader;
		private var _imageWidth:Number;
		private var _imageHeight:Number;
		
		private var _data:Data;
		
		private var sizePt:EditPoint;

		public function Image() {
			this.doubleClickEnabled = true;
		}
		
		/* IEditable methods*/
		override public function redraw():void 
		{ 
			if ( style.href == null ) return;
			_x = _y = this.x = this.y = 0;
			this.transform.matrix = new Matrix();
			if ( _href != style.href )
			{
				_href = style.href;
				if ( _loader ) _loader.unload();
				loadImage();
			}else 
			{
				applyStyle( _loader.content ,  false );
			}
		}
		
		override public function edit():void 
		{ 
			createControl();
			sizePt = new EditPoint( _controlLayer, _pathLayer , 1 , _width, _height );
			sizePt.addEventListener( PathEditEvent.PATH_EDIT , onPathEdit );
		}
		
		override public function exit():void 
		{ 
			this.graphics.clear();
			sizePt.exit();
			removeControl();
			if ( !_loader ) this.parent.removeChild( this );
		}
		
		override public function getSvg():XML 
		{
			if ( !_href ) return new XML();
			var node:XML = <{Image.LOCALNAME} />;
			node.@width = _width;
			node.@height = _height;
			
			var xlink:Namespace = Constants.xlink;
			node.@xlink::href = _href;
			
			style.setAttr( node, "id" , "transform", "clip_path" , "filter" );
			return node;
		}
		
		override public function outline( f:Boolean ):void
		{
			_outline = f;
			_loader.visible = !_outline;
			if ( _outline )
				drawOutLine();
			else
				this.graphics.clear();
		}
		
		/* IParser methods*/
		public function parse( data:Data ):void 
		{
			_x = StyleUtil.toNumber( data.currentXml.@x );
			_y = StyleUtil.toNumber( data.currentXml.@y );
			_width = StyleUtil.toNumber( data.currentXml.@width );
			_height = StyleUtil.toNumber( data.currentXml.@height );
			
			style = new Style( data.currentXml );
			_data = data;
			
			var xlink:Namespace = Constants.xlink;
			_href = data.currentXml.@xlink::href;
			if ( _href.indexOf( "data:" ) == 0 ) {
				_binaryData = _href;
				_href = null;
			}
			
			if ( _href != null ) loadImage();
			data.currentCanvas.addChild( this );
		}
		
		override protected function onCreationUpdate( e:Event ):void
		{
			this.x = _x = _creationBox.rect.x;
			this.y = _y = _creationBox.rect.y;
			_width = _creationBox.rect.width;
			_height = _creationBox.rect.height;
			drawEditLine();
		}
		
		protected function drawEditLine():void 
		{
			this.graphics.clear();
			this.graphics.lineStyle( 1, Constants.EDIT_LINE_COLOR, 1 );
			this.graphics.beginFill( 0x666666 , .2 );
			this.graphics.drawRect( 0 , 0 , _width, _height );
			this.graphics.endFill();
		}
		
		protected function drawOutLine():void 
		{
			this.graphics.clear();
			this.graphics.lineStyle( 1, Constants.OUTLINE_COLOR, 1 , false, LineScaleMode.NONE );
			this.graphics.drawRect( 0 , 0 , _width, _height );
		}
		
		override protected function applyStyle( target:DisplayObject , setName:Boolean = true  ):void 
		{
			_imageWidth = _loader.content.width;
			_imageHeight = _loader.content.height;
			_loader.content.x = _x;
			_loader.content.y = _y;
			if ( _imageWidth != _width || _imageHeight != _height ) 
			{
				_loader.content.height = _height;
				_loader.content.width = _width;
			}
			
			super.applyStyle( target , setName );
			
			this.x = _loader.content.x;
			this.y = _loader.content.y;
			_loader.content.x = 0;
			_loader.content.y = 0;
		}
		
		private function onPathEdit( e:PathEditEvent ):void 
		{
			_width = sizePt.ax;
			_height = sizePt.ay;
			if ( _loader )
			{
				_loader.content.width = _width;
				_loader.content.height = _height;
			}
			drawEditLine();
		}

		private function loadImage():void 
		{
			this.name = _style.id;
			if( !_loader )_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener( Event.COMPLETE, loadComplete );
			_loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR , loadFailed );
			_loader.contentLoaderInfo.addEventListener( SecurityErrorEvent.SECURITY_ERROR , loadFailed );
			_loader.load( new URLRequest( _href ) );
			_loader.doubleClickEnabled = true;
			if ( !this.contains( _loader )) 
				addChild( _loader );
		}
		
		private function loadComplete( e:Event ):void 
		{
			applyStyle( _loader.content , false );
		}
		
		private function loadFailed( e:Event ):void
		{}
	}

}