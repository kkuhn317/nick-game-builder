package com.sarbakan.sbdk.utils
{
   public class StringDirection extends AbstractEnumeration
   {
      
      public static const LEFT:StringDirection = new StringDirection("left",oProtectionFlag);
      
      public static const RIGHT:StringDirection = new StringDirection("right",oProtectionFlag);
      
      public static const BOTH:StringDirection = new StringDirection("both",oProtectionFlag);
      
      public function StringDirection(_sName:String, _oProtectionFlag:Object)
      {
         super(_sName,_oProtectionFlag);
      }
   }
}

