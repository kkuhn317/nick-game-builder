package com.sarbakan.sbdk.events
{
   import flash.events.Event;
   
   public class UpdateEvent extends Event
   {
      
      public static const UPDATE:String = "sbdk_update";
      
      public static const UPDATE_PAUSED:String = "sbdk_update_paused";
      
      public static const PAUSE:String = "sbdk_pause";
      
      public static const RESUME:String = "sbdk_resume";
      
      public function UpdateEvent(_sType:String, _bBubbles:Boolean = false, _bCancelable:Boolean = false)
      {
         super(_sType,_bBubbles,_bCancelable);
      }
      
      override public function clone() : Event
      {
         return new UpdateEvent(type,bubbles,cancelable);
      }
      
      override public function toString() : String
      {
         return formatToString("UpdateEvent","type","bubbles","cancelable");
      }
   }
}

