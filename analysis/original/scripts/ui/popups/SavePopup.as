package ui.popups
{
   import builderManager.BuilderManager;
   import com.sarbakan.sbdk.asset.AssetReference;
   import com.sarbakan.sbdk.events.UIEvent;
   import com.sarbakan.sbdk.events.ViewEvent;
   import com.sarbakan.sbdk.localization.LocalizationManager;
   import com.sarbakan.sbdk.state.AnimStateLocation;
   import com.sarbakan.sbdk.ui.Button;
   import com.sarbakan.sbdk.view.AbstractInOutView;
   import com.sarbakan.sbdk.view.ViewManager;
   import data.GameData;
   import flash.events.Event;
   import flash.events.TextEvent;
   import flash.geom.ColorTransform;
   import flash.text.TextField;
   import services.BuilderService;
   import services.ProxyManager;
   import services.ServiceManager;
   import services.ServiceRequest;
   import services.events.LoginEvent;
   import services.events.ServiceRequestEvent;
   
   public class SavePopup extends AbstractInOutView
   {
      
      private static var sEVENT_MANAGER_ID:String = "events";
      
      private var oBtnConfirm:Button;
      
      private var oBtnCancel:Button;
      
      private var sGameTitle:String;
      
      public function SavePopup()
      {
         super(AnimStateLocation.TIMELINE);
         setTimelineAssetReference(AssetReference.fromLibraryClass(mcPopupSave));
      }
      
      override public function destroy() : void
      {
         eventManager.cleanUp(sEVENT_MANAGER_ID);
         this.destroyButtons();
         super.destroy();
      }
      
      override public function onBeforeShow() : void
      {
         super.onBeforeShow();
         skipInOutStates = false;
         this.sGameTitle = BuilderMain.instance.gameData.title;
         if(this.sGameTitle == null)
         {
            this.sGameTitle = "";
         }
         eventManager.addEventListener(sEVENT_MANAGER_ID,ViewManager.instance.getView(BuilderMain.sPOPUP_MESSAGE),Event.COMPLETE,this.onErrorPopupConfirm);
         eventManager.addEventListener(sEVENT_MANAGER_ID,ViewManager.instance.getView(BuilderMain.sPOPUP_MESSAGE),ViewEvent.HIDE,this.onErrorPopupHide);
      }
      
      override public function onHide() : void
      {
         eventManager.cleanUp(sEVENT_MANAGER_ID);
         this.destroyButtons();
      }
      
      private function initLocalizedContent() : void
      {
         LocalizationManager.instance.setTextField(mcState.mcPopup.mcTitle.txtTitle,"id_ui_step_builder_savePopup_title");
         var _txtTitle:TextField = mcState.mcPopup.txtTitle;
         _txtTitle.maxChars = BuilderConfig.nMAX_TITLE_LENGTH;
         LocalizationManager.instance.setTextField(_txtTitle,"id_ui_step_builder_savePopup_gameTitle",{"$value$":this.sGameTitle});
         _txtTitle.multiline = false;
         eventManager.addEventListener(sEVENT_MANAGER_ID,_txtTitle,TextEvent.TEXT_INPUT,this.onTitleChange);
         this.showErrorText(null);
      }
      
      private function initButtons(_bClickable:Boolean = true) : void
      {
         this.oBtnConfirm = new Button(mcState.mcPopup.btnConfirm);
         this.oBtnConfirm.setLocalizedLabel("id_ui_step_builder_savePopup_confirm");
         this.oBtnCancel = new Button(mcState.mcPopup.btnCancel);
         this.oBtnCancel.setLocalizedLabel("id_ui_step_builder_savePopup_cancel");
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
      
      private function showErrorText(_sLocaleID:String, _oReplacementObject:Object = null) : void
      {
         if(_sLocaleID == null)
         {
            mcState.mcPopup.txtError.text = "";
         }
         else
         {
            LocalizationManager.instance.setTextField(mcState.mcPopup.txtError,_sLocaleID,_oReplacementObject);
         }
      }
      
      private function showMessagePopup(_sTitleID:String, _sTextID:String) : void
      {
         BuilderMain.instance.showMessagePopup(_sTitleID,_sTextID);
         mcContent.transform.colorTransform = CommonConfig.oINACTIVE_COLOR_TRANSFORM;
      }
      
      private function showLoading(_sLocale:String = null) : void
      {
         StepManager.instance.showLoading(_sLocale);
         mcContent.transform.colorTransform = CommonConfig.oINACTIVE_COLOR_TRANSFORM;
      }
      
      private function hideLoading() : void
      {
         StepManager.instance.hideLoading();
         mcContent.transform.colorTransform = new ColorTransform();
      }
      
      private function checkEmptyString() : Boolean
      {
         var i:uint = 0;
         var _bReturn:Boolean = true;
         var _oText:TextField = mcState.mcPopup.txtTitle;
         var _sTitle:String = _oText.text;
         if(_sTitle != "")
         {
            i = 0;
            while(_bReturn && i < _sTitle.length)
            {
               if(_sTitle.charAt(i) != " ")
               {
                  _bReturn = false;
               }
               i++;
            }
         }
         if(_bReturn)
         {
            _oText.text = "";
         }
         return _bReturn;
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
      
      private function onTitleChange(_e:TextEvent) : void
      {
         var _sNewTitle:String = mcState.mcPopup.txtTitle.text + _e.text;
         if(_sNewTitle.length > BuilderConfig.nMAX_TITLE_LENGTH)
         {
            this.showErrorText("id_ui_step_builder_savePopup_errorTooLong",{"$value$":BuilderConfig.nMAX_TITLE_LENGTH});
         }
      }
      
      private function onBtnConfirm(_e:UIEvent) : void
      {
         var _oService:BuilderService = null;
         var _oRequest:ServiceRequest = null;
         var _sTitle:String = mcState.mcPopup.txtTitle.text;
         if(this.checkEmptyString())
         {
            this.showMessagePopup("id_ui_error_title","id_ui_error_noTitle");
         }
         else
         {
            this.showLoading("id_ui_loading_save");
            _oService = ServiceManager.instance.getService(BuilderService.sID) as BuilderService;
            _oRequest = _oService.checkWordFilter(_sTitle);
            eventManager.addEventListener(sEVENT_MANAGER_ID,_oRequest,ServiceRequestEvent.RESPONSE,this.onWordFilterResponse);
         }
      }
      
      private function onBtnCancel(_e:UIEvent) : void
      {
         BuilderMain.instance.hidePopup(ID);
         dispatchEvent(new Event(Event.CANCEL));
      }
      
      private function onWordFilterResponse(_e:ServiceRequestEvent) : void
      {
         var _oData:Object = _e.data;
         if(_oData.name == "good")
         {
            eventManager.addEventListener(sEVENT_MANAGER_ID,ProxyManager.instance,LoginEvent.LOGIN_SUCCEED,this.onLoginSucceed);
            eventManager.addEventListener(sEVENT_MANAGER_ID,ProxyManager.instance,LoginEvent.LOGIN_CANCEL,this.onLoginCancel);
            ProxyManager.instance.checkLogin();
         }
         else
         {
            this.showMessagePopup("id_ui_error_title","id_ui_error_badTitle");
            this.hideLoading();
         }
      }
      
      private function onLoginSucceed(_e:LoginEvent) : void
      {
         eventManager.removeEventListener(sEVENT_MANAGER_ID,ProxyManager.instance,LoginEvent.LOGIN_SUCCEED,this.onLoginSucceed);
         eventManager.removeEventListener(sEVENT_MANAGER_ID,ProxyManager.instance,LoginEvent.LOGIN_CANCEL,this.onLoginCancel);
         var _oService:BuilderService = ServiceManager.instance.getService(BuilderService.sID) as BuilderService;
         var _oRequest:ServiceRequest = _oService.getSavedGames();
         eventManager.addEventListener(sEVENT_MANAGER_ID,_oRequest,ServiceRequestEvent.RESPONSE,this.onRemainingSlotResponse);
      }
      
      private function onLoginCancel(_e:LoginEvent) : void
      {
         eventManager.removeEventListener(sEVENT_MANAGER_ID,ProxyManager.instance,LoginEvent.LOGIN_SUCCEED,this.onLoginSucceed);
         eventManager.removeEventListener(sEVENT_MANAGER_ID,ProxyManager.instance,LoginEvent.LOGIN_CANCEL,this.onLoginCancel);
         this.hideLoading();
         this.showMessagePopup("id_ui_error_title","id_ui_error_canotLogin");
      }
      
      private function onRemainingSlotResponse(_e:ServiceRequestEvent) : void
      {
         var _oGameData:GameData = null;
         var _oService:BuilderService = null;
         var _oRequest:ServiceRequest = null;
         eventManager.removeEventListener(sEVENT_MANAGER_ID,_e.target as ServiceRequest,ServiceRequestEvent.RESPONSE,this.onRemainingSlotResponse);
         var _oResponse:XML = new XML(_e.data);
         var _nSlotLeft:int = int(_oResponse.games.@free);
         if(_nSlotLeft > 0 || BuilderMain.instance.nSlot != -1)
         {
            if(BuilderMain.instance.nSlot == -1)
            {
               _nSlotLeft--;
            }
            if(Boolean(BuilderManager.instance))
            {
               BuilderManager.instance.copyToGameData();
            }
            _oGameData = BuilderMain.instance.gameData;
            this.sGameTitle = mcState.mcPopup.txtTitle.text;
            _oGameData.title = this.sGameTitle;
            _oService = ServiceManager.instance.getService(BuilderService.sID) as BuilderService;
            _oRequest = _oService.setGameData(_oGameData.xmlOut(),this.sGameTitle,_oGameData.builderAlias,_oGameData.propertyAlias,BuilderMain.instance.builderPath,BuilderMain.instance.nSlot);
            eventManager.addEventListener(sEVENT_MANAGER_ID,_oRequest,ServiceRequestEvent.RESPONSE,this.onSaveResponse,false,0,true,_nSlotLeft);
         }
         else
         {
            this.hideLoading();
            this.showMessagePopup("id_ui_error_title","id_ui_error_noRoom");
         }
      }
      
      private function onSaveResponse(_e:ServiceRequestEvent, _nSlotLeft:int) : void
      {
         eventManager.removeEventListener(sEVENT_MANAGER_ID,_e.target as ServiceRequest,ServiceRequestEvent.RESPONSE,this.onSaveResponse);
         var _oResponse:XML = new XML(_e.data);
         var _oError:XMLList = _oResponse..error;
         if(_oError.length() > 0)
         {
            this.hideLoading();
            this.showMessagePopup("id_ui_error_title","id_ui_error_canotLogin");
         }
         else
         {
            BuilderMain.instance.nSlot = int(_oResponse.game.@slot);
            this.hideLoading();
            eventManager.addEventListener(sEVENT_MANAGER_ID,ViewManager.instance.getView(BuilderMain.sPOPUP_MESSAGE),Event.COMPLETE,this.onSaveConfirmComplete);
            this.showMessagePopup("id_ui_step_builder_savePopup_confirmTitle","id_ui_step_builder_savePopup_confirmText");
         }
      }
      
      private function onErrorPopupConfirm(_e:Event) : void
      {
         BuilderMain.instance.hidePopup(BuilderMain.sPOPUP_MESSAGE);
      }
      
      private function onSaveConfirmComplete(_e:Event) : void
      {
         BuilderMain.instance.hidePopup(ID);
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      private function onErrorPopupHide(_e:Event) : void
      {
         mcContent.transform.colorTransform = new ColorTransform();
      }
   }
}

