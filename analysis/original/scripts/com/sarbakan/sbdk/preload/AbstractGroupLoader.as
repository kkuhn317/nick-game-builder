package com.sarbakan.sbdk.preload
{
   import com.sarbakan.sbdk.events.PreloadEvent;
   import com.sarbakan.sbdk.utils.EventManager;
   import com.sarbakan.sbdk.utils.ObjectList;
   import flash.events.EventDispatcher;
   
   [Event(name="PROGRESS",type="com.sarbakan.sbdk.events.PreloadEvent")]
   [Event(name="STOP",type="com.sarbakan.sbdk.events.PreloadEvent")]
   [Event(name="START",type="com.sarbakan.sbdk.events.PreloadEvent")]
   [Event(name="ERROR",type="com.sarbakan.sbdk.events.PreloadEvent")]
   [Event(name="GROUP_COMPLETE",type="com.sarbakan.sbdk.events.PreloadEvent")]
   [Event(name="COMPLETE",type="com.sarbakan.sbdk.events.PreloadEvent")]
   public class AbstractGroupLoader extends EventDispatcher implements IPreloadable
   {
      
      protected var oEventManager:EventManager;
      
      protected var bLoading:Boolean;
      
      protected var bStopped:Boolean;
      
      protected var aLoadingList:Array;
      
      protected var lLoaderContents:ObjectList;
      
      protected var nTotalNbrLoader:uint;
      
      protected var nTotalNbrLoaded:uint;
      
      private var sId:String;
      
      private var nPriority:int;
      
      private var lLoadingProgress:ObjectList;
      
      private var nTotalPercentage:int;
      
      public function AbstractGroupLoader()
      {
         super();
         this.init();
      }
      
      public function destroy() : void
      {
         if(Boolean(this.lLoaderContents))
         {
            this.lLoaderContents.destroy();
         }
         this.lLoaderContents = null;
         if(Boolean(this.lLoadingProgress))
         {
            this.lLoadingProgress.destroy();
         }
         this.lLoadingProgress = null;
         if(Boolean(this.oEventManager))
         {
            this.oEventManager.destroy();
         }
         this.oEventManager = null;
         this.aLoadingList = null;
         this.bStopped = true;
      }
      
      public function addLoader(_oPreloadRef:IPreloadable) : void
      {
         if(_oPreloadRef.isGroup == false)
         {
            this.aLoadingList.push(_oPreloadRef);
            ++this.nTotalNbrLoader;
         }
      }
      
      public function start() : void
      {
         this.bLoading = true;
         this.bStopped = false;
      }
      
      public function stop() : void
      {
         this.bLoading = false;
         this.bStopped = true;
      }
      
      protected function init() : void
      {
         this.oEventManager = new EventManager();
         this.aLoadingList = new Array();
         this.lLoaderContents = new ObjectList();
         this.lLoadingProgress = new ObjectList();
         this.nTotalNbrLoaded = 0;
         this.nTotalNbrLoader = 0;
         this.nTotalPercentage = 0;
      }
      
      protected function startLoader(_oLoader:IPreloadable) : void
      {
         this.oEventManager.addEventListener(_oLoader.fileName,_oLoader,PreloadEvent.COMPLETE,this.onLoadComplete);
         this.oEventManager.addEventListener(_oLoader.fileName,_oLoader,PreloadEvent.ERROR,this.onLoadError);
         this.oEventManager.addEventListener(_oLoader.fileName,_oLoader,PreloadEvent.PROGRESS,this.onLoadProgress);
         this.oEventManager.addEventListener(_oLoader.fileName,_oLoader,PreloadEvent.START,this.onLoadStart);
         this.oEventManager.addEventListener(_oLoader.fileName,_oLoader,PreloadEvent.STOP,this.onLoadStop);
         _oLoader.start();
         this.lLoadingProgress.insert(_oLoader.fileName,new LoadProgress());
      }
      
      private function calculateTotalPercentage() : void
      {
         var _oProgress:LoadProgress = null;
         var _nCurrentRatio:Number = NaN;
         var _nLoadedRatio:Number = NaN;
         var _nFileRatio:Number = 1 / this.nTotalNbrLoader;
         var _nBytesLoaded:int = 0;
         var _nBytesTotal:int = 0;
         for each(_oProgress in this.lLoadingProgress.object)
         {
            _nBytesLoaded += _oProgress.nBytesLoaded;
            _nBytesTotal += _oProgress.nBytesTotal;
         }
         _nCurrentRatio = _nBytesLoaded / _nBytesTotal * _nFileRatio;
         _nLoadedRatio = this.nTotalNbrLoaded * _nFileRatio;
         this.nTotalPercentage = Math.round(100 * (_nCurrentRatio + _nLoadedRatio));
      }
      
      protected function onLoadComplete(_oEvent:PreloadEvent) : void
      {
         this.oEventManager.cleanUp(_oEvent.fileName);
         this.lLoaderContents.insert(_oEvent.fileName,_oEvent.content);
         this.lLoadingProgress.remove(_oEvent.fileName);
         dispatchEvent(new PreloadEvent(_oEvent.type,false,false,this.ID,_oEvent.fileName,_oEvent.error,0,0,0,0,0,0,_oEvent.content,true));
      }
      
      protected function onLoadError(_oEvent:PreloadEvent) : void
      {
         this.oEventManager.cleanUp(_oEvent.fileName);
         dispatchEvent(_oEvent);
      }
      
      protected function onGroupComplete() : void
      {
         this.nTotalNbrLoader = 0;
         this.nTotalNbrLoaded = 0;
         dispatchEvent(new PreloadEvent(PreloadEvent.GROUP_COMPLETE,false,false,this.ID,"","",0,0,0,0,0,0,this.content,true));
      }
      
      protected function onLoadStart(_oEvent:PreloadEvent) : void
      {
         dispatchEvent(_oEvent);
      }
      
      protected function onLoadStop(_oEvent:PreloadEvent) : void
      {
         this.oEventManager.cleanUp(_oEvent.fileName);
         this.bLoading = false;
         this.nTotalNbrLoader = 0;
         this.nTotalNbrLoaded = 0;
         dispatchEvent(_oEvent);
      }
      
      private function onLoadProgress(_oEvent:PreloadEvent) : void
      {
         var _oProgress:LoadProgress = this.lLoadingProgress.find(_oEvent.fileName);
         _oProgress.nBytesLoaded = _oEvent.bytesLoaded;
         _oProgress.nBytesTotal = _oEvent.bytesTotal;
         this.calculateTotalPercentage();
         dispatchEvent(new PreloadEvent(_oEvent.type,_oEvent.bubbles,_oEvent.cancelable,_oEvent.ID,_oEvent.fileName,_oEvent.error,_oEvent.bytesLoaded,_oEvent.bytesTotal,this.nTotalPercentage,this.nTotalNbrLoaded,this.nTotalNbrLoader,this.nTotalPercentage,null,true));
      }
      
      public function get fileName() : String
      {
         return this.sId;
      }
      
      public function get ID() : String
      {
         return this.sId;
      }
      
      public function set ID(_sId:String) : void
      {
         this.sId = _sId;
      }
      
      public function get priority() : int
      {
         return this.nPriority;
      }
      
      public function set priority(_nValue:int) : void
      {
         this.nPriority = _nValue;
      }
      
      public function get isLoading() : Boolean
      {
         return this.bLoading;
      }
      
      public function get isGroupEmpty() : Boolean
      {
         return Boolean(this.totalFileToLoad == 0);
      }
      
      public function get isGroup() : Boolean
      {
         return true;
      }
      
      public function get content() : Array
      {
         var i:String = null;
         var _aReturn:Array = new Array();
         for(i in this.lLoaderContents.object)
         {
            _aReturn.push(this.lLoaderContents.find(i));
         }
         return _aReturn;
      }
      
      public function get totalFileToLoad() : int
      {
         return this.nTotalNbrLoader - this.nTotalNbrLoaded;
      }
      
      public function get loadingProgress() : int
      {
         return this.nTotalPercentage;
      }
   }
}

class LoadProgress
{
   
   public var nBytesLoaded:int = 0;
   
   public var nBytesTotal:int = 0;
   
   public function LoadProgress()
   {
      super();
   }
}
