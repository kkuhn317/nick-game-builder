package com.sarbakan.sbdk.localization
{
   import com.sarbakan.sbdk.asset.DisplayAsset;
   import com.sarbakan.sbdk.errors.AssetError;
   import com.sarbakan.sbdk.events.LocalizationEvent;
   import com.sarbakan.sbdk.tools.logger.Logger;
   import com.sarbakan.sbdk.utils.EventManager;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   
   public class LocalizedExternalDisplayObject
   {
      
      private static const sEVENT_MANAGER_ID:String = "eventManager";
      
      private var oEventManager:EventManager;
      
      private var oLocalizationManager:LocalizationManager;
      
      private var mcContainer:DisplayObjectContainer;
      
      private var mcContent:DisplayObject;
      
      private var sFileName:String;
      
      private var bCache:Boolean;
      
      public function LocalizedExternalDisplayObject(_mcContainer:DisplayObjectContainer, _sFileName:String, _bCache:Boolean)
      {
         super();
         this.mcContainer = _mcContainer;
         this.sFileName = _sFileName;
         this.bCache = _bCache;
         this.init();
      }
      
      public function toString() : String
      {
         return "[LocalizedExternalDisplayObject: File name = " + this.sFileName + "]";
      }
      
      public function destroy() : void
      {
         this.oEventManager.clearAll();
         this.oEventManager.destroy();
         this.oEventManager = null;
         this.mcContainer = null;
         this.mcContent = null;
         this.oLocalizationManager = null;
      }
      
      private function init() : void
      {
         this.oEventManager = new EventManager();
         this.oLocalizationManager = LocalizationManager.instance;
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oLocalizationManager,LocalizationEvent.LOCALE_CHANGED,this.onLocaleChanged);
         this.loadDisplayObject();
      }
      
      private function loadDisplayObject() : void
      {
         this.oLocalizationManager.requestDisplayAsset(this.sFileName,this.bCache,this.onLoaded,this.onError);
      }
      
      private function onLoaded(_oAsset:DisplayAsset) : void
      {
         if(this.mcContent != null)
         {
            if(this.mcContent.parent != null)
            {
               this.mcContent.parent.removeChild(this.mcContent);
            }
            this.mcContent = null;
         }
         this.mcContent = _oAsset.content as DisplayObject;
         this.mcContainer.addChild(this.mcContent);
      }
      
      private function onError(_oError:AssetError) : void
      {
         Logger.instance.logError("Unable to load \'" + _oError.ID + "\': " + _oError.error);
      }
      
      private function onLocaleChanged(_e:LocalizationEvent) : void
      {
         this.loadDisplayObject();
      }
      
      public function get mc() : DisplayObject
      {
         return this.mcContent;
      }
   }
}

