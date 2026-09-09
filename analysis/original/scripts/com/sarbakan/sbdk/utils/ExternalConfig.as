package com.sarbakan.sbdk.utils
{
   import com.sarbakan.sbdk.errors.ErrorMessages;
   import com.sarbakan.sbdk.events.PreloadEvent;
   import com.sarbakan.sbdk.preload.FileLoader;
   import com.sarbakan.sbdk.preload.PreloadManager;
   import flash.errors.IllegalOperationError;
   import flash.events.*;
   
   public class ExternalConfig extends EventDispatcher
   {
      
      private static var oInstance:ExternalConfig;
      
      private static const sEVENT_MANAGER_ID:String = "eventManager";
      
      private static const sPRELOAD_MANAGER_ID:String = "externalConfig";
      
      public static const sDEFAULT_CONFIG_PATH:String = "xml/config.xml";
      
      private static var bAllowConstruction:Boolean = false;
      
      private var oEventManager:EventManager;
      
      private var oProperty:Object;
      
      private var bLoaded:Boolean;
      
      public function ExternalConfig()
      {
         super();
         if(!bAllowConstruction)
         {
            throw new Error(ErrorMessages.sSINGLETON_STAGE);
         }
         this.init();
      }
      
      public static function get instance() : ExternalConfig
      {
         if(oInstance == null)
         {
            bAllowConstruction = true;
            oInstance = new ExternalConfig();
            bAllowConstruction = false;
         }
         return oInstance;
      }
      
      public function destroy() : void
      {
         oInstance = null;
         this.oEventManager.destroy();
         this.oEventManager = null;
         this.oProperty = null;
      }
      
      public function loadConfig(_sConfigFile:String) : void
      {
         var _oFileLoader:FileLoader = new FileLoader(_sConfigFile);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,_oFileLoader,PreloadEvent.COMPLETE,this.onConfigLoaded);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,_oFileLoader,PreloadEvent.ERROR,this.onConfigLoadError);
         PreloadManager.instance.addLoader(sPRELOAD_MANAGER_ID,_oFileLoader);
         PreloadManager.instance.start();
      }
      
      public function getProperty(_sPropertyName:String) : String
      {
         if(this.oProperty == null)
         {
            throw new IllegalOperationError();
         }
         return this.oProperty[_sPropertyName];
      }
      
      public function getPropertyAsInt(_sPropertyName:String) : int
      {
         if(this.oProperty == null)
         {
            throw new IllegalOperationError();
         }
         return this.oProperty[_sPropertyName] as int;
      }
      
      public function getPropertyAsUint(_sPropertyName:String) : uint
      {
         if(this.oProperty == null)
         {
            throw new IllegalOperationError();
         }
         return uint(this.oProperty[_sPropertyName]);
      }
      
      public function getPropertyAsNumber(_sPropertyName:String) : Number
      {
         if(this.oProperty == null)
         {
            throw new IllegalOperationError();
         }
         return Number(this.oProperty[_sPropertyName]);
      }
      
      public function getPropertyAsBoolean(_sPropertyName:String) : Boolean
      {
         if(this.oProperty == null)
         {
            throw new IllegalOperationError();
         }
         var _bValue:Boolean = false;
         if(this.oProperty[_sPropertyName] == "true")
         {
            _bValue = true;
         }
         return _bValue;
      }
      
      public function getPropertyAsString(_sPropertyName:String) : String
      {
         if(this.oProperty == null)
         {
            throw new IllegalOperationError();
         }
         return this.oProperty[_sPropertyName] as String;
      }
      
      public function getPropertyAsObject(_sPropertyName:String) : Object
      {
         if(this.oProperty == null)
         {
            throw new IllegalOperationError();
         }
         return this.oProperty[_sPropertyName] as Object;
      }
      
      public function getPropertyAsArray(_sPropertyName:String) : Array
      {
         if(this.oProperty == null)
         {
            throw new IllegalOperationError();
         }
         return this.oProperty[_sPropertyName].split(",");
      }
      
      private function init() : void
      {
         this.oEventManager = new EventManager();
         this.oProperty = new Object();
         this.bLoaded = false;
      }
      
      private function parseConfig(_oConfigData:XML) : void
      {
         var _oProperty:XML = null;
         for each(_oProperty in _oConfigData.property)
         {
            this.oProperty[_oProperty.@name] = _oProperty;
         }
      }
      
      private function onConfigLoaded(_e:PreloadEvent) : void
      {
         this.parseConfig(new XML(_e.content as String));
         this.bLoaded = true;
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      private function onConfigLoadError(_e:PreloadEvent) : void
      {
         dispatchEvent(_e);
      }
      
      public function get loaded() : Boolean
      {
         return this.bLoaded;
      }
   }
}

