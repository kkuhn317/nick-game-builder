package com.sarbakan.sbdk.blitting.core
{
   import com.sarbakan.sbdk.data.spatialIndexing.quadTree.QuadTree;
   import com.sarbakan.sbdk.data.spatialIndexing.sweepAndPrune.SweepAndPruneScene;
   
   public class LayerInfoStruct
   {
      
      private var sLayerID:String;
      
      private var nDepth:int;
      
      private var aList:Array;
      
      private var nXOffset:Number;
      
      private var nYOffset:Number;
      
      private var oSAP:SweepAndPruneScene;
      
      private var oQT:QuadTree;
      
      private var aViewSortList:Array;
      
      public function LayerInfoStruct(_sLayerID:String, _nDepth:int, _nXOffset:Number, _nYOffset:Number, _nSurfaceWidth:int, _nSurfaceHeight:int)
      {
         super();
         this.sLayerID = _sLayerID;
         this.nDepth = _nDepth;
         this.nXOffset = _nXOffset;
         this.nYOffset = _nYOffset;
         this.oQT = new QuadTree(0,_nSurfaceWidth,0,_nSurfaceHeight);
         this.oSAP = new SweepAndPruneScene();
         this.aList = new Array();
         this.aViewSortList = new Array();
      }
      
      internal function get displayList() : Array
      {
         return this.aList;
      }
      
      internal function destroy() : void
      {
         this.aList.splice(0,this.aList.length);
         this.aList = null;
         this.aViewSortList.splice(0,this.aViewSortList.length);
         this.aViewSortList = null;
         if(this.oSAP != null)
         {
            this.oSAP.destroy();
            this.oSAP = null;
         }
         if(this.oQT != null)
         {
            this.oQT.destroy();
            this.oQT = null;
         }
      }
      
      internal function clear() : void
      {
         for(var i:int = 0; i < this.aList.length; i++)
         {
            this.aList[i].setContainer(null);
            this.oQT.removeElement(this.aList[i].spatialIndexHandler);
            this.aList[i].spatialIndexHandler = null;
            this.aList[i].layer = "";
            this.aList[i].layerDepth = 0;
            this.aList[i].depth = 0;
         }
         this.aList.splice(0,this.aList.length);
         this.aViewSortList.splice(0,this.aViewSortList.length);
      }
      
      public function get xOffset() : Number
      {
         return this.nXOffset;
      }
      
      public function get yOffset() : Number
      {
         return this.nYOffset;
      }
      
      public function get layerID() : String
      {
         return this.sLayerID;
      }
      
      public function get depth() : int
      {
         return this.nDepth;
      }
      
      public function set depth(_nValue:int) : void
      {
         this.nDepth = _nValue;
      }
      
      public function get QT() : QuadTree
      {
         return this.oQT;
      }
      
      public function get SAP() : SweepAndPruneScene
      {
         return this.oSAP;
      }
      
      internal function get viewSortList() : Array
      {
         return this.aViewSortList;
      }
      
      internal function set viewSortList(_aValue:Array) : void
      {
         this.aViewSortList = _aValue;
      }
   }
}

