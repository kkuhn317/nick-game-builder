package com.sarbakan.sbdk.state
{
   import com.sarbakan.sbdk.utils.AbstractEnumeration;
   
   public class AnimStateLocation extends AbstractEnumeration
   {
      
      public static const TIMELINE:AnimStateLocation = new AnimStateLocation("timeline",oProtectionFlag);
      
      public static const ASSET:AnimStateLocation = new AnimStateLocation("asset",oProtectionFlag);
      
      public function AnimStateLocation(_sName:String, _oProtectionFlag:Object)
      {
         super(_sName,_oProtectionFlag);
      }
   }
}

