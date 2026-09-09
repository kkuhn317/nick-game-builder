package com.sarbakan.sbdk.blitting.core
{
   import com.sarbakan.sbdk.errors.ErrorMessages;
   import com.sarbakan.sbdk.math.geom.AABB2;
   import com.sarbakan.sbdk.tools.Debug;
   
   internal class BitmappedAnimDepthManager
   {
      
      private var aDisplayList:Array;
      
      public function BitmappedAnimDepthManager()
      {
         super();
         this.init();
      }
      
      public function destroy() : void
      {
         this.aDisplayList.splice(0,this.aDisplayList.length);
         this.aDisplayList = null;
      }
      
      public function addLayer(_sLayerID:String, _nDepth:int, _nXOffset:Number, _nYOffset:Number, _nSurfaceWidth:int, _nSurfaceHeight:int) : void
      {
         var _oLayerInfo:LayerInfoStruct = null;
         var i:int = 0;
         if(_nDepth > 0)
         {
            if(this.aDisplayList[_nDepth - 1] != null)
            {
               if(this.aDisplayList[_nDepth] != null)
               {
                  this.aDisplayList[_nDepth].depth = _nDepth + 1;
                  _oLayerInfo = new LayerInfoStruct(_sLayerID,_nDepth,_nXOffset,_nYOffset,_nSurfaceWidth,_nSurfaceHeight);
                  this.aDisplayList.splice(_nDepth,0,_oLayerInfo);
               }
               else
               {
                  _oLayerInfo = new LayerInfoStruct(_sLayerID,_nDepth,_nXOffset,_nYOffset,_nSurfaceWidth,_nSurfaceHeight);
                  this.aDisplayList[_nDepth] = _oLayerInfo;
               }
            }
         }
         else
         {
            _oLayerInfo = new LayerInfoStruct(_sLayerID,0,_nXOffset,_nYOffset,_nSurfaceWidth,_nSurfaceHeight);
            this.aDisplayList.push(_oLayerInfo);
            for(i = 0; i < this.aDisplayList.length; i++)
            {
               this.aDisplayList[i].depth = i;
            }
         }
      }
      
      public function containsAnimation(_oAnimation:IBitmappedAnimation) : Boolean
      {
         var _nLength_2:int = 0;
         var j:int = 0;
         var _oLayer:LayerInfoStruct = null;
         var _nLength_1:int = int(this.aDisplayList.length);
         for(var i:int = 0; i < _nLength_1; i++)
         {
            _oLayer = this.aDisplayList[i];
            for(_nLength_2 = int(_oLayer.displayList.length); j < _nLength_2; )
            {
               if(_oLayer.displayList[j] == _oAnimation)
               {
                  return true;
               }
               j++;
            }
         }
         return false;
      }
      
      public function addAnimation(_oAnimation:IBitmappedAnimation, _sLayerID:String, _nDepth:int = -1) : LayerInfoStruct
      {
         var i:int = 0;
         var _oTargetLayer:LayerInfoStruct = this.getLayer(_sLayerID);
         if(_oTargetLayer != null)
         {
            _oAnimation.layer = _sLayerID;
            _oAnimation.depth = _nDepth;
            _oAnimation.layerDepth = _oTargetLayer.depth;
            if(!_oAnimation.moving)
            {
               _oAnimation.spatialIndexHandler = _oTargetLayer.QT.addElement(new AABB2(_oAnimation.rect.left,_oAnimation.rect.right,_oAnimation.rect.top,_oAnimation.rect.bottom),_oAnimation);
            }
            else
            {
               _oAnimation.spatialIndexHandler = _oTargetLayer.SAP.addElement(new AABB2(_oAnimation.rect.left,_oAnimation.rect.right,_oAnimation.rect.top,_oAnimation.rect.bottom),_oAnimation);
            }
            if(_nDepth > 0)
            {
               if(_oTargetLayer.displayList[_nDepth - 1] == null)
               {
                  Debug.assert(false == false,ErrorMessages.sNON_SEQUENTIAL_DEPTH,{
                     "LAYER":_sLayerID,
                     "DEPTH":_nDepth
                  },"addAnimation","BitmappedAnimDepthManager");
               }
               else if(_oTargetLayer.displayList[_nDepth - 1] != null && _oTargetLayer.displayList[_nDepth] == null)
               {
                  _oTargetLayer.displayList[_nDepth] = _oAnimation;
               }
               else
               {
                  _oTargetLayer.displayList.splice(_nDepth,0,_oAnimation);
               }
            }
            else if(_nDepth == 0)
            {
               if(_oTargetLayer.displayList[_nDepth] == null)
               {
                  _oTargetLayer.displayList[_nDepth] = _oAnimation;
               }
               else
               {
                  _oTargetLayer.displayList.splice(0,0,_oAnimation);
               }
            }
            else if(_nDepth < 0)
            {
               _oTargetLayer.displayList.push(_oAnimation);
            }
            for(i = 0; i < _oTargetLayer.displayList.length; i++)
            {
               _oTargetLayer.displayList[i].depth = i;
            }
         }
         return _oTargetLayer;
      }
      
      public function removeAnimation(_oAnimation:IBitmappedAnimation) : void
      {
         var _nLength_2:int = 0;
         var j:int = 0;
         var k:int = 0;
         var _oLayer:LayerInfoStruct = null;
         var _nLength_1:int = int(this.aDisplayList.length);
         for(var i:int = 0; i < _nLength_1; i++)
         {
            _oLayer = this.aDisplayList[i];
            _nLength_2 = int(_oLayer.displayList.length);
            for(j = 0; j < _nLength_2; j++)
            {
               if(_oLayer.displayList[j] == _oAnimation)
               {
                  _oLayer.displayList.splice(j,1);
                  for(k = 0; k < _oLayer.displayList.length; k++)
                  {
                     _oLayer.displayList[k].depth = k;
                  }
                  if(!_oAnimation.moving)
                  {
                     _oLayer.QT.removeElement(_oAnimation.spatialIndexHandler);
                  }
                  else
                  {
                     _oLayer.SAP.removeElement(_oAnimation.spatialIndexHandler);
                  }
                  break;
               }
            }
         }
      }
      
      public function setAnimationLayer(_oAnimation:IBitmappedAnimation, _sLayerID:String, _nDepth:int = -1) : void
      {
         this.removeAnimation(_oAnimation);
         this.addAnimation(_oAnimation,_sLayerID,_nDepth);
      }
      
      public function setAnimationDepth(_oAnimation:IBitmappedAnimation, _nDepth:int) : void
      {
         this.removeAnimation(_oAnimation);
         this.addAnimation(_oAnimation,_oAnimation.layer,_nDepth);
      }
      
      public function removeLayer(_sLayerID:String) : Boolean
      {
         var _oLayer:LayerInfoStruct = null;
         var _bFound:Boolean = false;
         var _nLength:int = int(this.aDisplayList.length);
         for(var i:int = 0; i < _nLength; i++)
         {
            if(this.aDisplayList[i].layerID == _sLayerID)
            {
               this.aDisplayList[i].destroy();
               this.aDisplayList.splice(i,1);
               _bFound = true;
               break;
            }
         }
         return _bFound;
      }
      
      public function clearLayer(_sLayerID:String) : void
      {
         var _oTargetLayer:LayerInfoStruct = null;
         var i:int = 0;
         if(_sLayerID != null)
         {
            _oTargetLayer = this.getLayer(_sLayerID);
            if(_oTargetLayer != null)
            {
               _oTargetLayer.clear();
            }
         }
         else
         {
            for(i = 0; i < this.aDisplayList.length; i++)
            {
               this.aDisplayList[i].clear();
            }
         }
      }
      
      public function getNumChildren(_sLayerID:String = null) : int
      {
         var _nLength:int = 0;
         var i:int = 0;
         var _oTargetLayer:LayerInfoStruct = null;
         var _nTotalCmpt:int = 0;
         if(_sLayerID != null)
         {
            _oTargetLayer = this.getLayer(_sLayerID);
            if(_oTargetLayer != null)
            {
               return _oTargetLayer.displayList.length;
            }
            return 0;
         }
         _nLength = int(this.aDisplayList.length);
         for(i = 0; i < _nLength; i++)
         {
            _nTotalCmpt += this.aDisplayList[i].displayList.length;
         }
         return _nTotalCmpt;
      }
      
      public function getLayer(_sLayerID:String) : LayerInfoStruct
      {
         var _oLayer:LayerInfoStruct = null;
         var _nLength:int = int(this.aDisplayList.length);
         for(var i:int = 0; i < _nLength; i++)
         {
            if(this.aDisplayList[i].layerID == _sLayerID)
            {
               _oLayer = this.aDisplayList[i];
               break;
            }
         }
         return _oLayer;
      }
      
      public function swapLayer(_sLayerID1:String, _sLayerID2:String) : void
      {
         var _nLayer_1_Depth:int = 0;
         var _nLayer_2_Depth:int = 0;
         var _oLayer_1:LayerInfoStruct = this.getLayer(_sLayerID1);
         var _oLayer_2:LayerInfoStruct = this.getLayer(_sLayerID2);
         if(_oLayer_1 != null && _oLayer_2 != null)
         {
            _nLayer_1_Depth = _oLayer_1.depth;
            _nLayer_2_Depth = _oLayer_2.depth;
            _oLayer_1.depth = _nLayer_2_Depth;
            _oLayer_2.depth = _nLayer_1_Depth;
            this.aDisplayList.sortOn("depth",Array.NUMERIC);
         }
      }
      
      public function setLayerDepth(_sLayerID:String, _nDepth:int) : void
      {
         var _oLayer_1:LayerInfoStruct = null;
         var _oLayer_2:LayerInfoStruct = null;
         var _nCurrentDepth:int = 0;
         if(_nDepth <= this.aDisplayList.length - 1)
         {
            _oLayer_1 = this.getLayer(_sLayerID);
            _oLayer_2 = this.aDisplayList[_nDepth];
            _nCurrentDepth = _oLayer_1.depth;
            _oLayer_1.depth = _nDepth;
            _oLayer_2.depth = _nCurrentDepth;
            this.aDisplayList.sortOn("depth",Array.NUMERIC);
         }
      }
      
      private function init() : void
      {
         this.aDisplayList = new Array();
      }
      
      public function get displayList() : Array
      {
         return this.aDisplayList;
      }
   }
}

