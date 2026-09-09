package com.sarbakan.sbdk.blitting.core
{
   import com.sarbakan.sbdk.utils.AbstractEnumeration;
   
   public class BitmappedAnimationMode extends AbstractEnumeration
   {
      
      public static const TIME_BASE:BitmappedAnimationMode = new BitmappedAnimationMode("time_base",oProtectionFlag);
      
      public static const FRAME_BASE:BitmappedAnimationMode = new BitmappedAnimationMode("frame_base",oProtectionFlag);
      
      public function BitmappedAnimationMode(_sName:String, _oProtectionFlag:Object)
      {
         super(_sName,_oProtectionFlag);
      }
   }
}

