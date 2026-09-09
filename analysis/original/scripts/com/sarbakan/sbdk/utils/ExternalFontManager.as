package com.sarbakan.sbdk.utils
{
   import com.sarbakan.sbdk.errors.ErrorMessages;
   import com.sarbakan.sbdk.events.PreloadEvent;
   import com.sarbakan.sbdk.preload.DisplayLoader;
   import com.sarbakan.sbdk.preload.PreloadManager;
   import com.sarbakan.sbdk.tools.logger.Logger;
   import flash.system.ApplicationDomain;
   import flash.text.Font;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class ExternalFontManager
   {
      
      private static var oInstance:ExternalFontManager;
      
      private static var bAllowConstruction:Boolean = false;
      
      private const sPRELOAD_EVENT:String = "PRELOAD_EVENT";
      
      private var oEventManager:EventManager;
      
      private var oPreloadManager:PreloadManager;
      
      private var lLoadingFontConfig:ObjectList;
      
      private var lFontCallback:ObjectList;
      
      private var lFontErrorCallback:ObjectList;
      
      private var sCurrentFontLoadingID:String;
      
      public function ExternalFontManager()
      {
         super();
         if(!bAllowConstruction)
         {
            throw new Error(ErrorMessages.sSINGLETON_ERROR);
         }
         this.init();
      }
      
      public static function get instance() : ExternalFontManager
      {
         if(!oInstance)
         {
            bAllowConstruction = true;
            oInstance = new ExternalFontManager();
            bAllowConstruction = false;
         }
         return oInstance;
      }
      
      public function loadAndRegisterFont(_sFilePath:String, _aFonts:Array, _sCallbackID:String, _fCompleteCallback:Function, _fErrorCallback:Function) : void
      {
         var _oFontLoader:DisplayLoader = new DisplayLoader(_sFilePath);
         this.sCurrentFontLoadingID = _sFilePath;
         this.lLoadingFontConfig.insert(_sCallbackID,_aFonts);
         this.lFontCallback.insert(_sCallbackID,_fCompleteCallback);
         this.lFontErrorCallback.insert(_sCallbackID,_fErrorCallback);
         this.oPreloadManager.addLoader(_sCallbackID,_oFontLoader,0);
         this.oEventManager.addEventListener(this.sPRELOAD_EVENT,this.oPreloadManager,PreloadEvent.COMPLETE,this.onFontLoaded);
         this.oEventManager.addEventListener(this.sPRELOAD_EVENT,this.oPreloadManager,PreloadEvent.ERROR,this.onFontLoadError);
         this.oPreloadManager.start();
      }
      
      public function isFontRegistered(_sFont:String) : Boolean
      {
         var _oFont:Font = null;
         var _bRegistered:Boolean = false;
         _sFont = _sFont.toLowerCase();
         var _aFonts:Array = Font.enumerateFonts(false);
         for each(_oFont in _aFonts)
         {
            if(_oFont.fontName.toLowerCase() == _sFont)
            {
               _bRegistered = true;
               break;
            }
         }
         return _bRegistered;
      }
      
      public function setTextFormat(_oTextField:TextField, _oTextFormat:TextFormat) : void
      {
         _oTextField.setTextFormat(_oTextFormat);
      }
      
      public function destroy() : void
      {
         if(this.oEventManager != null)
         {
            this.oEventManager.clearAll();
            this.oEventManager.destroy();
            this.oEventManager = null;
         }
         this.oPreloadManager = null;
         if(this.lLoadingFontConfig != null)
         {
            this.lLoadingFontConfig.clear();
            this.lLoadingFontConfig.destroy();
            this.lLoadingFontConfig = null;
         }
         if(this.lFontCallback != null)
         {
            this.lFontCallback.clear();
            this.lFontCallback.destroy();
            this.lFontCallback = null;
         }
         if(this.lFontErrorCallback != null)
         {
            this.lFontErrorCallback.clear();
            this.lFontErrorCallback.destroy();
            this.lFontErrorCallback = null;
         }
         oInstance = null;
      }
      
      public function unlinkLocalizationManager(_sCallbackID:String) : void
      {
         if(this.lFontCallback != null)
         {
            this.lFontCallback.remove(_sCallbackID);
         }
         if(this.lFontErrorCallback != null)
         {
            this.lFontErrorCallback.remove(_sCallbackID);
         }
      }
      
      private function init() : void
      {
         this.lLoadingFontConfig = new ObjectList();
         this.lFontCallback = new ObjectList();
         this.lFontErrorCallback = new ObjectList();
         this.oPreloadManager = PreloadManager.instance;
         this.oEventManager = new EventManager();
      }
      
      private function onFontLoaded(_oEvent:PreloadEvent) : void
      {
         var _aFntConfig:Array = null;
         var _oFntClass:Class = null;
         var _fCallback:Function = null;
         var i:int = 0;
         if(_oEvent.fileName == this.sCurrentFontLoadingID)
         {
            _aFntConfig = this.lLoadingFontConfig.find(_oEvent.ID);
            if(_aFntConfig != null)
            {
               for(i = 0; i < _aFntConfig.length; i++)
               {
                  try
                  {
                     _oFntClass = ApplicationDomain.currentDomain.getDefinition(_aFntConfig[i]) as Class;
                     try
                     {
                        Font.registerFont(_oFntClass);
                     }
                     catch(e:Error)
                     {
                        _fCallback = lFontErrorCallback.find(_oEvent.ID);
                        if(_fCallback != null)
                        {
                           _fCallback(_oEvent.error);
                        }
                        return;
                     }
                     Logger.instance.logSBDK("Sucessfully loaded font: " + Object(_oFntClass).toString());
                  }
                  catch(e:Error)
                  {
                     _fCallback = lFontErrorCallback.find(_oEvent.ID);
                     if(_fCallback != null)
                     {
                        _fCallback(_oEvent.error);
                     }
                     return;
                  }
               }
               _fCallback = this.lFontCallback.find(_oEvent.ID);
               if(_fCallback != null)
               {
                  _fCallback();
               }
            }
            this.oEventManager.cleanUp(this.sPRELOAD_EVENT);
         }
      }
      
      private function onFontLoadError(_oEvent:PreloadEvent) : void
      {
         var _fCallback:Function = this.lFontErrorCallback.find(_oEvent.ID);
         if(_fCallback != null)
         {
            _fCallback(_oEvent.error);
         }
      }
   }
}

