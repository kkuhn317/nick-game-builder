package com.sarbakan.sbdk.asset
{
   import com.sarbakan.sbdk.errors.AssetError;
   import com.sarbakan.sbdk.errors.ErrorMessages;
   import com.sarbakan.sbdk.events.AssetEvent;
   import com.sarbakan.sbdk.preload.PreloadManager;
   import com.sarbakan.sbdk.tools.*;
   import com.sarbakan.sbdk.utils.EventManager;
   import com.sarbakan.sbdk.utils.ObjectList;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.events.EventDispatcher;
   import flash.media.Sound;
   import flash.system.ApplicationDomain;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   import flash.utils.getQualifiedSuperclassName;
   
   public class AssetManager extends EventDispatcher
   {
      
      private static var oInstance:AssetManager;
      
      private static const sBITMAPDATA:String = "flash.display::BitmapData";
      
      private static const sMOVIECLIP:String = "flash.display::MovieClip";
      
      private static const sSPRITE:String = "flash.display::Sprite";
      
      private static const sSOUND:String = "flash.media::Sound";
      
      private static const sPRELOAD_PREFIX:String = "asset_";
      
      private static var bAllowConstruction:Boolean = false;
      
      private var lAssetFactoryList:ObjectList;
      
      private var oEventManager:EventManager;
      
      public function AssetManager()
      {
         super();
         if(!bAllowConstruction)
         {
            throw new Error(ErrorMessages.sSINGLETON_ERROR);
         }
         this.init();
      }
      
      public static function get instance() : AssetManager
      {
         if(!oInstance)
         {
            bAllowConstruction = true;
            oInstance = new AssetManager();
            bAllowConstruction = false;
         }
         return oInstance;
      }
      
      public function destroy() : void
      {
         var i:* = undefined;
         for each(i in this.lAssetFactoryList.object)
         {
            i.destroy();
         }
         this.lAssetFactoryList.clear();
         this.lAssetFactoryList.destroy();
         this.lAssetFactoryList = null;
         this.oEventManager.clearAll();
         this.oEventManager.destroy();
         this.oEventManager = null;
         oInstance = null;
      }
      
      public function reprioritizeAssetLoading(_sAssetID:String, _nPriority:int, _bForceRestart:Boolean = false) : Boolean
      {
         return PreloadManager.instance.reprioritize(sPRELOAD_PREFIX + _sAssetID,_nPriority,_bForceRestart);
      }
      
      public function addFileAsset(_sId:String, _sPath:String, _bCache:Boolean = false, _bPreload:Boolean = false, _bByteMode:Boolean = false) : void
      {
         if(this.lAssetFactoryList.find(_sId) == null)
         {
            if(_bPreload)
            {
               this.lAssetFactoryList.insert(_sId,new FileAssetFactory(_sId,_sPath,true,_bByteMode));
               this.requestAsset(AssetReference.fromAssetManager(_sId),null);
            }
            else
            {
               this.lAssetFactoryList.insert(_sId,new FileAssetFactory(_sId,_sPath,_bCache,_bByteMode));
            }
         }
      }
      
      public function addDisplayAsset(_sId:String, _sPathOrClass:String, _oLocation:AssetLocation, _bCache:Boolean = false, _bPreload:Boolean = false, _oAppDomain:ApplicationDomain = null) : void
      {
         if(this.lAssetFactoryList.find(_sId) == null)
         {
            if(_bPreload)
            {
               this.lAssetFactoryList.insert(_sId,new DisplayAssetFactory(_sId,_sPathOrClass,_oLocation,true,_oAppDomain));
               this.requestAsset(AssetReference.fromAssetManager(_sId),null);
            }
            else
            {
               this.lAssetFactoryList.insert(_sId,new DisplayAssetFactory(_sId,_sPathOrClass,_oLocation,_bCache,_oAppDomain));
            }
         }
      }
      
      public function addSoundAsset(_sId:String, _sPathOrClass:String, _oLocation:AssetLocation, _bCache:Boolean = false, _nBufferTime:int = -1, _bPreload:Boolean = false) : void
      {
         if(this.lAssetFactoryList.find(_sId) == null)
         {
            if(_bPreload)
            {
               this.lAssetFactoryList.insert(_sId,new SoundAssetFactory(_sId,_sPathOrClass,_oLocation,true,_nBufferTime));
               this.requestAsset(AssetReference.fromAssetManager(_sId),null);
            }
            else
            {
               this.lAssetFactoryList.insert(_sId,new SoundAssetFactory(_sId,_sPathOrClass,_oLocation,_bCache,_nBufferTime));
            }
         }
      }
      
      public function removeAsset(_sId:String) : void
      {
         if(this.lAssetFactoryList.find(_sId) != null)
         {
            this.lAssetFactoryList.remove(_sId);
         }
      }
      
      public function assetExists(_sId:String) : Boolean
      {
         return this.lAssetFactoryList.find(_sId) != null;
      }
      
      public function requestAsset(_oLocation:AssetReference, _fCompleteCallback:Function, _fErrorCallback:Function = null) : void
      {
         var _oAssetFactory:AbstractAssetFactory = null;
         var _oClass:* = undefined;
         switch(_oLocation.location)
         {
            case AssetReference.sASSET_MANAGER:
               _oAssetFactory = this.lAssetFactoryList.find(_oLocation.assetID);
               if(_oAssetFactory != null)
               {
                  this.oEventManager.addEventListener(_oLocation.assetID,_oAssetFactory,AssetEvent.COMPLETE,this.onLoadComplete);
                  this.oEventManager.addEventListener(_oLocation.assetID,_oAssetFactory,AssetEvent.ERROR,this.onLoadError);
                  this.oEventManager.addEventListener(_oLocation.assetID,_oAssetFactory,AssetEvent.PROGRESS,this.onLoadProgress);
                  _oAssetFactory.request(_fCompleteCallback,_fErrorCallback);
               }
               break;
            case AssetReference.sLIBRARY_CLASS:
               switch(getQualifiedSuperclassName(_oLocation.classRef))
               {
                  case sSOUND:
                     this.requestDirectSoundAsset(_oLocation.classRef,_fCompleteCallback,_fErrorCallback);
                     break;
                  case sBITMAPDATA:
                  case sMOVIECLIP:
                  case sSPRITE:
                     this.requestDirectDisplayAsset(_oLocation.classRef,_fCompleteCallback,_fErrorCallback);
               }
               break;
            case AssetReference.sLIBRARY_STRING:
               try
               {
                  _oClass = getDefinitionByName(_oLocation.linkID) as Class;
               }
               catch(e:Error)
               {
                  if(_fErrorCallback != null)
                  {
                     _fErrorCallback(new AssetError(getQualifiedClassName(_oClass),e.toString()));
                  }
               }
               if(_oClass != null)
               {
                  switch(getQualifiedSuperclassName(_oClass))
                  {
                     case sSOUND:
                        this.requestDirectSoundAsset(_oClass,_fCompleteCallback,_fErrorCallback);
                        break;
                     case sBITMAPDATA:
                     case sMOVIECLIP:
                     case sSPRITE:
                        this.requestDirectDisplayAsset(_oClass,_fCompleteCallback,_fErrorCallback);
                  }
               }
         }
      }
      
      private function requestDirectSoundAsset(_oClassRef:Class, _fCompleteCallback:Function = null, _fErrorCallback:Function = null) : void
      {
         var _oSoundRef:Sound = null;
         var _sError:String = null;
         try
         {
            _oSoundRef = new _oClassRef();
         }
         catch(e:Error)
         {
            _sError = e.toString();
         }
         if(_fErrorCallback != null && _sError != null)
         {
            _fErrorCallback(new AssetError(getQualifiedClassName(_oClassRef),_sError));
         }
         else if(_oSoundRef != null)
         {
            _fCompleteCallback(new SoundAsset(getQualifiedClassName(_oClassRef),_oSoundRef));
         }
      }
      
      private function requestDirectDisplayAsset(_oClassRef:Class, _fCompleteCallback:Function = null, _fErrorCallback:Function = null) : void
      {
         var _oAsset:* = undefined;
         var _sClassName:String = null;
         var bitmap:Bitmap = null;
         var _sError:String = null;
         if(_sError == null)
         {
            try
            {
               _sClassName = getQualifiedSuperclassName(_oClassRef);
               if(_sClassName == sBITMAPDATA)
               {
                  bitmap = new Bitmap(new _oClassRef(0,0));
                  _oAsset = bitmap as DisplayObject;
               }
               else if(_sClassName == sMOVIECLIP || _sClassName == sSPRITE)
               {
                  _oAsset = new _oClassRef();
               }
            }
            catch(e:Error)
            {
               _sError = e.toString();
            }
         }
         if(_fErrorCallback != null && _sError != null)
         {
            _fErrorCallback(new AssetError(getQualifiedClassName(_oClassRef),_sError));
         }
         else if(_oAsset != null)
         {
            if(_sClassName == sBITMAPDATA)
            {
               _fCompleteCallback(new DisplayAsset(getQualifiedClassName(_oClassRef),_oAsset));
            }
            else if(_sClassName == sMOVIECLIP || _sClassName == sSPRITE)
            {
               _fCompleteCallback(new DisplayAsset(getQualifiedClassName(_oClassRef),_oAsset));
            }
         }
      }
      
      private function init() : void
      {
         this.lAssetFactoryList = new ObjectList();
         this.oEventManager = new EventManager();
      }
      
      private function onLoadProgress(_oEvent:AssetEvent) : void
      {
         dispatchEvent(_oEvent);
      }
      
      private function onLoadComplete(_oEvent:AssetEvent) : void
      {
         this.oEventManager.cleanUp(_oEvent.assetID);
      }
      
      private function onLoadError(_oEvent:AssetEvent) : void
      {
         this.oEventManager.cleanUp(_oEvent.assetID);
      }
   }
}

