package com.arabicode.text.Flaraby
{
   import flash.events.Event;
   
   public class PersianRemEvent extends Event
   {
      
      public static const PERSIANREM:String = "persianOff";
      
      public function PersianRemEvent(type:String)
      {
         super(PERSIANREM);
      }
      
      override public function toString() : String
      {
         return "[Event name=\"" + PERSIANREM + "\", type=\"com.arabicode.text.Flaraby.PersianRemEvent\" ]";
      }
      
      override public function clone() : Event
      {
         return new PersianRemEvent(PERSIANREM);
      }
   }
}

