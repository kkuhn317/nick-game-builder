package com.sarbakan.sbdk.events
{
   import flash.display.Bitmap;
   import flash.events.Event;
   
   public class ViewEvent extends Event
   {
      
      public static const SHOW:String = "sbdk_show";
      
      public static const HIDE:String = "sbdk_hide";
      
      public static const ERROR:String = "sbdk_error";
      
      private var sViewId:String;
      
      private var sError:String;
      
      private var mcAssetRef:Bitmap;
      
      public function ViewEvent(_sType:String, _bBubbles:Boolean = false, _bCancelable:Boolean = false, _sViewId:String = "", _assetRef:Bitmap = null, _sError:String = "")
      {
         super(_sType,_bBubbles,_bCancelable);
         this.sViewId = _sViewId;
         this.mcAssetRef = _assetRef;
         this.sError = _sError;
      }
      
      override public function clone() : Event
      {
         return new ViewEvent(type,bubbles,cancelable,this.viewID,null,this.error);
      }
      
      override public function toString() : String
      {
         return formatToString("AssetEvent","type","bubbles","cancelable","viewID","assetRef","error");
      }
      
      public function get viewID() : String
      {
         return this.sViewId;
      }
      
      public function get error() : String
      {
         return this.sError;
      }
      
      public function get assetRef() : Bitmap
      {
         return this.mcAssetRef;
      }
   }
}

