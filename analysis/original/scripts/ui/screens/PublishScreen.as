package ui.screens
{
   import com.sarbakan.sbdk.asset.AssetReference;
   import com.sarbakan.sbdk.events.UIEvent;
   import com.sarbakan.sbdk.localization.LocalizationManager;
   import com.sarbakan.sbdk.ui.Button;
   import com.sarbakan.sbdk.view.ViewManager;
   import data.GameData;
   import flash.events.Event;
   import flash.events.TextEvent;
   import flash.external.ExternalInterface;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import services.BuilderService;
   import services.ProxyManager;
   import services.ServiceManager;
   import services.ServiceRequest;
   import services.events.LoginEvent;
   import services.events.ServiceRequestEvent;
   import ui.popups.MessagePopup;
   
   public class PublishScreen extends AbstractBuilderStepScreen
   {
      
      private var oLayout:TheaterScreenLayout;
      
      public function PublishScreen()
      {
         super(AssetReference.fromLibraryClass(mcPublishScreen));
      }
      
      override public function destroy() : void
      {
         super.destroy();
      }
      
      override public function onBeforeShow() : void
      {
         super.onBeforeShow();
         StepManager.instance.showHeader();
         eventManager.addEventListener(sEVENT_MANAGER_ID,ViewManager.instance.getView(BuilderMain.sPOPUP_MESSAGE),Event.COMPLETE,this.onErrorPopupConfirm);
         var _oBtnNext:Button = StepManager.instance.header.btnNext;
         _oBtnNext.mcContainer.visible = true;
         _oBtnNext.setLocalizedLabel("id_step_publish_btnPublish");
         _oBtnNext.enabled = true;
         eventManager.addEventListener(sEVENT_MANAGER_ID,_oBtnNext,UIEvent.RELEASE,this.onBtnConfirm);
         this.initLayout();
         this.initTextInput();
         StepManager.instance.disableAllStep();
      }
      
      override public function onHide() : void
      {
         super.onHide();
         eventManager.cleanUp(sEVENT_MANAGER_ID);
         this.hideLoading();
         var _oMessage:MessagePopup = ViewManager.instance.getView(BuilderMain.sPOPUP_MESSAGE) as MessagePopup;
         if(_oMessage.isDisplayed)
         {
            _oMessage.skipInOutStates = true;
            BuilderMain.instance.hidePopup(BuilderMain.sPOPUP_MESSAGE);
         }
      }
      
      private function initLayout() : void
      {
         this.oLayout = new TheaterScreenLayout(BuilderMain.instance.gameData,BuilderMain.instance.mediaList);
         var _sTitle:String = BuilderMain.instance.gameData.title;
         if(_sTitle == null)
         {
            _sTitle = "";
         }
         this.oLayout.setTitleLocale("id_ui_title_gameTitle",{"$value$":_sTitle});
         mcContent.mcPreview.mcContent.addChildAt(this.oLayout.mcContent,0);
         mcContent.mcPreview.mcContent.scrollRect = new Rectangle(0,0,954,517);
         mcContent.mcPreview.mcContent.y -= 5;
         mcContent.mcPreview.mcContent.x += 3;
      }
      
      private function initTextInput() : void
      {
         var _sTitle:String = BuilderMain.instance.gameData.title;
         if(_sTitle == null)
         {
            _sTitle = "";
         }
         var _txtTitle:TextField = mcContent.txtTitle;
         _txtTitle.maxChars = BuilderConfig.nMAX_TITLE_LENGTH;
         LocalizationManager.instance.setTextField(_txtTitle,"id_ui_step_builder_savePopup_gameTitle",{"$value$":_sTitle});
         _txtTitle.multiline = false;
         eventManager.addEventListener(sEVENT_MANAGER_ID,_txtTitle,TextEvent.TEXT_INPUT,this.onTitleInput);
         eventManager.addEventListener(sEVENT_MANAGER_ID,_txtTitle,Event.CHANGE,this.onTitleChange);
         this.showErrorText(null);
      }
      
      private function showErrorText(_sLocaleID:String, _oReplacementObject:Object = null) : void
      {
         if(_sLocaleID == null)
         {
            mcContent.txtError.text = "";
         }
         else
         {
            LocalizationManager.instance.setTextField(mcContent.txtError,_sLocaleID,_oReplacementObject);
         }
      }
      
      private function showErrorPopup(_sTitleID:String, _sTextID:String) : void
      {
         BuilderMain.instance.showMessagePopup("id_ui_error_title",_sTextID);
      }
      
      private function showLoading(_sLocale:String = null) : void
      {
         StepManager.instance.showLoading(_sLocale);
      }
      
      private function hideLoading() : void
      {
         StepManager.instance.hideLoading();
      }
      
      private function checkEmptyString() : Boolean
      {
         var i:uint = 0;
         var _bReturn:Boolean = true;
         var _oText:TextField = mcContent.txtTitle;
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
      
      private function publish() : void
      {
         var _oService:BuilderService = null;
         var _oRequest:ServiceRequest = null;
         var _sTitle:String = mcContent.txtTitle.text;
         if(this.checkEmptyString())
         {
            this.showErrorPopup("id_ui_error_title","id_ui_error_noTitle");
         }
         else
         {
            this.showLoading("id_loading_publish");
            _oService = ServiceManager.instance.getService(BuilderService.sID) as BuilderService;
            _oRequest = _oService.checkWordFilter(_sTitle);
            eventManager.addEventListener(sEVENT_MANAGER_ID,_oRequest,ServiceRequestEvent.RESPONSE,this.onWordFilterResponse);
         }
      }
      
      private function onTitleInput(_e:TextEvent) : void
      {
         var _sNewTitle:String = mcContent.txtTitle.text + _e.text;
         if(_sNewTitle.length > BuilderConfig.nMAX_TITLE_LENGTH)
         {
            this.showErrorText("id_ui_step_builder_savePopup_errorTooLong",{"$value$":BuilderConfig.nMAX_TITLE_LENGTH});
         }
      }
      
      private function onTitleChange(_e:Event) : void
      {
         this.oLayout.setTitleLocale("id_ui_title_gameTitle",{"$value$":mcContent.txtTitle.text + "(AD)"});
      }
      
      private function onBtnConfirm(_e:UIEvent) : void
      {
         this.publish();
      }
      
      private function onWordFilterResponse(_e:ServiceRequestEvent) : void
      {
         var _oBtnNext:Button = null;
         var _oData:Object = _e.data;
         if(_oData.name == "good")
         {
            _oBtnNext = StepManager.instance.header.btnNext;
            _oBtnNext.mcContainer.visible = true;
            _oBtnNext.setLocalizedLabel("id_step_publish_btnPublish");
            _oBtnNext.enabled = false;
            BuilderMain.instance.gameData.title = mcContent.txtTitle.text;
            eventManager.addEventListener(sEVENT_MANAGER_ID,ProxyManager.instance,LoginEvent.LOGIN_SUCCEED,this.onLoginSucceed);
            eventManager.addEventListener(sEVENT_MANAGER_ID,ProxyManager.instance,LoginEvent.LOGIN_CANCEL,this.onLoginCancel);
            ProxyManager.instance.checkLogin();
         }
         else
         {
            this.showErrorPopup("id_ui_error_title","id_ui_error_badTitle");
            this.hideLoading();
         }
      }
      
      private function onLoginSucceed(_e:LoginEvent) : void
      {
         eventManager.removeEventListener(sEVENT_MANAGER_ID,ProxyManager.instance,LoginEvent.LOGIN_SUCCEED,this.onLoginSucceed);
         eventManager.removeEventListener(sEVENT_MANAGER_ID,ProxyManager.instance,LoginEvent.LOGIN_CANCEL,this.onLoginCancel);
         var _oGameData:GameData = BuilderMain.instance.gameData;
         var _sTitle:String = LocalizationManager.instance.getString("id_ui_title_gameTitle",{"$value$":_oGameData.title}).string;
         var _oService:BuilderService = ServiceManager.instance.getService(BuilderService.sID) as BuilderService;
         var _oRequest:ServiceRequest = _oService.publishGame(BuilderMain.instance.nSlot,_oGameData.builderAlias,BuilderMain.instance.category,BuilderMain.instance.builderPath,_oGameData.xmlOut(),_sTitle,BuilderMain.instance.oBuilderSnapshot);
         eventManager.addEventListener(sEVENT_MANAGER_ID,_oRequest,ServiceRequestEvent.RESPONSE,this.onPublish);
      }
      
      private function onLoginCancel(_e:LoginEvent) : void
      {
         eventManager.removeEventListener(sEVENT_MANAGER_ID,ProxyManager.instance,LoginEvent.LOGIN_SUCCEED,this.onLoginSucceed);
         eventManager.removeEventListener(sEVENT_MANAGER_ID,ProxyManager.instance,LoginEvent.LOGIN_CANCEL,this.onLoginCancel);
         this.hideLoading();
         this.showErrorPopup("id_ui_error_title","id_ui_error_canotLogin");
      }
      
      private function onErrorPopupConfirm(_e:Event) : void
      {
         BuilderMain.instance.hidePopup(BuilderMain.sPOPUP_MESSAGE);
      }
      
      private function onPublish(_e:ServiceRequestEvent) : void
      {
         var _oMessage:MessagePopup = null;
         var _sTitle:String = null;
         this.hideLoading();
         var _oResponse:XML = new XML(_e.data);
         var _oError:XMLList = _oResponse..error;
         if(_oError.length() > 0)
         {
            this.showErrorPopup("id_ui_error_title","id_ui_error_canotLogin");
         }
         else
         {
            eventManager.cleanUp(sEVENT_MANAGER_ID);
            if(ExternalInterface.available)
            {
               _sTitle = _e.data;
               ExternalInterface.call("onPublish",_sTitle);
            }
            _oMessage = ViewManager.instance.getView(BuilderMain.sPOPUP_MESSAGE) as MessagePopup;
            eventManager.addEventListener(sEVENT_MANAGER_ID,_oMessage,Event.COMPLETE,this.onPublishConfirmationClose);
            BuilderMain.instance.showMessagePopup("id_step_publish_succeedTitle","id_step_publish_succeedText","id_step_publish_btnNext");
         }
      }
      
      private function onPublishConfirmationClose(_e:Event) : void
      {
         BuilderMain.instance.onPublish();
      }
   }
}

