package com.sarbakan.sbdk.asset
{
   public class FileAsset extends AbstractAsset
   {
      
      private var oFile:Object;
      
      public function FileAsset(_sID:String, _oFile:Object)
      {
         super(_sID);
         this.oFile = _oFile;
      }
      
      override public function destroy() : void
      {
         this.oFile = null;
      }
      
      public function get content() : Object
      {
         return this.oFile;
      }
   }
}

