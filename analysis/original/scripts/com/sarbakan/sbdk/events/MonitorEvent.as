package com.sarbakan.sbdk.events
{
   import flash.events.Event;
   
   public class MonitorEvent extends Event
   {
      
      public static const UPDATE:String = "sbdk_update";
      
      public static const MIN:String = "sbdk_min";
      
      public static const MAX:String = "sbdk_max";
      
      private var nValue:int;
      
      private var nAverage:Number;
      
      public function MonitorEvent(_sType:String, _bBubbles:Boolean, _bCancelable:Boolean, _nValue:int, _nAverage:Number)
      {
         super(_sType,_bBubbles,_bCancelable);
         this.nValue = _nValue;
         this.nAverage = _nAverage;
      }
      
      override public function clone() : Event
      {
         return new MonitorEvent(type,bubbles,cancelable,this.nValue,this.nAverage);
      }
      
      override public function toString() : String
      {
         return formatToString("MonitorEvent","type","bubbles","cancelable","value","average");
      }
      
      public function get value() : int
      {
         return this.nValue;
      }
      
      public function get average() : Number
      {
         return this.nAverage;
      }
   }
}

