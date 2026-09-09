package com.arabicode.text.Flaraby
{
   import flash.events.Event;
   
   public class UrduRemEvent extends Event
   {
      
      public static const URDUREM:String = "urduOff";
      
      public function UrduRemEvent(type:String)
      {
         super(URDUREM);
      }
      
      override public function toString() : String
      {
         return "[Event name=\"" + URDUREM + "\", type=\"com.arabicode.text.Flaraby.UrduRemEvent\" ]";
      }
      
      override public function clone() : Event
      {
         return new UrduRemEvent(URDUREM);
      }
   }
}

