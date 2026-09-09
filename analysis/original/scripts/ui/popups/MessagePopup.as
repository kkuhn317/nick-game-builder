package ui.popups
{
   import com.sarbakan.sbdk.asset.AssetReference;
   import com.sarbakan.sbdk.events.UIEvent;
   import com.sarbakan.sbdk.localization.LocalizationManager;
   import com.sarbakan.sbdk.state.AnimStateLocation;
   import com.sarbakan.sbdk.ui.Button;
   import com.sarbakan.sbdk.view.AbstractInOutView;
   import flash.events.Event;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   
   public class MessagePopup extends AbstractInOutView
   {
      
      private static var sEVENT_MANAGER_ID:String = "events";
      
      private var oBtnOk:Button;
      
      private var sTitleLocaleID:String;
      
      private var sTextLocaleID:String;
      
      private var sBtnLocaleID:String;
      
      private var oReplacement:Object;
      
      public function MessagePopup()
      {
         super(AnimStateLocation.TIMELINE);
         setTimelineAssetReference(AssetReference.fromLibraryClass(mcPopupMessage));
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
      
      public function setupLocale(_sTitleID:String, _sTextID:String, _sBtnID:String = null, _oReplacement:Object = null) : void
      {
         this.sTitleLocaleID = _sTitleID;
         this.sTextLocaleID = _sTextID;
         this.sBtnLocaleID = Boolean(_sBtnID) ? _sBtnID : "id_ui_error_btnOk";
         this.oReplacement = _oReplacement;
      }
      
      private function initLocalizedContent() : void
      {
         LocalizationManager.instance.setTextField(mcState.mcPopup.mcTitle.txtTitle,this.sTitleLocaleID);
         LocalizationManager.instance.setTextField(mcState.mcPopup.mcText.txtText,this.sTextLocaleID,this.oReplacement);
         TextField(mcState.mcPopup.mcText.txtText).selectable = Boolean(this.oReplacement != null && this.oReplacement["$value$"] != "");
      }
      
      private function initButtons(_bClickable:Boolean = true) : void
      {
         this.oBtnOk = new Button(mcState.mcPopup.btnOk);
         this.oBtnOk.setLocalizedLabel(this.sBtnLocaleID);
         if(_bClickable)
         {
            eventManager.addEventListener(sEVENT_MANAGER_ID,this.oBtnOk,UIEvent.RELEASE,this.onBtnOk);
         }
      }
      
      private function destroyButtons() : void
      {
         if(this.oBtnOk != null)
         {
            this.oBtnOk.destroy();
         }
         this.oBtnOk = null;
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
      
      private function onBtnOk(_e:UIEvent) : void
      {
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}

