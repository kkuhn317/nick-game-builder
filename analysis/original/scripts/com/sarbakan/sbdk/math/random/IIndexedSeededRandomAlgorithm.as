package com.sarbakan.sbdk.math.random
{
   public interface IIndexedSeededRandomAlgorithm extends IStatelessSeededRandomAlgorithm
   {
      
      function get index() : uint;
      
      function set index(param1:uint) : void;
   }
}

