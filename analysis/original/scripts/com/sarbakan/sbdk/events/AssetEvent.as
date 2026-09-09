package com.sarbakan.sbdk.events
{
   import flash.events.Event;
   
   public class AssetEvent extends Event
   {
      
      public static const PROGRESS:String = "sbdk_progress";
      
      public static const COMPLETE:String = "sbdk_complete";
      
      public static const ERROR:String = "sbdk_error";
      
      private var sAssetID:String;
      
      private var nBytesLoaded:int;
      
      private var nBytesTotal:int;
      
      public function AssetEvent(_sType:String, _bBubbles:Boolean = false, _bCancelable:Boolean = false, _sAssetID:String = "", _nBytesLoaded:int = 0, _nBytesTotal:int = 0)
      {
         super(_sType,_bBubbles,_bCancelable);
         this.sAssetID = _sAssetID;
         this.nBytesLoaded = _nBytesLoaded;
         this.nBytesTotal = _nBytesTotal;
      }
      
      override public function clone() : Event
      {
         return new AssetEvent(type,bubbles,cancelable,this.assetID,this.bytesLoaded,this.bytesTotal);
      }
      
      override public function toString() : String
      {
         return formatToString("AssetEvent","type","bubbles","cancelable","assetID","bytesLoaded","bytesTotal");
      }
      
      public function get assetID() : String
      {
         return this.sAssetID;
      }
      
      public function get bytesLoaded() : int
      {
         return this.nBytesLoaded;
      }
      
      public function get bytesTotal() : int
      {
         return this.nBytesTotal;
      }
   }
}

