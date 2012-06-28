package svgeditor.ui 
{
	import flash.display.Sprite;
	import flash.display.DisplayObjectContainer;
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import svgeditor.Constants;
	import svgeditor.parser.IEditable;
	import svgeditor.parser.IGradient;
	import svgeditor.parser.LinearGradient;
	import svgeditor.parser.RadialGradient;
	import svgeditor.parser.utils.GeomUtil;
	
	public class GradientBox extends Sprite
	{
		public var parentLayer:DisplayObjectContainer;
		public var editItem:IEditable;
		
		private var grad:IGradient;
		private var editStroke:Boolean = false;
		private var type:String;
		private var icons:Vector.<Sprite>;
		private var drag:DragItem;
		
		public function GradientBox( parentLayer:DisplayObjectContainer, editItem:DisplayObject , editStroke:Boolean = false ) 
		{ 
			this.parentLayer = parentLayer;
			this.editItem = editItem as IEditable;
			this.editStroke = editStroke;
			
			grad = editStroke ? this.editItem.style.getGradientStroke() : this.editItem.style.getGradientFill();
			if ( !grad ) return;
			
			parentLayer.addChild( this );
			
			this.type = grad.type;
			if ( this.type == GradientType.LINEAR ) createLinearBox();
			else createRadialBox();
		}
		
		public function exit():void 
		{
			if ( parentLayer && parentLayer.contains( this ) ) 
				parentLayer.removeChild( this );
			parentLayer = null;
			editItem = null;
			grad = null;
			icons = null;
		}
		
		private function draw( e:MouseEvent=null ):void 
		{
			this.graphics.clear();
			if ( type == GradientType.LINEAR ) drawLinear();
			else drawRadial();
		}
		
		private function createLinearBox():void 
		{
			var pt1:Point;
			var pt2:Point;
			var lg:LinearGradient = grad as LinearGradient;
			if ( isNaN( lg.x1 ) || isNaN( lg.y1 ) || isNaN( lg.x2 ) || isNaN( lg.y2 ) ) 
			{
				pt1 = editItem.getRegistrationPoint();
				pt2 = pt1.clone();
				pt2.offset( 100, 100 );
			}else 
			{
				pt1 = GeomUtil.getVirtualPosition( this , editItem.asContainer , lg.x1, lg.y1 );
				pt2 = GeomUtil.getVirtualPosition( this , editItem.asContainer , lg.x2, lg.y2 );
			}
			
			createIcon( pt1.x, pt1.y );
			createIcon( pt2.x, pt2.y );
			draw();
		}
		
		private function drawLinear():void 
		{
			this.graphics.lineStyle( 2, Constants.GRADIENT_BOX_COLOR, 1 );
			this.graphics.moveTo( icons[0].x , icons[0].y );
			this.graphics.lineTo( icons[1].x , icons[1].y );
			
			var pt1:Point = GeomUtil.getActualPosition( this , editItem.asContainer , icons[0].x, icons[0].y );
			var pt2:Point = GeomUtil.getActualPosition( this , editItem.asContainer , icons[1].x, icons[1].y );
			var lg:LinearGradient = grad as LinearGradient;
			lg.x1 = pt1.x;
			lg.y1 = pt1.y;
			lg.x2 = pt2.x;
			lg.y2 = pt2.y;
			lg.createGradient();
			editItem.redraw();
		}
		
		private function createRadialBox():void 
		{
			var pt1:Point;
			var pt2:Point;
			var pt3:Point;
			var rg:RadialGradient = grad as RadialGradient;
			if ( isNaN( rg.cx ) || isNaN( rg.cy ) || isNaN( rg.r ) ) 
			{
				pt1 = editItem.getRegistrationPoint();
				pt2 = pt1.clone();
				pt2.offset( 100, 100 );
			}else 
			{
				pt1 = GeomUtil.getVirtualPosition( this , editItem.asContainer , rg.cx , rg.cy );
				pt2 = GeomUtil.getVirtualPosition( this , editItem.asContainer , rg.cx + rg.r, rg.cy );
			}
			
			createIcon( pt1.x, pt1.y );
			createIcon( pt2.x, pt2.y );
			draw();
		}
		
		private function drawRadial():void 
		{
			this.graphics.lineStyle( 2, Constants.GRADIENT_BOX_COLOR, 1 );
			this.graphics.moveTo( icons[0].x , icons[0].y );
			this.graphics.lineTo( icons[1].x , icons[1].y );
			
			var pt1:Point = GeomUtil.getActualPosition( parentLayer , editItem.asContainer , icons[0].x, icons[0].y );
			var pt2:Point = GeomUtil.getActualPosition( parentLayer , editItem.asContainer , icons[1].x, icons[1].y );
			var rg:RadialGradient = grad as RadialGradient;
			
			rg.cx = rg.fx = pt1.x;
			rg.cy = rg.fy = pt1.y;
			rg.r = GeomUtil.getDistance( pt1, pt2 );

			rg.createGradient();
			editItem.redraw();
		}
		
		private function createIcon( x:Number , y:Number ):void 
		{
			if ( !icons ) icons = new Vector.<Sprite>();
			var icon:Sprite = new Sprite();
			icon.graphics.lineStyle( 5, 0,0 );
			icon.graphics.beginFill( Constants.GRADIENT_BOX_COLOR , 1 );
			icon.graphics.drawCircle( 0 , 0 , 5 );
			icon.graphics.endFill();
			icon.x = x;
			icon.y = y;
			addChild( icon );
			icons.push( icon );
			icon.addEventListener( MouseEvent.MOUSE_DOWN , dragPoint );
		}
		
		private function dragPoint( e:MouseEvent ):void 
		{
			new RemovableDragItem( e.currentTarget as DisplayObject );
			this.stage.addEventListener( MouseEvent.MOUSE_MOVE , onDragging );
			this.stage.addEventListener( MouseEvent.MOUSE_UP , onDragStop );
		}
		
		private function onDragging( e:MouseEvent ):void 
		{
			draw();
		}
		
		private function onDragStop( e:MouseEvent ):void 
		{
			this.stage.removeEventListener( MouseEvent.MOUSE_MOVE , onDragging );
			this.stage.removeEventListener( MouseEvent.MOUSE_UP , onDragStop );
		}
	}

}