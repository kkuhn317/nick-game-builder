package com.sarbakan.sbdk.math.random.seedAlgorithm
{
   import com.sarbakan.sbdk.math.random.IIndexedSeededRandomAlgorithm;
   import flash.display.BitmapData;
   import flash.display.BitmapDataChannel;
   
   public class BitmapBased implements IIndexedSeededRandomAlgorithm
   {
      
      private var oBmpD:BitmapData;
      
      private var nBitmapSize:uint;
      
      private var nPointer:uint;
      
      private var nSeed:uint;
      
      private var nStartSeed:uint;
      
      private var nPointerMax:uint;
      
      private var nIndex:uint = 0;
      
      private var bFirstProcessRequired:Boolean = true;
      
      public function BitmapBased(_nSeed:uint, _nBitmapSize:uint = 25)
      {
         super();
         this.nBitmapSize = _nBitmapSize;
         this.nPointerMax = Math.pow(this.nBitmapSize,2) - 1;
         this.oBmpD = new BitmapData(this.nBitmapSize,this.nBitmapSize,true);
         this.nStartSeed = _nSeed;
         this.internalSeed = _nSeed;
         this.nPointer = 0;
      }
      
      public function nextValue() : Number
      {
         var _nFloat:Number = NaN;
         if(this.nPointer > this.nPointerMax)
         {
            ++this.internalSeed;
            this.nPointer = 0;
         }
         var _nX:uint = Math.floor(this.nPointer / this.nBitmapSize);
         var _nY:uint = this.nPointer % this.nBitmapSize;
         _nFloat = this.oBmpD.getPixel32(_nX,_nY) / 4294967295;
         ++this.nPointer;
         ++this.nIndex;
         return _nFloat;
      }
      
      public function get index() : uint
      {
         return this.nIndex;
      }
      
      public function set index(_nIndex:uint) : void
      {
         this.nIndex = _nIndex;
         this.nPointer = this.nIndex % (this.nPointerMax + 1);
         var _nSeedAddon:uint = Math.floor(this.nIndex / (this.nPointerMax + 1));
         this.internalSeed = this.nStartSeed + _nSeedAddon;
      }
      
      public function get seed() : uint
      {
         return this.nStartSeed;
      }
      
      private function get internalSeed() : uint
      {
         return this.nSeed;
      }
      
      private function set internalSeed(_nSeed:uint) : void
      {
         if(this.nSeed != _nSeed || this.bFirstProcessRequired)
         {
            this.nSeed = _nSeed;
            this.bFirstProcessRequired = false;
            this.generateGrid();
         }
      }
      
      private function generateGrid() : void
      {
         this.oBmpD.noise(this.nSeed,0,255,BitmapDataChannel.RED | BitmapDataChannel.GREEN | BitmapDataChannel.BLUE | BitmapDataChannel.ALPHA);
      }
   }
}

