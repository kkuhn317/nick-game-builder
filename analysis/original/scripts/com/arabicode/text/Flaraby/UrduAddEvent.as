package com.arabicode.text.Flaraby
{
   import flash.events.Event;
   
   public class UrduAddEvent extends Event
   {
      
      public static const URDUADD:String = "urduOn";
      
      public function UrduAddEvent(type:String)
      {
         super(URDUADD);
      }
      
      override public function toString() : String
      {
         return "[Event name=\"" + URDUADD + "\", type=\"com.arabicode.text.Flaraby.UrduAddEvent\" ]";
      }
      
      override public function clone() : Event
      {
         return new UrduAddEvent(URDUADD);
      }
   }
}

