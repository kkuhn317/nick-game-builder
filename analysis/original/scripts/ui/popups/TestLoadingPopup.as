package ui.popups
{
   import com.sarbakan.sbdk.asset.AssetReference;
   import com.sarbakan.sbdk.localization.LocalizationManager;
   import com.sarbakan.sbdk.state.AnimStateLocation;
   import com.sarbakan.sbdk.utils.FrameTimer;
   import com.sarbakan.sbdk.view.AbstractInOutView;
   import com.sarbakan.sbdk.view.ViewManager;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import media.MediaManager;
   import media.events.MediaEvent;
   
   public class TestLoadingPopup extends AbstractInOutView
   {
      
      private static var sEVENT_MANAGER_ID:String = "events";
      
      private static var sEVENT_TIMER_ID:String = "timer";
      
      private var oReadyTimer:FrameTimer;
      
      private var bReady:Boolean;
      
      private var aMedias:Array;
      
      public function TestLoadingPopup()
      {
         super(AnimStateLocation.TIMELINE);
         setTimelineAssetReference(AssetReference.fromLibraryClass(mcPopupTestLoading));
         setCustomInSound(AssetReference.fromLibraryClass(SoundConfig.cSFX_POPUP_IN),SoundConfig.sSOUND_CATEGORY_SOUNDS,0);
         setCustomInSound(AssetReference.fromLibraryClass(SoundConfig.cSFX_POPUP_OUT),SoundConfig.sSOUND_CATEGORY_SOUNDS,0);
      }
      
      override public function destroy() : void
      {
         eventManager.clearAll();
         super.destroy();
      }
      
      override public function onShow() : void
      {
         super.onShow();
         var _aAlias:Array = BuilderMain.instance.gameData.usedMediaAlias;
         this.aMedias = BuilderMain.instance.mediaList.listMediasFromAlias(_aAlias);
         this.bReady = false;
         this.oReadyTimer = new FrameTimer(1,0,false);
         eventManager.addEventListener(sEVENT_TIMER_ID,this.oReadyTimer,TimerEvent.TIMER,this.onReadyTimer);
         this.oReadyTimer.start();
         eventManager.addEventListener(sEVENT_MANAGER_ID,MediaManager.instance,MediaEvent.MEDIA_ALL_LOAD_COMPLETE,this.onAllMediaLoaded);
         MediaManager.instance.addMediaToLoad(this.aMedias);
         MediaManager.instance.startMediaLoading();
         skipInOutStates = false;
      }
      
      override public function onHide() : void
      {
         skipInOutStates = false;
      }
      
      private function initLocale() : void
      {
         LocalizationManager.instance.setTextField(mcState.mcPopup.mcText.txtText,"id_ui_loading_builderTest");
      }
      
      override protected function state_in_init() : void
      {
         super.state_in_init();
         this.initLocale();
      }
      
      override protected function state_idle_init() : void
      {
         super.state_idle_init();
         this.initLocale();
      }
      
      override protected function state_out_init() : void
      {
         super.state_out_init();
         this.initLocale();
      }
      
      private function onAllMediaLoaded(_e:Event) : void
      {
         eventManager.cleanUp(sEVENT_MANAGER_ID);
         eventManager.addEventListener(sEVENT_MANAGER_ID,MediaManager.instance,MediaEvent.MEDIA_ALL_RENDERED,this.onAllMediaRendered);
         MediaManager.instance.addMediaToRender(this.aMedias);
         MediaManager.instance.startMediaRendering();
      }
      
      private function onAllMediaRendered(_e:Event) : void
      {
         eventManager.cleanUp(sEVENT_MANAGER_ID);
         dispatchEvent(new Event(Event.COMPLETE));
         if(this.bReady)
         {
            ViewManager.instance.hideView(ID);
         }
         else
         {
            skipInOutStates = true;
            this.bReady = true;
         }
      }
      
      private function onReadyTimer(_e:TimerEvent) : void
      {
         this.oReadyTimer.destroy();
         this.oReadyTimer = null;
         if(this.bReady)
         {
            ViewManager.instance.hideView(ID);
         }
         else
         {
            this.bReady = true;
         }
      }
   }
}

