package ui.screens
{
   import assets.ExternalAssetManager;
   import assets.events.ExternalAssetEvent;
   import com.sarbakan.sbdk.asset.AssetReference;
   import com.sarbakan.sbdk.blitting.core.VectorToBitmapConverter;
   import com.sarbakan.sbdk.events.BitmappedEvent;
   import com.sarbakan.sbdk.events.PreloadEvent;
   import com.sarbakan.sbdk.localization.LocalizationManager;
   import com.sarbakan.sbdk.ui.SteppedProgressBar;
   import com.sarbakan.sbdk.utils.FrameTimer;
   import com.sarbakan.sbdk.view.AbstractView;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.text.TextField;
   import media.MediaManager;
   
   public class LoadedScreen extends AbstractView
   {
      
      private static const sEVENT_MANAGER_ID:String = "eventManager";
      
      private static const sEVENT_PROGRESS_BAR:String = "eventProgressBar";
      
      private static const sPROGRESS_STEP_CONFIG:String = "stepConfig";
      
      private static const sPROGRESS_STEP_MEDIAS:String = "stepMedias";
      
      private static const sPROGRESS_STEP_BLITTING:String = "stepBlitting";
      
      private static const sPROGRESS_STEP_ASSETS:String = "stepAssets";
      
      private var oProgressBar:SteppedProgressBar;
      
      private var oFrameTimer:FrameTimer;
      
      public function LoadedScreen()
      {
         super(AssetReference.fromAssetManager(CommonConfig.sPRELOADER_ASSET_ID));
      }
      
      override public function destroy() : void
      {
         if(Boolean(this.oProgressBar))
         {
            this.oProgressBar.destroy();
         }
         this.oProgressBar = null;
         if(Boolean(this.oFrameTimer))
         {
            this.oFrameTimer.destroy();
         }
         this.oFrameTimer = null;
         eventManager.cleanUp(sEVENT_MANAGER_ID);
         super.destroy();
      }
      
      override public function onBeforeShow() : void
      {
         mcContent.mcErrorMessage.visible = false;
         this.oProgressBar = new SteppedProgressBar(mcContent.mcPreloader,"%",false,0,100,10);
         this.oProgressBar.setLocalizedLabel("id_ui_loading_label");
         this.oProgressBar.setLocalizedValue("id_ui_loading_progress",{"$value$":this.oProgressBar.displayedValue + "%"},"$value$");
         this.oProgressBar.addStep(sPROGRESS_STEP_CONFIG,0,100,0.1);
         this.oProgressBar.addStep(sPROGRESS_STEP_MEDIAS,0,100,0.3);
         this.oProgressBar.addStep(sPROGRESS_STEP_BLITTING,0,100,0.3);
         this.oProgressBar.addStep(sPROGRESS_STEP_ASSETS,0,100,0.3);
         eventManager.addEventListener(sEVENT_PROGRESS_BAR,this.oProgressBar,Event.COMPLETE,this.onAllComplete);
         eventManager.addEventListener(sEVENT_MANAGER_ID,BuilderMain.instance,BuilderMain.sAPPLICATION_LOADED,this.onApplicationLoaded);
      }
      
      override public function onHide() : void
      {
         this.oProgressBar.destroy();
         this.oProgressBar = null;
         if(Boolean(this.oFrameTimer))
         {
            this.oFrameTimer.destroy();
         }
         this.oFrameTimer = null;
         eventManager.cleanUp(sEVENT_MANAGER_ID);
         eventManager.cleanUp(sEVENT_PROGRESS_BAR);
      }
      
      public function showError(_sErrorMessage:String, _bDebug:Boolean) : void
      {
         var _mcError:MovieClip = null;
         var _oText:TextField = null;
         if(Boolean(mcContent))
         {
            _mcError = mcContent.mcErrorMessage;
            _mcError.visible = true;
            LocalizationManager.instance.setTextField(_mcError.txtTitle,"id_ui_error_title");
            _oText = _mcError.txtText;
            if(_bDebug)
            {
               _oText.text = _sErrorMessage;
               _oText.selectable = true;
            }
            else
            {
               LocalizationManager.instance.setTextField(_oText,"id_ui_error_loading");
            }
         }
         else if(_bDebug)
         {
            throw new Error(_sErrorMessage);
         }
      }
      
      private function onApplicationLoaded(_e:Event) : void
      {
         eventManager.cleanUp(sEVENT_MANAGER_ID);
         this.oProgressBar.setStepValue(sPROGRESS_STEP_CONFIG,100);
         eventManager.addEventListener(sEVENT_MANAGER_ID,ExternalAssetManager.instance,ExternalAssetEvent.PROGRESS,this.onAssetProgress);
         eventManager.addEventListener(sEVENT_MANAGER_ID,BuilderMain.instance,BuilderMain.sASSETS_LOADED,this.onAssetLoaded);
      }
      
      private function onAssetProgress(_e:ExternalAssetEvent) : void
      {
         this.oProgressBar.setStepValue(sPROGRESS_STEP_ASSETS,_e.percentage);
      }
      
      private function onAssetLoaded(_e:Event) : void
      {
         eventManager.cleanUp(sEVENT_MANAGER_ID);
         this.oProgressBar.setStepValue(sPROGRESS_STEP_ASSETS,100);
         eventManager.addEventListener(sEVENT_MANAGER_ID,MediaManager.instance,PreloadEvent.PROGRESS,this.onMediaLoadProgress);
         eventManager.addEventListener(sEVENT_MANAGER_ID,BuilderMain.instance,BuilderMain.sMEDIAS_LOADED,this.onMediaLoaded);
      }
      
      private function onMediaLoadProgress(_e:PreloadEvent) : void
      {
         this.oProgressBar.setStepValue(sPROGRESS_STEP_MEDIAS,_e.totalPercentage);
      }
      
      private function onMediaLoaded(_e:Event) : void
      {
         eventManager.cleanUp(sEVENT_MANAGER_ID);
         this.oProgressBar.setStepValue(sPROGRESS_STEP_MEDIAS,100);
         if(Boolean(MediaManager.instance.renderer))
         {
            eventManager.addEventListener(sEVENT_MANAGER_ID,MediaManager.instance.renderer,BitmappedEvent.PROGRESS,this.onMediaRenderProgress);
            eventManager.addEventListener(sEVENT_MANAGER_ID,BuilderMain.instance,BuilderMain.sMEDIAS_RENDERED,this.onMediaRendered);
         }
         else
         {
            this.onMediaRendered(null);
         }
      }
      
      private function onMediaRenderProgress(_e:BitmappedEvent) : void
      {
         this.oProgressBar.setStepValue(sPROGRESS_STEP_BLITTING,VectorToBitmapConverter(_e.target).progressPercentage);
      }
      
      private function onMediaRendered(_e:Event) : void
      {
         eventManager.cleanUp(sEVENT_MANAGER_ID);
         this.oProgressBar.setStepValue(sPROGRESS_STEP_BLITTING,100);
      }
      
      private function onAllComplete(_oEvent:Event) : void
      {
         eventManager.cleanUp(sEVENT_PROGRESS_BAR);
         BuilderMain.instance.startApplication();
      }
   }
}

