// ***************************************************************************
// ColorWheel.as
// 
// Copyright (c) 2007 Ryan Taylor | http://www.boostworthy.com
// 
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.

package component.color
{
	import flash.display.CapsStyle;
	import flash.display.GradientType;
	import flash.display.LineScaleMode;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	
	import mx.managers.CursorManager;
	
	public class ColorWheel extends Sprite
	{
		/** Configures the default radius of this object. */
		private static const DEFAULT_RADIUS:Number  = 100;
		private var cursorID:int;
		
		[Embed(source="../../asset/colorpicker.gif")]
		private var colorPickerIcon:Class;
		
		/**
		 * Constructor.
		 */
		public function ColorWheel()
		{
			createListeners();
		}
		
		private function createListeners():void
		{
			addEventListener(MouseEvent.ROLL_OVER, setCusros);
			addEventListener(MouseEvent.ROLL_OUT, removeCusros);
		}
		
		private function setCusros(event:MouseEvent):void
		{
			cursorID = CursorManager.setCursor(colorPickerIcon, 2, -8, -23);
		}
		
		private function removeCusros(event:MouseEvent):void
		{
			if (cursorID)
				CursorManager.removeCursor(cursorID);
		}

		/**
		 * Initializes the color wheel.
		 * 
		 * @param	nRadius		The radius of the color wheel.
		 */
		public function draw(nRadius:Number = DEFAULT_RADIUS):void
		{
			var nRadians   : Number;
			var nR         : Number;
			var nG         : Number;
			var nB         : Number;
			var nColor     : Number;
			var objMatrix  : Matrix;
			var nX         : Number;
			var nY         : Number;
			var iThickness : int;
			
			// Clear the graphics container.
			graphics.clear();

			// Calculate the thickness of the lines which draw the colors.
			iThickness = 1 + int(nRadius / 50);
			
			// Loop from '0' to '360' degrees, drawing lines from the center 
			// of the wheel outward the length of the specified radius.
			for(var i:int = 0; i < 360; i++)
			{
				// Convert the degree to radians.
				nRadians = i * (Math.PI / 180);
				
				// Calculate the RGB channels based on the angle of the line 
				// being drawn.
				nR = Math.cos(nRadians)                   * 127 + 128 << 16;
				nG = Math.cos(nRadians + 2 * Math.PI / 3) * 127 + 128 << 8;
				nB = Math.cos(nRadians + 4 * Math.PI / 3) * 127 + 128;
				
				// OR the individual color channels together.
				nColor = nR | nG | nB;
				
				// Calculate the coordinate in which the line should be drawn to.
				nX = (nRadius) * Math.cos(nRadians);
				nY = (nRadius) * Math.sin(nRadians);
				
				// Create a matrix for the lines gradient color.
				objMatrix = new Matrix();
				objMatrix.createGradientBox(nRadius*2, nRadius*2, nRadians, 0, 0);
				
				// Create and drawn the line.
				graphics.lineStyle(iThickness, 0, 1, false, LineScaleMode.NONE,
					CapsStyle.NONE);
				graphics.lineGradientStyle(GradientType.LINEAR, [0xFFFFFF, nColor],
					[100, 100], [127, 255], objMatrix);
				graphics.moveTo(nRadius, nRadius);
				graphics.lineTo(nX + nRadius,nY + nRadius);
				
			}
		}

	}
}