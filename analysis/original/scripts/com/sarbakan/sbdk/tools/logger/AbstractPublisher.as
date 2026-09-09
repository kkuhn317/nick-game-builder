package com.sarbakan.sbdk.tools.logger
{
   import com.sarbakan.sbdk.errors.ErrorMessages;
   import com.sarbakan.sbdk.events.LogEvent;
   import com.sarbakan.sbdk.utils.EventManager;
   import flash.errors.IllegalOperationError;
   import flash.events.EventDispatcher;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public class AbstractPublisher extends EventDispatcher
   {
      
      private static const sLOG_EVENT:String = "LOG_EVENT";
      
      private var oEventManager:EventManager;
      
      private var oPublicEventManager:EventManager;
      
      protected var oFilter:LogFilter;
      
      public function AbstractPublisher()
      {
         super();
         if(Class(getDefinitionByName(getQualifiedClassName(this))) == AbstractPublisher)
         {
            throw new IllegalOperationError(ErrorMessages.sABSTRACT_CLASS_ERROR);
         }
         this.initialize();
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
         if(this.oFilter != null)
         {
            this.oFilter.destroy();
         }
         this.oFilter = null;
      }
      
      public function setFilter(_oFilter:LogFilter) : void
      {
         this.oFilter = _oFilter;
      }
      
      protected function init() : void
      {
      }
      
      protected function publish(_sScope:String, _sFunctionDef:String, _sMsg:String, _oLevel:LogLevel) : void
      {
      }
      
      private function initialize() : void
      {
         this.oEventManager = new EventManager();
         this.oEventManager.addEventListener(sLOG_EVENT,Logger.instance,LogEvent.LOG,this.onLogEvent);
         this.init();
      }
      
      private function onLogEvent(_oEvent:LogEvent) : void
      {
         this.publish(_oEvent.scope,_oEvent.functionDef,_oEvent.msg,_oEvent.level);
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

