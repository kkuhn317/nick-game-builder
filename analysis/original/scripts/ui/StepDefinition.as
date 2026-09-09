package ui
{
   import com.sarbakan.sbdk.view.AbstractView;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import ui.header.StepHeaderRadio;
   import ui.screens.AbstractBuilderStepScreen;
   
   public class StepDefinition
   {
      
      private var sID:String;
      
      private var sTitleLocale1:String;
      
      private var sTitleLocale2:String;
      
      private var sRadioLocale:String;
      
      private var sRadioInstanceName:String;
      
      private var oScreen:AbstractBuilderStepScreen;
      
      private var oPopup:AbstractView;
      
      private var oRadio:StepHeaderRadio;
      
      private var mcStepLink:MovieClip;
      
      private var bEnabled:Boolean;
      
      public function StepDefinition(_sID:String, _sTitleLocale1:String, _sTitleLocale2:String, _sRadioLocaleID:String, _sRadioInstanceName:String, _oScreen:AbstractBuilderStepScreen, _oPopup:AbstractView = null)
      {
         super();
         this.sID = _sID;
         this.sTitleLocale1 = _sTitleLocale1;
         this.sTitleLocale2 = _sTitleLocale2;
         this.sRadioInstanceName = _sRadioInstanceName;
         this.sRadioLocale = _sRadioLocaleID;
         this.oScreen = _oScreen;
         this.oPopup = _oPopup;
         this.bEnabled = false;
      }
      
      public function destroy() : void
      {
         this.oScreen = null;
         this.oPopup = null;
         if(Boolean(this.oRadio))
         {
            this.oRadio.destroy();
         }
         this.oRadio = null;
      }
      
      public function initRadio(_mcContainer:DisplayObjectContainer) : void
      {
         var _mcRef:MovieClip = null;
         if(Boolean(this.sRadioInstanceName))
         {
            _mcRef = _mcContainer.getChildByName(this.sRadioInstanceName) as MovieClip;
            if(Boolean(_mcRef))
            {
               this.oRadio = new StepHeaderRadio(_mcRef,this.sID);
               this.oRadio.setLocalizedLabel(this.sRadioLocale);
            }
            this.mcStepLink = _mcContainer.getChildByName(this.sRadioInstanceName + "_link") as MovieClip;
            this.updateStepLink();
         }
      }
      
      private function updateStepLink() : void
      {
         if(Boolean(this.mcStepLink))
         {
            if(this.bEnabled)
            {
               this.mcStepLink.gotoAndStop("Enabled");
            }
            else
            {
               this.mcStepLink.gotoAndStop("Disabled");
            }
         }
      }
      
      public function get id() : String
      {
         return this.sID;
      }
      
      public function get radio() : StepHeaderRadio
      {
         return this.oRadio;
      }
      
      public function get enabled() : Boolean
      {
         return this.bEnabled;
      }
      
      public function set enabled(_bEnabled:Boolean) : void
      {
         this.bEnabled = _bEnabled;
         this.updateStepLink();
         if(Boolean(this.oRadio))
         {
            this.oRadio.enabled = _bEnabled;
         }
      }
      
      public function get screen() : AbstractBuilderStepScreen
      {
         return this.oScreen;
      }
      
      public function get popup() : AbstractView
      {
         return this.oPopup;
      }
      
      public function get title1() : String
      {
         return this.sTitleLocale1;
      }
      
      public function get title2() : String
      {
         return this.sTitleLocale2;
      }
   }
}

