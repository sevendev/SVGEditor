package svgeditor.parser 
{
	import flash.display.*;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.engine.*;
	import flash.text.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import svgeditor.Constants;
	import svgeditor.parser.abstract.AbstractEditable;
	import svgeditor.parser.model.PersistentData;
	import svgeditor.parser.utils.StyleUtil;
	import svgeditor.event.ItemEditEvent;
	import svgeditor.parser.model.Data;
	import svgeditor.parser.style.Style;
	import svgeditor.parser.utils.GeomUtil;
	

	public class Text extends AbstractEditable implements IParser
	{
		public static var LOCALNAME:String = "text";
		
		private var textElements:Vector.<ContentElement>;
		private var _data:Data;
		private var _x:Number = 0;
		private var _y:Number = 0;
		private var _localX:Number = 0;
		private var _localY:Number = 0;
		private var _xml:XML;
		
		private var _block:TextBlock;
		private var _textLines:Vector.<TextLine> = new Vector.<TextLine>();
		private var groupElement:GroupElement;
		
		private var inputTf:TextField
		
		private var creationTimer:Timer;
		
		public function Text() { }
		
		/* IEditable methods*/
		override public function redraw():void 
		{
			for each ( var tl:TextLine in _textLines ) 
				this.removeChild( tl );
			_textLines = new Vector.<TextLine>();
			textElements = new Vector.<ContentElement>();
			var span:XML = <text>{_block.content.rawText}</text>;
			parseSpan( span , style );
			drawTextElements();
			this.transform.matrix = new Matrix();
			applyStyle( this );
		}
		
		override public function edit():void 
		{
			createControl();
			
			var rawText:String = "";
			for each( var tl:TextLine in _textLines )
			{
				var t:String = tl.textBlock.content.rawText;
				rawText += ( t.replace( /\s/g , "" ) == "" ) ? "" : t;
			}
			
			inputTf = new TextField();
			var f:TextFormat = new TextFormat( style.font_family, style.font_size, style.fill );
			f.kerning = style.kerning;
			f.letterSpacing = style.letter_spacing;
			inputTf.defaultTextFormat = f;
			inputTf.text = rawText;
			inputTf.border = true;
			inputTf.borderColor = Constants.EDIT_LINE_COLOR;
			inputTf.background = true;
			inputTf.type = TextFieldType.INPUT;
			inputTf.selectable = true;
			var pt:Point = getRegistrationPoint();
			pt = GeomUtil.getVirtualPosition( _controlLayer , this.parent , pt.x, pt.y );
			inputTf.x = pt.x;
			inputTf.y = pt.y;
			inputTf.width = inputTf.textWidth;
			inputTf.height = inputTf.textHeight;
			inputTf.addEventListener( Event.CHANGE , onTextInput );
			_controlLayer.addChild( inputTf );
		}
		
		override public function exit():void
		{
			inputTf.removeEventListener( Event.CHANGE , onTextInput );
			removeControl();
		}
		
		override public function getSvg():XML 
		{
			var node:XML = <{Text.LOCALNAME} />;
			node.@x = _textLines[0].x;
			node.@y = _textLines[0].y;
			
			for each ( var tl:TextLine in _textLines ) 
			{
				var span:XML = <tspan>{ tl.textBlock.content.rawText }</tspan>;
				span.@x = tl.x;
				span.@y = tl.y;
				node.appendChild( span );
				setStyleAttr( tl.userData.style, span );
			}

			style.setAttr( node, "id" , "transform", "clip_path" , "filter");
			setStyleAttr( style, node );
			return node;
		}
		
		override public function newPrimitive():void 
		{ 
			this.stage.addEventListener( MouseEvent.MOUSE_DOWN, createText );
		};
		
		override public function cancelCreation():void
		{
			creationTimer.stop();
			dispatchEvent( new ItemEditEvent( ItemEditEvent.CREATION_CANCELED ) );
			this.parent.removeChild( this );
		}
		
		/* IParser methods*/
		public function parse( data:Data ):void 
		{
			_data = data;
			textElements = new Vector.<ContentElement>();
			this.name = data.currentXml.@id.toString();
			style = new Style( data.currentXml );
			_xml = data.currentXml;
			parseSpan( _xml , style );
			drawTextElements();
			data.currentCanvas.addChild( this );
			applyStyle( this  );
			_data = null;
		}
		
		/* IEditable private methods*/
		private function onTextInput( e:Event ):void 
		{
			_block = new TextBlock( new TextElement( inputTf.text , createFormat( style ) ) );
			redraw();
		}
		
		private function createText( e:MouseEvent ):void 
		{
			this.stage.removeEventListener( MouseEvent.MOUSE_DOWN, createText );
			creationTimer = new Timer( Constants.AUTO_CREATION_DELAY , 1);
			creationTimer.addEventListener( TimerEvent.TIMER_COMPLETE, function( e:TimerEvent ):void
			{
				creationTimer.removeEventListener(  TimerEvent.TIMER_COMPLETE, arguments.callee );
				doCreateText();
			} );
			creationTimer.start();
		}
		
		private function doCreateText():void 
		{
			_style = new Style();
			style.fill = PersistentData.getInstance().currentStyle.fill;
			if ( _style.fill == 0 ) _style.fill = StyleUtil.getRandomColor();
			style.font_size = PersistentData.getInstance().currentStyle.font_size;
			_block = new TextBlock( new TextElement( "Text" , createFormat( style ) ) );
			redraw();
			this.x = this.mouseX;
			this.y = this.mouseY;
			dispatchEvent( new ItemEditEvent( ItemEditEvent.CREATION_COMPLETE ) );
		}
		
		/* IParser private methods*/
		private function parseSpan( xml:XML , style:Style ):void 
		{
			setPosition( Number( xml.@x.toString() ), Number( xml.@y.toString() ) );

			if ( xml.hasSimpleContent() ) setText( xml.text(), style );
			else 
			{
				var list:XMLList = xml.children();
				for each( var span:XML in list ) 
				{
					var ls:Style = style.copy();
					ls.addStyle( span );
					if ( span.hasComplexContent() ) parseSpan ( span , ls );
					else 
					{
						if ( span.toString().replace( /\s/g , "" ) == "" ) continue;
						setPosition( Number( span.@x.toString() ), Number( span.@y.toString() ) );
						setText( span , ls );
					}
				}
			}
		}
		
		private function setPosition( x:Number, y:Number ):void 
		{
			if ( x != 0 && y != 0 ) {
				_x = x;
				_y = y;
			}
			_localX = x;
			_localY = y;
		}
		
		private function createFormat( style:Style ):ElementFormat
		{
			var fd:FontDescription = new FontDescription( style.font_family, style.font_weight );
			fd.fontLookup = Constants.FONT_LOOKUP;
			var format:ElementFormat = new ElementFormat( fd , style.font_size , style.fill , style.fill_opacity  );
			format.trackingRight = style.letter_spacing;
			format.breakOpportunity = BreakOpportunity.NONE;
			return format;
		}

		private function setText(  txt:String , style:Style ):void 
		{
			txt = txt.replace(/[\t|\n|\r]+/g , "" );
			var tElement:TextElement = new TextElement( txt , createFormat( style ) );
			if ( _localX == 0 && _localY == 0 ) {
				tElement.userData = { x:_x, y:_y , style:style };
				textElements.push( tElement );
			}else {
				_block = new TextBlock( tElement );
				var textLine:TextLine = _block.createTextLine ();
				if ( textLine ) layoutTextLine(textLine, _localX, _localY, style );
			}
		}
		
		private function drawTextElements():void 
		{
			if ( textElements.length <= 0 ) return;
			var groupElement:GroupElement = new GroupElement( textElements );
			var firstElement:ContentElement = textElements[0];

			var ex:Number = firstElement.userData.x;
			var ey:Number = firstElement.userData.y;
			var estyle:Style = firstElement.userData.style;
			_block = new TextBlock( groupElement );
			var textLine:TextLine = _block.createTextLine () ;
			if ( textLine ) 
				layoutTextLine( textLine, ex , ey , estyle );
		}
		
		private function layoutTextLine( textLine:TextLine , x:Number, y:Number, style:Style  ):void 
		{
			if ( style.text_align == "center" ) x -= textLine.width / 2 ;
			else if ( style.text_align == "end" ) x -= textLine.width;
			textLine.x = x;
			textLine.y = y;
			textLine.rotation = style.rotate;
			textLine.alpha = style.opacity;
			addChild( textLine );
			textLine.doubleClickEnabled = true;
			textLine.userData = { style:style };
			_textLines.push( textLine );
		}
		
		private function setStyleAttr( s:Style, node:XML ):void 
		{
			s.setStyleAttr( node, 	"font-size", "font-style", "font-family", "font-weight", "fill", 
									"font-size-adjust", "font-stretch", "font-variant", "direction", "opacity",
									"letter-spacing", "word-spacing", "text-decoration", "alignment-baseline",
									"text-decoration", "alignment-baseline", "baseline-shift", "dominant-baseline",
									"glyph-orientation-horizontal", "glyph-orientation-vertical", "kerning",
									"text-align","writing-mode","line-height" );
		}

	}

}