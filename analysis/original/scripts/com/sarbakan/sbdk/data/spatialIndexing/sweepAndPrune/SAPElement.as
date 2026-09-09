package com.sarbakan.sbdk.data.spatialIndexing.sweepAndPrune
{
   import com.sarbakan.sbdk.data.spatialIndexing.ISpatialIndexElement;
   import com.sarbakan.sbdk.math.geom.AABB2;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class SAPElement implements ISpatialIndexElement
   {
      
      internal var oRangeY:SAPRange;
      
      internal var oRangeX:SAPRange;
      
      internal var uValidAxis:uint = 0;
      
      private var oScene:SweepAndPruneScene;
      
      private var oData:*;
      
      public function SAPElement(_oData:*, _oScene:SweepAndPruneScene)
      {
         super();
         this.oData = _oData;
         this.oScene = _oScene;
         this.oRangeX = new SAPRange(1,this);
         this.oRangeY = new SAPRange(2,this);
      }
      
      public function setPositionPoint(_oPoint:Point) : void
      {
         this.oRangeX.nMin = _oPoint.x;
         this.oRangeY.nMin = _oPoint.y;
         this.oRangeX.nMax = _oPoint.x;
         this.oRangeY.nMax = _oPoint.y;
         this.oScene.invalidate();
      }
      
      public function setPositionBox(_oBox:AABB2) : void
      {
         this.oRangeX.nMin = _oBox.nXMin;
         this.oRangeY.nMin = _oBox.nYMin;
         this.oRangeX.nMax = _oBox.nXMax;
         this.oRangeY.nMax = _oBox.nYMax;
         this.oScene.invalidate();
      }
      
      public function setPositionRectangle(_oRect:Rectangle) : void
      {
         this.oRangeX.nMin = _oRect.left;
         this.oRangeY.nMin = _oRect.top;
         this.oRangeX.nMax = _oRect.right;
         this.oRangeY.nMax = _oRect.bottom;
         this.oScene.invalidate();
      }
      
      public function setPosition(_nLeft:Number, _nTop:Number, _nRight:Number, _nBottom:Number) : void
      {
         this.oRangeX.nMin = _nLeft;
         this.oRangeY.nMin = _nTop;
         this.oRangeX.nMax = _nRight;
         this.oRangeY.nMax = _nBottom;
         this.oScene.invalidate();
      }
      
      internal function destroy() : void
      {
         this.oRangeX.destroy();
         this.oRangeY.destroy();
         this.oRangeX = null;
         this.oRangeY = null;
         this.oData = null;
         this.oScene = null;
      }
      
      public function get bounds() : AABB2
      {
         return new AABB2(this.oRangeX.nMin,this.oRangeX.nMax,this.oRangeY.nMin,this.oRangeY.nMax);
      }
      
      public function get boundsRectangle() : Rectangle
      {
         return new Rectangle(this.oRangeX.nMin,this.oRangeY.nMin,this.oRangeX.nMax - this.oRangeX.nMin,this.oRangeY.nMax - this.oRangeY.nMin);
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

