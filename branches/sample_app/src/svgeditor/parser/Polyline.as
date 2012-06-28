package svgeditor.parser 
{
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.display.GraphicsPathCommand;
	import flash.events.Event;
	import flash.geom.Point;
	import svgeditor.parser.IParser;
	import svgeditor.parser.abstract.AbstractPaint;
	import svgeditor.parser.model.Data;
	import svgeditor.parser.style.Style;
	import svgeditor.event.PathEditEvent;
	import svgeditor.parser.model.PersistentData;
	import svgeditor.parser.utils.StyleUtil;
	import svgeditor.parser.path.EditPoint;
	import svgeditor.ui.CreationPoint;
	import svgeditor.event.ItemEditEvent;
	import svgeditor.Constants;
	
	public class Polyline extends AbstractPaint implements IParser
	{
		public static var LOCALNAME:String = "polyline";
		
		protected var _commands:Vector.<int>;
		protected var _vertices:Vector.<Number>;
		protected var _editPoints:Vector.<EditPoint>;
		protected var _creationPoint:CreationPoint;
		
		public function Polyline() { }
		
		/* IEditable methods*/
		override public function redraw():void 
		{ 
			paint( this , style );
		}
		
		override public function edit():void 
		{
			createControl();
			
			_editPoints = new Vector.<EditPoint>();
			var length:int = _vertices.length;
			for ( var i:int = 0; i < length ; i += 2 ) 
			{
				var pt:EditPoint = new EditPoint( _controlLayer, _pathLayer , i / 2 , _vertices[i], _vertices[ i + 1] );
				pt.addEventListener( PathEditEvent.PATH_EDIT , onPathEdit );
				pt.addEventListener( PathEditEvent.PATH_EDIT_FINISH , onPathEditFinish );
				_editPoints.push( pt );
			}
			drawEditLine();
		}
		override public function exit():void
		{
			for each ( var ep:EditPoint in _editPoints ) 
			{
				ep.removeEventListener( PathEditEvent.PATH_EDIT , onPathEdit );
				ep.removeEventListener( PathEditEvent.PATH_EDIT_FINISH , onPathEditFinish );
				ep.exit();
			}
			removeControl();
		}
		
		override public function getSvg():XML 
		{
			var node:XML = <{Polyline.LOCALNAME} />;
			
			var pointStr:String = "";
			var length:int = _vertices.length;
			for ( var i:int = 0; i < length; i += 2 )
				pointStr += _vertices[i] + "," + _vertices[ i + 1 ] + " ";
			
			node.@points = pointStr;
			
			setPaintAttr( node );
			return node;
		}
		
		override public function newPrimitive():void 
		{ 
			createControl();
			_style = new Style();
			_style.hasFill = false;
			_style.stroke = PersistentData.getInstance().currentStyle.stroke;
			if ( _style.stroke == 0 ) _style.stroke = StyleUtil.getRandomColor();
			_style.stroke_width = Constants.DEFAULT_LINE_WIDTH;
			_style.hasStroke = true;
			_creationPoint = new CreationPoint( _controlLayer , _pathLayer );
			_creationPoint.addEventListener( Event.CHANGE , onCreationUpdate );
			_creationPoint.addEventListener( Event.COMPLETE , onCreationComplete );
			_creationPoint.addEventListener( Event.CANCEL , onCreationCanceled );
		};
		
		override public function get convertible():Boolean { return true ; };
		
		/* IParser methods*/
		public function parse( data:Data ):void 
		{
			_style = new Style( data.currentXml );
			
			var points:Array = data.currentXml.@points.toString()	.replace(/\s+$/, "")
																	.replace(/\s+/g , ",")
																	.split(",");
			_vertices = Vector.<Number>( points );
			calculateCommand();

			data.currentCanvas.addChild( this );
			paint( this, style, data );
		}
		
		override protected function draw( graphics:Graphics ):void {
			graphics.drawPath( _commands, _vertices );
		}
		
		override protected function onCreationUpdate( e:Event ):void 
		{  
			_vertices = new Vector.<Number>();
			var pts:Vector.<Point> = _creationPoint.points;
			for each( var p:Point in pts )
				_vertices.push( p.x, p.y );
			calculateCommand();
			redraw();
		}
		
		override protected function onCreationComplete( e:Event ):void
		{
			_creationPoint.removeEventListener( Event.CHANGE , onCreationUpdate );
			_creationPoint.removeEventListener( Event.COMPLETE , onCreationComplete );
			_creationPoint.removeEventListener( Event.CANCEL , onCreationCanceled );
			_creationPoint.exit();
			removeControl();
			dispatchEvent( new ItemEditEvent( ItemEditEvent.CREATION_COMPLETE ) );
		}
		
		protected function onCreationCanceled( e:Event ):void
		{
			_creationPoint.removeEventListener( Event.CHANGE , onCreationUpdate );
			_creationPoint.removeEventListener( Event.COMPLETE , onCreationComplete );
			_creationPoint.removeEventListener( Event.CANCEL , onCreationCanceled );
			_creationPoint.exit();
			removeControl();
			dispatchEvent( new ItemEditEvent( ItemEditEvent.CREATION_CANCELED ) );
			this.parent.removeChild( this );
		}
		
		protected function onPathEdit( e:PathEditEvent ):void 
		{
			var length:int = _editPoints.length;
			for ( var i:int = 0; i < length ; i++ ) 
			{
				_vertices[i * 2] =  _editPoints[i].ax;
				_vertices[( i * 2 ) + 1 ] =  _editPoints[i].ay;
			}
			
			drawEditLine();
		}
		
		protected function onPathEditFinish( e:PathEditEvent ):void 
		{
			redraw();
		}
		
		override protected function getPathString():String 
		{ 
			var d:String = "M";
			var length:int = _vertices.length;
			for ( var i:int = 0; i < length; i += 2 )
				d += _vertices[i] + "," + _vertices[ i + 1 ] + " ";
			return d;
		}
		
		protected function calculateCommand():void 
		{
			var comLength:int = (_vertices.length / 2 ) -1;
			_commands  = Vector.<int>([GraphicsPathCommand.MOVE_TO]);
			for ( var i:int = 0 ; i < comLength   ; i++ )
				_commands.push( GraphicsPathCommand.LINE_TO );
		}
		
	}

}