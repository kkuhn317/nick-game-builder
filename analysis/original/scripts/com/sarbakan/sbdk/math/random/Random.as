package com.sarbakan.sbdk.math.random
{
   import com.sarbakan.sbdk.math.random.seedAlgorithm.NoSeed;
   
   public class Random
   {
      
      private static var oAlgorithm:IRandomAlgorithm;
      
      private var oAlgorithm:IRandomAlgorithm;
      
      public function Random(_oAlgorithm:IRandomAlgorithm = null)
      {
         super();
         if(_oAlgorithm != null)
         {
            this.oAlgorithm = _oAlgorithm;
         }
         else
         {
            this.oAlgorithm = new NoSeed();
         }
      }
      
      public static function setAlgorithm(_oAlgorithm:IRandomAlgorithm = null) : void
      {
         if(_oAlgorithm != null)
         {
            oAlgorithm = _oAlgorithm;
         }
         else
         {
            oAlgorithm = new NoSeed();
         }
      }
      
      public static function getInt(_nMin:int = 0, _nMax:int = 2147483647) : int
      {
         initStaticSeed();
         return setInt(_nMin,_nMax,oAlgorithm.nextValue());
      }
      
      public static function getFloat(_nMin:Number = 0, _nMax:Number = 1, _nNumberAfterPoint:uint = undefined) : Number
      {
         initStaticSeed();
         return setFloat(_nMin,_nMax,_nNumberAfterPoint,oAlgorithm.nextValue());
      }
      
      public static function getBoolean(_nChance:Number = 0.5) : Boolean
      {
         initStaticSeed();
         return setBoolean(_nChance,oAlgorithm.nextValue());
      }
      
      public static function getSign(_nChance:Number = 0.5) : int
      {
         initStaticSeed();
         return setSign(_nChance,oAlgorithm.nextValue());
      }
      
      public static function getBit(_nChance:Number = 0.5) : uint
      {
         initStaticSeed();
         return setBit(_nChance,oAlgorithm.nextValue());
      }
      
      public static function getArrayElement(_aArray:Array, _bRemove:Boolean = false) : Object
      {
         initStaticSeed();
         return setArrayElement(_aArray,_bRemove,oAlgorithm.nextValue());
      }
      
      private static function initStaticSeed() : void
      {
         if(oAlgorithm == null)
         {
            setAlgorithm();
         }
      }
      
      private static function setInt(_nMin:int, _nMax:int, _nValue:Number) : int
      {
         var _nRange:Number = _nMax - _nMin + 1;
         return Math.floor(_nValue * _nRange + _nMin);
      }
      
      private static function setFloat(_nMin:Number, _nMax:Number, _nNumberAfterPoint:uint, _nValue:Number) : Number
      {
         var _nRank:Number = NaN;
         var _nRange:Number = _nMax - _nMin;
         var nResult:Number = _nValue * _nRange + _nMin;
         if(_nNumberAfterPoint != 0)
         {
            _nRank = 10;
            while(_nNumberAfterPoint > 1)
            {
               _nRank *= 10;
               _nNumberAfterPoint--;
            }
            nResult = Math.floor(nResult * _nRank) / _nRank;
         }
         return nResult;
      }
      
      private static function setBoolean(_nChance:Number, _nValue:Number) : Boolean
      {
         if(_nValue > _nChance)
         {
            return false;
         }
         return true;
      }
      
      private static function setSign(_nChance:Number, _nValue:Number) : int
      {
         if(_nValue > _nChance)
         {
            return -1;
         }
         return 1;
      }
      
      private static function setBit(_nChance:Number, _nValue:Number) : uint
      {
         if(_nValue > _nChance)
         {
            return 0;
         }
         return 1;
      }
      
      private static function setArrayElement(_aArray:Array, _bRemove:Boolean, _nValue:Number) : Object
      {
         var _nResult:Number = Math.floor(_nValue * _aArray.length);
         if(_bRemove)
         {
            return _aArray.splice(_nResult,1)[0];
         }
         return _aArray[_nResult];
      }
      
      public function getInt(_nMin:int = 0, _nMax:int = 2147483647) : int
      {
         return setInt(_nMin,_nMax,this.oAlgorithm.nextValue());
      }
      
      public function getFloat(_nMin:Number = 0, _nMax:Number = 1, _nNumberAfterPoint:uint = undefined) : Number
      {
         return setFloat(_nMin,_nMax,_nNumberAfterPoint,this.oAlgorithm.nextValue());
      }
      
      public function getBoolean(_nChance:Number = 0.5) : Boolean
      {
         return setBoolean(_nChance,this.oAlgorithm.nextValue());
      }
      
      public function getSign(_nChance:Number = 0.5) : int
      {
         return setSign(_nChance,this.oAlgorithm.nextValue());
      }
      
      public function getBit(_nChance:Number = 0.5) : uint
      {
         return setBit(_nChance,this.oAlgorithm.nextValue());
      }
      
      public function getArrayElement(_aArray:Array, _bRemove:Boolean = false) : Object
      {
         return setArrayElement(_aArray,_bRemove,this.oAlgorithm.nextValue());
      }
   }
}

