package com.sarbakan.sbdk.preload
{
   import com.sarbakan.sbdk.events.PreloadEvent;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLVariables;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   
   [Event(name="PROGRESS",type="com.sarbakan.sbdk.events.PreloadEvent")]
   [Event(name="STOP",type="com.sarbakan.sbdk.events.PreloadEvent")]
   [Event(name="START",type="com.sarbakan.sbdk.events.PreloadEvent")]
   [Event(name="ERROR",type="com.sarbakan.sbdk.events.PreloadEvent")]
   [Event(name="COMPLETE",type="com.sarbakan.sbdk.events.PreloadEvent")]
   public class DisplayLoader extends AbstractLoader implements IPreloadable
   {
      
      private var oLoader:Loader;
      
      private var oAppDomain:ApplicationDomain;
      
      private var oLoaderContext:LoaderContext;
      
      public function DisplayLoader(_sFileName:String, _oAppDomain:ApplicationDomain = null, _sMethod:String = null, _oData:URLVariables = null, _sContentType:String = null, _aRequestHeaders:Array = null)
      {
         super(_sFileName,_sMethod,_oData,_sContentType,_aRequestHeaders);
         this.oAppDomain = _oAppDomain;
         this.init();
      }
      
      override protected function init() : void
      {
         if(this.oAppDomain != null)
         {
            this.oLoaderContext = new LoaderContext();
            this.oLoaderContext.applicationDomain = this.oAppDomain;
         }
         else
         {
            this.oLoaderContext = new LoaderContext();
            this.oLoaderContext.applicationDomain = ApplicationDomain.currentDomain;
         }
         this.oLoader = new Loader();
         eventManager.addEventListener(fileName,this.oLoader.contentLoaderInfo,Event.INIT,this.onLoadComplete);
         eventManager.addEventListener(fileName,this.oLoader.contentLoaderInfo,IOErrorEvent.IO_ERROR,this.onLoadError);
         eventManager.addEventListener(fileName,this.oLoader.contentLoaderInfo,Event.OPEN,this.onLoadOpen);
         eventManager.addEventListener(fileName,this.oLoader.contentLoaderInfo,ProgressEvent.PROGRESS,this.onLoadProgress);
      }
      
      override public function destroy() : void
      {
         eventManager.cleanUp(fileName);
         super.destroy();
         this.oLoader = null;
         this.oLoaderContext = null;
         this.oAppDomain = null;
      }
      
      override public function start() : void
      {
         if(!bLoading)
         {
            this.oLoader.load(oRequest,this.oLoaderContext);
            bLoading = true;
         }
      }
      
      override public function stop() : void
      {
         if(bLoading)
         {
            this.oLoader.close();
            this.oLoader.unload();
            eventManager.cleanUp(fileName);
            bLoading = false;
            dispatchEvent(new PreloadEvent(PreloadEvent.STOP,false,false,ID,fileName));
         }
      }
      
      private function onLoadComplete(_oEvent:Event) : void
      {
         eventManager.cleanUp(fileName);
         dispatchEvent(new PreloadEvent(PreloadEvent.COMPLETE,false,false,ID,fileName,"",0,0,0,0,0,0,this.content));
      }
      
      private function onLoadError(_oEvent:IOErrorEvent) : void
      {
         eventManager.cleanUp(fileName);
         dispatchEvent(new PreloadEvent(PreloadEvent.ERROR,false,false,ID,fileName,_oEvent.text));
      }
      
      private function onSecurityError(_oEvent:SecurityErrorEvent) : void
      {
         eventManager.cleanUp(fileName);
         dispatchEvent(new PreloadEvent(PreloadEvent.ERROR,false,false,ID,fileName,_oEvent.text));
      }
      
      private function onLoadOpen(_oEvent:Event) : void
      {
         dispatchEvent(new PreloadEvent(PreloadEvent.START,false,false,ID,fileName));
      }
      
      private function onLoadProgress(_oEvent:ProgressEvent) : void
      {
         nProgress = Math.round(_oEvent.bytesLoaded / _oEvent.bytesTotal * 100);
         dispatchEvent(new PreloadEvent(PreloadEvent.PROGRESS,false,false,ID,fileName,"",_oEvent.bytesLoaded,_oEvent.bytesTotal,nProgress));
      }
      
      public function get content() : DisplayObject
      {
         return this.oLoader.content;
      }
      
      override public function get priority() : int
      {
         return super.priority;
      }
      
      override public function set priority(_nValue:int) : void
      {
         super.priority = _nValue;
      }
   }
}

