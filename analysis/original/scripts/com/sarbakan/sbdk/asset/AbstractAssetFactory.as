package com.sarbakan.sbdk.asset
{
   import com.sarbakan.sbdk.preload.PreloadManager;
   import com.sarbakan.sbdk.utils.EventManager;
   import flash.events.EventDispatcher;
   
   internal class AbstractAssetFactory extends EventDispatcher
   {
      
      protected static const sPRELOAD_PREFIX:String = "asset_";
      
      protected var oPreloadManager:PreloadManager;
      
      protected var sId:String;
      
      protected var sName:String;
      
      protected var aRequestList:Array;
      
      protected var bCache:Boolean;
      
      private var oEventManager:EventManager;
      
      private var oPublicEventManager:EventManager;
      
      public function AbstractAssetFactory(_sId:String, _sPathOrClass:String)
      {
         super();
         this.sId = _sId;
         this.sName = _sPathOrClass;
         this.init();
      }
      
      public function destroy() : void
      {
         if(this.oPublicEventManager != null)
         {
            this.oPublicEventManager.clearAll();
            this.oPublicEventManager.destroy();
            this.oPublicEventManager = null;
         }
         this.oEventManager.clearAll();
         this.oEventManager = null;
         this.oPreloadManager = null;
         for(var i:uint = 0; i < this.aRequestList.length; i++)
         {
            this.aRequestList[i].destroy();
         }
         this.aRequestList.splice(0,this.aRequestList.length);
         this.aRequestList = null;
      }
      
      public function request(_fCompleteCallback:Function, _fErrorCallback:Function) : void
      {
      }
      
      override public function toString() : String
      {
         return "[AbstractAssetFactory: " + this.sId + " " + this.sName + "]";
      }
      
      protected function init() : void
      {
         this.aRequestList = new Array();
         this.oEventManager = new EventManager();
         this.oPreloadManager = PreloadManager.instance;
      }
      
      public function get eventManager() : EventManager
      {
         if(this.oPublicEventManager == null)
         {
            this.oPublicEventManager = new EventManager();
         }
         return this.oPublicEventManager;
      }
   }
}

