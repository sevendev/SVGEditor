package svgeditor.parser 
{
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.display.GraphicsPathCommand;
	import flash.events.Event;
	import svgeditor.parser.IParser;
	import svgeditor.parser.abstract.AbstractPaint;
	import svgeditor.parser.model.Data;
	import svgeditor.parser.style.Style;
	import svgeditor.parser.utils.StyleUtil;
	import svgeditor.parser.path.EditPoint;
	import svgeditor.event.PathEditEvent;
	
	public class Line extends AbstractPaint implements IParser
	{
		
		public function Line() { }
		
		public static var LOCALNAME:String = "line";
		
		private var _x1:Number;
		private var _y1:Number;
		private var _x2:Number;
		private var _y2:Number;
		
		private var _commands:Vector.<int>;
		private var _vertices:Vector.<Number>;
		
		private var pt1:EditPoint;
		private var pt2:EditPoint;
		
		/* IEditable methods*/
		override public function redraw():void 
		{ 
			paint( this , style );
		}
		
		override public function edit():void 
		{
			createControl();
			pt1 = new EditPoint( _controlLayer, _pathLayer , 0, _x1, _y1 );
			pt2 = new EditPoint( _controlLayer, _pathLayer , 1, _x2, _y2 );
			pt1.addEventListener( PathEditEvent.PATH_EDIT , onPathEdit );
			pt1.addEventListener( PathEditEvent.PATH_EDIT_FINISH , onPathEditFinish );
			pt2.addEventListener( PathEditEvent.PATH_EDIT , onPathEdit );
			pt2.addEventListener( PathEditEvent.PATH_EDIT_FINISH , onPathEditFinish );
			drawEditLine();
		}
		
		override public function exit():void
		{
			pt1.removeEventListener( PathEditEvent.PATH_EDIT , onPathEdit );
			pt1.removeEventListener( PathEditEvent.PATH_EDIT_FINISH , onPathEditFinish );
			pt1.exit();
			pt2.removeEventListener( PathEditEvent.PATH_EDIT , onPathEdit );
			pt2.removeEventListener( PathEditEvent.PATH_EDIT_FINISH , onPathEditFinish );
			pt2.exit();
			removeControl();
		}
		
		override public function getSvg():XML 
		{
			var node:XML = <{Line.LOCALNAME} />;
			node.@x1 = _x1;
			node.@x2 = _x2;
			node.@y1 = _y1;
			node.@y2 = _y2;
			setPaintAttr( node );
			return node;
		}
		
		override public function get convertible():Boolean { return true ; };
		
		/* IParser methods*/
		public function parse( data:Data ):void 
		{
			_style = new Style( data.currentXml );
			
			_x1 = StyleUtil.toNumber( data.currentXml.@x1 );
			_x2 = StyleUtil.toNumber( data.currentXml.@x2 );
			_y1 = StyleUtil.toNumber( data.currentXml.@y1 );
			_y2 = StyleUtil.toNumber( data.currentXml.@y2 );
			
			_vertices = Vector.<Number>([ _x1, _y1 , _x2 , _y2 ]);
			_commands  = Vector.<int>([GraphicsPathCommand.MOVE_TO , GraphicsPathCommand.LINE_TO ]);

			data.currentCanvas.addChild( this );
			paint( this, style, data );
		}
		
		override protected function draw( graphics:Graphics ):void {
			graphics.drawPath( _commands, _vertices );
		}
		
		override protected function onCreationUpdate( e:Event ):void
		{
			_x1 = _creationBox.rect.x;
			_y1 = _creationBox.rect.y;
			_x2 = _creationBox.rect.width + _x1;
			_y2 = _creationBox.rect.height + _y1;
			_vertices = Vector.<Number>([ _x1, _y1 , _x2 , _y2 ]);
			_commands  = Vector.<int>([GraphicsPathCommand.MOVE_TO , GraphicsPathCommand.LINE_TO ]);
			redraw();
		}
		
		override protected function getPathString():String 
		{ 
			var d:String = 	"M" + _x1 + "," + _y1 + "L" + _x2 + "," + _y2 ;
			return d;
		}
		
		private function onPathEdit( e:PathEditEvent ):void 
		{
			_x1 = pt1.ax;
			_y1 = pt1.ay;
			_x2 = pt2.ax;
			_y2 = pt2.ay;
			_vertices = Vector.<Number>([ _x1, _y1 , _x2 , _y2 ]);
			drawEditLine();
		}
		
		private function onPathEditFinish( e:PathEditEvent ):void 
		{
			redraw();
		}
		
	}

}