package ui.header
{
   import com.sarbakan.sbdk.asset.AssetReference;
   import com.sarbakan.sbdk.events.UIEvent;
   import com.sarbakan.sbdk.localization.LocalizationManager;
   import com.sarbakan.sbdk.ui.Button;
   import com.sarbakan.sbdk.ui.Radio;
   import com.sarbakan.sbdk.ui.RadioGroup;
   import com.sarbakan.sbdk.view.AbstractView;
   import flash.events.Event;
   import ui.StepDefinition;
   import ui.controls.MuteButton;
   
   public class StepHeader extends AbstractView
   {
      
      protected static const sEVENT_MANAGER_ID:String = "eventManager";
      
      private var oStepGroup:RadioGroup;
      
      private var oMuteButton:MuteButton;
      
      private var oBtnNext:Button;
      
      private var oBtnHelp:Button;
      
      private var oBtnSave:Button;
      
      public function StepHeader()
      {
         super(AssetReference.fromLibraryClass(mcStepHeader));
         this.oStepGroup = new RadioGroup();
         bUseMouseBlocker = false;
      }
      
      override public function destroy() : void
      {
         super.destroy();
         if(Boolean(this.oMuteButton))
         {
            this.oMuteButton.destroy();
         }
         this.oMuteButton = null;
         if(Boolean(this.oBtnNext))
         {
            this.oBtnNext.destroy();
         }
         this.oBtnNext = null;
         if(Boolean(this.oBtnHelp))
         {
            this.oBtnHelp.destroy();
         }
         this.oBtnHelp = null;
         if(Boolean(this.oBtnSave))
         {
            this.oBtnSave.destroy();
         }
         this.oBtnSave = null;
         if(Boolean(this.oStepGroup))
         {
            this.oStepGroup.destroy();
         }
         this.oStepGroup = null;
      }
      
      override public function onBeforeShow() : void
      {
         super.onBeforeShow();
         this.updateMute();
         this.oBtnNext = new Button(mcContent.mcNavigation.btnNext);
         this.oBtnSave = new Button(mcContent.mcNavigation.btnSave);
         this.oBtnSave.enabled = false;
         BuilderMain.instance.tooltipManager.addTargetLocalized(this.oBtnSave.mcContainer,"id_tooltip_btnSave");
         eventManager.addEventListener(sEVENT_MANAGER_ID,this.oBtnSave,UIEvent.RELEASE,this.onBtnSave);
         this.oBtnHelp = new Button(mcContent.mcNavigation.btnHelp);
         eventManager.addEventListener(sEVENT_MANAGER_ID,this.oBtnHelp,UIEvent.RELEASE,this.onBtnHelp);
      }
      
      override public function onHide() : void
      {
         if(Boolean(this.oMuteButton))
         {
            this.oMuteButton.destroy();
         }
         this.oMuteButton = null;
         if(Boolean(this.oBtnNext))
         {
            this.oBtnNext.destroy();
         }
         this.oBtnNext = null;
         if(Boolean(this.oBtnSave))
         {
            this.oBtnSave.destroy();
         }
         this.oBtnSave = null;
         if(Boolean(this.oBtnHelp))
         {
            this.oBtnHelp.destroy();
         }
         this.oBtnHelp = null;
      }
      
      public function addRadio(_oStep:StepDefinition, _nStepID:uint) : void
      {
         _oStep.initRadio(mcContent.mcNavigation);
         var _oRadio:StepHeaderRadio = _oStep.radio;
         if(Boolean(_oRadio))
         {
            eventManager.addEventListener(sEVENT_MANAGER_ID,_oRadio,UIEvent.RELEASE,this.onNavigation);
            this.oStepGroup.addRadio(_oRadio);
            _oRadio.stepID = _nStepID;
         }
      }
      
      public function updateTitle(_nStepID:uint, _oStep:StepDefinition) : void
      {
         LocalizationManager.instance.setTextField(mcContent.mcNavigation.mcTitle.txtStepID,"id_ui_global_stepTitle",{"$value$":_nStepID});
         if(Boolean(_oStep.title1))
         {
            LocalizationManager.instance.setTextField(mcContent.mcNavigation.mcTitle.txtTitle,_oStep.title1);
         }
         if(Boolean(_oStep.title2))
         {
            LocalizationManager.instance.setTextField(mcContent.mcNavigation.mcTitle.txtText,_oStep.title2);
         }
      }
      
      public function updateButtonDisplay(_bVisible:Boolean) : void
      {
         mcContent.mcNavigation.mcStep7.visible = _bVisible;
         mcContent.mcNavigation.mcStep8.visible = _bVisible;
         mcContent.mcNavigation.btnSave.visible = _bVisible;
      }
      
      public function updateMute() : void
      {
         this.oMuteButton = new MuteButton(mcContent.mcNavigation.btnMute);
      }
      
      private function onNavigation(_e:Event) : void
      {
         dispatchEvent(new UIEvent(UIEvent.CHANGE));
      }
      
      private function onBtnSave(_e:UIEvent) : void
      {
         BuilderMain.instance.showPopup(BuilderMain.sPOPUP_SAVE);
      }
      
      private function onBtnHelp(_e:UIEvent) : void
      {
         StepManager.instance.showTutorial(true);
      }
      
      public function get selected() : Radio
      {
         return this.oStepGroup.selected;
      }
      
      public function set selected(_oValue:Radio) : void
      {
         this.oStepGroup.selected = _oValue;
      }
      
      public function set titleLocaleID(_sTitleLocaleID:String) : void
      {
         if(Boolean(_sTitleLocaleID))
         {
            LocalizationManager.instance.setTextField(mcContent.mcTitle.txtTitle,_sTitleLocaleID);
         }
      }
      
      public function get btnNext() : Button
      {
         return this.oBtnNext;
      }
      
      public function get btnSave() : Button
      {
         return this.oBtnSave;
      }
   }
}

