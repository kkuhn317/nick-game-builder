package com.sarbakan.sbdk.blitting.core
{
   import com.sarbakan.sbdk.core.UpdateManager;
   import com.sarbakan.sbdk.data.spatialIndexing.ISpatialIndexElement;
   import com.sarbakan.sbdk.utils.EventManager;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.getQualifiedClassName;
   import flash.utils.getQualifiedSuperclassName;
   
   public class BitmappedAnimContainer extends Sprite
   {
      
      private static const sSTAGE_EVENT:String = "STAGE_EVENT";
      
      private static const sENTER_FRAME_EVENT:String = "ENTER_FRAME_EVENT";
      
      private static const sUPDATE_EVENT:String = "UPDATE_EVENT";
      
      private static const sMOUSE_EVENT:String = "MOUSE_EVENT";
      
      private static const sMCANIMATION:String = "com.sarbakan.sbdk.blitting.core::MCAnimation";
      
      private static const sBITMAPPED_ANIM_STATE_MACHINE:String = "com.sarbakan.sbdk.blitting.core::BitmappedAnimStateMachine";
      
      private var oEventManager:EventManager;
      
      private var oDepthManager:BitmappedAnimDepthManager;
      
      private var oUpdateManager:UpdateManager;
      
      private var nSurfaceWidth:uint;
      
      private var nSurfaceHeight:uint;
      
      private var nViewWidth:uint;
      
      private var nViewHeight:uint;
      
      private var nViewX:Number;
      
      private var nViewY:Number;
      
      private var aDisplayList:Array;
      
      private var oViewRect:Rectangle;
      
      private var oBlitPoint:Point;
      
      private var nZoom:Number;
      
      private var bMouseEnabled:Boolean;
      
      private var oMouseTargetAnim:IBitmappedAnimation;
      
      private var oCanvas:Bitmap;
      
      private var aBufferList:Array;
      
      private var oZoomBuffer:BitmapData;
      
      private var nBufferIndex:uint;
      
      private var bZooming:Boolean;
      
      private var oMatrix:Matrix;
      
      public function BitmappedAnimContainer(_nSurfaceWidth:uint, _nSurfaceHeight:uint, _nViewWidth:uint, _nViewHeight:uint, _nInitX:Number = 0, _nInitY:Number = 0)
      {
         super();
         this.nSurfaceWidth = _nSurfaceWidth;
         this.nSurfaceHeight = _nSurfaceHeight;
         this.nViewWidth = _nViewWidth;
         this.nViewHeight = _nViewHeight;
         this.nViewX = _nInitX;
         this.nViewY = _nInitY;
         this.init();
      }
      
      public function destroy() : void
      {
         this.oEventManager.destroy();
         this.oEventManager = null;
         this.oDepthManager.destroy();
         this.oDepthManager = null;
         this.aDisplayList = null;
         this.oViewRect = null;
         this.oBlitPoint = null;
         for(var i:int = 0; i < this.aBufferList.length; i++)
         {
            this.aBufferList[i].dispose();
         }
         this.aBufferList.splice(0,this.aBufferList.length);
         this.aBufferList = null;
         if(this.oZoomBuffer != null)
         {
            this.oZoomBuffer.dispose();
            this.oZoomBuffer = null;
         }
         this.oMatrix = null;
         this.oMouseTargetAnim = null;
         this.removeChild(this.oCanvas);
      }
      
      public function addLayer(_sLayerID:String, _nDepth:int = -1, _nXOffset:Number = 1, _nYOffset:Number = 1) : void
      {
         this.oDepthManager.addLayer(_sLayerID,_nDepth,_nXOffset,_nYOffset,this.nSurfaceWidth,this.nSurfaceHeight);
      }
      
      public function removeLayer(_sLayerID:String) : Boolean
      {
         return this.oDepthManager.removeLayer(_sLayerID);
      }
      
      public function setAnimationLayer(_oAnimation:IBitmappedAnimation, _sLayerID:String, _nDepth:int = -1) : void
      {
         this.oDepthManager.setAnimationLayer(_oAnimation,_sLayerID,_nDepth);
      }
      
      public function setAnimationDepth(_oAnimation:IBitmappedAnimation, _nDepth:int = -1) : void
      {
         this.oDepthManager.setAnimationDepth(_oAnimation,_nDepth);
      }
      
      public function getLayer(_sLayerID:String) : LayerInfoStruct
      {
         return this.oDepthManager.getLayer(_sLayerID);
      }
      
      public function getLayerElements(_sLayerID:String, _bMoving:Boolean) : Array
      {
         var _oLayerInfo:LayerInfoStruct = this.oDepthManager.getLayer(_sLayerID);
         if(_oLayerInfo != null)
         {
            if(_bMoving)
            {
               return _oLayerInfo.QT.queryRectangle(this.oViewRect);
            }
            return _oLayerInfo.SAP.queryRectangle(this.oViewRect);
         }
         return null;
      }
      
      public function swapLayer(_sLayerID1:String, _sLayerID2:String) : void
      {
         this.oDepthManager.swapLayer(_sLayerID1,_sLayerID2);
      }
      
      public function setLayerDepth(_sLayerID:String, _nDepth:int) : void
      {
         this.oDepthManager.setLayerDepth(_sLayerID,_nDepth);
      }
      
      public function addBitmappedAnimation(_oAnimation:IBitmappedAnimation, _sLayer:String, _nDepth:int = -1, _bMoving:Boolean = false) : void
      {
         if(_oAnimation.container != null)
         {
            return;
         }
         _oAnimation.setContainer(this);
         _oAnimation.moving = _bMoving;
         this.oDepthManager.addAnimation(_oAnimation,_sLayer,_nDepth);
      }
      
      public function removeAnimation(_oAnimation:IBitmappedAnimation) : void
      {
         this.oDepthManager.removeAnimation(_oAnimation);
         _oAnimation.setContainer(null);
         _oAnimation.spatialIndexHandler = null;
         _oAnimation.layer = "";
         _oAnimation.layerDepth = 0;
         _oAnimation.depth = 0;
      }
      
      public function containsAnimation(_oAnimation:IBitmappedAnimation) : Boolean
      {
         return this.oDepthManager.containsAnimation(_oAnimation);
      }
      
      public function addMovieClip(_oClass:Class, _nX:uint, _nY:uint, _sLayer:String, _nDepth:int = -1, _bMoving:Boolean = false, _sType:String = "DYNAMIC", _bCheckForCollider:Boolean = false) : MCAnimation
      {
         var _oAnimation:MCAnimation = new MCAnimation(_oClass,_nX,_nY,_sLayer,_nDepth,_sType,_bCheckForCollider);
         _oAnimation.moving = _bMoving;
         _oAnimation.setContainer(this);
         this.oDepthManager.addAnimation(_oAnimation,_sLayer,_nDepth);
         return _oAnimation;
      }
      
      public function clear(_sLayer:String = null) : void
      {
         this.oDepthManager.clearLayer(_sLayer);
      }
      
      public function getNumChildren(_sLayer:String = null) : int
      {
         return this.oDepthManager.getNumChildren(_sLayer);
      }
      
      public function display(_nX:uint, _nY:uint) : void
      {
         this.nViewX = _nX;
         this.nViewY = _nY;
      }
      
      private function init() : void
      {
         this.oEventManager = new EventManager();
         this.oEventManager.addEventListener(sSTAGE_EVENT,this,Event.ADDED_TO_STAGE,this.onAddedToStage);
         this.oEventManager.addEventListener(sSTAGE_EVENT,this,Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
         this.oEventManager.addEventListener(sMOUSE_EVENT,this,MouseEvent.MOUSE_DOWN,this.onMouseEvent);
         this.oEventManager.addEventListener(sMOUSE_EVENT,this,MouseEvent.MOUSE_UP,this.onMouseEvent);
         this.oDepthManager = new BitmappedAnimDepthManager();
         this.aDisplayList = this.oDepthManager.displayList;
         this.oViewRect = new Rectangle();
         this.oBlitPoint = new Point();
         this.aBufferList = new Array();
         this.aBufferList[0] = new BitmapData(this.nViewWidth,this.nViewHeight);
         this.aBufferList[1] = new BitmapData(this.nViewWidth,this.nViewHeight);
         this.nBufferIndex = 0;
         this.oCanvas = new Bitmap(this.aBufferList[this.nBufferIndex]);
         this.addChild(this.oCanvas);
         this.nZoom = 1;
         this.bMouseEnabled = false;
         this.oUpdateManager = UpdateManager.instance;
      }
      
      private function blit(_oBackbuffer:BitmapData, _oAnimRef:IBitmappedAnimation, _nXOffset:Number, _nYOffset:Number, _oFrameData:BitmapData) : void
      {
         var _oRect:Rectangle = _oAnimRef.frameRect;
         this.oBlitPoint.x = Math.floor((_oAnimRef.x + _oRect.left - this.nViewX) * _nXOffset);
         this.oBlitPoint.y = Math.floor((_oAnimRef.y + _oRect.top - this.nViewY) * _nYOffset);
         _oBackbuffer.copyPixels(_oFrameData,_oFrameData.rect,this.oBlitPoint,null,null,true);
      }
      
      private function cleanBackground(_oBuffer:BitmapData) : void
      {
         _oBuffer.fillRect(_oBuffer.rect,0);
      }
      
      private function compareArray(_aArray_1:Array, _aArray_2:Array) : Array
      {
         var _oItem:* = undefined;
         var _aDiffList:Array = new Array();
         for each(_oItem in _aArray_1)
         {
            if(_aArray_2.indexOf(_oItem) == -1)
            {
               _aDiffList.push(_oItem);
            }
         }
         return _aDiffList;
      }
      
      private function resizeViewCanvas(_nWidth:uint, _nHeight:uint) : void
      {
         this.aBufferList[0].dispose();
         this.aBufferList[1].dispose();
         this.aBufferList[0] = new BitmapData(_nWidth,_nHeight);
         this.aBufferList[1] = new BitmapData(_nWidth,_nHeight);
         this.oCanvas.bitmapData = this.aBufferList[this.nBufferIndex];
      }
      
      private function flip() : void
      {
         if(this.nBufferIndex == 0)
         {
            this.nBufferIndex = 1;
         }
         else
         {
            this.nBufferIndex = 0;
         }
         this.oCanvas.bitmapData = this.aBufferList[this.nBufferIndex];
         if(this.bZooming)
         {
            this.oZoomBuffer.copyPixels(this.oCanvas.bitmapData,this.oCanvas.bitmapData.rect,new Point(0,0));
            this.oCanvas.bitmapData.fillRect(this.oCanvas.bitmapData.rect,0);
            this.oCanvas.bitmapData.draw(this.oZoomBuffer,this.oMatrix,null,null,null,true);
         }
      }
      
      private function onMouseEvent(oEvent:MouseEvent) : void
      {
         var _oLayerInfo:LayerInfoStruct = null;
         var _aSAPResult:Array = null;
         var _aQTResult:Array = null;
         var _aResult:Array = null;
         var j:int = 0;
         var _nLayeDepth:int = 0;
         var _aABSDisplayList:Array = new Array();
         var _nRelativeX:Number = this.viewX + oEvent.localX;
         var _nRelativeY:Number = this.viewY + oEvent.localY;
         for(var i:int = 0; i < this.aDisplayList.length; i++)
         {
            _oLayerInfo = this.aDisplayList[i];
            _aSAPResult = _oLayerInfo.SAP.queryBounds(_nRelativeX,_nRelativeX,_nRelativeY,_nRelativeY);
            _aQTResult = _oLayerInfo.QT.queryBounds(_nRelativeX,_nRelativeX,_nRelativeY,_nRelativeY);
            _aResult = _aSAPResult.concat(_aQTResult);
            for(j = 0; j < _aResult.length; j++)
            {
               if(Boolean(_aResult[j].data.mouseEnabled))
               {
                  _aABSDisplayList.push(_aResult[j]);
               }
            }
         }
         _aABSDisplayList.sort(this.sortLayerDepth);
         if(_aABSDisplayList.length > 0)
         {
            _nLayeDepth = int(_aABSDisplayList[_aABSDisplayList.length - 1].data.layerDepth);
            for(i = 0; i < _aABSDisplayList.length; i++)
            {
               if(!_aABSDisplayList[i].data.rect.contains(_nRelativeX,_nRelativeY))
               {
                  _aABSDisplayList.splice(i,1);
                  i--;
               }
            }
            for(i = 0; i < _aABSDisplayList.length; i++)
            {
               if(_aABSDisplayList.length > 1 && _aABSDisplayList[i].data.layerDepth != _nLayeDepth)
               {
                  _aABSDisplayList.splice(i,1);
                  i--;
               }
            }
            if(_aABSDisplayList.length > 0)
            {
               _aABSDisplayList.sort(this.sortDepth);
               _aABSDisplayList[_aABSDisplayList.length - 1].data.onMouseEvent(oEvent);
               if(this.oMouseTargetAnim != _aABSDisplayList[_aABSDisplayList.length - 1].data)
               {
                  if(this.oMouseTargetAnim != null)
                  {
                     this.oMouseTargetAnim.onMouseOut(oEvent);
                     this.oMouseTargetAnim = null;
                  }
               }
               this.oMouseTargetAnim = _aABSDisplayList[_aABSDisplayList.length - 1].data;
            }
            else if(this.oMouseTargetAnim != null)
            {
               this.oMouseTargetAnim.onMouseOut(oEvent);
               this.oMouseTargetAnim = null;
            }
         }
      }
      
      private function onAddedToStage(_oEvent:Event) : void
      {
         this.oEventManager.addEventListener(sENTER_FRAME_EVENT,this,Event.ENTER_FRAME,this.update);
      }
      
      private function onRemovedFromStage(_oEvent:Event) : void
      {
         this.oEventManager.cleanUp(sENTER_FRAME_EVENT);
         this.oEventManager.cleanUp(sUPDATE_EVENT);
      }
      
      private function sortLayerDepth(_oHandler_1:ISpatialIndexElement, _oHandler_2:ISpatialIndexElement) : Number
      {
         var _nDepth_1:int = int(_oHandler_1.data.layerDepth);
         var _nDepth_2:int = int(_oHandler_2.data.layerDepth);
         if(_nDepth_1 > _nDepth_2)
         {
            return 1;
         }
         if(_nDepth_1 < _nDepth_2)
         {
            return -1;
         }
         return 0;
      }
      
      private function sortDepth(_oHandler_1:ISpatialIndexElement, _oHandler_2:ISpatialIndexElement) : Number
      {
         var _nDepth_1:int = int(_oHandler_1.data.depth);
         var _nDepth_2:int = int(_oHandler_2.data.depth);
         if(_nDepth_1 > _nDepth_2)
         {
            return 1;
         }
         if(_nDepth_1 < _nDepth_2)
         {
            return -1;
         }
         return 0;
      }
      
      private function update(_oEvent:Event) : void
      {
         var _oLayerInfo:LayerInfoStruct = null;
         var _aSAPResult:Array = null;
         var _aQTResult:Array = null;
         var _aResult:Array = null;
         var _sClassName:String = null;
         var _sSuperClassName:String = null;
         var _nLength:int = 0;
         var j:int = 0;
         var _oFrameData:BitmapData = null;
         var _aDiffList:Array = null;
         this.backBuffer.lock();
         this.cleanBackground(this.backBuffer);
         for(var i:int = 0; i < this.aDisplayList.length; i++)
         {
            _oLayerInfo = this.aDisplayList[i];
            _oLayerInfo.SAP.update();
            if(_oLayerInfo.xOffset != 1)
            {
               this.oViewRect.left = this.nViewX - this.nViewWidth;
               this.oViewRect.right = this.nViewX + this.viewWidth * 2;
            }
            else
            {
               this.oViewRect.left = this.nViewX;
               this.oViewRect.right = this.nViewX + this.viewWidth;
            }
            if(_oLayerInfo.yOffset != 1)
            {
               this.oViewRect.top = this.nViewY - this.nViewHeight;
               this.oViewRect.bottom = this.nViewY + this.viewHeight * 2;
            }
            else
            {
               this.oViewRect.top = this.nViewY;
               this.oViewRect.bottom = this.nViewY + this.viewHeight;
            }
            _aSAPResult = _oLayerInfo.SAP.queryRectangle(this.oViewRect);
            _aQTResult = _oLayerInfo.QT.queryRectangle(this.oViewRect);
            _aResult = _aSAPResult.concat(_aQTResult);
            _aResult.sort(this.sortDepth);
            _nLength = int(_aResult.length);
            for(j = 0; j < _nLength; j++)
            {
               _sClassName = getQualifiedClassName(_aResult[j].data);
               _sSuperClassName = getQualifiedSuperclassName(_aResult[j].data);
               _aResult[j].data.setDisplayed(true);
               if(_sClassName == sMCANIMATION || _sClassName == sBITMAPPED_ANIM_STATE_MACHINE || _sSuperClassName == sBITMAPPED_ANIM_STATE_MACHINE)
               {
                  _aResult[j].data.draw();
               }
               _oFrameData = _aResult[j].data.frameData;
               if(_oFrameData != null)
               {
                  this.blit(this.backBuffer,_aResult[j].data,_oLayerInfo.xOffset,_oLayerInfo.yOffset,_oFrameData);
               }
            }
            if(_oLayerInfo.viewSortList != null)
            {
               _aDiffList = this.compareArray(_oLayerInfo.viewSortList,_aResult);
               _nLength = int(_aDiffList.length);
               for(j = 0; j < _nLength; j++)
               {
                  if(_aDiffList[j].data is MCAnimation)
                  {
                     _aDiffList[j].data.kill();
                  }
                  if(_aDiffList[j].data != null)
                  {
                     _aDiffList[j].data.setDisplayed(false);
                  }
               }
            }
            _oLayerInfo.viewSortList = _aResult;
         }
         this.backBuffer.unlock();
         this.flip();
      }
      
      public function get zoom() : Number
      {
         return this.nZoom;
      }
      
      public function set zoom(_nValue:Number) : void
      {
         this.nZoom = _nValue;
         if(this.nZoom != 1)
         {
            if(this.oZoomBuffer == null)
            {
               this.oZoomBuffer = new BitmapData(this.oCanvas.width,this.oCanvas.height,true,0);
            }
            if(this.oMatrix == null)
            {
               this.oMatrix = new Matrix();
            }
            this.oMatrix.a = _nValue;
            this.oMatrix.d = _nValue;
            this.oMatrix.tx = (this.oCanvas.width - this.oCanvas.width * this.oMatrix.a) / 2;
            this.oMatrix.ty = (this.oCanvas.height - this.oCanvas.height * this.oMatrix.d) / 2;
            this.bZooming = true;
         }
         else
         {
            this.bZooming = false;
            if(this.oMatrix != null)
            {
               this.oMatrix = null;
            }
            if(this.oZoomBuffer != null)
            {
               this.oZoomBuffer.dispose();
               this.oZoomBuffer = null;
            }
         }
      }
      
      public function get backBuffer() : BitmapData
      {
         if(this.nBufferIndex == 0)
         {
            return this.aBufferList[1];
         }
         return this.aBufferList[0];
      }
      
      override public function get mouseEnabled() : Boolean
      {
         return this.bMouseEnabled;
      }
      
      override public function set mouseEnabled(_bValue:Boolean) : void
      {
         if(_bValue)
         {
            this.oEventManager.addEventListener(sMOUSE_EVENT,this,MouseEvent.MOUSE_DOWN,this.onMouseEvent);
            this.oEventManager.addEventListener(sMOUSE_EVENT,this,MouseEvent.MOUSE_UP,this.onMouseEvent);
            this.oEventManager.addEventListener(sMOUSE_EVENT,this,MouseEvent.MOUSE_MOVE,this.onMouseEvent);
         }
         else
         {
            this.oEventManager.cleanUp(sMOUSE_EVENT);
         }
      }
      
      public function get surfaceWidth() : uint
      {
         return this.nSurfaceWidth;
      }
      
      public function get surfaceHeight() : uint
      {
         return this.nSurfaceHeight;
      }
      
      public function get viewWidth() : uint
      {
         return this.nViewWidth;
      }
      
      public function set viewWidth(_nValue:uint) : void
      {
         this.nViewWidth = _nValue;
         this.resizeViewCanvas(this.nViewWidth,this.nViewHeight);
      }
      
      public function get viewHeight() : uint
      {
         return this.nViewHeight;
      }
      
      public function set viewHeight(_nValue:uint) : void
      {
         this.nViewHeight = _nValue;
         this.resizeViewCanvas(this.nViewWidth,this.nViewHeight);
      }
      
      public function get viewX() : Number
      {
         return this.nViewX;
      }
      
      public function set viewX(_nValue:Number) : void
      {
         this.nViewX = _nValue;
      }
      
      public function get viewY() : Number
      {
         return this.nViewY;
      }
      
      public function set viewY(_nValue:Number) : void
      {
         this.nViewY = _nValue;
      }
      
      public function get viewRect() : Rectangle
      {
         this.oViewRect.left = this.nViewX;
         this.oViewRect.top = this.nViewY;
         this.oViewRect.right = this.oViewRect.left + this.viewWidth;
         this.oViewRect.bottom = this.oViewRect.top + this.viewHeight;
         return this.oViewRect;
      }
   }
}

