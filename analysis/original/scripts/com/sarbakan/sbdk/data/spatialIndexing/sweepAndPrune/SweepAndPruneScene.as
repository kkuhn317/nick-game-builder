package com.sarbakan.sbdk.data.spatialIndexing.sweepAndPrune
{
   import com.sarbakan.sbdk.data.spatialIndexing.ISpatialIndexElement;
   import com.sarbakan.sbdk.data.spatialIndexing.ISpatialIndexManager;
   import com.sarbakan.sbdk.math.geom.AABB2;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class SweepAndPruneScene implements ISpatialIndexManager
   {
      
      private var aRangesX:Array = new Array();
      
      private var aRangesY:Array = new Array();
      
      private var aElements:Array = new Array();
      
      private var bValid:Boolean = true;
      
      private var aResults:Array;
      
      public function SweepAndPruneScene()
      {
         super();
      }
      
      public function destroy() : void
      {
         var _oElement:SAPElement = null;
         this.aResults = null;
         for each(_oElement in this.aElements)
         {
            _oElement.destroy();
         }
         this.aElements = null;
         this.aRangesX = null;
         this.aRangesY = null;
      }
      
      public function addElement(_oRegion:AABB2, _oData:*) : ISpatialIndexElement
      {
         var _oElement:SAPElement = new SAPElement(_oData,this);
         _oElement.setPositionBox(_oRegion);
         this.aElements.push(_oElement);
         this.aRangesX.push(_oElement.oRangeX);
         this.aRangesY.push(_oElement.oRangeY);
         this.invalidate();
         return _oElement;
      }
      
      public function removeElement(_oOrigElement:ISpatialIndexElement) : void
      {
         var i:int = 0;
         var _oRangeX:SAPRange = null;
         var _oRangeY:SAPRange = null;
         var _oElement:SAPElement = _oOrigElement as SAPElement;
         var _nLatestIndex:int = this.aElements.length - 1;
         for(i = 0; i <= _nLatestIndex; i++)
         {
            if(_oElement == this.aElements[i])
            {
               _oRangeX = _oElement.oRangeX;
               _oRangeY = _oElement.oRangeY;
               _oElement.destroy();
               this.aElements.splice(i,1);
               break;
            }
         }
         if(_oRangeX != null)
         {
            _nLatestIndex = this.aRangesX.length - 1;
            for(i = 0; i <= _nLatestIndex; i++)
            {
               if(_oRangeX == this.aRangesX[i])
               {
                  this.aRangesX.splice(i,1);
                  break;
               }
            }
            _oRangeX.destroy();
         }
         if(_oRangeY != null)
         {
            _nLatestIndex = this.aRangesY.length - 1;
            for(i = 0; i <= _nLatestIndex; i++)
            {
               if(_oRangeY == this.aRangesY[i])
               {
                  this.aRangesY.splice(i,1);
                  break;
               }
            }
            _oRangeY.destroy();
         }
         this.invalidate();
      }
      
      public function update() : void
      {
         if(!this.bValid)
         {
            this.aRangesX.sortOn("nMin",Array.NUMERIC);
            this.aRangesY.sortOn("nMin",Array.NUMERIC);
            this.bValid = true;
         }
      }
      
      public function queryElement(_oOrigElement:ISpatialIndexElement) : Array
      {
         var _oElement:SAPElement = _oOrigElement as SAPElement;
         return this.queryBounds(_oElement.oRangeX.nMin,_oElement.oRangeX.nMax,_oElement.oRangeY.nMin,_oElement.oRangeY.nMax);
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
         this.aResults = new Array();
         this.sweepElements(this.aRangesX,1,_nXMin,_nXMax,0,false);
         this.sweepElements(this.aRangesY,2,_nYMin,_nYMax,1,true);
         this.clearValidities();
         var _aReturn:Array = this.aResults;
         this.aResults = null;
         return _aReturn;
      }
      
      internal function invalidate() : void
      {
         this.bValid = false;
      }
      
      private function sweepElements(_aRanges:Array, _uAxis:uint, _nMin:Number, _nMax:Number, _uRequiredValidity:uint, _bFinalPass:Boolean) : void
      {
         var i:uint = 0;
         var _oRange:SAPRange = null;
         var _oElement:SAPElement = null;
         var _iOpenCount:int = 0;
         var _nLatestIndex:uint = _aRanges.length;
         for(i = 0; i < _nLatestIndex; i++)
         {
            _oRange = _aRanges[i];
            _oElement = _oRange.oElement;
            if((_oElement.uValidAxis & _uRequiredValidity) == _uRequiredValidity)
            {
               if(_oRange.nMin >= _nMax)
               {
                  break;
               }
               if(_oRange.nMax >= _nMin)
               {
                  if(_bFinalPass)
                  {
                     this.aResults.push(_oElement);
                  }
                  else
                  {
                     _oElement.uValidAxis |= _uAxis;
                  }
               }
            }
         }
      }
      
      private function clearValidities() : void
      {
         var i:uint = 0;
         var _oElement:SAPElement = null;
         var _nLatestIndex:uint = this.aElements.length;
         for(i = 0; i < _nLatestIndex; i++)
         {
            _oElement = this.aElements[i];
            _oElement.uValidAxis = 0;
         }
      }
      
      public function get bounds() : AABB2
      {
         var _oBounds:AABB2 = null;
         if(this.aRangesX.length > 0 && this.aRangesY.length > 0)
         {
            _oBounds = new AABB2(SAPRange(this.aRangesX[0]).nMin,SAPRange(this.aRangesX[this.aRangesX.length - 1]).nMax,SAPRange(this.aRangesY[0]).nMin,SAPRange(this.aRangesY[this.aRangesY.length - 1]).nMax);
         }
         else
         {
            _oBounds = new AABB2(0,0,0,0);
         }
         return _oBounds;
      }
   }
}

