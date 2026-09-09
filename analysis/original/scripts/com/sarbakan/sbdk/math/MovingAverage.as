package com.sarbakan.sbdk.math
{
   import de.polygonal.ds.SLinkedList;
   
   public class MovingAverage
   {
      
      private var nMaxSamples:uint;
      
      private var lSampleBuffer:SLinkedList;
      
      private var nTotal:Number;
      
      private var nCachedAverage:Number;
      
      private var bAverageChanged:Boolean;
      
      public function MovingAverage(_nMaxSamples:uint = 32)
      {
         super();
         this.nMaxSamples = _nMaxSamples;
         this.init();
      }
      
      public function destroy() : void
      {
         this.lSampleBuffer.clear();
         this.lSampleBuffer = null;
      }
      
      public function addSample(_nValue:Number) : void
      {
         if(this.lSampleBuffer.size == this.nMaxSamples)
         {
            this.nTotal -= this.lSampleBuffer.head.data;
            this.lSampleBuffer.removeHead();
         }
         this.nTotal += _nValue;
         this.lSampleBuffer.append(_nValue);
         this.bAverageChanged = true;
      }
      
      public function reset() : void
      {
         this.lSampleBuffer.clear();
         this.nTotal = 0;
         this.bAverageChanged = false;
         this.nCachedAverage = 0;
      }
      
      public function toString() : String
      {
         return "[MovingAverage: Max sample = " + String(this.nMaxSamples) + ", Total sample = " + String(this.nTotal) + "]";
      }
      
      private function init() : void
      {
         this.lSampleBuffer = new SLinkedList();
         this.reset();
      }
      
      public function get average() : Number
      {
         if(this.bAverageChanged)
         {
            this.nCachedAverage = this.nTotal / this.lSampleBuffer.size;
            this.bAverageChanged = false;
         }
         return this.nCachedAverage;
      }
   }
}

