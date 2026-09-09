package com.arabicode.text.Flaraby
{
   import flash.events.Event;
   
   public class ConvertEvent extends Event
   {
      
      public static const CONVERT:String = "convert";
      
      public function ConvertEvent(type:String)
      {
         super(CONVERT);
      }
      
      override public function toString() : String
      {
         return "[Event name=\"" + CONVERT + "\", type=\"com.arabicode.text.Flaraby.ConvertEvent\" ]";
      }
      
      override public function clone() : Event
      {
         return new ConvertEvent(CONVERT);
      }
   }
}

