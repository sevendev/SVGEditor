package svgeditor.parser.abstract
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.display.LineScaleMode;
	import svgeditor.parser.model.Data;
	import svgeditor.parser.style.Style;
	import svgeditor.Constants;
	import svgeditor.parser.IGradient;
	
	public class AbstractPaint extends AbstractEditable
	{
		public function AbstractPaint() { }
		
		protected function paint( target:Sprite, style:Style , data:Data = null ):void 
		{
			if ( _outline ) 
			{
				drawOutLine( target );
				return;
			}
			
			this.transform.matrix = new Matrix();
			this.graphics.clear();
			
			if ( style.hasStroke  ) target.graphics.lineStyle( 	style.stroke_width, style.stroke, style.stroke_opacity, 
																Constants.LINE_PIXEL_HINTING, Constants.LINE_SCALE_MODE , 
																style.stroke_linecap ,style.stroke_linejoin, style.stroke_miterlimit  );
			if ( style.hasGradientStroke ) 
			{
				var sgrad:IGradient = style.getGradientStroke(); 
				if( sgrad ) target.graphics.lineGradientStyle( 	sgrad.type, sgrad.colors, sgrad.alphas, 
																sgrad.ratios, sgrad.matrix, sgrad.method );
			}
			if ( style.hasFill ) target.graphics.beginFill( style.fill , style.fill_opacity );
			if ( style.hasGradientFill ) 
			{
				var grad:IGradient = style.getGradientFill();
				if ( grad ) target.graphics.beginGradientFill( 	grad.type, grad.colors, grad.alphas , 
																grad.ratios , grad.matrix , grad.method  );
			}
			
			draw( target.graphics );	//draw graphics
			
			if ( style.hasFill || style.hasGradientFill || style.hasStroke ) target.graphics.endFill();
			
			applyStyle( this );
		}
		
		protected function drawOutLine( target:Sprite ):void
		{
			target.graphics.clear();
			target.graphics.lineStyle( 1, Constants.OUTLINE_COLOR , 1 , false, LineScaleMode.NONE );
			target.graphics.beginFill( 0 , 0 );

			draw( target.graphics );	//draw graphics
			
			target.graphics.endFill();
			target.filters = [];
			target.mask = null;
		}
		
		protected function drawEditLine():void 
		{
			_pathLayer.graphics.clear();
			_pathLayer.graphics.lineStyle( 1 , Constants.EDIT_LINE_COLOR , 1 , false, LineScaleMode.NONE );
			draw( _pathLayer.graphics );	//draw graphics
			
		}
		
		protected function draw( graphics:Graphics ):void 
		{
			throw new Error( "AbstractPaint.draw" );
		}
		
		protected function setPaintAttr( node:XML ):void 
		{
			style.setAttr( node, "id" , "transform" , "clip_path" );
			style.setStyleAttr( node, 	"opacity" , "stroke", "fill" , "filter" ,
										"fill-opacity" , "stroke-opacity" , 
										"stroke-width", "stroke-miterlimit", 
										"stroke-linecap", "stroke-linejoin" , "fill-rule" );
		}
	}

}