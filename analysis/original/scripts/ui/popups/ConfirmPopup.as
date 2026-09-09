package ui.popups
{
   import com.sarbakan.sbdk.asset.AssetReference;
   import com.sarbakan.sbdk.events.UIEvent;
   import com.sarbakan.sbdk.localization.LocalizationManager;
   import com.sarbakan.sbdk.state.AnimStateLocation;
   import com.sarbakan.sbdk.ui.Button;
   import com.sarbakan.sbdk.view.AbstractInOutView;
   import flash.geom.Rectangle;
   import ui.events.PopupEvent;
   
   public class ConfirmPopup extends AbstractInOutView
   {
      
      private static var sEVENT_MANAGER_ID:String = "events";
      
      private var oBtnConfirm:Button;
      
      private var oBtnCancel:Button;
      
      private var sTitleLocaleID:String;
      
      private var sTextLocaleID:String;
      
      private var sConfirmLocaleID:String;
      
      private var sCancelLocaleID:String;
      
      private var nRatioConfirm:Number;
      
      public function ConfirmPopup()
      {
         super(AnimStateLocation.TIMELINE);
         setTimelineAssetReference(AssetReference.fromLibraryClass(mcPopupConfirm));
      }
      
      override public function destroy() : void
      {
         eventManager.cleanUp(sEVENT_MANAGER_ID);
         this.destroyButtons();
         super.destroy();
      }
      
      override public function onBeforeShow() : void
      {
         var _oRect:Rectangle = null;
         var _nDistX:Number = NaN;
         super.onBeforeShow();
         if(StepManager.instance.currentStep.id == StepManager.sSTEP_TEST)
         {
            _oRect = mcContent.getBounds(mcContainer);
            _nDistX = _oRect.left + _oRect.width / 2 - BuilderMain.instance.stage.stageWidth / 2;
            mcContent.x -= _nDistX;
         }
         else
         {
            mcContent.x = 0;
         }
         skipInOutStates = false;
      }
      
      override public function onHide() : void
      {
         eventManager.cleanUp(sEVENT_MANAGER_ID);
         this.destroyButtons();
      }
      
      public function setupLocale(_sTitleID:String, _sTextID:String, _sConfirmID:String, _sCancelID:String, _nRatioConfirm:Number = 1) : void
      {
         this.sTitleLocaleID = _sTitleID;
         this.sTextLocaleID = _sTextID;
         this.sConfirmLocaleID = _sConfirmID;
         this.sCancelLocaleID = _sCancelID;
         this.nRatioConfirm = _nRatioConfirm;
      }
      
      private function initLocalizedContent() : void
      {
         LocalizationManager.instance.setTextField(mcState.mcPopup.mcTitle.txtTitle,this.sTitleLocaleID);
         LocalizationManager.instance.setTextField(mcState.mcPopup.mcText.txtText,this.sTextLocaleID);
      }
      
      private function initButtons(_bClickable:Boolean = true) : void
      {
         this.oBtnConfirm = new Button(mcState.mcPopup.btnConfirm);
         this.oBtnConfirm.setLocalizedLabel(this.sConfirmLocaleID);
         this.oBtnConfirm.mcContainer.scaleX = this.nRatioConfirm;
         this.oBtnConfirm.mcContainer.scaleY = this.nRatioConfirm;
         this.oBtnCancel = new Button(mcState.mcPopup.btnCancel);
         this.oBtnCancel.setLocalizedLabel(this.sCancelLocaleID);
         if(_bClickable)
         {
            eventManager.addEventListener(sEVENT_MANAGER_ID,this.oBtnConfirm,UIEvent.RELEASE,this.onBtnConfirm);
            eventManager.addEventListener(sEVENT_MANAGER_ID,this.oBtnCancel,UIEvent.RELEASE,this.onBtnCancel);
         }
      }
      
      private function destroyButtons() : void
      {
         if(this.oBtnConfirm != null)
         {
            this.oBtnConfirm.destroy();
         }
         this.oBtnConfirm = null;
         if(this.oBtnCancel != null)
         {
            this.oBtnCancel.destroy();
         }
         this.oBtnCancel = null;
      }
      
      override protected function state_in_init() : void
      {
         super.state_in_init();
         this.initLocalizedContent();
         this.initButtons(false);
      }
      
      override protected function state_idle_init() : void
      {
         super.state_idle_init();
         this.initLocalizedContent();
         this.initButtons();
      }
      
      override protected function state_out_init() : void
      {
         super.state_out_init();
         this.initLocalizedContent();
         this.initButtons(false);
      }
      
      private function onBtnConfirm(_e:UIEvent) : void
      {
         dispatchEvent(new PopupEvent(PopupEvent.CONFIRM,ID));
      }
      
      private function onBtnCancel(_e:UIEvent) : void
      {
         dispatchEvent(new PopupEvent(PopupEvent.CANCEL,ID));
         this.oBtnCancel.enabled = false;
      }
   }
}

