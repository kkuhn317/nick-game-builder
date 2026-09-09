package com.sarbakan.sbdk.events
{
   import flash.events.Event;
   
   public class UIEvent extends Event
   {
      
      public static const CHANGE:String = "change";
      
      public static const ENABLE:String = "enable";
      
      public static const DISABLE:String = "disable";
      
      public static const PRESS:String = "press";
      
      public static const RELEASE:String = "released";
      
      public static const RELEASE_OUTSIDE:String = "releaseOutside";
      
      public static const ROLL_OVER:String = "rollOver";
      
      public static const ROLL_OUT:String = "rollOut";
      
      public static const COMPLETE:String = "complete";
      
      public static const FOCUS_OUT:String = "focus_out";
      
      public function UIEvent(_sType:String, _bBubbles:Boolean = false, _bCancelable:Boolean = false)
      {
         super(_sType,_bBubbles,_bCancelable);
      }
      
      override public function clone() : Event
      {
         return new UIEvent(type,bubbles,cancelable);
      }
      
      override public function toString() : String
      {
         return formatToString("UIEvent","type","bubbles","cancelable");
      }
   }
}

