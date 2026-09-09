package com.sarbakan.sbdk.events
{
   import flash.events.Event;
   
   public class SequenceEvent extends Event
   {
      
      public static const SEQUENCE_COMPLETED:String = "sbdk_sequence_completed";
      
      public static const SEQUENCE_UNIT:String = "sbdk_sequence_unit";
      
      public static const SEQUENCE_FAILED:String = "sbdk_sequence_failed";
      
      private var sSequenceID:String;
      
      public function SequenceEvent(_sType:String, _bBubbles:Boolean, _bCancelable:Boolean, _sSequenceID:String)
      {
         super(_sType,_bBubbles,_bCancelable);
         this.sSequenceID = _sSequenceID;
      }
      
      override public function clone() : Event
      {
         return new SequenceEvent(type,bubbles,cancelable,this.sSequenceID);
      }
      
      override public function toString() : String
      {
         return formatToString("SequenceEvent","type","bubbles","cancelable","ID");
      }
      
      public function get ID() : String
      {
         return this.sSequenceID;
      }
   }
}

