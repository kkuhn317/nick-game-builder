package builderManager
{
   import builderManager.elements.BuilderElement;
   import com.sarbakan.sbdk.asset.AssetReference;
   import com.sarbakan.sbdk.core.UpdateManager;
   import com.sarbakan.sbdk.errors.ErrorMessages;
   import com.sarbakan.sbdk.events.UIEvent;
   import com.sarbakan.sbdk.events.UpdateEvent;
   import com.sarbakan.sbdk.input.KeyCode;
   import com.sarbakan.sbdk.input.KeyManager;
   import com.sarbakan.sbdk.input.MouseUtils;
   import com.sarbakan.sbdk.math.geom.AABB2;
   import com.sarbakan.sbdk.math.random.Random;
   import com.sarbakan.sbdk.sound.SoundManager;
   import com.sarbakan.sbdk.sound.SoundUnit;
   import com.sarbakan.sbdk.ui.Button;
   import com.sarbakan.sbdk.utils.EventManager;
   import com.sarbakan.sbdk.view.ViewManager;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.getTimer;
   import ui.popups.ConfirmPopup;
   import ui.popups.SavePopup;
   import ui.selectionGrid.LibraryItemDefinition;
   import ui.selectionGrid.SelectionGrid;
   
   public class ToolManager extends EventDispatcher
   {
      
      private static var oInstance:ToolManager;
      
      public static const sEVENT_ADDED:String = "added";
      
      public static const sEVENT_REMOVED:String = "removed";
      
      public static const sEVENT_UPDATED:String = "updated";
      
      private static const sEVENT_MANAGER_ID:String = "eventManager";
      
      private static const sEVENT_SELECTION_ID:String = "eventSelection";
      
      public static const TOOL_NONE:uint = 0;
      
      public static const TOOL_PAINT:uint = 1;
      
      public static const TOOL_ERASE:uint = 2;
      
      private static const nBUILDER_STEP:int = 5;
      
      private static var bAllowConstruction:Boolean = false;
      
      public var mcContainer:MovieClip;
      
      public var oMousePos:Point;
      
      public var oTilePos:Point;
      
      public var oRenderPos:Point;
      
      public var oDrawBounds:AABB2;
      
      private var nCurrentTool:uint;
      
      private var oEventManager:EventManager;
      
      private var oKeyManager:KeyManager;
      
      private var oBtnErase:Button;
      
      private var oBtnMove:Button;
      
      private var oBtnZoom:Button;
      
      private var oBtnHero:Button;
      
      private var oCursor:ToolCursor;
      
      private var oDragStagePos:Point;
      
      private var oLastPos:Point;
      
      private var oDragOffset:Point;
      
      private var nLastTime:int;
      
      private var oSelector:SelectionGrid;
      
      private var oSelectedItem:LibraryItemDefinition;
      
      private var oRenderer:BuilderRenderer;
      
      private var oDraggedElement:BuilderElement;
      
      private var oLastPaintElement:BuilderElement;
      
      private var oMouseUtils:MouseUtils;
      
      public function ToolManager()
      {
         super();
         if(!bAllowConstruction)
         {
            throw new Error(ErrorMessages.sSINGLETON_ERROR);
         }
         this.oEventManager = new EventManager();
      }
      
      public static function get instance() : ToolManager
      {
         if(oInstance == null)
         {
            bAllowConstruction = true;
            oInstance = new ToolManager();
            bAllowConstruction = false;
         }
         return oInstance;
      }
      
      public function init() : void
      {
         this.mcContainer = new mcTools();
         this.mcContainer.mouseEnabled = false;
         this.nCurrentTool = TOOL_NONE;
         this.nLastTime = getTimer();
         var _oStage:Stage = ViewManager.instance.stage;
         this.oKeyManager = new KeyManager(_oStage);
         this.oMouseUtils = MouseUtils.instance(_oStage);
         this.oBtnErase = new Button(this.mcContainer.btnEraser);
         BuilderMain.instance.tooltipManager.addTargetLocalized(this.oBtnErase.mcContainer,"id_tooltip_btnErase");
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oBtnErase,UIEvent.RELEASE,this.onBtnEraser);
         this.oBtnMove = new Button(this.mcContainer.btnTrash);
         BuilderMain.instance.tooltipManager.addTargetLocalized(this.oBtnMove.mcContainer,"id_tooltip_btnMove");
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oBtnMove,UIEvent.RELEASE,this.onBtnTrash);
         this.oBtnZoom = new Button(this.mcContainer.btnZoom);
         BuilderMain.instance.tooltipManager.addTargetLocalized(this.oBtnZoom.mcContainer,"id_tooltip_btnZoom");
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oBtnZoom,UIEvent.RELEASE,this.onBtnZoom);
         this.oBtnHero = new Button(this.mcContainer.btnHero);
         BuilderMain.instance.tooltipManager.addTargetLocalized(this.oBtnHero.mcContainer,"id_tooltip_btnGotoHero");
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oBtnHero,UIEvent.RELEASE,this.onBtnHero);
         this.oCursor = new ToolCursor(this);
         BuilderMain.instance.addChild(this.oCursor.mcContainer);
         this.oRenderer = BuilderManager.instance.renderer;
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,UpdateManager.instance,UpdateEvent.UPDATE,this.onUpdate);
         this.stopDrag();
      }
      
      public function destroy() : void
      {
         if(Boolean(this.oBtnErase))
         {
            this.oBtnErase.destroy();
         }
         this.oBtnErase = null;
         if(Boolean(this.oBtnMove))
         {
            this.oBtnMove.destroy();
         }
         this.oBtnMove = null;
         if(Boolean(this.oBtnZoom))
         {
            this.oBtnZoom.destroy();
         }
         this.oBtnZoom = null;
         if(Boolean(this.oBtnHero))
         {
            this.oBtnHero.destroy();
         }
         this.oBtnHero = null;
         if(Boolean(this.oCursor))
         {
            BuilderMain.instance.removeChild(this.oCursor.mcContainer);
            this.oCursor.destroy();
         }
         this.oCursor = null;
         if(Boolean(this.oKeyManager))
         {
            this.oKeyManager.destroy();
         }
         this.oKeyManager = null;
         if(Boolean(this.oEventManager))
         {
            this.oEventManager.destroy();
         }
         this.oEventManager = null;
         this.oRenderer = null;
         this.oLastPaintElement = null;
         this.oDraggedElement = null;
         this.oDragStagePos = null;
         this.mcContainer = null;
         oInstance = null;
      }
      
      public function isOverUnerasable(_sNewType:String = null) : Boolean
      {
         var _aElements:Array = null;
         var _oElement:BuilderElement = null;
         var _bReturn:Boolean = false;
         if(Boolean(this.oDrawBounds))
         {
            _aElements = BuilderManager.instance.getElementInRegion(this.oDrawBounds);
            for each(_oElement in _aElements)
            {
               if(_oElement != this.oDraggedElement && _oElement.isUnique)
               {
                  if(_sNewType != _oElement.mediaType)
                  {
                     _bReturn = true;
                     break;
                  }
               }
            }
         }
         return _bReturn;
      }
      
      private function startDrag() : void
      {
         this.oEventManager.removeEventListener(sEVENT_MANAGER_ID,this.oRenderer.mcContainer,MouseEvent.MOUSE_DOWN,this.onMouseDown);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,ViewManager.instance.stage,MouseEvent.MOUSE_UP,this.onMouseUp);
         this.updateDraggedBD();
         this.oLastPos = this.oTilePos;
      }
      
      private function stopDrag() : void
      {
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oRenderer.mcContainer,MouseEvent.MOUSE_DOWN,this.onMouseDown);
         this.oEventManager.removeEventListener(sEVENT_MANAGER_ID,ViewManager.instance.stage,MouseEvent.MOUSE_UP,this.onMouseUp);
         this.updateDraggedBD();
         this.oLastPos = null;
      }
      
      private function updateScroll() : void
      {
         var _nOffsetX:Number = NaN;
         var _nOffsetY:Number = NaN;
         var _nElapsedTime:int = 0;
         var _nTimeRatio:Number = NaN;
         var _nSpeed:Number = NaN;
         var _oPos:Point = null;
         var _mcContainer:MovieClip = null;
         var _nX:Number = NaN;
         var _nY:Number = NaN;
         if(Boolean(this.oRenderer))
         {
            _nOffsetX = 0;
            _nOffsetY = 0;
            _nElapsedTime = getTimer() - this.nLastTime;
            _nTimeRatio = _nElapsedTime / (1000 / 35);
            _nSpeed = _nTimeRatio * BuilderConfig.nSCROLL_SPEED;
            _oPos = this.oRenderer.centerPos;
            if(this.oKeyManager.isKeyDown(KeyCode.SPACE) || Boolean(this.oDraggedElement) && Boolean(this.oMousePos == null))
            {
               _mcContainer = this.oRenderer.mcContainer;
               _nX = 2 * (_mcContainer.mouseX - _mcContainer.width / 2) / _mcContainer.width;
               if(_nX > 1)
               {
                  _nX = 1;
               }
               if(_nX < -1)
               {
                  _nX = -1;
               }
               _nY = 2 * (_mcContainer.mouseY - _mcContainer.height / 2) / _mcContainer.width;
               if(_nY > 1)
               {
                  _nY = 1;
               }
               if(_nY < -1)
               {
                  _nY = -1;
               }
               _nOffsetX = _nX * _nSpeed;
               _nOffsetY = _nY * _nSpeed;
            }
            else
            {
               if(this.oKeyManager.isKeyDown(KeyCode.LEFT))
               {
                  _nOffsetX = -_nSpeed;
               }
               else if(this.oKeyManager.isKeyDown(KeyCode.RIGHT))
               {
                  _nOffsetX = _nSpeed;
               }
               if(this.oKeyManager.isKeyDown(KeyCode.UP))
               {
                  _nOffsetY = -_nSpeed;
               }
               else if(this.oKeyManager.isKeyDown(KeyCode.DOWN))
               {
                  _nOffsetY = _nSpeed;
               }
            }
            if(_nOffsetX != 0 || _nOffsetY != 0)
            {
               this.oRenderer.updateCenterPos(_oPos.x + _nOffsetX,_oPos.y + _nOffsetY);
            }
         }
      }
      
      private function dragStage() : void
      {
         var _oPos:Point = this.oRenderer.centerPos;
         var _nDeltaX:Number = this.oDragStagePos.x - this.oRenderer.mcContainer.mouseX;
         var _nDeltaY:Number = this.oDragStagePos.y - this.oRenderer.mcContainer.mouseY;
         this.oRenderer.updateCenterPos(_oPos.x + _nDeltaX * BuilderConfig.nDRAG_STAGE_SPEED,_oPos.y + _nDeltaY * BuilderConfig.nDRAG_STAGE_SPEED);
         this.oDragStagePos.x = this.oRenderer.mcContainer.mouseX;
         this.oDragStagePos.y = this.oRenderer.mcContainer.mouseY;
      }
      
      private function paint() : void
      {
         var _nDrawWidth:Number = NaN;
         var _nDrawHeight:Number = NaN;
         var _oBounds:AABB2 = null;
         var _aTiles:Array = null;
         var _oPos:Point = null;
         var _bDraw:Boolean = false;
         var _aElements:Array = null;
         var _oElement:BuilderElement = null;
         var _oNewElement:BuilderElement = null;
         if(Boolean(this.oTilePos) && Boolean(this.oLastPos))
         {
            _nDrawWidth = this.oSelectedItem.drawBounds.nXMax - this.oSelectedItem.drawBounds.nXMin;
            _nDrawHeight = this.oSelectedItem.drawBounds.nYMax - this.oSelectedItem.drawBounds.nYMin;
            _oBounds = new AABB2();
            _aTiles = this.listTileBetweenPoints(_nDrawWidth,_nDrawHeight);
            for each(_oPos in _aTiles)
            {
               _oBounds.nXMin = _oPos.x;
               _oBounds.nXMax = _oPos.x + _nDrawWidth;
               _oBounds.nYMin = _oPos.y;
               _oBounds.nYMax = _oPos.y + _nDrawHeight;
               _bDraw = true;
               _aElements = BuilderManager.instance.getElementInRegion(_oBounds);
               for each(_oElement in _aElements)
               {
                  if(_oElement.isUnique && _oElement.mediaType != this.oSelectedItem.media.type || _oElement == this.oLastPaintElement)
                  {
                     _bDraw = false;
                     break;
                  }
               }
               if(_bDraw)
               {
                  _oNewElement = BuilderData.createElementFromMedia(_oBounds.nXMin,_oBounds.nYMin,this.oSelectedItem.media,false,this.oSelectedItem.linkage);
                  BuilderManager.instance.addElement(_oNewElement);
                  this.oLastPaintElement = _oNewElement;
                  this.playSound(BuilderSoundConfig.aSND_ELEMENT_DROP,BuilderSoundConfig.nVOLUME_DROP);
                  dispatchEvent(new Event(sEVENT_ADDED));
               }
            }
         }
      }
      
      private function erase() : void
      {
         var _aPos:Array = null;
         var _oPos:Point = null;
         var _oElement:BuilderElement = null;
         if(Boolean(this.oTilePos) && Boolean(this.oLastPos))
         {
            _aPos = this.listTileBetweenPoints(CommonConfig.nCELL_SIZE,CommonConfig.nCELL_SIZE);
            for each(_oPos in _aPos)
            {
               _oElement = BuilderManager.instance.getElementAt(_oPos.x + CommonConfig.nCELL_SIZE / 2,_oPos.y + CommonConfig.nCELL_SIZE / 2);
               if(_oElement != null && _oElement.isUnique == false)
               {
                  BuilderManager.instance.removeElement(_oElement);
                  this.playSound(BuilderSoundConfig.aSND_ELEMENT_ERASE,BuilderSoundConfig.nVOLUME_ERASE);
                  dispatchEvent(new Event(sEVENT_REMOVED));
               }
            }
         }
      }
      
      private function updateMousePos() : void
      {
         if(Boolean(this.oRenderer) && Boolean(this.oRenderer.mcContainer.stage) && this.oMouseUtils.isMouseOver(this.oRenderer.mcContainer))
         {
            this.oMousePos = this.oRenderer.centerPos;
            this.oMousePos.x += (this.oRenderer.mcContainer.mouseX - this.oRenderer.mcContainer.width / 2) / this.oRenderer.zoom;
            this.oMousePos.y += (this.oRenderer.mcContainer.mouseY - this.oRenderer.mcContainer.height / 2) / this.oRenderer.zoom;
         }
         else
         {
            this.oMousePos = null;
         }
      }
      
      private function updateTilePos() : void
      {
         if(Boolean(this.oMousePos))
         {
            this.oTilePos = new Point();
            this.oTilePos.x = Math.floor(this.oMousePos.x / CommonConfig.nCELL_SIZE) * CommonConfig.nCELL_SIZE;
            this.oTilePos.y = Math.floor(this.oMousePos.y / CommonConfig.nCELL_SIZE) * CommonConfig.nCELL_SIZE;
            if(Boolean(this.oDragOffset))
            {
               this.oTilePos.x -= this.oDragOffset.x;
               this.oTilePos.y -= this.oDragOffset.y;
            }
         }
         else
         {
            this.oTilePos = null;
         }
      }
      
      private function updateRenderPos() : void
      {
         if(Boolean(this.oTilePos))
         {
            this.oRenderPos = this.oRenderer.centerPos;
            this.oRenderPos.x = (this.oTilePos.x - this.oRenderPos.x) * this.oRenderer.zoom;
            this.oRenderPos.y = (this.oTilePos.y - this.oRenderPos.y) * this.oRenderer.zoom;
         }
         else
         {
            this.oRenderPos = null;
         }
      }
      
      private function updateDrawBounds() : void
      {
         var _nWidth:Number = NaN;
         var _nHeight:Number = NaN;
         if(Boolean(this.oDraggedElement) && Boolean(this.oTilePos))
         {
            _nWidth = this.oDraggedElement.bounds.nXMax - this.oDraggedElement.bounds.nXMin;
            _nHeight = this.oDraggedElement.bounds.nYMax - this.oDraggedElement.bounds.nYMin;
            this.oDrawBounds = new AABB2(this.oTilePos.x,this.oTilePos.x + _nWidth,this.oTilePos.y,this.oTilePos.y + _nHeight);
         }
         else if(Boolean(this.oSelectedItem) && Boolean(this.oTilePos))
         {
            this.oDrawBounds = this.oSelectedItem.drawBounds.clone();
            this.oDrawBounds.offset(this.oTilePos.x,this.oTilePos.y);
         }
         else
         {
            this.oDrawBounds = null;
         }
      }
      
      private function updateDraggedBD() : void
      {
         var _oBD:BitmapData = null;
         if(Boolean(this.oDraggedElement))
         {
            _oBD = this.oDraggedElement.getBitmapData(this.oRenderer.zoom);
         }
         else if(this.currentTool == TOOL_PAINT)
         {
            if(Boolean(this.oSelectedItem))
            {
               _oBD = this.oSelectedItem.media.getPreview(this.oSelectedItem.linkage,this.oRenderer.zoom);
            }
         }
         if(Boolean(this.oCursor))
         {
            this.oCursor.draggedBD = _oBD;
         }
      }
      
      private function listTileBetweenPoints(_nCursorWidth:Number, _nCursorHeight:Number) : Array
      {
         var _oRect:Rectangle = null;
         var y:Number = NaN;
         var _nSlope:Number = NaN;
         var _nOffsetY:Number = NaN;
         var x:Number = NaN;
         var _oNewPos:Point = null;
         var _aReturn:Array = [];
         if(Boolean(this.oTilePos) && Boolean(this.oLastPos))
         {
            _oRect = new Rectangle();
            _oRect.left = Math.min(this.oTilePos.x,this.oLastPos.x);
            _oRect.right = Math.max(this.oTilePos.x,this.oLastPos.x);
            _oRect.top = Math.min(this.oTilePos.y,this.oLastPos.y);
            _oRect.bottom = Math.max(this.oTilePos.y,this.oLastPos.y);
            if(this.oTilePos.x == this.oLastPos.x)
            {
               for(y = _oRect.top; y <= _oRect.bottom; y += _nCursorHeight)
               {
                  _aReturn.push(new Point(this.oTilePos.x,y));
               }
            }
            else
            {
               _nSlope = (this.oTilePos.y - this.oLastPos.y) / (this.oTilePos.x - this.oLastPos.x);
               _nOffsetY = this.oTilePos.y - _nSlope * this.oTilePos.x;
               for(x = _oRect.left; x <= _oRect.right; x += _nCursorWidth)
               {
                  _oNewPos = new Point();
                  _oNewPos.x = x;
                  _oNewPos.y = Math.floor((_nSlope * x + _nOffsetY) / CommonConfig.nCELL_SIZE) * CommonConfig.nCELL_SIZE;
                  _aReturn.push(_oNewPos);
               }
            }
         }
         return _aReturn;
      }
      
      private function playSound(_aSound:Array, _nVolume:Number) : SoundUnit
      {
         var _cSfxClass:Class = Random.getArrayElement(_aSound) as Class;
         return SoundManager.instance.play(SoundConfig.sSOUND_CATEGORY_SOUNDS,AssetReference.fromLibraryClass(_cSfxClass),_nVolume);
      }
      
      private function onUpdate(_e:UpdateEvent) : void
      {
         var _oConfirmPopup:ConfirmPopup = null;
         var _oSavePopup:SavePopup = null;
         if(StepManager.instance.currentStepNumber == nBUILDER_STEP)
         {
            _oConfirmPopup = ViewManager.instance.getView(BuilderMain.sPOPUP_CONFIRM) as ConfirmPopup;
            _oSavePopup = ViewManager.instance.getView(BuilderMain.sPOPUP_SAVE) as SavePopup;
            if(!_oConfirmPopup.isDisplayed && !_oSavePopup.isDisplayed)
            {
               this.updateMousePos();
               this.updateTilePos();
               this.updateRenderPos();
               this.updateDrawBounds();
               this.updateScroll();
               if(this.oMouseUtils.isMouseUp() == false && this.oDraggedElement == null)
               {
                  if(Boolean(this.oDragStagePos))
                  {
                     this.dragStage();
                  }
                  else if(this.currentTool == TOOL_PAINT)
                  {
                     this.paint();
                  }
                  else if(this.currentTool == TOOL_ERASE)
                  {
                     this.erase();
                  }
               }
               if(Boolean(this.oLastPos) && Boolean(this.oTilePos))
               {
                  this.oLastPos = this.oTilePos;
               }
            }
         }
         this.nLastTime = getTimer();
      }
      
      private function onTileSelect(_e:Event) : void
      {
         this.oSelectedItem = this.oSelector.selectedValue;
         this.currentTool = TOOL_PAINT;
      }
      
      private function onBtnEraser(_e:UIEvent) : void
      {
         this.currentTool = TOOL_ERASE;
      }
      
      private function onBtnTrash(_e:UIEvent) : void
      {
         this.currentTool = TOOL_NONE;
      }
      
      private function onBtnZoom(_e:UIEvent) : void
      {
         if(this.oRenderer.zoom == BuilderRenderer.nMAX_ZOOM)
         {
            this.oRenderer.zoom = BuilderRenderer.nMIN_ZOOM;
         }
         else
         {
            this.oRenderer.zoom = BuilderRenderer.nMAX_ZOOM;
         }
         this.updateDraggedBD();
      }
      
      private function onBtnHero(_e:UIEvent) : void
      {
         BuilderManager.instance.targetHero();
      }
      
      private function onMouseDown(_e:MouseEvent) : void
      {
         var _bPainting:Boolean = false;
         var _oMouseElement:BuilderElement = null;
         if(Boolean(this.oMousePos))
         {
            _bPainting = false;
            _oMouseElement = BuilderManager.instance.getElementAt(this.oMousePos.x,this.oMousePos.y);
            if(this.currentTool == TOOL_ERASE)
            {
               _bPainting = true;
            }
            else if(this.currentTool == TOOL_PAINT)
            {
               _bPainting = true;
            }
            else
            {
               this.oDraggedElement = _oMouseElement;
               BuilderManager.instance.renderer.draggedElement = _oMouseElement;
               if(Boolean(this.oDraggedElement))
               {
                  this.playSound(BuilderSoundConfig.aSND_ELEMENT_GRAB,BuilderSoundConfig.nVOLUME_GRAB);
                  this.oDragOffset = new Point(this.oTilePos.x - this.oDraggedElement.bounds.nXMin,this.oTilePos.y - this.oDraggedElement.bounds.nYMin);
               }
            }
            if(_bPainting == false && _oMouseElement == null)
            {
               this.oDragStagePos = new Point(this.oRenderer.mcContainer.mouseX,this.oRenderer.mcContainer.mouseY);
            }
            if(Boolean(_bPainting) || Boolean(this.oDraggedElement) || Boolean(this.oDragStagePos))
            {
               this.startDrag();
            }
         }
      }
      
      private function onMouseUp(_e:MouseEvent) : void
      {
         if(Boolean(this.oDraggedElement))
         {
            if(this.isOverTrash)
            {
               if(this.oDraggedElement.isUnique == false)
               {
                  BuilderManager.instance.removeElement(this.oDraggedElement);
                  this.playSound(BuilderSoundConfig.aSND_ELEMENT_ERASE,BuilderSoundConfig.nVOLUME_ERASE);
                  dispatchEvent(new Event(sEVENT_REMOVED));
               }
            }
            else if(Boolean(this.oTilePos))
            {
               if(this.isOverUnerasable(this.oDraggedElement.mediaType) == false)
               {
                  if(this.oDraggedElement.flippable && this.oDraggedElement.bounds.nXMin == this.oTilePos.x && this.oDraggedElement.bounds.nYMin == this.oTilePos.y)
                  {
                     this.oDraggedElement.flip = !this.oDraggedElement.flip;
                  }
                  BuilderManager.instance.updateElementPos(this.oDraggedElement,this.oTilePos.x,this.oTilePos.y);
                  this.playSound(BuilderSoundConfig.aSND_ELEMENT_DROP,BuilderSoundConfig.nVOLUME_DROP);
                  dispatchEvent(new Event(sEVENT_UPDATED));
               }
            }
            BuilderManager.instance.renderer.invalidate();
         }
         BuilderManager.instance.renderer.draggedElement = null;
         this.oDragStagePos = null;
         this.oDraggedElement = null;
         this.oLastPaintElement = null;
         this.oDragOffset = null;
         this.stopDrag();
      }
      
      public function get currentTool() : uint
      {
         return this.nCurrentTool;
      }
      
      public function set currentTool(_nValue:uint) : void
      {
         this.nCurrentTool = _nValue;
         if(this.nCurrentTool != TOOL_PAINT)
         {
            if(Boolean(this.oSelector))
            {
               this.oSelector.selectNone();
            }
            this.oSelectedItem = null;
         }
         if(Boolean(this.oBtnErase))
         {
            this.oBtnErase.enabled = Boolean(this.nCurrentTool != TOOL_ERASE);
         }
         if(Boolean(this.oBtnMove))
         {
            this.oBtnMove.enabled = Boolean(this.nCurrentTool != TOOL_NONE);
         }
         this.updateDraggedBD();
      }
      
      public function get isOverTrash() : Boolean
      {
         var _bReturn:Boolean = false;
         if(this.oMousePos == null)
         {
            _bReturn = true;
         }
         return _bReturn;
      }
      
      public function get isDraggingStage() : Boolean
      {
         return Boolean(this.oDragStagePos != null);
      }
      
      public function get draggedElement() : BuilderElement
      {
         return this.oDraggedElement;
      }
      
      public function get selectedItem() : LibraryItemDefinition
      {
         return this.oSelectedItem;
      }
      
      public function set selectedItem(_oValue:LibraryItemDefinition) : void
      {
         if(_oValue != null)
         {
            this.oSelectedItem = _oValue;
            this.currentTool = TOOL_PAINT;
         }
         else
         {
            this.oSelectedItem = _oValue;
            this.currentTool = TOOL_NONE;
         }
      }
      
      public function set selector(_oValue:SelectionGrid) : void
      {
         this.oEventManager.cleanUp(sEVENT_SELECTION_ID);
         this.oSelector = _oValue;
         if(Boolean(this.oSelector))
         {
            this.oEventManager.addEventListener(sEVENT_SELECTION_ID,this.oSelector,UIEvent.CHANGE,this.onTileSelect);
         }
         else
         {
            this.selectedItem = null;
         }
      }
   }
}

