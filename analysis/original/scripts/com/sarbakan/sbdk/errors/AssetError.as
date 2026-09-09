package com.sarbakan.sbdk.errors
{
   public class AssetError
   {
      
      private var sId:String;
      
      private var sError:String;
      
      public function AssetError(_sId:String, _sError:String)
      {
         super();
         this.sId = _sId;
         this.sError = _sError;
      }
      
      public function get ID() : String
      {
         return this.sId;
      }
      
      public function get error() : String
      {
         return this.sError;
      }
   }
}

