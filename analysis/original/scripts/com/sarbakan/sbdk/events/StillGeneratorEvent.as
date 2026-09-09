package com.sarbakan.sbdk.events
{
   import com.sarbakan.sbdk.blitting.core.StillPanel;
   import flash.events.Event;
   
   public class StillGeneratorEvent extends Event
   {
      
      public static const PANEL_ADDED:String = "sbdk_progress";
      
      private var oPanel:StillPanel;
      
      public function StillGeneratorEvent(_sType:String, _oPanel:StillPanel, _bBubbles:Boolean = false, _bCancelable:Boolean = false)
      {
         super(_sType,_bBubbles,_bCancelable);
         this.oPanel = _oPanel;
      }
      
      override public function clone() : Event
      {
         return new StillGeneratorEvent(type,this.panel,bubbles,cancelable);
      }
      
      public function get panel() : StillPanel
      {
         return this.oPanel;
      }
   }
}

