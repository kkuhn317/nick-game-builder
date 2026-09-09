package com.sarbakan.sbdk.asset
{
   import com.sarbakan.sbdk.utils.AbstractEnumeration;
   
   public class AssetLocation extends AbstractEnumeration
   {
      
      public static const INTERNAL:AssetLocation = new AssetLocation("internal",oProtectionFlag);
      
      public static const EXTERNAL:AssetLocation = new AssetLocation("external",oProtectionFlag);
      
      public function AssetLocation(_sName:String, _oProtectionFlag:Object)
      {
         super(_sName,_oProtectionFlag);
      }
   }
}

