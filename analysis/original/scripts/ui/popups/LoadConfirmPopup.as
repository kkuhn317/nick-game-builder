package ui.popups
{
   import com.sarbakan.sbdk.asset.AssetReference;
   import com.sarbakan.sbdk.core.UpdateManager;
   import com.sarbakan.sbdk.events.UIEvent;
   import com.sarbakan.sbdk.localization.LocalizationManager;
   import com.sarbakan.sbdk.state.AnimStateLocation;
   import com.sarbakan.sbdk.ui.Button;
   import com.sarbakan.sbdk.view.AbstractInOutView;
   import com.sarbakan.sbdk.view.ViewManager;
   import flash.events.Event;
   import flash.geom.ColorTransform;
   import services.LoadGameRequest;
   import services.events.GameLoadEvent;
   import ui.screens.TestScreen;
   
   public class LoadConfirmPopup extends AbstractInOutView
   {
      
      private static var sEVENT_MANAGER_ID:String = "events";
      
      private static var sEVENT_SERVICES_ID:String = "eventServices";
      
      private var oLoadRequest:LoadGameRequest;
      
      private var bSameSlot:Boolean;
      
      private var bBuilderEnabled:Boolean;
      
      private var oBtnSave:Button;
      
      private var oBtnNoSave:Button;
      
      private var oBtnCancel:Button;
      
      public function LoadConfirmPopup()
      {
         super(AnimStateLocation.TIMELINE);
         setTimelineAssetReference(AssetReference.fromLibraryClass(mcPopupLoadConfirm));
      }
      
      override public function destroy() : void
      {
         eventManager.cleanUp(sEVENT_MANAGER_ID);
         this.destroyButton();
         super.destroy();
         if(Boolean(this.oLoadRequest))
         {
            this.oLoadRequest.destroy();
         }
         this.oLoadRequest = null;
      }
      
      override public function onBeforeShow() : void
      {
         this.bSameSlot = Boolean(BuilderMain.instance.nSlot == BuilderMain.instance.nPendingSlot);
         this.bBuilderEnabled = StepManager.instance.isStepEnabled(StepManager.sSTEP_BUILDER);
         UpdateManager.instance.pause();
      }
      
      override public function onHide() : void
      {
         if(ViewManager.instance.getView(BuilderMain.sPOPUP_MENU).isDisplayed == false)
         {
            UpdateManager.instance.resume();
         }
         if(Boolean(this.oLoadRequest))
         {
            this.oLoadRequest.destroy();
         }
         this.oLoadRequest = null;
      }
      
      private function initTitle() : void
      {
         if(this.bSameSlot)
         {
            LocalizationManager.instance.setTextField(mcState.mcPopup.mcTitle.txtTitle,"id_ui_loadGamePopup_titleReset");
         }
         else if(this.bBuilderEnabled)
         {
            LocalizationManager.instance.setTextField(mcState.mcPopup.mcTitle.txtTitle,"id_ui_loadGamePopup_titleSave");
         }
         else
         {
            LocalizationManager.instance.setTextField(mcState.mcPopup.mcTitle.txtTitle,"id_ui_loadGamePopup_titleNoSave");
         }
      }
      
      private function initButton(_bEnable:Boolean = true) : void
      {
         this.oBtnSave = new Button(mcState.mcPopup.btnSave);
         this.oBtnNoSave = new Button(mcState.mcPopup.btnNoSave);
         this.oBtnCancel = new Button(mcState.mcPopup.btnCancel);
         if(this.bBuilderEnabled && !this.bSameSlot)
         {
            this.oBtnSave.setLocalizedLabel("id_ui_loadGamePopup_btnYes");
            this.oBtnNoSave.setLocalizedLabel("id_ui_loadGamePopup_btnNo");
            this.oBtnCancel.setLocalizedLabel("id_ui_loadGamePopup_btnCancel");
         }
         else
         {
            if(BuilderMain.instance.gameData.propertyAlias == "gb_danimals")
            {
               mcState.mcPopup.mcBtnSaveAssise.visible = false;
            }
            else
            {
               this.oBtnSave.mcContainer.visible = false;
            }
            this.oBtnNoSave.setLocalizedLabel("id_ui_loadGamePopup_btnYes");
            this.oBtnCancel.setLocalizedLabel("id_ui_loadGamePopup_btnNo");
         }
         if(_bEnable)
         {
            eventManager.addEventListener(sEVENT_MANAGER_ID,this.oBtnSave,UIEvent.RELEASE,this.onBtnSave);
            eventManager.addEventListener(sEVENT_MANAGER_ID,this.oBtnNoSave,UIEvent.RELEASE,this.onBtnNoSave);
            eventManager.addEventListener(sEVENT_MANAGER_ID,this.oBtnCancel,UIEvent.RELEASE,this.onBtnCancel);
         }
      }
      
      private function destroyButton() : void
      {
         if(Boolean(this.oBtnSave))
         {
            this.oBtnSave.destroy();
         }
         this.oBtnSave = null;
         if(Boolean(this.oBtnNoSave))
         {
            this.oBtnNoSave.destroy();
         }
         this.oBtnNoSave = null;
         if(Boolean(this.oBtnCancel))
         {
            this.oBtnCancel.destroy();
         }
         this.oBtnCancel = null;
      }
      
      private function loadGame() : void
      {
         if(StepManager.instance.currentStep.id == StepManager.sSTEP_TEST)
         {
            TestScreen(StepManager.instance.currentStep.screen).takeSnapshot();
         }
         this.oLoadRequest = new LoadGameRequest(BuilderMain.instance.nPendingSlot);
         eventManager.addEventListener(sEVENT_SERVICES_ID,this.oLoadRequest,GameLoadEvent.LOAD_COMPLETE,this.onGameLoaded);
         StepManager.instance.showLoading();
         mcContent.transform.colorTransform = CommonConfig.oINACTIVE_COLOR_TRANSFORM;
      }
      
      override protected function state_in_init() : void
      {
         super.state_in_init();
         this.initTitle();
         this.initButton(false);
      }
      
      override protected function state_idle_init() : void
      {
         super.state_idle_init();
         this.initTitle();
         this.initButton();
      }
      
      override protected function state_out_init() : void
      {
         super.state_out_init();
         this.initTitle();
         this.initButton(false);
      }
      
      private function onBtnSave(_e:UIEvent) : void
      {
         var _oSavePopup:SavePopup = ViewManager.instance.getView(BuilderMain.sPOPUP_SAVE) as SavePopup;
         eventManager.addEventListener(sEVENT_SERVICES_ID,_oSavePopup,Event.COMPLETE,this.onSaveComplete);
         eventManager.addEventListener(sEVENT_SERVICES_ID,_oSavePopup,Event.CANCEL,this.onSaveCancel);
         BuilderMain.instance.showPopup(BuilderMain.sPOPUP_SAVE,false);
         mcContent.transform.colorTransform = CommonConfig.oINACTIVE_COLOR_TRANSFORM;
      }
      
      private function onBtnNoSave(_e:UIEvent) : void
      {
         this.loadGame();
      }
      
      private function onBtnCancel(_e:UIEvent) : void
      {
         BuilderMain.instance.hidePopup(ID);
      }
      
      private function onSaveComplete(_e:Event) : void
      {
         eventManager.cleanUp(sEVENT_SERVICES_ID);
         this.loadGame();
      }
      
      private function onSaveCancel(_e:Event) : void
      {
         eventManager.cleanUp(sEVENT_SERVICES_ID);
         mcContent.transform.colorTransform = new ColorTransform();
      }
      
      private function onGameLoaded(_e:GameLoadEvent) : void
      {
         eventManager.cleanUp(sEVENT_SERVICES_ID);
         BuilderMain.instance.nSlot = this.oLoadRequest.slotID;
         BuilderMain.instance.nPendingSlot = -1;
         BuilderMain.instance.templateData = this.oLoadRequest.templateData;
         BuilderMain.instance.gameData = this.oLoadRequest.gameData;
         if(Boolean(this.oLoadRequest))
         {
            this.oLoadRequest.destroy();
         }
         this.oLoadRequest = null;
         BuilderMain.instance.hidePopup(ID);
         StepManager.instance.hideLoading();
         mcContent.transform.colorTransform = new ColorTransform();
      }
   }
}

