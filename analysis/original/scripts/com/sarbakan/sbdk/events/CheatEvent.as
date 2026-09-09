package com.sarbakan.sbdk.events
{
   import flash.events.Event;
   
   public class CheatEvent extends Event
   {
      
      public static const CHEAT_ACTIVATED:String = "sbdk_cheat_activated";
      
      private var sID:String;
      
      public function CheatEvent(_sType:String, _bBubbles:Boolean, _bCancelable:Boolean, _sID:String)
      {
         super(_sType,_bBubbles,_bCancelable);
         this.sID = _sID;
      }
      
      override public function clone() : Event
      {
         return new CheatEvent(type,bubbles,cancelable,this.sID);
      }
      
      override public function toString() : String
      {
         return formatToString("CheatEvent","type","bubbles","cancelable","ID");
      }
      
      public function get ID() : String
      {
         return this.sID;
      }
   }
}

