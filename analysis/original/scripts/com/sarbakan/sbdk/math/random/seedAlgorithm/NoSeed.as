package com.sarbakan.sbdk.math.random.seedAlgorithm
{
   import com.sarbakan.sbdk.math.random.IRandomAlgorithm;
   
   public class NoSeed implements IRandomAlgorithm
   {
      
      public function NoSeed()
      {
         super();
      }
      
      public function nextValue() : Number
      {
         return Math.random();
      }
   }
}

