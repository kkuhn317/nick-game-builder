package com.sarbakan.sbdk.data.spatialIndexing.quadTree
{
   import com.sarbakan.sbdk.data.spatialIndexing.ISpatialIndexElement;
   import com.sarbakan.sbdk.math.geom.AABB2;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class QTElement implements ISpatialIndexElement
   {
      
      internal var aNodes:Array;
      
      internal var oScene:QuadTree;
      
      internal var oRegion:AABB2;
      
      private var oData:*;
      
      public function QTElement(_oRegion:AABB2, _aNodes:Array, _oScene:QuadTree, _oData:*)
      {
         super();
         this.oRegion = _oRegion;
         this.aNodes = _aNodes;
         this.oScene = _oScene;
         this.oData = _oData;
      }
      
      public function setPositionPoint(_oPoint:Point) : void
      {
         this.setPosition(_oPoint.x,_oPoint.y,_oPoint.x,_oPoint.y);
      }
      
      public function setPositionRectangle(_oRect:Rectangle) : void
      {
         this.setPosition(_oRect.left,_oRect.top,_oRect.right,_oRect.bottom);
      }
      
      public function setPositionBox(_oBox:AABB2) : void
      {
         this.setPosition(_oBox.nXMin,_oBox.nXMax,_oBox.nYMin,_oBox.nYMax);
      }
      
      public function setPosition(_nLeft:Number, _nTop:Number, _nRight:Number, _nBottom:Number) : void
      {
         this.oRegion.nXMin = _nLeft;
         this.oRegion.nYMin = _nTop;
         this.oRegion.nXMax = _nRight;
         this.oRegion.nYMax = _nBottom;
         this.oScene.updateElement(this);
      }
      
      internal function destroy() : void
      {
         this.oRegion = null;
         this.aNodes = null;
         this.oScene = null;
         this.oData = null;
      }
      
      public function get bounds() : AABB2
      {
         return this.oRegion.clone();
      }
      
      public function get boundsRectangle() : Rectangle
      {
         return this.oRegion.toRectangle();
      }
      
      public function get data() : *
      {
         return this.oData;
      }
      
      public function set data(_o:*) : void
      {
         this.oData = _o;
      }
   }
}

