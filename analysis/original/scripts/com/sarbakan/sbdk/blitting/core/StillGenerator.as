package com.sarbakan.sbdk.blitting.core
{
   import com.sarbakan.sbdk.core.UpdateManager;
   import com.sarbakan.sbdk.data.spatialIndexing.ISpatialIndexElement;
   import com.sarbakan.sbdk.data.spatialIndexing.sweepAndPrune.SweepAndPruneScene;
   import com.sarbakan.sbdk.events.StillGeneratorEvent;
   import com.sarbakan.sbdk.events.UpdateEvent;
   import com.sarbakan.sbdk.math.geom.AABB2;
   import com.sarbakan.sbdk.utils.EventManager;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class StillGenerator extends EventDispatcher
   {
      
      private static const sEVENT_MANAGER_ID:String = "eventManager";
      
      private var oEventManager:EventManager;
      
      private var nPanelWidth:uint;
      
      private var nPanelHeight:uint;
      
      private var aPanels:Array;
      
      private var oPanels:SweepAndPruneScene;
      
      private var bInvalidateElements:Boolean;
      
      private var aElements:Array;
      
      private var oElements:SweepAndPruneScene;
      
      public function StillGenerator(_nPanelWidth:uint = 600, _nPanelHeight:uint = 400)
      {
         super();
         this.oEventManager = new EventManager();
         this.nPanelWidth = _nPanelWidth;
         this.nPanelHeight = _nPanelHeight;
         this.oPanels = new SweepAndPruneScene();
         this.aPanels = new Array();
         this.oElements = new SweepAndPruneScene();
         this.aElements = new Array();
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,UpdateManager.instance,UpdateEvent.UPDATE,this.onUpdate);
      }
      
      public function destroy() : void
      {
         var _oContainer:StillPanel = null;
         var _oElement:StillElement = null;
         if(Boolean(this.aPanels))
         {
            for each(_oContainer in this.aPanels)
            {
               this.oPanels.removeElement(_oContainer.spatialIndexHandler);
               _oContainer.destroy();
            }
            this.oPanels.destroy();
         }
         this.oPanels = null;
         this.aPanels = null;
         if(Boolean(this.aElements))
         {
            for each(_oElement in this.aElements)
            {
               this.removeElement(_oElement);
            }
            this.oElements.destroy();
         }
         this.oElements = null;
         this.aElements = null;
         if(Boolean(this.oEventManager))
         {
            this.oEventManager.destroy();
         }
         this.oEventManager = null;
      }
      
      public function addElement(_oElement:StillElement) : void
      {
         this.checkNewPanels(_oElement.bounds);
         var _oIndex:ISpatialIndexElement = this.oElements.addElement(_oElement.bounds,_oElement);
         _oElement.spatialIndex = _oIndex;
         _oElement.container = this;
         this.bInvalidateElements = true;
         this.aElements.push(_oElement);
      }
      
      public function removeElement(_oElement:StillElement) : void
      {
         this.oElements.removeElement(_oElement.spatialIndex);
         this.aElements.splice(this.aElements.indexOf(_oElement),1);
         _oElement.container = null;
         _oElement.spatialIndex = null;
         this.bInvalidateElements = true;
      }
      
      internal function invalidate(_oBounds:AABB2 = null, _bCheckForNew:Boolean = false) : void
      {
         var _aIndex:Array = null;
         var _oIndex:ISpatialIndexElement = null;
         var _oPanel:StillPanel = null;
         if(_bCheckForNew)
         {
            this.checkNewPanels(_oBounds);
         }
         if(Boolean(_oBounds))
         {
            _aIndex = this.oPanels.queryBounds(_oBounds.nXMin,_oBounds.nXMax,_oBounds.nYMin,_oBounds.nYMax);
            for each(_oIndex in _aIndex)
            {
               StillPanel(_oIndex.data).invalidate();
            }
         }
         else
         {
            for each(_oPanel in this.aPanels)
            {
               _oPanel.invalidate();
            }
         }
         this.bInvalidateElements = true;
      }
      
      internal function queryRectangle(_oRect:Rectangle) : Array
      {
         return this.oElements.queryRectangle(_oRect);
      }
      
      private function checkNewPanels(_oBounds:AABB2) : void
      {
         var _oReusePoint:Point = null;
         var _nPanelX:int = 0;
         var _nPanelY:int = 0;
         var _aPanels:Array = null;
         var _oPanel:ISpatialIndexElement = null;
         if(Boolean(_oBounds))
         {
            _oReusePoint = new Point();
            _nPanelX = Math.floor(_oBounds.nXMin / this.nPanelWidth);
            while(_nPanelX * this.nPanelWidth <= _oBounds.nXMax)
            {
               _nPanelY = Math.floor(_oBounds.nYMin / this.nPanelHeight);
               while(_nPanelY * this.nPanelHeight <= _oBounds.nYMax)
               {
                  _oReusePoint.x = (_nPanelX + 0.5) * this.nPanelWidth;
                  _oReusePoint.y = (_nPanelY + 0.5) * this.nPanelHeight;
                  _aPanels = this.oPanels.queryPoint(_oReusePoint);
                  if(_aPanels.length <= 0)
                  {
                     this.createNewPanel(_nPanelX,_nPanelY);
                  }
                  else
                  {
                     for each(_oPanel in _aPanels)
                     {
                        StillPanel(_oPanel.data).invalidate();
                     }
                  }
                  _nPanelY++;
               }
               _nPanelX++;
            }
         }
      }
      
      private function createNewPanel(_nX:int, _nY:int) : void
      {
         var _oPanel:StillPanel = new StillPanel(this,_nX * this.nPanelWidth,_nY * this.nPanelHeight,this.nPanelWidth,this.nPanelHeight);
         this.oPanels.addElement(AABB2.fromRectangle(_oPanel.rect),_oPanel);
         this.oPanels.update();
         this.aPanels.push(_oPanel);
         dispatchEvent(new StillGeneratorEvent(StillGeneratorEvent.PANEL_ADDED,_oPanel));
      }
      
      private function onUpdate(_e:UpdateEvent) : void
      {
         if(this.bInvalidateElements)
         {
            this.oElements.update();
         }
         this.bInvalidateElements = false;
      }
   }
}

