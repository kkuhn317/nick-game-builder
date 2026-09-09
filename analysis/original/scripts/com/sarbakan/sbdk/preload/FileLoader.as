package com.sarbakan.sbdk.preload
{
   import com.sarbakan.sbdk.events.PreloadEvent;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLVariables;
   
   [Event(name="PROGRESS",type="com.sarbakan.sbdk.events.PreloadEvent")]
   [Event(name="STOP",type="com.sarbakan.sbdk.events.PreloadEvent")]
   [Event(name="START",type="com.sarbakan.sbdk.events.PreloadEvent")]
   [Event(name="ERROR",type="com.sarbakan.sbdk.events.PreloadEvent")]
   [Event(name="COMPLETE",type="com.sarbakan.sbdk.events.PreloadEvent")]
   public class FileLoader extends AbstractLoader implements IPreloadable
   {
      
      private var oLoader:URLLoader;
      
      private var bLoadByte:Boolean;
      
      public function FileLoader(_sFileName:String, _bLoadByte:Boolean = false, _sMethod:String = null, _oData:URLVariables = null, _sContentType:String = null, _aRequestHeaders:Array = null)
      {
         this.bLoadByte = _bLoadByte;
         super(_sFileName,_sMethod,_oData,_sContentType,_aRequestHeaders);
         this.init();
      }
      
      override protected function init() : void
      {
         this.oLoader = new URLLoader();
         if(this.bLoadByte)
         {
            this.oLoader.dataFormat = URLLoaderDataFormat.BINARY;
         }
         eventManager.addEventListener(sFileName,this.oLoader,Event.COMPLETE,this.onLoadComplete);
         eventManager.addEventListener(sFileName,this.oLoader,IOErrorEvent.IO_ERROR,this.onLoadError);
         eventManager.addEventListener(sFileName,this.oLoader,ProgressEvent.PROGRESS,this.onLoadProgress);
      }
      
      override public function destroy() : void
      {
         this.oLoader = null;
         eventManager.cleanUp(sFileName);
      }
      
      override public function start() : void
      {
         if(!bLoading)
         {
            this.oLoader.load(oRequest);
            dispatchEvent(new PreloadEvent(PreloadEvent.START,false,false,ID,fileName));
            bLoading = true;
         }
      }
      
      override public function stop() : void
      {
         if(bLoading)
         {
            this.oLoader.close();
            bLoading = false;
         }
      }
      
      private function onLoadComplete(_oEvent:Event) : void
      {
         dispatchEvent(new PreloadEvent(PreloadEvent.COMPLETE,false,false,ID,fileName,"",0,0,0,0,0,0,this.content));
         eventManager.cleanUp(sFileName);
      }
      
      private function onLoadError(_oEvent:IOErrorEvent) : void
      {
         dispatchEvent(new PreloadEvent(PreloadEvent.ERROR,false,false,ID,fileName,_oEvent.text));
         eventManager.cleanUp(sFileName);
      }
      
      private function onLoadProgress(_oEvent:ProgressEvent) : void
      {
         nProgress = Math.round(_oEvent.bytesLoaded / _oEvent.bytesTotal * 100);
         dispatchEvent(new PreloadEvent(PreloadEvent.PROGRESS,false,false,ID,fileName,"",_oEvent.bytesLoaded,_oEvent.bytesTotal,nProgress));
      }
      
      public function get content() : *
      {
         return this.oLoader.data;
      }
   }
}

