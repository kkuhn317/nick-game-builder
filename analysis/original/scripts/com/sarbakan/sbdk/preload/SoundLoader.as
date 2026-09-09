package com.sarbakan.sbdk.preload
{
   import com.sarbakan.sbdk.events.PreloadEvent;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.TimerEvent;
   import flash.media.Sound;
   import flash.media.SoundLoaderContext;
   import flash.net.URLLoader;
   import flash.net.URLVariables;
   import flash.utils.Timer;
   
   [Event(name="PROGRESS",type="com.sarbakan.sbdk.events.PreloadEvent")]
   [Event(name="STOP",type="com.sarbakan.sbdk.events.PreloadEvent")]
   [Event(name="START",type="com.sarbakan.sbdk.events.PreloadEvent")]
   [Event(name="ERROR",type="com.sarbakan.sbdk.events.PreloadEvent")]
   [Event(name="COMPLETE",type="com.sarbakan.sbdk.events.PreloadEvent")]
   public class SoundLoader extends AbstractLoader implements IPreloadable
   {
      
      private static const sTIMER_EVENT:String = "TIMER_EVENT";
      
      private static const nTIMER_DELAY:Number = 500;
      
      private var oSound:Sound;
      
      private var oLoaderContext:SoundLoaderContext;
      
      private var oLoader:URLLoader;
      
      private var bAlreadySent:Boolean;
      
      private var oDelayTimer:Timer;
      
      public function SoundLoader(_sFileName:String, _oLoaderContext:SoundLoaderContext = null, _sMethod:String = null, _oData:URLVariables = null, _sContentType:String = null, _aRequestHeaders:Array = null)
      {
         this.oLoaderContext = _oLoaderContext;
         super(_sFileName,_sMethod,_oData,_sContentType,_aRequestHeaders);
         this.init();
      }
      
      override protected function init() : void
      {
         this.oDelayTimer = new Timer(nTIMER_DELAY);
         this.oDelayTimer.repeatCount = 1;
         eventManager.addEventListener(sTIMER_EVENT,this.oDelayTimer,TimerEvent.TIMER_COMPLETE,this.onTimerComplete);
         this.bAlreadySent = false;
         this.oSound = new Sound();
         eventManager.addEventListener(sFileName,this.oSound,Event.COMPLETE,this.onLoadComplete);
         eventManager.addEventListener(sFileName,this.oSound,IOErrorEvent.IO_ERROR,this.onLoadError);
         eventManager.addEventListener(sFileName,this.oSound,ProgressEvent.PROGRESS,this.onLoadProgress);
      }
      
      override public function destroy() : void
      {
         this.oSound = null;
         eventManager.clearAll();
         this.oDelayTimer = null;
         eventManager.cleanUp(sFileName);
      }
      
      override public function start() : void
      {
         if(!bLoading)
         {
            this.oSound.load(oRequest,this.oLoaderContext);
            if(this.oLoaderContext != null)
            {
               this.oDelayTimer.start();
            }
            dispatchEvent(new PreloadEvent(PreloadEvent.START,false,false,ID,fileName));
            bLoading = true;
         }
      }
      
      override public function stop() : void
      {
         if(bLoading)
         {
            this.oSound.close();
            bLoading = false;
         }
      }
      
      private function onTimerComplete(_oEvent:TimerEvent) : void
      {
         this.onLoadComplete(null);
      }
      
      private function onLoadComplete(_oEvent:Event) : void
      {
         if(!this.bAlreadySent)
         {
            dispatchEvent(new PreloadEvent(PreloadEvent.COMPLETE,false,false,ID,fileName,"",0,0,0,0,0,0,this.content));
         }
         bLoading = false;
         this.bAlreadySent = false;
         eventManager.cleanUp(sFileName);
      }
      
      private function onLoadError(_oEvent:IOErrorEvent) : void
      {
         bLoading = false;
         dispatchEvent(new PreloadEvent(PreloadEvent.ERROR,false,false,ID,fileName,_oEvent.text));
         eventManager.cleanUp(sFileName);
      }
      
      private function onLoadProgress(_oEvent:ProgressEvent) : void
      {
         nProgress = Math.round(_oEvent.bytesLoaded / _oEvent.bytesTotal * 100);
         dispatchEvent(new PreloadEvent(PreloadEvent.PROGRESS,false,false,ID,fileName,"",_oEvent.bytesLoaded,_oEvent.bytesTotal,nProgress));
      }
      
      public function get content() : Sound
      {
         return this.oSound;
      }
   }
}

