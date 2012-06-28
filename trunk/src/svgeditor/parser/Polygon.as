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
	import svgeditor.parser.path.EditPoint;
	import svgeditor.event.PathEditEvent;
	import svgeditor.ui.CreationPoint;
	import svgeditor.parser.model.PersistentData;
	import svgeditor.parser.utils.StyleUtil;
	import svgeditor.event.ItemEditEvent;
	import svgeditor.Constants;
	
	public class Polygon extends Polyline implements IParser
	{
		public static var LOCALNAME:String = "polygon";

		override public function edit():void 
		{
			createControl();
			
			_editPoints = new Vector.<EditPoint>();
			var length:int = _vertices.length;
			for ( var i:int = 0; i < length ; i += 2 ) 
			{
				var pt:EditPoint = new EditPoint( _controlLayer, _pathLayer , i / 2 , _vertices[i], _vertices[ i + 1] );
				if ( i == length - 2 ) 
				{
					_editPoints[0].setSlave( pt );
				}
				else{
					pt.addEventListener( PathEditEvent.PATH_EDIT , onPathEdit );
					pt.addEventListener( PathEditEvent.PATH_EDIT_FINISH , onPathEditFinish );
				}
				_editPoints.push( pt );
			}
			drawEditLine();
		}

		override public function newPrimitive():void 
		{ 
			createControl();

			_style = new Style();
			_style.fill = PersistentData.getInstance().currentStyle.fill;
			if ( _style.fill == 0 ) _style.fill = StyleUtil.getRandomColor();
			_style.stroke = PersistentData.getInstance().currentStyle.stroke;
			if ( _style.stroke == 0 ) _style.stroke = StyleUtil.getRandomColor();
			_style.stroke_width = Constants.DEFAULT_LINE_WIDTH;
			_style.hasStroke = true;
			
			_creationPoint = new CreationPoint( _controlLayer , _pathLayer );
			_creationPoint.addEventListener( Event.CHANGE , onCreationUpdate );
			_creationPoint.addEventListener( Event.COMPLETE , onCreationComplete );
			_creationPoint.addEventListener( Event.CANCEL , onCreationCanceled );
		};
		
		override public function getSvg():XML 
		{
			var node:XML = <{Polygon.LOCALNAME} />;
			
			var pointStr:String = "";
			var length:int = _vertices.length - 2;
			for ( var i:int = 0; i < length; i += 2 )
				pointStr += _vertices[i] + "," + _vertices[ i + 1 ] + " ";
			
			node.@points = pointStr;
			
			setPaintAttr( node );
			return node;
		}

		/* IParser methods*/
		override public function parse( data:Data ):void 
		{
			_style = new Style( data.currentXml );
			
			var points:Array = data.currentXml.@points.toString()	.replace(/\s+$/, "")
																	.replace(/\s+/g , ",")
																	.split(",");
			_vertices = Vector.<Number>( points );
			_vertices.push( _vertices[0], _vertices[1] );
			calculateCommand();

			data.currentCanvas.addChild( this );
			paint( this, style, data );
		}
		
		override protected function onCreationUpdate( e:Event ):void 
		{  
			_vertices = new Vector.<Number>();
			var pts:Vector.<Point> = _creationPoint.points;
			for each( var p:Point in pts )
				_vertices.push( p.x, p.y );
			_vertices.push( _vertices[0], _vertices[1] );
			calculateCommand();
			redraw();
		}
		
		override protected function getPathString():String 
		{ 
			return super.getPathString() + "Z";
		}

	}

}