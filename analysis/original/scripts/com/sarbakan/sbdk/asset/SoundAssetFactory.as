package com.sarbakan.sbdk.asset
{
   import com.sarbakan.sbdk.errors.AssetError;
   import com.sarbakan.sbdk.events.AssetEvent;
   import com.sarbakan.sbdk.events.PreloadEvent;
   import com.sarbakan.sbdk.preload.SoundLoader;
   import flash.media.Sound;
   import flash.media.SoundLoaderContext;
   import flash.utils.getDefinitionByName;
   
   internal class SoundAssetFactory extends AbstractAssetFactory
   {
      
      private var sndRef:Sound;
      
      private var oLoaderContext:SoundLoaderContext;
      
      private var oLocation:AssetLocation;
      
      public function SoundAssetFactory(_sId:String, _sPathOrClass:String, _oLocation:AssetLocation, _bCache:Boolean = true, _nBufferTime:int = -1)
      {
         super(_sId,_sPathOrClass);
         this.oLocation = _oLocation;
         _bCache = _bCache;
         if(_nBufferTime != -1)
         {
            this.oLoaderContext = new SoundLoaderContext(_nBufferTime);
         }
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.sndRef = null;
         this.oLoaderContext = null;
         this.oLocation = null;
      }
      
      override public function request(_fCompleteCallback:Function, _fErrorCallback:Function) : void
      {
         var _oLoader:SoundLoader = null;
         var _sError:String = null;
         var _oAssetClass:Class = null;
         var _oSoundRef:Sound = null;
         if(this.content == null)
         {
            if(this.oLocation == AssetLocation.EXTERNAL)
            {
               _oLoader = new SoundLoader(sName,this.oLoaderContext);
               oPreloadManager.addLoader(sPRELOAD_PREFIX + sId,_oLoader);
               eventManager.addEventListener(sPRELOAD_PREFIX + sId,oPreloadManager,PreloadEvent.COMPLETE,this.onLoadComplete);
               eventManager.addEventListener(sPRELOAD_PREFIX + sId,oPreloadManager,PreloadEvent.ERROR,this.onLoadError);
               eventManager.addEventListener(sPRELOAD_PREFIX + sId,oPreloadManager,PreloadEvent.PROGRESS,this.onLoadProgress);
               aRequestList.push({
                  "complete":_fCompleteCallback,
                  "error":_fErrorCallback
               });
               oPreloadManager.start();
            }
            else if(this.oLocation == AssetLocation.INTERNAL)
            {
               _sError = null;
               try
               {
                  _oAssetClass = getDefinitionByName(sName) as Class;
                  _oSoundRef = new _oAssetClass();
                  if(bCache)
                  {
                     this.sndRef = _oSoundRef;
                  }
               }
               catch(e:Error)
               {
                  _sError = e.toString();
               }
               if(_fErrorCallback != null && _sError != null)
               {
                  _fErrorCallback(new AssetError(sId,_sError));
                  dispatchEvent(new AssetEvent(AssetEvent.ERROR,false,false,sId,0,0));
               }
               else if(_oSoundRef != null)
               {
                  _fCompleteCallback(new SoundAsset(sId,_oSoundRef));
                  dispatchEvent(new AssetEvent(AssetEvent.COMPLETE,false,false,sId,0,0));
               }
            }
         }
         else
         {
            _fCompleteCallback(new SoundAsset(sId,this.sndRef));
         }
      }
      
      override protected function init() : void
      {
         super.init();
      }
      
      private function onLoadProgress(_oEvent:PreloadEvent) : void
      {
         dispatchEvent(new AssetEvent(AssetEvent.PROGRESS,false,false,sId,_oEvent.bytesLoaded,_oEvent.bytesTotal));
      }
      
      private function onLoadComplete(_oEvent:PreloadEvent) : void
      {
         var _fCallback:Function = null;
         if(_oEvent.ID == sPRELOAD_PREFIX + sId)
         {
            if(bCache)
            {
               this.sndRef = _oEvent.content;
            }
            eventManager.cleanUp(_oEvent.ID);
            _fCallback = aRequestList.pop().complete;
            if(_fCallback != null)
            {
               _fCallback(new SoundAsset(sId,_oEvent.content));
            }
         }
      }
      
      private function onLoadError(_oEvent:PreloadEvent) : void
      {
         var _fCallback:Function = null;
         if(_oEvent.ID == sPRELOAD_PREFIX + sId)
         {
            eventManager.cleanUp(_oEvent.ID);
            _fCallback = aRequestList.pop().error;
            if(_fCallback != null)
            {
               _fCallback(new AssetError(sId,_oEvent.error));
            }
         }
      }
      
      public function get content() : Sound
      {
         return this.sndRef;
      }
   }
}

