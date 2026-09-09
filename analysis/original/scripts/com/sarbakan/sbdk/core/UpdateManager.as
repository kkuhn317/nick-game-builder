package com.sarbakan.sbdk.core
{
   import com.sarbakan.sbdk.errors.ErrorMessages;
   import com.sarbakan.sbdk.events.UpdateEvent;
   import com.sarbakan.sbdk.utils.EventManager;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   [Event(name="RESUME",type="com.sarbakan.sbdk.events.UpdateEvent")]
   [Event(name="PAUSE",type="com.sarbakan.sbdk.events.UpdateEvent")]
   [Event(name="UPDATE_PAUSED",type="com.sarbakan.sbdk.events.UpdateEvent")]
   [Event(name="UPDATE",type="com.sarbakan.sbdk.events.UpdateEvent")]
   public class UpdateManager extends EventDispatcher
   {
      
      private static var oInstance:UpdateManager;
      
      private static const sEVENT_MANAGER_ID:String = "updateManager";
      
      private static var bAllowConstruction:Boolean = false;
      
      private var oStage:Stage;
      
      private var oEventManager:EventManager;
      
      private var bPaused:Boolean;
      
      public function UpdateManager()
      {
         super();
         if(!bAllowConstruction)
         {
            throw new Error(ErrorMessages.sSINGLETON_STAGE);
         }
         this.init();
      }
      
      public static function get instance() : UpdateManager
      {
         if(oInstance == null)
         {
            bAllowConstruction = true;
            oInstance = new UpdateManager();
            bAllowConstruction = false;
         }
         return oInstance;
      }
      
      public function pause() : void
      {
         if(this.bPaused == false)
         {
            this.bPaused = true;
            dispatchEvent(new UpdateEvent(UpdateEvent.PAUSE));
         }
      }
      
      public function resume() : void
      {
         if(this.bPaused == true)
         {
            this.bPaused = false;
            dispatchEvent(new UpdateEvent(UpdateEvent.RESUME));
         }
      }
      
      public function togglePause() : void
      {
         if(this.bPaused == false)
         {
            this.pause();
         }
         else
         {
            this.resume();
         }
      }
      
      public function destroy() : void
      {
         this.oEventManager.destroy();
         this.oEventManager = null;
         this.oStage = null;
         oInstance = null;
      }
      
      public function setUpdateCallback(_oUpdateDispatcher:EventDispatcher = null, _sUpdateEvent:String = "") : void
      {
         this.oEventManager.clearAll();
         if(_oUpdateDispatcher != null)
         {
            this.oEventManager.addEventListener(sEVENT_MANAGER_ID,_oUpdateDispatcher,_sUpdateEvent,this.onEnterFrame);
         }
      }
      
      override public function toString() : String
      {
         return "[UpdateManager: paused = " + String(this.bPaused) + "]";
      }
      
      private function init() : void
      {
         this.oEventManager = new EventManager();
         this.bPaused = false;
      }
      
      private function onEnterFrame(_e:Event) : void
      {
         if(this.bPaused == false)
         {
            dispatchEvent(new UpdateEvent(UpdateEvent.UPDATE));
         }
         else
         {
            dispatchEvent(new UpdateEvent(UpdateEvent.UPDATE_PAUSED));
         }
      }
      
      public function get paused() : Boolean
      {
         return this.bPaused;
      }
      
      public function get stage() : Stage
      {
         return this.oStage;
      }
      
      public function set stage(_oStageRef:Stage) : void
      {
         this.oStage = _oStageRef;
      }
   }
}

