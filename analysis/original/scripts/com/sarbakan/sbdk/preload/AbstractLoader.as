package com.sarbakan.sbdk.preload
{
   import com.sarbakan.sbdk.errors.ErrorMessages;
   import com.sarbakan.sbdk.utils.AbsPathUtil;
   import com.sarbakan.sbdk.utils.EventManager;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.net.URLRequest;
   import flash.net.URLVariables;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public class AbstractLoader implements IPreloadable, IEventDispatcher
   {
      
      protected var sId:String;
      
      protected var sFileName:String;
      
      protected var oRequest:URLRequest;
      
      protected var bLoading:Boolean;
      
      protected var nProgress:int;
      
      private var oDispatcher:EventDispatcher;
      
      private var oEventManager:EventManager;
      
      private var oPublicEventManager:EventManager;
      
      private var nPriority:int;
      
      public function AbstractLoader(_sFileName:String, _sMethod:String, _oData:URLVariables, _sContentType:String, _aRequestHeaders:Array)
      {
         var _sPath:String = null;
         super();
         var _bUsingAbsPath:Boolean = _sFileName.indexOf(":/") != -1;
         if(Class(getDefinitionByName(getQualifiedClassName(this))) == AbstractLoader)
         {
            throw new IllegalOperationError(ErrorMessages.sABSTRACT_CLASS_ERROR);
         }
         this.sFileName = _sFileName;
         if(!_bUsingAbsPath)
         {
            _sPath = AbsPathUtil.parseAbsoluteURL(PreloadManager.instance.appAbsPath + this.sFileName);
         }
         else
         {
            _sPath = this.sFileName;
         }
         this.oRequest = new URLRequest(_sPath);
         if(_sMethod != null)
         {
            this.oRequest.method = _sMethod;
         }
         this.oRequest.data = _oData;
         this.oRequest.contentType = _sContentType;
         if(_aRequestHeaders != null)
         {
            this.oRequest.requestHeaders = _aRequestHeaders;
         }
         this.bLoading = false;
         this.nPriority = -1;
         this.oDispatcher = new EventDispatcher(this);
         this.oEventManager = new EventManager();
      }
      
      public function destroy() : void
      {
         this.oEventManager.destroy();
         if(this.oPublicEventManager != null)
         {
            this.oPublicEventManager.clearAll();
            this.oPublicEventManager.destroy();
            this.oPublicEventManager = null;
         }
         this.oRequest = null;
         this.oEventManager = null;
      }
      
      public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false) : void
      {
         this.oDispatcher.addEventListener(type,listener,useCapture,priority,useWeakReference);
      }
      
      public function dispatchEvent(evt:Event) : Boolean
      {
         return this.oDispatcher.dispatchEvent(evt);
      }
      
      public function hasEventListener(type:String) : Boolean
      {
         return this.oDispatcher.hasEventListener(type);
      }
      
      public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false) : void
      {
         this.oDispatcher.removeEventListener(type,listener,useCapture);
      }
      
      public function willTrigger(type:String) : Boolean
      {
         return this.oDispatcher.willTrigger(type);
      }
      
      public function start() : void
      {
      }
      
      public function stop() : void
      {
      }
      
      public function toString() : String
      {
         return "[AbstractLoader: ID = " + this.sId + ", File name = " + this.sFileName + ", Loading = " + String(this.bLoading) + "]";
      }
      
      protected function init() : void
      {
      }
      
      public function get priority() : int
      {
         return this.nPriority;
      }
      
      public function set priority(_nValue:int) : void
      {
         this.nPriority = _nValue;
      }
      
      public function get loadingProgress() : int
      {
         return this.nProgress;
      }
      
      public function get isLoading() : Boolean
      {
         return this.bLoading;
      }
      
      public function get fileName() : String
      {
         return this.sFileName;
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
      
      public function get eventManager() : EventManager
      {
         if(this.oPublicEventManager == null)
         {
            this.oPublicEventManager = new EventManager();
         }
         return this.oPublicEventManager;
      }
      
      public function get isGroup() : Boolean
      {
         return false;
      }
   }
}

