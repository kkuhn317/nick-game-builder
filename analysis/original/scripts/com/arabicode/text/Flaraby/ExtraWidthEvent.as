package com.arabicode.text.Flaraby
{
   import flash.events.Event;
   
   public class ExtraWidthEvent extends Event
   {
      
      public static const EXTRAWIDTHCHANGE:String = "extraWidthChange";
      
      public function ExtraWidthEvent(type:String)
      {
         super(EXTRAWIDTHCHANGE);
      }
      
      override public function toString() : String
      {
         return "[Event name=\"" + EXTRAWIDTHCHANGE + "\", type=\"com.arabicode.text.Flaraby.ExtraWidthEvent\" ]";
      }
      
      override public function clone() : Event
      {
         return new ExtraWidthEvent(EXTRAWIDTHCHANGE);
      }
   }
}

