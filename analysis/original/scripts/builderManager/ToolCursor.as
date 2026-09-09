package builderManager
{
   import builderManager.elements.BuilderElement;
   import com.sarbakan.sbdk.input.MouseUtils;
   import com.sarbakan.sbdk.math.geom.AABB2;
   import com.sarbakan.sbdk.state.AnimStateMachine;
   import com.sarbakan.sbdk.view.ViewManager;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.geom.Point;
   import flash.ui.Mouse;
   import ui.popups.ConfirmPopup;
   import ui.popups.LoadConfirmPopup;
   import ui.popups.SavePopup;
   
   public class ToolCursor
   {
      
      private static const sSTATE_NONE:String = "None";
      
      private static const sSTATE_MOVE:String = "Move";
      
      private static const sSTATE_MOVE_DOWN:String = "MoveDown";
      
      private static const sSTATE_PAINT:String = "Paint";
      
      private static const sSTATE_PAINT_DOWN:String = "PaintDown";
      
      private static const sSTATE_PAINT_DENIED:String = "PaintDenied";
      
      private static const sSTATE_PAINT_TRASH:String = "PaintTrash";
      
      private static const sSTATE_ERASE:String = "Erase";
      
      private static const sSTATE_ERASE_DOWN:String = "EraseDown";
      
      private static const sSTATE_ERASE_DENIED:String = "EraseDenied";
      
      private static const sSTATE_ERASE_TRASH:String = "EraseTrash";
      
      private static const sSTATE_DRAG:String = "Drag";
      
      private static const sSTATE_DRAG_DOWN:String = "DragDown";
      
      private static const sSTATE_DRAG_DENIED:String = "DragDenied";
      
      private static const sSTATE_DRAG_TRASH:String = "DragTrash";
      
      public var mcContainer:Sprite;
      
      private var mcCursor:MovieClip;
      
      private var oStateMachine:AnimStateMachine;
      
      private var oDrawGuide:Shape;
      
      private var bShowGuide:Boolean;
      
      private var oBitmap:Bitmap;
      
      private var oManager:ToolManager;
      
      private var oMouseUtils:MouseUtils;
      
      public function ToolCursor(_oManager:ToolManager)
      {
         super();
         this.oManager = _oManager;
         this.oMouseUtils = MouseUtils.instance(ViewManager.instance.stage);
         this.mcContainer = new Sprite();
         this.mcContainer.mouseEnabled = false;
         this.mcContainer.mouseChildren = false;
         this.oDrawGuide = new Shape();
         this.mcContainer.addChild(this.oDrawGuide);
         this.oBitmap = new Bitmap();
         this.mcContainer.addChild(this.oBitmap);
         this.initStateMachine();
      }
      
      public function destroy() : void
      {
         if(Boolean(this.oStateMachine))
         {
            this.oStateMachine.destroy();
         }
         this.oStateMachine = null;
         this.oManager = null;
         this.oBitmap = null;
         this.oDrawGuide = null;
         this.mcCursor = null;
         this.mcContainer = null;
         this.oMouseUtils = null;
         Mouse.show();
      }
      
      private function initStateMachine() : void
      {
         this.mcCursor = new mcMouseCursor();
         this.mcContainer.addChildAt(this.mcCursor,0);
         this.oStateMachine = new AnimStateMachine(this.mcCursor,false);
         this.oStateMachine.addState(sSTATE_NONE,this.updateCursor,this.state_noneInit,this.state_noneEnd);
         this.oStateMachine.addState(sSTATE_MOVE,this.updateCursor);
         this.oStateMachine.addState(sSTATE_MOVE_DOWN,this.updateCursor);
         this.oStateMachine.addState(sSTATE_PAINT,this.updateCursor);
         this.oStateMachine.addState(sSTATE_PAINT_DOWN,this.updateCursor);
         this.oStateMachine.addState(sSTATE_PAINT_DENIED,this.updateCursor);
         this.oStateMachine.addState(sSTATE_PAINT_TRASH,this.updateCursor);
         this.oStateMachine.addState(sSTATE_ERASE,this.updateCursor);
         this.oStateMachine.addState(sSTATE_ERASE_DOWN,this.updateCursor);
         this.oStateMachine.addState(sSTATE_ERASE_DENIED,this.updateCursor);
         this.oStateMachine.addState(sSTATE_ERASE_TRASH,this.updateCursor);
         this.oStateMachine.addState(sSTATE_DRAG,this.updateCursor,this.state_handIdleInit,this.state_handIdleEnd);
         this.oStateMachine.addState(sSTATE_DRAG_DOWN,this.updateCursor);
         this.oStateMachine.addState(sSTATE_DRAG_DENIED,this.updateCursor);
         this.oStateMachine.addState(sSTATE_DRAG_TRASH,this.updateCursor);
         this.oStateMachine.setState(sSTATE_NONE);
      }
      
      private function state_noneInit() : void
      {
         this.oBitmap.visible = false;
         this.bShowGuide = false;
      }
      
      private function state_noneEnd() : void
      {
         this.oBitmap.visible = true;
         this.bShowGuide = true;
      }
      
      private function state_handIdleInit() : void
      {
         this.oBitmap.visible = false;
         this.bShowGuide = false;
      }
      
      private function state_handIdleEnd() : void
      {
         this.oBitmap.visible = true;
         this.bShowGuide = true;
      }
      
      private function updateCursor() : void
      {
         var _sState:String = null;
         var _bDown:Boolean = false;
         var _oMousePos:Point = null;
         var _oMouseElement:BuilderElement = null;
         var _mcRenderer:MovieClip = null;
         var _oConfirmPopup:ConfirmPopup = ViewManager.instance.getView(BuilderMain.sPOPUP_CONFIRM) as ConfirmPopup;
         var _oSavePopup:SavePopup = ViewManager.instance.getView(BuilderMain.sPOPUP_SAVE) as SavePopup;
         var _oLoadPopup:LoadConfirmPopup = ViewManager.instance.getView(BuilderMain.sPOPUP_LOAD_CONFIRM) as LoadConfirmPopup;
         if(_oConfirmPopup.isDisplayed || _oSavePopup.isDisplayed || _oLoadPopup.isDisplayed)
         {
            this.oStateMachine.setState(sSTATE_NONE);
            Mouse.show();
         }
         else
         {
            _bDown = Boolean(this.oMouseUtils.isMouseUp() == false);
            _oMousePos = this.oManager.oMousePos;
            if(Boolean(_oMousePos))
            {
               _oMouseElement = BuilderManager.instance.getElementAt(_oMousePos.x,_oMousePos.y);
            }
            if(Boolean(this.oManager.draggedElement))
            {
               if(this.oManager.isOverTrash && this.oManager.draggedElement.isUnique == false)
               {
                  _sState = sSTATE_DRAG_TRASH;
               }
               else if(this.oManager.isOverUnerasable(this.oManager.draggedElement.mediaType) || _oMousePos == null)
               {
                  _sState = sSTATE_DRAG_DENIED;
               }
               else
               {
                  _sState = sSTATE_DRAG_DOWN;
               }
            }
            if(_sState == null && this.oManager.currentTool == ToolManager.TOOL_NONE)
            {
               if(this.oManager.isDraggingStage)
               {
                  _sState = sSTATE_MOVE_DOWN;
               }
               else if(Boolean(_oMouseElement))
               {
                  _sState = sSTATE_DRAG;
               }
               else if(Boolean(_oMousePos))
               {
                  _sState = sSTATE_MOVE;
               }
               else
               {
                  _sState = sSTATE_NONE;
               }
            }
            if(_sState == null && this.oManager.currentTool == ToolManager.TOOL_PAINT)
            {
               if(Boolean(_oMousePos))
               {
                  if(this.oManager.isOverUnerasable(this.oManager.selectedItem.media.type))
                  {
                     _sState = sSTATE_PAINT_DENIED;
                  }
                  else if(_bDown)
                  {
                     _sState = sSTATE_PAINT_DOWN;
                  }
                  else
                  {
                     _sState = sSTATE_PAINT;
                  }
               }
               else if(StepManager.instance.currentStep.id == StepManager.sSTEP_BUILDER)
               {
                  _sState = sSTATE_NONE;
               }
               else
               {
                  _sState = sSTATE_DRAG_DOWN;
               }
            }
            if(_sState == null && this.oManager.currentTool == ToolManager.TOOL_ERASE)
            {
               if(Boolean(_oMousePos))
               {
                  if(_oMouseElement == null || _oMouseElement.isUnique == false)
                  {
                     if(_bDown)
                     {
                        _sState = sSTATE_ERASE_DOWN;
                     }
                     else
                     {
                        _sState = sSTATE_ERASE;
                     }
                  }
                  else
                  {
                     _sState = sSTATE_ERASE_DENIED;
                  }
               }
               else if(this.oManager.isOverTrash)
               {
                  _sState = sSTATE_ERASE_TRASH;
               }
               else
               {
                  _sState = sSTATE_NONE;
               }
            }
            this.oStateMachine.setState(_sState);
            this.mcCursor.x = this.mcContainer.mouseX;
            this.mcCursor.y = this.mcContainer.mouseY;
            if(Boolean(_oMousePos))
            {
               _mcRenderer = BuilderManager.instance.renderer.mcContainer;
               this.oBitmap.x = _mcRenderer.x + _mcRenderer.width / 2 + this.oManager.oRenderPos.x;
               this.oBitmap.y = _mcRenderer.y + _mcRenderer.height / 2 + this.oManager.oRenderPos.y;
               this.oDrawGuide.x = this.oBitmap.x;
               this.oDrawGuide.y = this.oBitmap.y;
               this.oDrawGuide.visible = this.bShowGuide;
            }
            else
            {
               this.oBitmap.x = this.mcContainer.mouseX;
               this.oBitmap.y = this.mcContainer.mouseY;
               this.oDrawGuide.visible = false;
            }
            if(this.oStateMachine.isState(sSTATE_NONE))
            {
               Mouse.show();
            }
            else
            {
               Mouse.hide();
            }
         }
      }
      
      public function set draggedBD(_oValue:BitmapData) : void
      {
         var _oDrawBounds:AABB2 = null;
         var _nZoom:Number = NaN;
         var _nX:Number = NaN;
         var _nY:Number = NaN;
         var _nWidth:Number = NaN;
         var _nHeight:Number = NaN;
         this.oBitmap.bitmapData = _oValue;
         this.oDrawGuide.graphics.clear();
         if(Boolean(_oValue))
         {
            if(ToolManager.instance.draggedElement != null)
            {
               _oDrawBounds = ToolManager.instance.draggedElement.bounds;
            }
            else
            {
               _oDrawBounds = ToolManager.instance.selectedItem.drawBounds;
            }
            _nZoom = BuilderManager.instance.renderer.zoom;
            _nX = _oDrawBounds.nXMin % CommonConfig.nCELL_SIZE;
            _nY = _oDrawBounds.nYMin % CommonConfig.nCELL_SIZE;
            _nWidth = Math.ceil((_oDrawBounds.nXMax - _oDrawBounds.nXMin) / CommonConfig.nCELL_SIZE) * CommonConfig.nCELL_SIZE;
            _nHeight = Math.ceil((_oDrawBounds.nYMax - _oDrawBounds.nYMin) / CommonConfig.nCELL_SIZE) * CommonConfig.nCELL_SIZE;
            this.oDrawGuide.graphics.beginFill(13421772,0.4);
            this.oDrawGuide.graphics.drawRect(_nX,_nY,_nWidth * _nZoom,_nHeight * _nZoom);
            this.oDrawGuide.graphics.endFill();
         }
      }
   }
}

