package com.sarbakan.sbdk.sound.vomanager
{
   import com.sarbakan.sbdk.math.random.Random;
   
   public class LipsyncDataDummy extends AbstractLipsyncData
   {
      
      private static const nDEFAULT_DURATION:int = 2;
      
      private static const nUPDATE_STEP:int = 150;
      
      private static const aPHONEMES:Array = ["x","j","n","y","AE","AA","w","v","l","r"];
      
      private var nDuration:int;
      
      public function LipsyncDataDummy()
      {
         super();
         bDummy = true;
         lipsArray = new Array();
         timingArray = new Array();
      }
      
      private function createTimingInfo() : void
      {
         if(lipsArray.length > 0)
         {
            lipsArray.splice(0,lipsArray.length);
         }
         if(timingArray.length > 0)
         {
            timingArray.splice(0,timingArray.length);
         }
         for(var i:int = 0; i <= this.nDuration / nUPDATE_STEP; i++)
         {
            lipsArray.push(aPHONEMES[Random.getInt(0,aPHONEMES.length - 1)]);
            timingArray.push(i * nUPDATE_STEP);
         }
      }
      
      public function get duration() : int
      {
         return this.nDuration;
      }
      
      public function set duration(_nLength:int) : void
      {
         this.nDuration = _nLength * 1000;
         this.createTimingInfo();
      }
   }
}

