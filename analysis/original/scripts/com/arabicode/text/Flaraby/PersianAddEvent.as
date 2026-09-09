package com.arabicode.text.Flaraby
{
   import flash.events.Event;
   
   public class PersianAddEvent extends Event
   {
      
      public static const PERSIANADD:String = "persianOn";
      
      public function PersianAddEvent(type:String)
      {
         super(PERSIANADD);
      }
      
      override public function toString() : String
      {
         return "[Event name=\"" + PERSIANADD + "\", type=\"com.arabicode.text.Flaraby.PersianAddEvent\" ]";
      }
      
      override public function clone() : Event
      {
         return new PersianAddEvent(PERSIANADD);
      }
   }
}

