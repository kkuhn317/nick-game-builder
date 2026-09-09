package com.sarbakan.sbdk.events
{
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   
   public class KeyEvent extends KeyboardEvent
   {
      
      public static const KEY_DOWN:String = "sbdk_keyDown";
      
      public static const KEY_UP:String = "sbdk_keyUp";
      
      public static const KEY_COMBINATION_DOWN:String = "sbdk_keyCombinationDown";
      
      public static const KEY_COMBINATION_UP:String = "sbdk_keyCombinationUp";
      
      private var sID:String;
      
      public function KeyEvent(_sType:String, _bBubbles:Boolean, _bCancelable:Boolean, _sID:String, _nCharCodeValue:uint = 0, _nKeyCodeValue:uint = 0, _nKeyLocationValue:uint = 0, _bCtrlKeyValue:Boolean = false, _bAltKeyValue:Boolean = false, _bShiftKeyValue:Boolean = false)
      {
         super(_sType,_bBubbles,_bCancelable,_nCharCodeValue,_nKeyCodeValue,_nKeyLocationValue,_bCtrlKeyValue,_bAltKeyValue,_bShiftKeyValue);
         this.sID = _sID;
      }
      
      override public function clone() : Event
      {
         return new KeyEvent(type,bubbles,cancelable,this.sID);
      }
      
      override public function toString() : String
      {
         return formatToString("KeyEvent","type","bubbles","cancelable","ID","altKey","charCode","ctrlKey","keyCode","keyLocation","shiftKey");
      }
      
      public function get ID() : String
      {
         return this.sID;
      }
   }
}

