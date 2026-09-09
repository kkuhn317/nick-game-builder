package com.sarbakan.sbdk.data.spatialIndexing.quadTree
{
   import com.sarbakan.sbdk.math.geom.AABB2;
   import flash.display.Graphics;
   
   internal class QTNode extends AABB2
   {
      
      internal var bLeaf:Boolean = false;
      
      internal var aElements:Array = new Array();
      
      internal var oParent:QTNode;
      
      internal var oNextInNode:QTNode;
      
      internal var oNextInTree:QTNode;
      
      internal var oNextInList:QTNode;
      
      private var uCurrentDepth:uint;
      
      private var oNodeNW:QTNode;
      
      private var oNodeNE:QTNode;
      
      private var oNodeSE:QTNode;
      
      private var oNodeSW:QTNode;
      
      public function QTNode(_nXMin:Number, _nXMax:Number, _nYMin:Number, _nYMax:Number, _uCurrentDepth:uint, _oParent:QTNode)
      {
         super(_nXMin,_nXMax,_nYMin,_nYMax);
         this.uCurrentDepth = _uCurrentDepth;
         this.oParent = _oParent;
      }
      
      public function destroy() : void
      {
         var _oElement:QTElement = null;
         for each(_oElement in this.aElements)
         {
            _oElement.destroy();
         }
         this.aElements = null;
         this.oParent = null;
         this.oNextInNode = null;
         this.oNextInTree = null;
         this.oNextInList = null;
         if(!this.bLeaf)
         {
            this.oNodeNW.destroy();
            this.oNodeNE.destroy();
            this.oNodeSW.destroy();
            this.oNodeSE.destroy();
         }
         this.oNodeNW = null;
         this.oNodeNE = null;
         this.oNodeSW = null;
         this.oNodeSE = null;
      }
      
      public function debugDraw(_oTarget:Graphics, _bRecursive:Boolean = true) : void
      {
         _oTarget.lineStyle(1,0);
         _oTarget.moveTo(nXMin,nYMin);
         _oTarget.lineTo(nXMax,nYMin);
         _oTarget.lineTo(nXMax,nYMax);
         _oTarget.lineTo(nXMin,nYMax);
         _oTarget.lineTo(nXMin,nYMin);
         if(!this.bLeaf && _bRecursive)
         {
            this.oNodeNW.debugDraw(_oTarget);
            this.oNodeNE.debugDraw(_oTarget);
            this.oNodeSE.debugDraw(_oTarget);
            this.oNodeSW.debugDraw(_oTarget);
         }
      }
      
      override public function toString() : String
      {
         return "[QTNode - Depth " + this.uCurrentDepth + ", Region: " + super.toString() + "]";
      }
      
      internal function adaptGrid(_uMaxElementsPerNode:uint, _uMaxDepth:uint) : void
      {
         var i:uint = 0;
         var _oElement:QTElement = null;
         if(this.bLeaf)
         {
            if(this.aElements.length > _uMaxElementsPerNode && this.uCurrentDepth + 1 < _uMaxDepth)
            {
               this.buildLeaves(this.uCurrentDepth + 1);
               while(this.aElements.length > 0)
               {
                  _oElement = this.aElements[i];
                  _oElement.oScene.updateElement(_oElement);
               }
               this.adaptGrid(_uMaxElementsPerNode,_uMaxDepth);
            }
         }
         else
         {
            this.oNodeNW.adaptGrid(_uMaxElementsPerNode,_uMaxDepth);
            this.oNodeNE.adaptGrid(_uMaxElementsPerNode,_uMaxDepth);
            this.oNodeSE.adaptGrid(_uMaxElementsPerNode,_uMaxDepth);
            this.oNodeSW.adaptGrid(_uMaxElementsPerNode,_uMaxDepth);
         }
      }
      
      internal function appendSelfLeafIfIntersecting(_aContainer:Array, _nXMin:Number, _nXMax:Number, _nYMin:Number, _nYMax:Number) : void
      {
         if(this.bLeaf)
         {
            if(nXMin > _nXMax)
            {
               return;
            }
            if(nXMax < _nXMin)
            {
               return;
            }
            if(nYMin > _nYMax)
            {
               return;
            }
            if(nYMax < _nYMin)
            {
               return;
            }
            _aContainer.push(this);
         }
         else
         {
            this.oNodeNW.appendSelfLeafIfIntersecting(_aContainer,_nXMin,_nXMax,_nYMin,_nYMax);
            this.oNodeNE.appendSelfLeafIfIntersecting(_aContainer,_nXMin,_nXMax,_nYMin,_nYMax);
            this.oNodeSW.appendSelfLeafIfIntersecting(_aContainer,_nXMin,_nXMax,_nYMin,_nYMax);
            this.oNodeSE.appendSelfLeafIfIntersecting(_aContainer,_nXMin,_nXMax,_nYMin,_nYMax);
         }
      }
      
      internal function appendContent(_aContainer:Array) : void
      {
         var i:uint = 0;
         var j:uint = 0;
         var _nMaxIndex:uint = 0;
         var _nContainerMaxIndex:uint = 0;
         var _bFoundDuplicate:Boolean = false;
         var _oCurrentElement:QTElement = null;
         if(!this.bLeaf)
         {
            this.oNodeNW.appendContent(_aContainer);
            this.oNodeNE.appendContent(_aContainer);
            this.oNodeSW.appendContent(_aContainer);
            this.oNodeSE.appendContent(_aContainer);
         }
         else
         {
            _nMaxIndex = this.aElements.length;
            _nContainerMaxIndex = _aContainer.length;
            for(i = 0; i < _nMaxIndex; i++)
            {
               _oCurrentElement = this.aElements[i];
               _bFoundDuplicate = false;
               for(j = 0; j < _nContainerMaxIndex; j++)
               {
                  if(_oCurrentElement == _aContainer[j])
                  {
                     _bFoundDuplicate = true;
                     break;
                  }
               }
               if(!_bFoundDuplicate)
               {
                  _aContainer.push(this.aElements[i]);
                  _nContainerMaxIndex++;
               }
            }
         }
      }
      
      internal function buildLeaves(_uTargetFinalDepth:uint) : void
      {
         var _oCurrentParent:QTNode = null;
         var _uLeavesDepth:uint = this.uCurrentDepth + 1;
         if(_uLeavesDepth <= _uTargetFinalDepth)
         {
            this.bLeaf = false;
            this.oNodeNW = new QTNode(nXMin,nXMin + (nXMax - nXMin) / 2,nYMin,nYMin + (nYMax - nYMin) / 2,_uLeavesDepth,this);
            this.oNodeNE = new QTNode((nXMin + nXMax) / 2,nXMax,nYMin,nYMin + (nYMax - nYMin) / 2,_uLeavesDepth,this);
            this.oNodeSW = new QTNode(nXMin,nXMin + (nXMax - nXMin) / 2,(nYMin + nYMax) / 2,nYMax,_uLeavesDepth,this);
            this.oNodeSE = new QTNode((nXMin + nXMax) / 2,nXMax,(nYMin + nYMax) / 2,nYMax,_uLeavesDepth,this);
            this.oNextInTree = this.oNodeNW;
            this.oNextInList = this.oNodeNW;
            this.oNodeNW.oNextInNode = this.oNodeNE;
            this.oNodeNE.oNextInNode = this.oNodeSW;
            this.oNodeSW.oNextInNode = this.oNodeSE;
            this.oNodeSE.oNextInNode = null;
            this.oNodeNW.oNextInList = this.oNodeNE;
            this.oNodeNE.oNextInList = this.oNodeSW;
            this.oNodeSW.oNextInList = this.oNodeSE;
            if(this.oNextInNode != null)
            {
               this.oNodeSE.oNextInList = this.oNextInNode;
            }
            else if(this.uCurrentDepth != 1)
            {
               _oCurrentParent = this.oParent;
               while(_oCurrentParent != null && _oCurrentParent.oNextInNode == null)
               {
                  _oCurrentParent = _oCurrentParent.oParent;
               }
               if(_oCurrentParent != null)
               {
                  this.oNodeSE.oNextInList = _oCurrentParent.oNextInNode;
               }
            }
            this.oNodeNW.buildLeaves(_uTargetFinalDepth);
            this.oNodeNE.buildLeaves(_uTargetFinalDepth);
            this.oNodeSW.buildLeaves(_uTargetFinalDepth);
            this.oNodeSE.buildLeaves(_uTargetFinalDepth);
         }
         else
         {
            this.bLeaf = true;
         }
      }
   }
}

