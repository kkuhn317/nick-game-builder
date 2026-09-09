package com.sarbakan.sbdk.preload
{
   import com.sarbakan.sbdk.errors.ErrorMessages;
   import com.sarbakan.sbdk.events.PreloadEvent;
   import com.sarbakan.sbdk.tools.*;
   import com.sarbakan.sbdk.utils.EventManager;
   import flash.events.*;
   
   [Event(name="PROGRESS",type="com.sarbakan.sbdk.events.PreloadEvent")]
   [Event(name="STOP",type="com.sarbakan.sbdk.events.PreloadEvent")]
   [Event(name="START",type="com.sarbakan.sbdk.events.PreloadEvent")]
   [Event(name="ERROR",type="com.sarbakan.sbdk.events.PreloadEvent")]
   [Event(name="ALL_COMPLETE",type="com.sarbakan.sbdk.events.PreloadEvent")]
   [Event(name="COMPLETE",type="com.sarbakan.sbdk.events.PreloadEvent")]
   public class PreloadManager extends EventDispatcher
   {
      
      private static var oInstance:PreloadManager;
      
      private static var bAllowConstruction:Boolean = false;
      
      private var aLoaderList:Array;
      
      private var bLoading:Boolean;
      
      private var oCurrentLoader:IPreloadable;
      
      private var oEventManager:EventManager;
      
      private var nTotalNbrLoaded:int;
      
      private var nTotalNbrToLoad:int;
      
      private var sAppAbsPath:String;
      
      public function PreloadManager()
      {
         super();
         if(!bAllowConstruction)
         {
            throw new Error(ErrorMessages.sSINGLETON_ERROR);
         }
         this.init();
      }
      
      public static function get instance() : PreloadManager
      {
         if(!oInstance)
         {
            bAllowConstruction = true;
            oInstance = new PreloadManager();
            bAllowConstruction = false;
         }
         return oInstance;
      }
      
      public static function get size() : int
      {
         if(oInstance.aLoaderList != null)
         {
            return oInstance.aLoaderList.length;
         }
         return 0;
      }
      
      public function destroy() : void
      {
         this.aLoaderList.splice(0,this.aLoaderList.length);
         this.aLoaderList = null;
         this.oCurrentLoader = null;
         oInstance = null;
         this.oEventManager.destroy();
         this.oEventManager = null;
      }
      
      public function addLoader(_sId:String, _oPreloadRef:IPreloadable, _nPriority:int = -1) : void
      {
         var _bContains:Boolean = this.aLoaderList.indexOf(_oPreloadRef) != -1;
         if(!_bContains)
         {
            _oPreloadRef.ID = _sId;
            this.aLoaderList.push(_oPreloadRef);
            if(_nPriority == -1)
            {
               _oPreloadRef.priority = this.aLoaderList.length;
            }
            this.sortPriority();
            this.nTotalNbrToLoad = this.totalFileToLoad;
         }
      }
      
      public function removeLoader(_sId:String) : void
      {
         var _oLoader:IPreloadable = this.find(_sId);
         if(_oLoader != null)
         {
            if(_oLoader.isLoading)
            {
               _oLoader.stop();
               _oLoader.destroy();
               this.endLoad();
            }
            else
            {
               _oLoader.destroy();
            }
            this.aLoaderList.splice(this.aLoaderList.indexOf(_oLoader),1);
            this.nTotalNbrToLoad = this.totalFileToLoad;
         }
      }
      
      public function removeAllLoaders() : void
      {
         this.pause();
         for(var i:int = 0; i < this.aLoaderList.length; i++)
         {
            if(Boolean(this.aLoaderList[i].isLoading))
            {
               this.aLoaderList[i].stop();
               this.aLoaderList[i].destroy();
               this.endLoad();
            }
            else
            {
               this.aLoaderList[i].destroy();
            }
         }
         this.aLoaderList.splice(0,this.aLoaderList.length);
         this.aLoaderList = null;
         this.nTotalNbrLoaded = 0;
         this.nTotalNbrToLoad = 0;
      }
      
      public function reprioritize(_sId:String, _nNewPriority:int, _bForceRestart:Boolean = false) : Boolean
      {
         var i:int = 0;
         var _oLoader:IPreloadable = this.find(_sId);
         if(_oLoader == null)
         {
            if(this.oCurrentLoader.ID == _sId)
            {
               _oLoader = this.oCurrentLoader;
            }
         }
         if(_oLoader != null)
         {
            for(i = 0; i < this.aLoaderList.length; i++)
            {
               if(this.aLoaderList[i].priority == _nNewPriority)
               {
                  this.aLoaderList[i].priority = _oLoader.priority;
                  break;
               }
            }
            _oLoader.priority = _nNewPriority;
            if(_bForceRestart)
            {
               this.pause();
               this.sortPriority();
               this.start();
            }
            else
            {
               this.sortPriority();
            }
            return true;
         }
         return false;
      }
      
      public function start() : void
      {
         if(!this.bLoading && this.aLoaderList.length > 0)
         {
            if(this.nTotalNbrToLoad <= 0)
            {
               this.nTotalNbrToLoad = this.totalFileToLoad;
            }
            this.oCurrentLoader = this.aLoaderList.shift();
            this.oEventManager.addEventListener(this.oCurrentLoader.ID,this.oCurrentLoader as IEventDispatcher,PreloadEvent.COMPLETE,this.onLoadComplete);
            this.oEventManager.addEventListener(this.oCurrentLoader.ID,this.oCurrentLoader as IEventDispatcher,PreloadEvent.GROUP_COMPLETE,this.onGroupComplete);
            this.oEventManager.addEventListener(this.oCurrentLoader.ID,this.oCurrentLoader as IEventDispatcher,PreloadEvent.ERROR,this.onLoadError);
            this.oEventManager.addEventListener(this.oCurrentLoader.ID,this.oCurrentLoader as IEventDispatcher,PreloadEvent.PROGRESS,this.onLoadProgress);
            this.oEventManager.addEventListener(this.oCurrentLoader.ID,this.oCurrentLoader as IEventDispatcher,PreloadEvent.START,this.onLoadStart);
            this.oEventManager.addEventListener(this.oCurrentLoader.ID,this.oCurrentLoader as IEventDispatcher,PreloadEvent.STOP,this.onLoadStop);
            this.oCurrentLoader.start();
            this.bLoading = true;
         }
      }
      
      public function pause() : void
      {
         if(this.bLoading)
         {
            this.aLoaderList.push(this.oCurrentLoader);
            this.oCurrentLoader.stop();
            this.sortPriority();
            this.oCurrentLoader = null;
            this.bLoading = false;
         }
      }
      
      public function resume() : void
      {
         this.start();
      }
      
      override public function toString() : String
      {
         return "[PreloadManager: Loading = " + this.bLoading + ", Total loaded = " + this.nTotalNbrLoaded + ", Total to load =" + this.nTotalNbrToLoad + "]";
      }
      
      private function sortPriority() : void
      {
         if(this.aLoaderList.length > 0)
         {
            this.aLoaderList.sortOn("priority");
         }
      }
      
      private function find(_sId:String) : IPreloadable
      {
         for(var i:int = 0; i < this.aLoaderList.length; i++)
         {
            if(this.aLoaderList[i].ID == _sId)
            {
               return this.aLoaderList[i];
            }
         }
         return null;
      }
      
      private function init() : void
      {
         this.nTotalNbrLoaded = 0;
         this.nTotalNbrToLoad = 0;
         this.oEventManager = new EventManager();
         this.bLoading = false;
         this.aLoaderList = new Array();
      }
      
      private function endLoad() : void
      {
         if(this.oCurrentLoader.isGroup)
         {
            if(!AbstractGroupLoader(this.oCurrentLoader).isGroupEmpty)
            {
               return;
            }
         }
         this.bLoading = false;
         this.oEventManager.cleanUp(this.oCurrentLoader.ID);
         this.oCurrentLoader.destroy();
         this.oCurrentLoader = null;
         this.start();
      }
      
      private function onLoadComplete(_oEvent:PreloadEvent) : void
      {
         var _bAllComplete:Boolean = false;
         if(!_oEvent.isGroup)
         {
            if(this.aLoaderList.length <= 0)
            {
               this.nTotalNbrLoaded = 0;
               this.nTotalNbrToLoad = 0;
               _bAllComplete = true;
            }
            else
            {
               ++this.nTotalNbrLoaded;
            }
            this.endLoad();
         }
         else
         {
            ++this.nTotalNbrLoaded;
         }
         dispatchEvent(_oEvent);
         if(_bAllComplete)
         {
            dispatchEvent(new PreloadEvent(PreloadEvent.ALL_COMPLETE));
         }
      }
      
      private function onGroupComplete(_oEvent:PreloadEvent) : void
      {
         dispatchEvent(_oEvent);
         if(this.aLoaderList.length <= 0)
         {
            this.nTotalNbrLoaded = 0;
            this.nTotalNbrToLoad = 0;
            dispatchEvent(new PreloadEvent(PreloadEvent.ALL_COMPLETE));
         }
         this.endLoad();
      }
      
      private function onLoadError(_oEvent:PreloadEvent) : void
      {
         this.endLoad();
         dispatchEvent(_oEvent);
         if(this.aLoaderList.length <= 0)
         {
            this.nTotalNbrLoaded = 0;
            this.nTotalNbrToLoad = 0;
            dispatchEvent(new PreloadEvent(PreloadEvent.ALL_COMPLETE));
         }
      }
      
      private function onLoadStart(_oEvent:PreloadEvent) : void
      {
         dispatchEvent(_oEvent);
      }
      
      private function onLoadProgress(_oEvent:PreloadEvent) : void
      {
         var _nPercentage:int = 0;
         if(!_oEvent.isGroup)
         {
            _nPercentage = Math.round(this.nTotalNbrLoaded / this.nTotalNbrToLoad * 100);
         }
         else
         {
            _nPercentage = Math.round((this.nTotalNbrLoaded + Math.floor(_oEvent.percentage / 100)) / this.nTotalNbrToLoad * 100);
         }
         dispatchEvent(new PreloadEvent(PreloadEvent.PROGRESS,false,false,_oEvent.ID,_oEvent.fileName,_oEvent.error,_oEvent.bytesLoaded,_oEvent.bytesTotal,_oEvent.percentage,this.nTotalNbrLoaded,this.nTotalNbrToLoad,_nPercentage,_oEvent.isGroup));
      }
      
      private function onLoadStop(_oEvent:PreloadEvent) : void
      {
         this.oEventManager.cleanUp(this.oCurrentLoader.ID);
         this.oCurrentLoader = null;
         dispatchEvent(_oEvent);
      }
      
      private function get totalFileToLoad() : int
      {
         var _nFileCount:int = 0;
         for(var i:int = 0; i < this.aLoaderList.length; i++)
         {
            if(IPreloadable(this.aLoaderList[i]).isGroup)
            {
               _nFileCount += this.aLoaderList[i].totalFileToLoad;
            }
            else
            {
               _nFileCount++;
            }
         }
         return _nFileCount;
      }
      
      public function get appAbsPath() : String
      {
         return this.sAppAbsPath;
      }
      
      public function set appAbsPath(_sPath:String) : void
      {
         this.sAppAbsPath = _sPath;
      }
      
      public function get isLoading() : Boolean
      {
         return this.bLoading;
      }
   }
}

