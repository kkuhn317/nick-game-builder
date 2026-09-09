package com.sarbakan.sbdk.data.spatialIndexing.quadTree
{
   import com.sarbakan.sbdk.data.spatialIndexing.ISpatialIndexElement;
   import com.sarbakan.sbdk.data.spatialIndexing.ISpatialIndexManager;
   import com.sarbakan.sbdk.math.geom.AABB2;
   import flash.display.Graphics;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class QuadTree implements ISpatialIndexManager
   {
      
      private var oRootNode:QTNode;
      
      private var aResults:Array;
      
      public function QuadTree(_nXMin:Number, _nXMax:Number, _nYMin:Number, _nYMax:Number, _uDepth:uint = 4)
      {
         super();
         this.oRootNode = new QTNode(_nXMin,_nXMax,_nYMin,_nYMax,1,null);
         this.oRootNode.buildLeaves(_uDepth);
      }
      
      public function destroy() : void
      {
         this.aResults = null;
         this.oRootNode.destroy();
      }
      
      public function addElement(_oRegion:AABB2, _oData:*) : ISpatialIndexElement
      {
         var _oNode:QTNode = null;
         var i:uint = 0;
         var _oBaseNode:QTNode = this.getExclusiveContainer(_oRegion.nXMin,_oRegion.nXMax,_oRegion.nYMin,_oRegion.nYMax);
         var _aNodes:Array = this.getIntersectingLeafNodesOf(_oRegion.nXMin,_oRegion.nXMax,_oRegion.nYMin,_oRegion.nYMax,_oBaseNode);
         var _oElement:QTElement = new QTElement(_oRegion,_aNodes,this,_oData);
         for(i = 0; i < _aNodes.length; i++)
         {
            _oNode = _aNodes[i];
            _oNode.aElements.push(_oElement);
         }
         return _oElement as ISpatialIndexElement;
      }
      
      public function removeElement(_oElement:ISpatialIndexElement) : void
      {
         this.unlinkElement(_oElement as QTElement);
         (_oElement as QTElement).destroy();
      }
      
      public function adaptGrid(_uMaxElementsPerNode:uint = 4, _uMaxDepth:uint = 10) : void
      {
         this.oRootNode.adaptGrid(_uMaxElementsPerNode,_uMaxDepth);
      }
      
      public function queryElement(_oElement:ISpatialIndexElement) : Array
      {
         return this.getContentFromNodes((_oElement as QTElement).aNodes);
      }
      
      public function queryRectangle(_oRect:Rectangle) : Array
      {
         return this.queryBounds(_oRect.left,_oRect.right,_oRect.top,_oRect.bottom);
      }
      
      public function queryPoint(_oPoint:Point) : Array
      {
         return this.queryBounds(_oPoint.x,_oPoint.x,_oPoint.y,_oPoint.y);
      }
      
      public function queryBounds(_nXMin:Number, _nXMax:Number, _nYMin:Number, _nYMax:Number) : Array
      {
         var _oBaseNode:QTNode = this.getExclusiveContainer(_nXMin,_nXMax,_nYMin,_nYMax);
         var _aNodes:Array = this.getIntersectingLeafNodesOf(_nXMin,_nXMax,_nYMin,_nYMax,_oBaseNode);
         return this.getContentFromNodes(_aNodes);
      }
      
      public function debugDraw(_oTarget:Graphics) : void
      {
         this.oRootNode.debugDraw(_oTarget,true);
      }
      
      public function update() : void
      {
      }
      
      internal function updateElement(_oElement:QTElement) : void
      {
         var _oNode:QTNode = null;
         this.unlinkElement(_oElement);
         var _oBaseNode:QTNode = this.getExclusiveContainer(_oElement.oRegion.nXMin,_oElement.oRegion.nXMax,_oElement.oRegion.nYMin,_oElement.oRegion.nYMax);
         var _aNodes:Array = this.getIntersectingLeafNodesOf(_oElement.oRegion.nXMin,_oElement.oRegion.nXMax,_oElement.oRegion.nYMin,_oElement.oRegion.nYMax,_oBaseNode);
         _oElement.aNodes = _aNodes;
         for each(_oNode in _aNodes)
         {
            _oNode.aElements.push(_oElement);
         }
      }
      
      private function unlinkElement(_oElement:QTElement) : void
      {
         var _oNode:QTNode = null;
         var _aNodeElements:Array = null;
         var i:uint = 0;
         var _uElementCount:uint = 0;
         var _aNodes:Array = _oElement.aNodes;
         for each(_oNode in _aNodes)
         {
            _aNodeElements = _oNode.aElements;
            _uElementCount = _aNodeElements.length;
            for(i = 0; i < _uElementCount; i++)
            {
               if(_aNodeElements[i] == _oElement)
               {
                  _aNodeElements.splice(i,1);
               }
            }
         }
      }
      
      private function getContentFromNodes(_aNodes:Array) : Array
      {
         var _oNode:QTNode = null;
         var _aReturn:Array = null;
         this.aResults = new Array();
         for each(_oNode in _aNodes)
         {
            _oNode.appendContent(this.aResults);
         }
         this.aResults;
         _aReturn = this.aResults;
         this.aResults = null;
         return _aReturn;
      }
      
      private function getIntersectingLeafNodesOf(_nXMin:Number, _nXMax:Number, _nYMin:Number, _nYMax:Number, _oBaseNode:QTNode) : Array
      {
         var _aIntersection:Array = new Array();
         _oBaseNode.appendSelfLeafIfIntersecting(_aIntersection,_nXMin,_nXMax,_nYMin,_nYMax);
         return _aIntersection;
      }
      
      private function getExclusiveContainer(_nXMin:Number, _nXMax:Number, _nYMin:Number, _nYMax:Number) : QTNode
      {
         var _oCurrentNode:QTNode = this.oRootNode;
         var _oResultNode:QTNode = this.oRootNode;
         while(_oCurrentNode != null)
         {
            if(_oCurrentNode.nXMin <= _nXMin)
            {
               if(_oCurrentNode.nXMax >= _nXMax)
               {
                  if(_oCurrentNode.nYMin <= _nYMin)
                  {
                     if(_oCurrentNode.nYMax >= _nYMax)
                     {
                        _oResultNode = _oCurrentNode;
                        _oCurrentNode = _oCurrentNode.oNextInTree;
                        continue;
                     }
                  }
               }
            }
            _oCurrentNode = _oCurrentNode.oNextInNode;
         }
         return _oResultNode;
      }
   }
}

