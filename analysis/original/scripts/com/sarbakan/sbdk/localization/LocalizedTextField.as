package com.sarbakan.sbdk.localization
{
   import com.sarbakan.sbdk.events.LocalizationEvent;
   import com.sarbakan.sbdk.utils.EventManager;
   import flash.text.TextField;
   
   public class LocalizedTextField
   {
      
      private static const sEVENT_MANAGER_ID:String = "eventManager";
      
      private var oEventManager:EventManager;
      
      private var oLocalizationManager:LocalizationManager;
      
      private var txtField:TextField;
      
      private var sStringID:String;
      
      private var oReplacements:Object;
      
      private var bInvalidated:Boolean;
      
      public function LocalizedTextField(_txtField:TextField, _sStringID:String, _oReplacements:Object = null)
      {
         super();
         this.txtField = _txtField;
         this.sStringID = _sStringID;
         this.oReplacements = _oReplacements;
         this.init();
      }
      
      public function destroy() : void
      {
         if(this.oEventManager != null)
         {
            this.oEventManager.clearAll();
            this.oEventManager.destroy();
            this.oEventManager = null;
         }
         this.txtField = null;
         this.oReplacements = null;
         this.oLocalizationManager = null;
      }
      
      public function updateText(_sStringID:String, _oReplacements:Object = null) : void
      {
         if(this.txtField != null)
         {
            this.oLocalizationManager.setTextField(this.txtField,_sStringID,_oReplacements);
         }
      }
      
      public function toString() : String
      {
         return "[LocalizedTextField: String ID = " + this.sStringID + "]";
      }
      
      private function init() : void
      {
         this.oEventManager = new EventManager();
         this.oLocalizationManager = LocalizationManager.instance;
         if(this.oLocalizationManager.isStringAvailaible(this.sStringID))
         {
            this.setText();
         }
         else
         {
            this.invalidate();
         }
      }
      
      private function setText() : void
      {
         if(this.txtField != null)
         {
            this.bInvalidated = false;
            this.oLocalizationManager.setTextField(this.txtField,this.sStringID,this.oReplacements);
            this.oEventManager.cleanUp(sEVENT_MANAGER_ID);
            this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oLocalizationManager,LocalizationEvent.LOCALE_CHANGED,this.onLocaleChanged);
         }
         else
         {
            this.destroy();
         }
      }
      
      private function invalidate() : void
      {
         this.bInvalidated = true;
         this.oEventManager.cleanUp(sEVENT_MANAGER_ID);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oLocalizationManager,LocalizationEvent.STRINGS_READY,this.onStringsReady);
      }
      
      private function onLocaleChanged(_e:LocalizationEvent) : void
      {
         this.invalidate();
      }
      
      private function onStringsReady(_e:LocalizationEvent) : void
      {
         this.setText();
      }
   }
}

