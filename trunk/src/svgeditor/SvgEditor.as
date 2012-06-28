package svgeditor 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.display.BlendMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ContextMenuEvent;
	import flash.filters.DisplacementMapFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.*;
	import svgeditor.memento.Caretaker;
	import svgeditor.memento.Memento;
	import svgeditor.ui.SelectionBox;
	
	import svgeditor.parser.model.Data;
	import svgeditor.parser.path.PathManager;
	import svgeditor.parser.style.Style;
	import svgeditor.ui.GradientBox;

	import svgeditor.event.SelectionChangeEvent;
	import svgeditor.event.ItemEditEvent;
	import svgeditor.event.PathEditEvent;
	import svgeditor.parser.*;
	import svgeditor.parser.model.PersistentData;
	import svgeditor.ui.DragItem;
	import svgeditor.ui.BoundingBox;
	
	[Event(name = "selectionChange", type = "svgeditor.event.SelectionChangeEvent")]
	[Event(name = "creationComplete", type = "svgeditor.event.ItemEditEvent")]
	[Event(name = "creationCanceled", type = "svgeditor.event.ItemEditEvent")]
	[Event(name = "pathEdit", type = "svgeditor.event.PathEditEvent")]
	[Event(name = "pathEditFinish", type = "svgeditor.event.PathEditEvent")]
	
	public class SvgEditor extends Sprite
	{
		private var _appStage:DisplayObject;
		private var _infoLayer:Sprite;
		
		private var _currentSelection:IEditable;
		private var _selectables:Vector.<IEditable>;
		private var _selections:Vector.<IEditable>
		private var _currentEditable:IEditable;
		private var _currentLayer:IEditable;
		private var _currentPrimitive:IEditable;
		
		private var _bounds:Vector.<BoundingBox>
		private var _gradientBox:GradientBox;
		private var _selectionBox:SelectionBox;
		private var _isSelectMode:Boolean = true;
		private var _multiSelMode:Boolean = false;
		private var _isOutline:Boolean = false;
		private var _dragStage:DragItem;
		private var _clipboard:XML;
		private var _styleClipboard:XML;
		private var _histories:Caretaker;
		
		public function SvgEditor( svg:XML = null ) 
		{
			if ( svg ) parse( svg );
			this.addEventListener( Event.ADDED_TO_STAGE, init );
		}
		
		public function newDocument( width:Number , height:Number ):void
		{
			var svg:XML = <svg />;
			var viewBox:String = "0 0 " + width + " " + height;
			svg.@viewBox = viewBox;
			parse( svg );
		}
		
		public function parse( svg:XML ):void 
		{
			PersistentData.getInstance().reset();
			
			var parser:SvgFactory = new SvgFactory();
			parser.addEventListener( Event.COMPLETE, onParseFinish );
			parser.parse( svg , this );
		
			_infoLayer = new Sprite();
			addChild( _infoLayer );
			PersistentData.getInstance().controlCanvas = _infoLayer;
			
			_selectables = new Vector.<IEditable>();
			_bounds = new Vector.<BoundingBox>();
			editRoot();
		}
		
		public function export():XML 
		{
			if( this.numChildren > 0 )
				return new SvgFactory().export( this.getChildAt( 0 ) as Svg );
			return <svg />;
		}
		
		public function get appStage():DisplayObject 
		{ 
			if ( !_appStage ) _appStage = this;
			return _appStage; 
		}
		
		public function set appStage(value:DisplayObject):void 
		{
			_appStage = value;
		}
		
		public function zoom( scale:Number ):void 
		{
			if( scale > 0 )
				PersistentData.getInstance().currentZoom = this.scaleX = this.scaleY = scale;
		}
		
		public function zoomByMouse( scale:Number , center:Point = null  ):void 
		{
			scale += 1 - this.scaleX;
			if ( scale > 0 )
			{
				if ( !center ) center = new Point();
				var mat:Matrix = this.transform.matrix.clone() ;
				mat.translate( -center.x, -center.y );
				mat.scale( scale , scale );
				mat.translate( center.x, center.y );
				this.transform.matrix = mat;
				PersistentData.getInstance().currentZoom = this.scaleX;
			}
		}
		
		public function move( _x:Number, _y:Number ):void 
		{
			this.x = _x;
			this.y = _y;
		}
		
		public function stageDraggable():void 
		{
			if ( _dragStage ) return;
			_isSelectMode = false;
			appStage.addEventListener( MouseEvent.MOUSE_DOWN, dragStage );
			this.stage.addEventListener( MouseEvent.MOUSE_UP, endDragStage );
		}
		
		public function stageUndraggable( ):void 
		{
			_isSelectMode = true;
			appStage.removeEventListener( MouseEvent.MOUSE_DOWN, dragStage );
			this.stage.removeEventListener( MouseEvent.MOUSE_UP, endDragStage );
		}
		
		public function get currentSelectionName():String 
		{ 
			return 	_currentSelection ? _currentSelection.asObject.name : ""; 
		}
		
		public function get currentSelectionType():String 
		{ 
			return _currentSelection ? getQualifiedClassName( _currentSelection ).replace(/.+::(.+)/, "$1")  : "" ; 
		}
		
		public function get currentSelection():IEditable { return _currentSelection; }
		public function set currentSelection(value:IEditable):void 
		{
			if ( _currentSelection == value ) return;
			_currentSelection = value;
			dispatchEvent( new SelectionChangeEvent );
			
			if ( !value ) return;
			var parent:IEditable = value.asContainer.parent as IEditable;
			if ( parent ) _currentLayer = parent;
			setHistory();
		}
		
		public function get currentMode():int 
		{
			if ( _currentEditable ) return Constants.EDIT_MODE;
			if ( _currentSelection && _selections.length > 0 ) return Constants.SELECT_MODE;
			return Constants.IDLE_MODE;
		}

		//history
		public function undo():void
		{
			if ( !_histories || !_histories.hasItems ) return;
			var state:Memento =  _histories.getMemento( _histories.prevIndex );
			parseHistory( state );
		}
		
		public function redo():void
		{
			if (  !_histories || !_histories.hasItems ) return;
			var state:Memento =  _histories.getMemento( _histories.nextIndex );
			parseHistory( state );
		}
		
		//depth
		public function sendToBack():void 
		{
			if ( !_currentSelection ) return;
			_currentSelection.asContainer.parent.setChildIndex( _currentSelection.asObject , 0 );
			if ( _multiSelMode )
			{
				for each ( var item:IEditable in _selections )
					item.asContainer.parent.setChildIndex( item.asObject , 0 );
			}
		}
		
		public function bringToFront():void 
		{
			if ( !_currentSelection ) return;
			var parent:DisplayObjectContainer = _currentSelection.asContainer.parent;
			parent.setChildIndex( _currentSelection.asObject , parent.numChildren -1 );
			if ( _multiSelMode )
			{
				for each ( var item:IEditable in _selections )
					parent.setChildIndex( item.asObject , parent.numChildren -1  );
			}
		}
		
		public function unselectAll():void 
		{
			exitEditMode();
			removeCurrentSelectables();
			clearSelections();
			hideBound();
			editRoot();
		}
		
		public function deleteSelection():void 
		{
			if ( !_currentSelection ) return;
			addSelection( _currentSelection );
			hideBound();
			while ( _selections.length ) {
				var item:IEditable = _selections.pop();
				if ( !item ) continue;
				item.asContainer.parent.removeChild( item.asObject );
			}
		}
		
		public function deletePathPoint():void
		{
			_currentEditable.getPathManager().deleteCurrentPoint();
		}
		
		public function deletePathControlPoint( id:int ):void
		{
			_currentEditable.getPathManager().deleteCurrentControl( id );
		}
		
		public function toggleOutline():void
		{
			var svg:Svg = this.getChildAt( 0 ) as Svg;
			svg.outline( _isOutline = ! _isOutline );
		}
		
		public function copy():void 
		{
			if ( !_currentSelection  ) return;
			_clipboard = _currentSelection.getSvg();
		}
		
		public function paste():void
		{
			if ( !_clipboard  ) return;
			var data:Data = new Data( _clipboard , _currentLayer.asContainer );
			SvgFactory.parseData( data );
			setCurrentSelectables( _currentLayer );
		}
		
		public function copyStyle():void
		{
			var s:XML = <Style />;
			_currentEditable.style.setStyleAttr( s, "opacity" , "stroke", "fill" , "filter" , "fill-opacity", "stroke-opacity", 
													"stroke-width", "stroke-miterlimit", "stroke-linecap", "stroke-linejoin" , "fill-rule" ,
													"font-size", "font-style", "font-family", "font-weight",
													"font-size-adjust", "font-stretch", "font-variant", "direction",
													"letter-spacing", "word-spacing", "text-decoration", "alignment-baseline",
													"text-decoration", "alignment-baseline", "baseline-shift", "dominant-baseline",
													"glyph-orientation-horizontal", "glyph-orientation-vertical", "kerning",
													"text-align", "writing-mode", "line-height");
			_styleClipboard = s;
		}
		
		public function pasteStyle():void
		{
			if ( !_currentSelection || !_styleClipboard ) return;
			_currentSelection.style.clearColors();
			_currentSelection.style.parse( _styleClipboard );
			_currentSelection.style.makeUniqueLinkedItems();
			_currentSelection.redraw();	
			if ( _multiSelMode )
			{
				for each( var item:IEditable in _selections )
				{
					item.style.clearColors();
					item.style.parse( _styleClipboard );
					item.style.makeUniqueLinkedItems();
					item.redraw();	
				}
			}
		}
		
		public function group():void
		{
			var g:Group = new Group();
			g.newPrimitive();
			_currentLayer.asContainer.addChild( g.asObject );
			_selections.sort( function( a:IEditable, b:IEditable ):Number {
				return _currentLayer.asContainer.getChildIndex( a.asObject ) - _currentLayer.asContainer.getChildIndex( b.asObject );
			});
			g.setChildren( _selections );
			_multiSelMode = false;
			setCurrentSelectables( _currentLayer );
			hideBound();
			showBound( g , false );
			currentSelection = g;
		}
		
		public function ungroup():void
		{
			if ( ! ( _currentSelection is Group ) ) return;
			var g:DisplayObjectContainer = _currentSelection.asContainer;
			var mat:Matrix = _currentSelection.getMatrix();
			var children:Vector.<IEditable> = _currentSelection.getChildren();
			for each ( var item:IEditable in children )
			{
				g.removeChild( item.asObject );
				g.parent.addChild( item.asObject );
				item.addMatrix( mat );
			}
			setCurrentSelectables( g.parent as IEditable );
			g.parent.removeChild( g );
			hideBound();
		}
		
		public function setClippingPath():void
		{
			if ( !_currentSelection || !_selections.length ) return;
			var index:int = _selections.indexOf( _currentSelection ); //remove currentSelection
			_selections.splice( index , 1 );

			var clip:ClipPath = new ClipPath();
			var item:IEditable = _selections[0];
			
			clip.convertFrom( _currentSelection );
			var mat:Matrix = item.getMatrix();
			mat.invert();
			mat.concat( clip.getMatrix() );
			clip.setMatrix( mat );

			item.style.clipPath_id = clip.style.id;
			item.redraw();
			
			_currentLayer.asContainer.removeChild( _currentSelection.asObject );
		}
		
		public function removeClippingPath():void
		{
			var id:String = _currentSelection.style.clipPath_id;
			var clip:ClipPath = PersistentData.getInstance().getClipPathById( id ) as ClipPath;
			var g:Group = clip.convertToGroup();
			_currentLayer.asContainer.addChild( g.asObject );
			
			_currentSelection.style.clipPath_id = null;
			_currentSelection.redraw();
			
			_currentSelection = g;
		}
		
		//create new item
		public function addPrimitive( className:String ):void	//Class name for IEditable
		{
			if ( !_isSelectMode ) return;
			var Item:Class = getDefinitionByName( "svgeditor.parser::" + className ) as Class;
			var item:IEditable = new Item();
			_currentLayer.asContainer.addChild( item.asObject );
			item.newPrimitive();
			item.addEventListener( ItemEditEvent.CREATION_COMPLETE, onItemCreated );
			item.addEventListener( ItemEditEvent.CREATION_CANCELED, onCreationCanceled );
			_isSelectMode = false;
			_currentPrimitive = item;
		}
		
		public function drawPath():void
		{
			var item:Path = new Path();
			_currentLayer.asContainer.addChild( item.asObject );
			item.newDrawing();
			item.addEventListener( ItemEditEvent.CREATION_COMPLETE, onItemCreated );
			item.addEventListener( ItemEditEvent.CREATION_CANCELED, onCreationCanceled );
			_isSelectMode = false;
			_currentPrimitive = item;
		}
		
		public function cancelCreation():void 
		{
			if(_currentPrimitive)
				_currentPrimitive.cancelCreation();
		}
		
		public function mixPath():void
		{
			if ( !_currentSelection || !( _currentSelection is Path ) ) return;
			var path1:Path = _currentSelection as Path;
			var path2:Path;
			for each( var item:IEditable in _selections )
			{
				if ( item is Path && item != _currentSelection )
				{
					path2 = item as Path;
					break;
				}
			}
			if ( !path2 ) return;
			path1.mixPath( path2 );
			path2.asContainer.parent.removeChild( path2.asObject );
			setCurrentSelectables( _currentLayer );
		}
		
		public function convertToPath():void
		{
			if ( !_currentSelection || !_currentSelection.convertible ) return;
			var path:IEditable = _currentSelection.convertToPath();
			_currentLayer.asContainer.addChild( path.asObject );
			_currentLayer.asContainer.swapChildren( path.asObject , _currentSelection.asObject );
			_currentLayer.asContainer.removeChild( _currentSelection.asObject );
			setCurrentSelectables( _currentLayer );
			currentSelection = path;
			clearSelections();
		}
		
		public function editGradientMatrix( editStroke:Boolean = false ):void 
		{
			if ( _currentSelection.style.hasGradientFill || _currentSelection.style.hasGradientStroke ) 
			{
				if ( _gradientBox ) _gradientBox.exit();
				_gradientBox = new GradientBox( _infoLayer , _currentSelection.asObject , editStroke );
			}
		}
		
		public function getStyle():StyleObject 
		{
			if ( !_currentSelection ) return new StyleObject();
			return _currentSelection.style.getStyleObj();
		}
		
		public function setStyle( o:StyleObject ):void 
		{
			if ( !_currentSelection ) return;
			_currentSelection.style.parseStyleObj( o );
			_currentSelection.redraw();
			PersistentData.getInstance().currentStyle.parseStyleObj( o );
		}
		
		//Private
		private function init( e:Event = null ):void
		{
			this.removeEventListener( Event.ADDED_TO_STAGE, init );
			this.addEventListener( Event.REMOVED_FROM_STAGE, exit );
			this.stage.addEventListener( MouseEvent.MOUSE_DOWN, onEmptySpaceClicked );
			editRoot();
		}
		
		private function exit( e:Event ):void 
		{
			this.removeEventListener( Event.REMOVED_FROM_STAGE, exit );
			this.stage.removeEventListener( MouseEvent.MOUSE_DOWN, onEmptySpaceClicked );
			stageUndraggable();
		}
		
		private function dragStage( e:MouseEvent ):void 
		{
			_dragStage = new DragItem( this as DisplayObject );
		}
		
		private function endDragStage( e:MouseEvent ):void 
		{
			if ( _dragStage ) _dragStage.exit();
			_dragStage = null;
		}
		
		private function editRoot():void 
		{
			if ( !this.numChildren ) return;
			var svgRoot:IEditable = this.getChildAt(0) as IEditable;
			setCurrentSelectables( svgRoot );
			_currentLayer = svgRoot;
			_multiSelMode = false;
		}

		private function setCurrentSelectables( s:IEditable ):void 
		{
			if ( s.getNumChildren() <= 0 ) 	//EDIT MODE
			{
				_currentEditable = s;
				if ( _currentEditable ) {
					_currentEditable.removeEventListener( MouseEvent.MOUSE_DOWN, onItemClick );
					_currentEditable.edit();
					currentSelection = _currentEditable;
				}
				return;
			}
			
			removeCurrentSelectables();
			if ( s.getNumChildren() <= 0 ) return;
			var children:Vector.<IEditable> = s.getChildren();
			for each( var item:IEditable in children ) 	//MAKE ITEMS SELECTABLE
			{
				_selectables.push( item );
				item.addEventListener( MouseEvent.MOUSE_DOWN, onItemClick );
				item.addEventListener( MouseEvent.DOUBLE_CLICK, enterEditMode );
			}
			_currentLayer = s;
			_currentLayer.edit();
		}
		
		private function removeCurrentSelectables():void 
		{
			for each ( var item:IEditable in _selectables ) 
			{
				item.removeEventListener( MouseEvent.MOUSE_DOWN, onItemClick );
				item.removeEventListener( MouseEvent.DOUBLE_CLICK, enterEditMode );
			}
			_selectables = new Vector.<IEditable>();
			if( _currentLayer ) _currentLayer.exit();
		}
		
		private function onItemClick( e:MouseEvent ):void 
		{
			_multiSelMode = e.shiftKey;
			if ( !_multiSelMode ) clearSelections();
			selectItem( e.currentTarget as IEditable );
		}
		
		private function selectItem( item:IEditable , draggable:Boolean = true ):void 
		{	
			if ( !_isSelectMode || (item is Svg) ) return;
			if ( !_multiSelMode || !_selections ) clearSelections();
			if ( _currentSelection  ) addSelection( _currentSelection );
			hideBound();
			currentSelection =  item;
			if ( _multiSelMode )
			{
				toggleSelection( item );
				for each( var sel:IEditable  in _selections )
					showBound( sel , false );
				
				if ( draggable ) 
					draggableSelections();
			}
			else
			{
				showBound( item , draggable );
				clearSelections();
			}
			
			if ( _currentEditable != item ) 
				exitEditMode();
		}
		
		private function enterEditMode( e:MouseEvent ):void 
		{
			if ( _currentEditable == e.currentTarget ) return;
			var localItem:IEditable = e.currentTarget as IEditable;
			if ( !localItem ) {	//empty space clicked
				editRoot();
				return;
			}
			hideBound();
			setCurrentSelectables( localItem );
		}
		
		private function exitEditMode():void 
		{
			if ( !_currentEditable ) return;
			_currentEditable.exit();
			_currentEditable.addEventListener( MouseEvent.MOUSE_DOWN, onItemClick );
			_currentEditable = null;
			setHistory();
		}
		
		private function onItemCreated( e:ItemEditEvent ):void 
		{
			e.currentTarget.removeEventListener( ItemEditEvent.CREATION_COMPLETE, onItemCreated );
			e.currentTarget.removeEventListener( ItemEditEvent.CREATION_CANCELED, onCreationCanceled );
			setCurrentSelectables( _currentLayer );
			_isSelectMode = true;
			_currentPrimitive = null;
			selectItem( e.currentTarget as IEditable , false );
			dispatchEvent( e );
		}
		
		private function onCreationCanceled( e:ItemEditEvent ):void 
		{
			e.currentTarget.removeEventListener( ItemEditEvent.CREATION_COMPLETE, onItemCreated );
			e.currentTarget.removeEventListener( ItemEditEvent.CREATION_CANCELED, onCreationCanceled );
			setCurrentSelectables( _currentLayer );
			_isSelectMode = true;
			_currentPrimitive = null;
			dispatchEvent( e );
		}
		
		private function onEmptySpaceClicked( e:MouseEvent ):void 
		{
			if ( ( e.target is Svg ) || e.target == appStage ) 
			{
				unselectAll();
				
				if ( !_isSelectMode ) return;
				_selectionBox = new SelectionBox( _infoLayer );
				_selectionBox.addEventListener( Event.COMPLETE , dragSelectComplete );
			}
			/*
			if ( _currentLayer is Group && _selectables.indexOf( e.target ) == -1 && currentMode != Constants.EDIT_MODE ) 
			{
				_currentLayer.exit();
				//var selection:IEditable = _currentLayer.asContainer.parent as IEditable;
				//clearSelections();
				//removeCurrentSelectables();
				//selectItem( selection );
				unselectAll();
				removeCurrentSelectables();
			}*/
		}
		
		private function dragSelectComplete( e:Event ):void
		{
			_multiSelMode = true;
			_currentSelection = null;
			var items:Vector.<IEditable> = _currentLayer.getChildren();
			for each( var item:IEditable in items )
			{
				if ( item.asObject.hitTestObject( _selectionBox ) )
					selectItem( item , false );
			}
			_selectionBox.exit();
		}
		
		private function toggleSelection( item:IEditable ):void
		{
			if ( _selections.indexOf( item ) == -1 )
				addSelection( item );
			else 
				removeSelection( item );
		}
		
		private function addSelection( item:IEditable ):void
		{
			if ( _selections.indexOf( item ) == -1 )
				_selections.push( item );
		}
		
		private function removeSelection( item:IEditable ):void
		{
			if ( _selections.indexOf( item ) == -1 ) return;
			_selections.splice( _selections.indexOf( item ) , 1 );
			currentSelection = _selections.length ? _selections[0] : null;
		}
		
		private function clearSelections():void
		{
			_selections = new Vector.<IEditable>();
			_multiSelMode = false;
		}
		
		private function draggableSelections():void
		{
			for each( var box:BoundingBox in _bounds )
				box.draggable();
		}
		
		//history
		private function setHistory( selection:IEditable = null ):void
		{
			if ( !selection ) selection = _currentSelection;
			if ( !selection || ( selection is Svg ) ) return;
			if ( !_histories ) _histories = new Caretaker();
			_histories.addMemento( new Memento( selection, selection.getSvg() ));
		}
		
		private function parseHistory( state:Memento ):void
		{
			if ( !state ) return;
			var instance:IEditable = state.instance;
			var parent:DisplayObjectContainer = instance.asContainer.parent;
			if ( !parent ) return;
			var data:Data = new Data( state.xml, parent );
			IParser( instance ).parse( data );
		}

		//Bounds
		private function showBound( o:IEditable , draggable:Boolean = true ):void 
		{
			for each( var box:BoundingBox in _bounds )
				if ( box.editItem == o ) return;
			
			_bounds.push( new BoundingBox( _infoLayer, o , draggable ) );
		}
		
		private function hideBound( e:Event = null ):void 
		{
			while ( _bounds.length ) 
			{
				var b:BoundingBox = _bounds.pop();
				b.exit();
			}
			if ( _gradientBox ) _gradientBox.exit();
			//currentSelection = null;
			_gradientBox = null;
		}
		
		private function getRootMatrix():Matrix 
		{
			var mat:Matrix = this.transform.matrix.clone();
			if ( this.parent ) 
				mat.concat( this.parent.transform.matrix.clone() );
			return mat;
		}
		
		private function onParseFinish( e:Event ):void 
		{
			e.currentTarget.removeEventListener( Event.COMPLETE, onParseFinish );
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
	}

}