package com.sarbakan.sbdk.data.spatialIndexing.sweepAndPrune
{
   internal class SAPRange
   {
      
      public var oElement:SAPElement;
      
      public var uAxis:uint;
      
      public var nMin:Number;
      
      public var nMax:Number;
      
      public function SAPRange(_uAxis:uint, _oElement:SAPElement)
      {
         super();
         this.uAxis = _uAxis;
         this.oElement = _oElement;
         this.nMin = 0;
         this.nMax = 0;
      }
      
      internal function destroy() : void
      {
         this.oElement = null;
      }
   }
}

