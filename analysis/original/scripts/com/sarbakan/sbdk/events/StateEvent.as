package com.sarbakan.sbdk.events
{
   import flash.events.Event;
   
   public class StateEvent extends Event
   {
      
      public static const START:String = "sbdk_start";
      
      public static const STOP:String = "sbdk_stop";
      
      public static const COMPLETE:String = "sbdk_complete";
      
      public static const PAUSE:String = "sbdk_pause";
      
      public static const RESUME:String = "sbdk_resume";
      
      private var sStateID:String;
      
      public function StateEvent(_sType:String, _bBubbles:Boolean, _bCancelable:Boolean, _sStateID:String)
      {
         super(_sType,_bBubbles,_bCancelable);
         this.sStateID = _sStateID;
      }
      
      override public function clone() : Event
      {
         return new StateEvent(type,bubbles,cancelable,this.stateID);
      }
      
      override public function toString() : String
      {
         return formatToString("StateEvent","type","bubbles","cancelable","stateID");
      }
      
      public function get stateID() : String
      {
         return this.sStateID;
      }
   }
}

