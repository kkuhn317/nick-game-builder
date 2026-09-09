package com.arabicode.text.Flaraby
{
   import flash.events.Event;
   
   public class DirEvent extends Event
   {
      
      public static const DIRCHANGE:String = "dirChange";
      
      public function DirEvent(type:String)
      {
         super(DIRCHANGE);
      }
      
      override public function toString() : String
      {
         return "[Event name=\"" + DIRCHANGE + "\", type=\"com.arabicode.text.Flaraby.DirEvent\" ]";
      }
      
      override public function clone() : Event
      {
         return new DirEvent(DIRCHANGE);
      }
   }
}

