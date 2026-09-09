package com.sarbakan.sbdk.asset
{
   import com.sarbakan.sbdk.errors.AssetError;
   import com.sarbakan.sbdk.events.AssetEvent;
   import com.sarbakan.sbdk.events.PreloadEvent;
   import com.sarbakan.sbdk.preload.FileLoader;
   
   internal class FileAssetFactory extends AbstractAssetFactory
   {
      
      private var oFile:Object;
      
      private var bByteMode:Boolean;
      
      public function FileAssetFactory(_sId:String, _sPathOrClass:String, _bCache:Boolean = true, _bByteMode:Boolean = false)
      {
         super(_sId,_sPathOrClass);
         bCache = _bCache;
         this.bByteMode = _bByteMode;
      }
      
      override public function destroy() : void
      {
         super.destroy();
      }
      
      override public function request(_fCompleteCallback:Function, _fErrorCallback:Function) : void
      {
         var oLoader:FileLoader = null;
         var _aRequestList:Array = null;
         if(this.content == null)
         {
            oLoader = new FileLoader(sName,this.bByteMode);
            oPreloadManager.addLoader(sPRELOAD_PREFIX + sId,oLoader);
            eventManager.addEventListener(sPRELOAD_PREFIX + sId,oPreloadManager,PreloadEvent.COMPLETE,this.onLoadComplete);
            eventManager.addEventListener(sPRELOAD_PREFIX + sId,oPreloadManager,PreloadEvent.ERROR,this.onLoadError);
            eventManager.addEventListener(sPRELOAD_PREFIX + sId,oPreloadManager,PreloadEvent.PROGRESS,this.onLoadProgress);
            oPreloadManager.start();
            _aRequestList = aRequestList;
            aRequestList.push({
               "complete":_fCompleteCallback,
               "error":_fErrorCallback
            });
         }
         else
         {
            _fCompleteCallback(new FileAsset(sId,this.oFile));
         }
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
            eventManager.cleanUp(_oEvent.ID);
            _fCallback = aRequestList.pop().complete;
            dispatchEvent(new AssetEvent(AssetEvent.COMPLETE,false,false,sId,0,0));
            if(_fCallback != null)
            {
               _fCallback(new FileAsset(sId,_oEvent.content));
               if(bCache)
               {
                  this.oFile = _oEvent.content;
               }
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
            dispatchEvent(new AssetEvent(AssetEvent.ERROR,false,false,sId,0,0));
            if(_fCallback != null)
            {
               _fCallback(new AssetError(sId,_oEvent.error));
            }
         }
      }
      
      public function get content() : Object
      {
         return this.oFile;
      }
   }
}

