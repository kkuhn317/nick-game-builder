package com.sarbakan.sbdk.asset
{
   import com.sarbakan.sbdk.errors.AssetError;
   import com.sarbakan.sbdk.errors.ErrorMessages;
   import com.sarbakan.sbdk.events.AssetEvent;
   import com.sarbakan.sbdk.events.PreloadEvent;
   import com.sarbakan.sbdk.preload.FileLoader;
   import com.sarbakan.sbdk.preload.PreloadManager;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.events.*;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.utils.ByteArray;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedSuperclassName;
   
   internal class DisplayAssetFactory extends AbstractAssetFactory
   {
      
      private static const sBITMAPDATA:String = "flash.display::BitmapData";
      
      private static const sMOVIECLIP:String = "flash.display::MovieClip";
      
      private static const sSPRITE:String = "flash.display::Sprite";
      
      private static const sLOADER_EVENT:String = "LOADER_EVENT";
      
      private static const sBYTE_LOADER_EVENT:String = "BYTE_LOADER_EVENT";
      
      private var oAppDomain:ApplicationDomain;
      
      private var oLocation:AssetLocation;
      
      private var oAsset:ByteArray;
      
      private var mcCached:DisplayObject;
      
      private var oLoader:Loader;
      
      private var oCopyLoader:Loader;
      
      private var oLoaderContext:LoaderContext;
      
      public function DisplayAssetFactory(_sId:String, _sPathOrClass:String, _oLocation:AssetLocation, _bCache:Boolean = false, _oAppDomain:ApplicationDomain = null)
      {
         super(_sId,_sPathOrClass);
         this.oLocation = _oLocation;
         bCache = _bCache;
         this.oAppDomain = _oAppDomain;
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.oAppDomain = null;
         this.oAsset = null;
         this.mcCached = null;
         this.oLoader = null;
         this.oCopyLoader = null;
      }
      
      override public function request(_fCompleteCallback:Function, _fErrorCallback:Function) : void
      {
         var _oLoader:FileLoader = null;
         var _oAssetClass:Class = null;
         var _sError:String = null;
         var _oAsset:* = undefined;
         var _sClassName:String = null;
         var bitmap:Bitmap = null;
         if(bCache && this.oAsset.length > 0)
         {
            _fCompleteCallback(new DisplayAsset(sId,this.mcCached));
            this.mcCached = null;
            dispatchEvent(new AssetEvent(AssetEvent.COMPLETE,false,false,sId,0,0));
            this.createCachedCopy();
         }
         else if(this.oLocation == AssetLocation.EXTERNAL)
         {
            _oLoader = new FileLoader(sName,true);
            oPreloadManager.addLoader(sPRELOAD_PREFIX + sId,_oLoader);
            eventManager.addEventListener(sPRELOAD_PREFIX + sId,oPreloadManager,PreloadEvent.COMPLETE,this.onLoadComplete);
            eventManager.addEventListener(sPRELOAD_PREFIX + sId,oPreloadManager,PreloadEvent.ERROR,this.onLoadError);
            eventManager.addEventListener(sPRELOAD_PREFIX + sId,oPreloadManager,PreloadEvent.PROGRESS,this.onLoadProgress);
            aRequestList.push({
               "complete":_fCompleteCallback,
               "error":_fErrorCallback
            });
            PreloadManager.instance.start();
         }
         else if(this.oLocation == AssetLocation.INTERNAL)
         {
            _sError = null;
            if(this.oAppDomain != null)
            {
               try
               {
                  _oAssetClass = this.oAppDomain.getDefinition(sName) as Class;
               }
               catch(e:Error)
               {
                  _sError = e.toString();
               }
            }
            else
            {
               try
               {
                  _oAssetClass = getDefinitionByName(sName) as Class;
               }
               catch(e:Error)
               {
                  _sError = e.toString();
               }
            }
            if(_sError == null)
            {
               try
               {
                  _sClassName = getQualifiedSuperclassName(_oAssetClass);
                  if(_sClassName == sBITMAPDATA)
                  {
                     bitmap = new Bitmap(new _oAssetClass(0,0));
                     _oAsset = bitmap as DisplayObject;
                  }
                  else if(_sClassName == sMOVIECLIP || _sClassName == sSPRITE)
                  {
                     _oAsset = new _oAssetClass();
                  }
               }
               catch(e:Error)
               {
                  _sError = e.toString();
               }
            }
            if(_fErrorCallback != null && _sError != null)
            {
               _fErrorCallback(new AssetError(sId,_sError));
            }
            else if(_oAsset != null)
            {
               _fCompleteCallback(new DisplayAsset(sId,_oAsset));
               dispatchEvent(new AssetEvent(AssetEvent.COMPLETE,false,false,sId,0,0));
            }
            else if(_fErrorCallback != null || _oAssetClass == null)
            {
               _fErrorCallback(new AssetError(sId,ErrorMessages.sASSET_DOESNT_EXIST));
               dispatchEvent(new AssetEvent(AssetEvent.ERROR,false,false,sId,0,0));
            }
         }
      }
      
      override protected function init() : void
      {
         super.init();
         this.oAsset = new ByteArray();
         if(this.oAppDomain != null)
         {
            this.oLoaderContext = new LoaderContext(false,this.oAppDomain);
         }
      }
      
      private function createLoader() : void
      {
         this.oLoader = new Loader();
         eventManager.addEventListener(sLOADER_EVENT,this.oLoader.contentLoaderInfo,Event.COMPLETE,this.onLoadByteComplete);
         eventManager.addEventListener(sLOADER_EVENT,this.oLoader.contentLoaderInfo,IOErrorEvent.IO_ERROR,this.onLoadByteError);
      }
      
      private function copyByte(_oByteArray:ByteArray) : void
      {
         this.oAsset.writeBytes(_oByteArray,0,_oByteArray.length);
      }
      
      private function createCachedCopy() : void
      {
         this.oCopyLoader = new Loader();
         eventManager.addEventListener(sBYTE_LOADER_EVENT,this.oCopyLoader.contentLoaderInfo,Event.COMPLETE,this.onCopyComplete);
         this.oCopyLoader.loadBytes(this.oAsset,this.oLoaderContext);
      }
      
      private function onLoadProgress(_oEvent:PreloadEvent) : void
      {
         dispatchEvent(new AssetEvent(AssetEvent.PROGRESS,false,false,sId,_oEvent.bytesLoaded,_oEvent.bytesTotal));
      }
      
      private function onLoadComplete(_oEvent:PreloadEvent) : void
      {
         if(_oEvent.ID == sPRELOAD_PREFIX + sId)
         {
            if(aRequestList.length == 1)
            {
               eventManager.cleanUp(_oEvent.ID);
            }
            this.oLoader = new Loader();
            eventManager.addEventListener(sLOADER_EVENT,this.oLoader.contentLoaderInfo,Event.COMPLETE,this.onLoadByteComplete);
            eventManager.addEventListener(sLOADER_EVENT,this.oLoader.contentLoaderInfo,IOErrorEvent.IO_ERROR,this.onLoadByteError);
            this.oLoader.loadBytes(_oEvent.content,this.oLoaderContext);
            if(bCache)
            {
               this.copyByte(_oEvent.content);
               this.createCachedCopy();
            }
         }
      }
      
      private function onLoadByteError(_oEvent:IOErrorEvent) : void
      {
         var _fCallback:Function = aRequestList.pop().error;
         eventManager.cleanUp(sLOADER_EVENT);
         if(_fCallback != null)
         {
            _fCallback(new AssetError(sId,_oEvent.text));
         }
         this.oLoader = null;
      }
      
      private function onLoadByteComplete(_oEvent:Event) : void
      {
         var _fCallback:Function = aRequestList.pop().complete;
         eventManager.cleanUp(sLOADER_EVENT);
         if(_fCallback != null)
         {
            _fCallback(new DisplayAsset(sId,this.oLoader.content));
         }
         this.oLoader = null;
         dispatchEvent(new AssetEvent(AssetEvent.COMPLETE,false,false,sId,0,0));
      }
      
      private function onCopyComplete(_oEvent:Event) : void
      {
         eventManager.cleanUp(sBYTE_LOADER_EVENT);
         this.mcCached = this.oCopyLoader.content;
         this.oCopyLoader = null;
      }
      
      private function onLoadError(_oEvent:PreloadEvent) : void
      {
         var _fCallback:Function = null;
         if(_oEvent.ID == sPRELOAD_PREFIX + sId)
         {
            _fCallback = aRequestList.pop().error;
            eventManager.cleanUp(_oEvent.ID);
            if(_fCallback != null)
            {
               _fCallback(new AssetError(sId,_oEvent.error));
            }
            dispatchEvent(new AssetEvent(AssetEvent.ERROR,false,false,sId,0,0));
         }
      }
   }
}

