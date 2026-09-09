package com.sarbakan.sbdk.events
{
   import flash.events.Event;
   
   public class VOEvent extends Event
   {
      
      public static const COMPLETE:String = "sbdk_complete";
      
      public static const START:String = "sbdk_start";
      
      public static const ERROR:String = "sbdk_error";
      
      public static const QUEUE_COMPLETE:String = "sbdk_queue_complete";
      
      private var sID:String;
      
      private var sUnitID:String;
      
      private var sError:String;
      
      public function VOEvent(_sType:String, _bBubbles:Boolean, _bCancelable:Boolean, _sVoiceOverID:String, _sUnitID:String = null, _sError:String = null)
      {
         super(_sType,_bBubbles,_bCancelable);
         this.sID = _sVoiceOverID;
         this.sUnitID = _sUnitID;
         this.sError = _sError;
      }
      
      override public function clone() : Event
      {
         return new VOEvent(type,bubbles,cancelable,this.ID,this.error);
      }
      
      override public function toString() : String
      {
         return formatToString("AssetEvent","type","bubbles","cancelable","ID","unitID","error");
      }
      
      public function get ID() : String
      {
         return this.sID;
      }
      
      public function get unitID() : String
      {
         return this.sUnitID;
      }
      
      public function get error() : String
      {
         return this.sError;
      }
   }
}

