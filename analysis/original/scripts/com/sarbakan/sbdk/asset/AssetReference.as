package com.sarbakan.sbdk.asset
{
   public class AssetReference
   {
      
      public static const sLIBRARY_CLASS:String = "LIBRARY_CLASS";
      
      public static const sLIBRARY_STRING:String = "LIBRARY_STRING";
      
      public static const sASSET_MANAGER:String = "ASSET_MANAGER";
      
      private var sLocation:String;
      
      private var sAssetId:String;
      
      private var sLinkId:String;
      
      private var oClassRef:Class;
      
      public function AssetReference(_sLocation:String, _oClassOrID:*)
      {
         super();
         switch(_sLocation)
         {
            case sASSET_MANAGER:
               this.sAssetId = _oClassOrID;
               break;
            case sLIBRARY_CLASS:
               this.oClassRef = _oClassOrID;
               break;
            case sLIBRARY_STRING:
               this.sLinkId = _oClassOrID;
         }
         this.sLocation = _sLocation;
      }
      
      public static function fromLibraryClass(_oClassRef:Class) : AssetReference
      {
         return new AssetReference(sLIBRARY_CLASS,_oClassRef);
      }
      
      public static function fromLibraryString(_sLinkID:String) : AssetReference
      {
         return new AssetReference(sLIBRARY_STRING,_sLinkID);
      }
      
      public static function fromAssetManager(_sAssetID:String) : AssetReference
      {
         return new AssetReference(sASSET_MANAGER,_sAssetID);
      }
      
      public function get location() : String
      {
         return this.sLocation;
      }
      
      public function get assetID() : String
      {
         return this.sAssetId;
      }
      
      public function get linkID() : String
      {
         return this.sLinkId;
      }
      
      public function get classRef() : Class
      {
         return this.oClassRef;
      }
   }
}

