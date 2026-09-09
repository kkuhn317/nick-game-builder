package ui.screens
{
   import com.sarbakan.sbdk.view.AbstractView;
   import flash.events.Event;
   import flash.utils.setTimeout;
   import flash.utils.clearTimeout;
   import media.MediaManager;

   public class LoadedScreen extends AbstractView
   {
      private static const EVENTS:String = "diagnosticLoading";
      private var configReady:Boolean = false;
      private var assetsReady:Boolean = false;
      private var mediasReady:Boolean = false;
      private var renderingReady:Boolean = false;
      private var failed:Boolean = false;
      private var started:Boolean = false;
      private var startTimer:uint = 0;

      public function LoadedScreen()
      {
         super(null,false,false);
      }

      override public function onBeforeShow() : void
      {
         eventManager.cleanUp(EVENTS);
         configReady = false;
         assetsReady = false;
         mediasReady = false;
         renderingReady = false;
         failed = false;
         started = false;
         BuilderMain.instance.diagnosticLog("Diagnostic loading view ready; waiting for config, assets, media and rendering.");
         eventManager.addEventListener(EVENTS,BuilderMain.instance,BuilderMain.sAPPLICATION_LOADED,onStageReady);
         eventManager.addEventListener(EVENTS,BuilderMain.instance,BuilderMain.sASSETS_LOADED,onStageReady);
         eventManager.addEventListener(EVENTS,BuilderMain.instance,BuilderMain.sMEDIAS_LOADED,onStageReady);
         eventManager.addEventListener(EVENTS,BuilderMain.instance,BuilderMain.sMEDIAS_RENDERED,onStageReady);
      }

      private function onStageReady(event:Event) : void
      {
         if(failed || started) return;
         if(event.type == BuilderMain.sAPPLICATION_LOADED) configReady = true;
         if(event.type == BuilderMain.sASSETS_LOADED) assetsReady = true;
         if(event.type == BuilderMain.sMEDIAS_LOADED)
         {
            mediasReady = true;
            if(MediaManager.instance.renderer == null) renderingReady = true;
         }
         if(event.type == BuilderMain.sMEDIAS_RENDERED) renderingReady = true;
         BuilderMain.instance.diagnosticLog("Loading completion signal: " + event.type);
         if(configReady && assetsReady && mediasReady && renderingReady)
         {
            started = true;
            eventManager.cleanUp(EVENTS);
            startTimer = setTimeout(startReadyApplication,1);
         }
      }

      private function startReadyApplication() : void
      {
         startTimer = 0;
         if(failed) return;
         BuilderMain.instance.diagnosticLog("All four loading stages completed; starting application.");
         BuilderMain.instance.startApplication();
      }

      public function showError(message:String,debug:Boolean) : void
      {
         failed = true;
         clearTimeout(startTimer);
         eventManager.cleanUp(EVENTS);
         BuilderMain.instance.diagnosticLog("LOADING STOPPED: " + message);
      }

      override public function onHide() : void
      {
         clearTimeout(startTimer);
         eventManager.cleanUp(EVENTS);
      }

      override public function destroy() : void
      {
         clearTimeout(startTimer);
         eventManager.cleanUp(EVENTS);
         super.destroy();
      }
   }
}
