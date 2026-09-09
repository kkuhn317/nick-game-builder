package com.sarbakan.sbdk.view
{
   import com.sarbakan.sbdk.utils.ObjectList;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   
   public class DepthManager
   {
      
      private var mcContainer:DisplayObjectContainer;
      
      private var lLayerList:ObjectList;
      
      private var lMCList:ObjectList;
      
      public function DepthManager(_mcContainer:DisplayObjectContainer)
      {
         super();
         this.mcContainer = _mcContainer;
         this.init();
      }
      
      public function addLayer(_sLayerID:String, _nDepth:int = -1) : Sprite
      {
         var _mcLayer:Sprite = new Sprite();
         if(_nDepth <= 0)
         {
            this.mcContainer.addChild(_mcLayer);
         }
         else
         {
            this.mcContainer.addChildAt(_mcLayer,_nDepth);
         }
         this.lLayerList.insert(_sLayerID,_mcLayer);
         return _mcLayer;
      }
      
      public function addLayerToLayer(_sLayerID:String, _sTargetLayerID:String, _nDepth:int = -1) : Sprite
      {
         var _mcLayer:Sprite = new Sprite();
         var _mcTargetLayer:Sprite = this.getLayer(_sTargetLayerID);
         if(_mcTargetLayer != null)
         {
            if(_nDepth <= 0)
            {
               _mcTargetLayer.addChild(_mcLayer);
            }
            else
            {
               _mcTargetLayer.addChildAt(_mcLayer,_nDepth);
            }
         }
         this.lLayerList.insert(_sLayerID,_mcLayer);
         return _mcLayer;
      }
      
      public function removeLayer(_sLayerID:String) : void
      {
         var _mcLayer:Sprite = this.lLayerList.find(_sLayerID) as Sprite;
         this.mcContainer.removeChild(_mcLayer);
         this.lLayerList.remove(_sLayerID);
      }
      
      public function getDisplayObjectLayer(_mcRef:DisplayObject) : String
      {
         var i:* = undefined;
         for each(i in this.lMCList.object)
         {
            if(i.mc == _mcRef)
            {
               return i.layerID;
            }
         }
         return null;
      }
      
      public function getLayer(_sLayerID:String) : Sprite
      {
         return this.lLayerList.find(_sLayerID) as Sprite;
      }
      
      public function swapLayer(_sLayerID1:String, _sLayerID2:String) : void
      {
         var _mcLayer1:Sprite = this.lLayerList.find(_sLayerID1) as Sprite;
         var _mcLayer2:Sprite = this.lLayerList.find(_sLayerID2) as Sprite;
         this.mcContainer.swapChildren(_mcLayer1,_mcLayer2);
      }
      
      public function setLayerDepth(_sLayerID:String, _nDepth:int) : void
      {
         var _mcLayer:Sprite = this.lLayerList.find(_sLayerID) as Sprite;
         this.mcContainer.setChildIndex(_mcLayer,_nDepth);
      }
      
      public function addDisplayObject(_sId:String, _mcRef:DisplayObject, _sLayerID:String, _nDepth:int = -1) : void
      {
         var _oTargetLayer:Sprite = this.getLayer(_sLayerID);
         if(_oTargetLayer != null)
         {
            this.lMCList.insert(_sId,{
               "mc":_mcRef,
               "layerID":_sLayerID
            });
            if(_nDepth == -1)
            {
               _oTargetLayer.addChild(_mcRef);
            }
            else
            {
               _oTargetLayer.addChildAt(_mcRef,_nDepth);
            }
         }
      }
      
      public function removeDisplayObject(_sId:String) : void
      {
         var _oConfig:Object = this.lMCList.find(_sId);
         var _mcTarget:DisplayObject = _oConfig.mc;
         var _oDepth:Sprite = this.getLayer(_oConfig.layerID);
         if(_mcTarget != null)
         {
            if(_oDepth.contains(_mcTarget))
            {
               _oDepth.removeChild(_mcTarget);
               this.lMCList.remove(_sId);
            }
         }
      }
      
      public function destroy() : void
      {
         var _mcLayer:Sprite = null;
         for each(_mcLayer in this.lLayerList.object)
         {
            this.mcContainer.removeChild(_mcLayer);
         }
         this.mcContainer = null;
         this.lLayerList.clear();
         this.lLayerList = null;
         this.lMCList.clear();
         this.lMCList = null;
      }
      
      private function init() : void
      {
         this.lLayerList = new ObjectList();
         this.lMCList = new ObjectList();
      }
   }
}

