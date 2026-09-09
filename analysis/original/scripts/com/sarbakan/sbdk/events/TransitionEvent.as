package com.sarbakan.sbdk.events
{
   import flash.display.Sprite;
   import flash.events.Event;
   
   public class TransitionEvent extends Event
   {
      
      public static const START:String = "sbdk_start";
      
      public static const STOP:String = "sbdk_stop";
      
      public static const COMPLETE:String = "sbdk_complete";
      
      public static const PAUSE:String = "sbdk_pause";
      
      public static const RESUME:String = "sbdk_resume";
      
      public static const ERROR:String = "sbdk_error";
      
      private var sTransitionID:String;
      
      private var mcRef:Sprite;
      
      private var sError:String;
      
      public function TransitionEvent(_sType:String, _bBubbles:Boolean, _bCancelable:Boolean, _sTransitionID:String = "", _mcRef:Sprite = null, _sError:String = "")
      {
         super(_sType,_bBubbles,_bCancelable);
         this.sTransitionID = _sTransitionID;
         this.mcRef = _mcRef;
         this.sError = _sError;
      }
      
      override public function clone() : Event
      {
         return new TransitionEvent(type,bubbles,cancelable,this.transitionID,this.asset,this.error);
      }
      
      override public function toString() : String
      {
         return formatToString("StateEvent","type","bubbles","cancelable","transitionID","asset","error");
      }
      
      public function get transitionID() : String
      {
         return this.sTransitionID;
      }
      
      public function get asset() : Sprite
      {
         return this.mcRef;
      }
      
      public function get error() : String
      {
         return this.sError;
      }
   }
}

