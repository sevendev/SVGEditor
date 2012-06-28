package svgeditor.parser 
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import svgeditor.parser.abstract.AbstractEditable;
	import svgeditor.parser.IParser;
	import svgeditor.parser.model.Data;
	import svgeditor.parser.style.Style;
	import svgeditor.parser.model.PersistentData;
	
	public class ClipPath extends AbstractEditable implements IParser
	{
		public static var LOCALNAME:String = "clipPath";
		
		public function ClipPath() { }
		
		/* IEditable methods*/
		override public function redraw():void {}
		override public function edit():void {}
		override public function exit():void{}
		
		override public function getNumChildren():int 
		{
			return numChildren;
		}
		
		override public function getSvg():XML 
		{
			var node:XML =<{ClipPath.LOCALNAME} />;
			style.setAttr( node, "id" , "viewBox", "transform" );
			var children:Vector.<IEditable> = this.getChildren();
			for each ( var item:IEditable in children ) 
				node.appendChild( item.getSvg() );
			return node;
		}
		
		/* IParser methods*/
		public function parse( data:Data ):void {
			style = new Style( data.currentXml );
			if ( !style.display ) return;

			var _xml:XML = data.currentXml;
			_xml.setLocalName(  "_clipPath" );
			
			this.name = style.id;
			SvgFactory.parseData( data.copy( _xml, this ));
			applyStyle( this );
			data.addClipPath( this );
		}
		
		/* ClipPath Specific */
		public function convertToGroup():Group 
		{
			if ( this.parent ) this.parent.removeChild( this );
			PersistentData.getInstance().removeClipPath( style.id );
			var g:Group = new Group();
			g.newPrimitive();
			g.style = style;
			var childlen:Vector.<IEditable> = getChildren();
			childlen.sort( function( a:IEditable, b:IEditable ):Number {
				return this.getChildIndex( a.asObject ) - this.getChildIndex( b.asObject );
			});
			g.setChildren( childlen );
			return g;
		}
		
		public function convertFrom( item:IEditable ):void
		{
			style = new Style();
			this.name = style.id = PersistentData.getInstance().clippathId;
			var xml:XML = getSvg();
			xml.appendChild( item.getSvg().copy() );
			var dammy:Sprite = new Sprite();
			var data:Data = new Data( xml, dammy );
			parse( data );
			dammy = null;
		}
	}

}