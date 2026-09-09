package com.sarbakan.sbdk.view
{
   import com.sarbakan.sbdk.asset.AssetManager;
   import com.sarbakan.sbdk.errors.ErrorMessages;
   import com.sarbakan.sbdk.events.TransitionEvent;
   import com.sarbakan.sbdk.utils.EventManager;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.errors.IllegalOperationError;
   import flash.events.EventDispatcher;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   [Event(name="ERROR",type="com.sarbakan.sbdk.events.TransitionEvent")]
   [Event(name="RESUME",type="com.sarbakan.sbdk.events.TransitionEvent")]
   [Event(name="PAUSE",type="com.sarbakan.sbdk.events.TransitionEvent")]
   [Event(name="COMPLETE",type="com.sarbakan.sbdk.events.TransitionEvent")]
   [Event(name="STOP",type="com.sarbakan.sbdk.events.TransitionEvent")]
   [Event(name="START",type="com.sarbakan.sbdk.events.TransitionEvent")]
   internal class AbstractTransition extends EventDispatcher
   {
      
      protected var bIsPlaying:Boolean;
      
      protected var mcContainerRef:Sprite;
      
      protected var oAssetManager:AssetManager;
      
      protected var mcOriginViewRef:DisplayObject;
      
      private var sId:String;
      
      private var oEventManager:EventManager;
      
      private var oPublicEventManager:EventManager;
      
      public function AbstractTransition()
      {
         super();
         if(Class(getDefinitionByName(getQualifiedClassName(this))) == AbstractTransition)
         {
            throw new IllegalOperationError(ErrorMessages.sABSTRACT_CLASS_ERROR);
         }
         this.init();
      }
      
      protected function init() : void
      {
         this.bIsPlaying = false;
         this.oEventManager = new EventManager();
         this.oAssetManager = AssetManager.instance;
         this.mcContainerRef = new Sprite();
      }
      
      public function destroy() : void
      {
         if(this.oPublicEventManager != null)
         {
            this.oPublicEventManager.clearAll();
            this.oPublicEventManager.destroy();
            this.oPublicEventManager = null;
         }
         this.oEventManager.clearAll();
         this.oEventManager.destroy();
         this.oEventManager = null;
         this.oAssetManager = null;
         this.mcContainerRef = null;
         this.mcOriginViewRef = null;
      }
      
      public function start(_mcRef:DisplayObject) : void
      {
         this.bIsPlaying = true;
         dispatchEvent(new TransitionEvent(TransitionEvent.START,false,false,this.ID,this.mcContainerRef));
      }
      
      public function stop() : void
      {
         this.bIsPlaying = false;
         dispatchEvent(new TransitionEvent(TransitionEvent.STOP,false,false,this.ID));
      }
      
      public function pause() : void
      {
         dispatchEvent(new TransitionEvent(TransitionEvent.PAUSE,false,false,this.ID));
      }
      
      public function resume() : void
      {
         dispatchEvent(new TransitionEvent(TransitionEvent.RESUME,false,false,this.ID));
      }
      
      override public function toString() : String
      {
         return "[AbstractTransition: ID = " + this.sId + ", Playing = " + this.bIsPlaying + "]";
      }
      
      public function get ID() : String
      {
         return this.sId;
      }
      
      public function set ID(_sId:String) : void
      {
         if(this.sId == null)
         {
            this.sId = _sId;
         }
      }
      
      public function get mcContainer() : Sprite
      {
         return this.mcContainerRef;
      }
      
      public function get isPlaying() : Boolean
      {
         return this.bIsPlaying;
      }
      
      public function get originViewAssetRef() : DisplayObject
      {
         return this.mcOriginViewRef;
      }
      
      public function set originViewAssetRef(_mcViewRef:DisplayObject) : void
      {
         this.mcOriginViewRef = _mcViewRef;
      }
      
      public function get eventManager() : EventManager
      {
         if(this.oPublicEventManager == null)
         {
            this.oPublicEventManager = new EventManager();
         }
         return this.oPublicEventManager;
      }
   }
}

