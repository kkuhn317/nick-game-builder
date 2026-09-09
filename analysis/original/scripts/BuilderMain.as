package
{
   import assets.ExternalAssetManager;
   import assets.events.ExternalAssetEvent;
   import builderManager.BuilderData;
   import builderManager.BuilderManager;
   import builderManager.TemplateData;
   import com.sarbakan.sbdk.asset.AssetLocation;
   import com.sarbakan.sbdk.asset.AssetManager;
   import com.sarbakan.sbdk.asset.AssetReference;
   import com.sarbakan.sbdk.core.AbstractApplication;
   import com.sarbakan.sbdk.events.CheatEvent;
   import com.sarbakan.sbdk.events.LocalizationEvent;
   import com.sarbakan.sbdk.events.PreloadEvent;
   import com.sarbakan.sbdk.events.TransitionEvent;
   import com.sarbakan.sbdk.localization.LocalizationManager;
   import com.sarbakan.sbdk.sound.SoundManager;
   import com.sarbakan.sbdk.sound.SoundUnit;
   import com.sarbakan.sbdk.tools.CheatManager;
   import com.sarbakan.sbdk.tools.logger.Logger;
   import com.sarbakan.sbdk.tools.logger.TracePublisher;
   import com.sarbakan.sbdk.ui.AbstractControl;
   import com.sarbakan.sbdk.ui.ToolTipManager;
   import com.sarbakan.sbdk.utils.ExternalConfig;
   import com.sarbakan.sbdk.utils.FocusKeeper;
   import com.sarbakan.sbdk.utils.StringUtils;
   import com.sarbakan.sbdk.view.AbstractInOutView;
   import com.sarbakan.sbdk.view.ViewManager;
   import data.GameData;
   import flash.display.BitmapData;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.geom.ColorTransform;
   import flash.system.Security;
   import flash.utils.getDefinitionByName;
   import gamePlayer.GameSession;
   import gamePlayer.events.GamePlayerEvent;
   import gamePlayer.ui.popup.HelpPopup;
   import gamePlayer.ui.popup.MenuPopup;
   import gamePlayer.ui.popup.QuitPopup;
   import media.MediaList;
   import media.MediaManager;
   import media.events.MediaEvent;
   import media.type.MusicMedia;
   import media.type.SfxMedia;
   import services.BuilderService;
   import services.GameDataService;
   import services.LoadGameRequest;
   import services.MediaService;
   import services.ProxyManager;
   import services.ServiceManager;
   import services.events.GameLoadEvent;
   import sound.SfxManager;
   import ui.StepDefinition;
   import ui.events.PopupEvent;
   import ui.popups.*;
   import ui.screens.*;
   
   [SWF(width="960",height="500",frameRate="35",backgroundColor="#FFFFFF")]
   public class BuilderMain extends AbstractApplication
   {
      
      private static var oInstance:BuilderMain;
      
      public static const sLAYER_SCREEN:String = "layerScreen";
      
      public static const sLAYER_SELECTION_WHEEL:String = "layerSelectionWheel";
      
      public static const sLAYER_HEADER:String = "layerHeader";
      
      public static const sLAYER_POPUP:String = "layerPopup";
      
      public static const sLAYER_LOADING:String = "layerLoading";
      
      public static const sSCREEN_LOADED:String = "screenLoaded";
      
      public static const sPOPUP_HELP:String = "popupHelp";
      
      public static const sPOPUP_MENU:String = "popupMenu";
      
      public static const sPOPUP_QUIT:String = "popupQuit";
      
      public static const sPOPUP_CONFIRM:String = "popupConfirm";
      
      public static const sPOPUP_SAVE:String = "popupSave";
      
      public static const sPOPUP_LOAD_CONFIRM:String = "popupLoadConfirm";
      
      public static const sPOPUP_MESSAGE:String = "popupMessage";
      
      public static const sDEFAULT_TRANSITION_IN:String = "defaultTransitionIn";
      
      public static const sDEFAULT_TRANSITION_OUT:String = "defaultTransitionOut";
      
      private static const sEVENT_MANAGER_ID:String = "eventManager";
      
      private static const sEVENT_PRELOAD_ID:String = "eventPreload";
      
      public static const sAPPLICATION_LOADED:String = "sbdk_applicationLoaded";
      
      public static const sMEDIAS_LOADED:String = "sbdk_mediasLoaded";
      
      public static const sMEDIAS_RENDERED:String = "sbdk_mediasRendered";
      
      public static const sASSETS_LOADED:String = "sbdk_assetsLoaded";
      
      [Embed(source="../../../.buildInfo",mimeType="application/octet-stream")]
      private static const cBUILD_INFO_STRING_CLASS:Class = BuilderMain_cBUILD_INFO_STRING_CLASS;
      
      private static const sBUILD_INFO_STRING:String = StringUtils.remove(String(new cBUILD_INFO_STRING_CLASS()),"\r\n");
      
      public static const sCHEAT_WIN:String = "cheat_win_game";
      
      public static const sCHEAT_LOSE:String = "cheat_lose_game";
      
      public static const sCHEAT_DESTROY:String = "cheat_destroy_game";
      
      public var nSlot:int;
      
      public var nPendingSlot:int;
      
      public var oBuilderSnapshot:BitmapData;
      
      private var oTracePublisher:TracePublisher;
      
      private var nExternalLocalizedFilesToPreload:int;
      
      private var oTransitionIn:SoundUnit;
      
      private var cTransitionIn:Class;
      
      private var oTransitionOut:SoundUnit;
      
      private var cTransitionOut:Class;
      
      private var sDataPath:String;
      
      private var bGameLoaded:Boolean;
      
      private var oCheatManager:CheatManager;
      
      private var oTemplateData:TemplateData;
      
      private var oLoadGameRequest:LoadGameRequest;
      
      private var oViewManager:ViewManager;
      
      private var oMediaList:MediaList;
      
      private var oGameData:GameData;
      
      private var sLanguage:String;
      
      public function BuilderMain()
      {
         super();
         oInstance = this;
         versionInfo = sBUILD_INFO_STRING;
         Security.allowDomain("*");
      }
      
      public static function get instance() : BuilderMain
      {
         return BuilderMain.oInstance;
      }
      
      override protected function init() : void
      {
         this.nSlot = -1;
         var _sPendingSlot:String = loaderInfo.parameters["slotID"];
         if(_sPendingSlot == null || _sPendingSlot == "")
         {
            this.nPendingSlot = -1;
         }
         else
         {
            this.nPendingSlot = int(loaderInfo.parameters["slotID"]);
         }
         this.sDataPath = loaderInfo.parameters["dataPath"];
         if(this.sDataPath == null || this.sDataPath == "")
         {
            this.sDataPath = CommonConfig.sDATA_PATH;
         }
         this.initViewManager();
         FocusKeeper.instance(stage).enable();
         eventManager.addEventListener(sEVENT_MANAGER_ID,ViewManager.instance,TransitionEvent.START,this.onTransitionStartEnd);
         this.loadExternalConfig();
         if(false == false)
         {
            contextMenu.hideBuiltInItems();
         }
         stage.stageFocusRect = false;
      }
      
      override public function destroy() : void
      {
         removeChild(this.oViewManager);
         this.oViewManager = null;
         GameSession.instance.destroy();
         super.destroy();
         if(Boolean(this.oTransitionIn))
         {
            this.oTransitionIn.destroy();
         }
         this.oTransitionIn = null;
         this.cTransitionIn = null;
         if(Boolean(this.oTransitionOut))
         {
            this.oTransitionOut.destroy();
         }
         this.oTransitionOut = null;
         this.cTransitionOut = null;
         if(Boolean(this.oLoadGameRequest))
         {
            this.oLoadGameRequest.destroy();
         }
         this.oLoadGameRequest = null;
         oInstance = null;
      }
      
      public function startApplication() : void
      {
         eventManager.cleanUp(sEVENT_PRELOAD_ID);
         if(this.nPendingSlot != -1)
         {
            this.oLoadGameRequest = new LoadGameRequest(this.nPendingSlot);
            eventManager.addEventListener(sEVENT_PRELOAD_ID,this.oLoadGameRequest,GameLoadEvent.LOAD_COMPLETE,this.onGameLoaded);
         }
         else
         {
            ProxyManager.instance.onGameCreated();
            StepManager.instance.start();
         }
      }
      
      public function showPopup(_sPopupViewID:String, _bTransitionPauseable:Boolean = true) : void
      {
         this.oViewManager.showView(_sPopupViewID,sLAYER_POPUP,-1,0,0,null,_bTransitionPauseable);
      }
      
      public function showConfirmPopup(_sTitleID:String, _sTextID:String, _sConfirmID:String, _sCancelID:String, _nRatioConfirm:Number = 1, _bTransitionPauseable:Boolean = true) : void
      {
         var _oPopup:ConfirmPopup = this.oViewManager.getView(sPOPUP_CONFIRM) as ConfirmPopup;
         _oPopup.setupLocale(_sTitleID,_sTextID,_sConfirmID,_sCancelID,_nRatioConfirm);
         this.showPopup(sPOPUP_CONFIRM,_bTransitionPauseable);
      }
      
      public function showMessagePopup(_sTitleID:String, _sTextID:String, _sBtnID:String = null, _oReplacement:Object = null) : void
      {
         var _oPopup:MessagePopup = this.oViewManager.getView(sPOPUP_MESSAGE) as MessagePopup;
         _oPopup.setupLocale(_sTitleID,_sTextID,_sBtnID,_oReplacement);
         this.showPopup(sPOPUP_MESSAGE,false);
      }
      
      public function hidePopup(_sPopupViewID:String) : void
      {
         this.oViewManager.hideView(_sPopupViewID);
      }
      
      private function showPreloadError(_sMessage:String) : void
      {
         eventManager.cleanUp(sEVENT_PRELOAD_ID);
         var _oLoadingScreen:LoadedScreen = this.oViewManager.getView(sSCREEN_LOADED) as LoadedScreen;
         if(Boolean(_oLoadingScreen))
         {
            _oLoadingScreen.showError(_sMessage,Boolean(loaderInfo.parameters.debug == "true"));
            return;
         }
         throw new Error(_sMessage);
      }
      
      private function loadExternalConfig() : void
      {
         var _sConfigPath:String = loaderInfo.parameters["configPath"];
         if(_sConfigPath == null || _sConfigPath == "")
         {
            _sConfigPath = this.sDataPath + ExternalConfig.sDEFAULT_CONFIG_PATH;
         }
         eventManager.addEventListener(sEVENT_PRELOAD_ID,ExternalConfig.instance,Event.COMPLETE,this.onExternalConfigLoaded);
         eventManager.addEventListener(sEVENT_PRELOAD_ID,ExternalConfig.instance,PreloadEvent.ERROR,this.onConfigLoadError);
         ExternalConfig.instance.loadConfig(_sConfigPath);
      }
      
      private function initGameData() : void
      {
         var _sBuilder:String = loaderInfo.parameters.builderType;
         if(_sBuilder == null || _sBuilder == "")
         {
            if(!Boolean(ServiceManager.instance.fakedServicePath))
            {
               throw new Error("Unable to find flashVar \'builderType\'");
            }
            _sBuilder = "platform";
         }
         this.sLanguage = loaderInfo.parameters.language;
         var _sProperty:String = loaderInfo.parameters.propertyAlias;
         if(_sProperty == null || _sProperty == "")
         {
            if(!Boolean(ServiceManager.instance.fakedServicePath))
            {
               throw new Error("Unable to find flashVar \'propertyAlias\'");
            }
            _sProperty = "gb_danimals";
         }
         if(this.sLanguage == null || this.sLanguage == "")
         {
         }
         this.oGameData = new GameData();
         this.oGameData.builderAlias = _sBuilder;
         this.oGameData.propertyAlias = _sProperty;
      }
      
      private function initLoadingScreen() : void
      {
         var _sPath:String = ExternalConfig.instance.getProperty(CommonConfig.sCONFIG_ASSETS_PATH) + "/" + this.oGameData.builderAlias + "/" + this.oGameData.propertyAlias + "/uiCommon/preloaderLib.swf";
         AssetManager.instance.addDisplayAsset(CommonConfig.sPRELOADER_ASSET_ID,_sPath,AssetLocation.EXTERNAL,true,true);
         this.oViewManager.addView(sSCREEN_LOADED,new LoadedScreen());
         this.oViewManager.showView(sSCREEN_LOADED,sLAYER_SCREEN);
      }
      
      private function initProxy() : void
      {
         eventManager.addEventListener(sEVENT_PRELOAD_ID,ProxyManager.instance,ProxyManager.PROXY_LOADED,this.onProxyLoaded);
         eventManager.addEventListener(sEVENT_PRELOAD_ID,ProxyManager.instance,IOErrorEvent.IO_ERROR,this.onProxyLoadError);
         ProxyManager.instance.load();
      }
      
      private function initServices() : void
      {
         ServiceManager.instance.addService(new GameDataService());
         ServiceManager.instance.addService(new MediaService());
         ServiceManager.instance.addService(new BuilderService());
      }
      
      private function loadSoundConfig() : void
      {
         eventManager.addEventListener(sEVENT_PRELOAD_ID,SfxManager.instance,Event.COMPLETE,this.onSoundConfigLoaded);
         eventManager.addEventListener(sEVENT_PRELOAD_ID,SfxManager.instance,PreloadEvent.ERROR,this.onConfigLoadError);
         SfxManager.instance.loadSoundConfig(this.sDataPath + CommonConfig.sPATH_CONFIG_SFX + this.oGameData.builderAlias + "_" + this.oGameData.propertyAlias + ".xml");
      }
      
      private function loadPropertyConfig() : void
      {
         eventManager.addEventListener(sEVENT_PRELOAD_ID,ExternalConfig.instance,Event.COMPLETE,this.onPropertyConfigLoaded);
         eventManager.addEventListener(sEVENT_PRELOAD_ID,ExternalConfig.instance,PreloadEvent.ERROR,this.onConfigLoadError);
         ExternalConfig.instance.loadConfig(this.sDataPath + CommonConfig.sPATH_CONFIG_PROPERTY + this.oGameData.builderAlias + "_" + this.oGameData.propertyAlias + ".xml");
      }
      
      private function initLocalizationManager() : void
      {
         LocalizationManager.instance.defaultFontDirectory = this.sDataPath + LocalizationManager.instance.defaultFontDirectory;
         LocalizationManager.instance.defaultStringDirectory = this.sDataPath + CommonConfig.sPATH_STRINGS;
         if(this.sLanguage != null)
         {
            LocalizationManager.instance.defaultStringFileName = this.oGameData.builderAlias + "_" + this.oGameData.propertyAlias + "_" + this.sLanguage + ".xml";
         }
         else
         {
            LocalizationManager.instance.defaultStringFileName = this.oGameData.builderAlias + "_" + this.oGameData.propertyAlias + ".xml";
         }
         LocalizationManager.instance.loadLocalizedString();
         LocalizationManager.instance.addEventListener(LocalizationEvent.STRINGS_READY,this.onLocalizationReady);
         LocalizationManager.instance.addEventListener(PreloadEvent.ERROR,this.onLocaleLoadError);
      }
      
      private function loadMediaList() : void
      {
         eventManager.addEventListener(sEVENT_PRELOAD_ID,MediaManager.instance,MediaEvent.LIST_LOAD_COMPLETE,this.onMediaListLoaded);
         eventManager.addEventListener(sEVENT_PRELOAD_ID,MediaManager.instance,MediaEvent.LIST_LOAD_ERROR,this.onMediaError);
         MediaManager.instance.loadMediaList(this.oGameData.builderAlias,this.oGameData.propertyAlias);
      }
      
      private function loadPreviewMedias() : void
      {
         MediaManager.instance.addMediaToLoad(this.oMediaList.medias,true);
         eventManager.addEventListener(sEVENT_PRELOAD_ID,MediaManager.instance,MediaEvent.MEDIA_ALL_LOAD_COMPLETE,this.onPreviewMediaLoaded);
         eventManager.addEventListener(sEVENT_PRELOAD_ID,MediaManager.instance,MediaEvent.MEDIA_LOAD_ERROR,this.onMediaError);
         MediaManager.instance.startMediaLoading();
      }
      
      private function renderPreviewMedias() : void
      {
         MediaManager.instance.addMediaToRender(this.oMediaList.medias,true);
         eventManager.addEventListener(sEVENT_PRELOAD_ID,MediaManager.instance,MediaEvent.MEDIA_ALL_RENDERED,this.onPreviewMediaRendered);
         eventManager.addEventListener(sEVENT_PRELOAD_ID,MediaManager.instance,MediaEvent.MEDIA_RENDER_ERROR,this.onMediaError);
         MediaManager.instance.startMediaRendering();
      }
      
      private function preloadExternalAssets() : void
      {
         var _sFile:String = null;
         ExternalAssetManager.instance.fileDirectory = ExternalConfig.instance.getProperty(CommonConfig.sCONFIG_ASSETS_PATH) + "/" + this.oGameData.builderAlias + "/" + this.oGameData.propertyAlias;
         ExternalAssetManager.instance.addCategory(BuilderConfig.sASSET_CATEGORY_APPLICATION);
         for each(_sFile in BuilderConfig.aEXTERNAL_ASSETS)
         {
            ExternalAssetManager.instance.addFile(BuilderConfig.sASSET_CATEGORY_APPLICATION,_sFile);
         }
         eventManager.addEventListener(sEVENT_PRELOAD_ID,ExternalAssetManager.instance,ExternalAssetEvent.COMPLETE,this.onExternalAssetLoaded);
         ExternalAssetManager.instance.start();
      }
      
      private function initSoundManager() : void
      {
         SoundManager.instance.addCategory(SoundConfig.sSOUND_CATEGORY_MUSIC);
         SoundManager.instance.addCategory(SoundConfig.sSOUND_CATEGORY_SOUNDS);
         SoundManager.instance.setRelativeVolume(SoundConfig.sSOUND_CATEGORY_MUSIC,SoundConfig.nDEFAULT_VOLUME_MUSIC);
         SoundManager.instance.setRelativeVolume(SoundConfig.sSOUND_CATEGORY_SOUNDS,SoundConfig.nDEFAULT_VOLUME_SOUNDS);
         AbstractControl.setDefaultSoundClick(AssetReference.fromLibraryClass(SoundConfig.cSFX_MOUSE_CLICK),SoundConfig.sSOUND_CATEGORY_SOUNDS,1);
         AbstractControl.setDefaultSoundRoll(AssetReference.fromLibraryClass(SoundConfig.cSFX_MOUSE_ROLL),SoundConfig.sSOUND_CATEGORY_SOUNDS,1);
         AbstractInOutView.setDefaultInSound(AssetReference.fromLibraryClass(SoundConfig.cSFX_POPUP_IN),SoundConfig.sSOUND_CATEGORY_SOUNDS,1);
         AbstractInOutView.setDefaultOutSound(AssetReference.fromLibraryClass(SoundConfig.cSFX_POPUP_OUT),SoundConfig.sSOUND_CATEGORY_SOUNDS,1);
         try
         {
            this.cTransitionIn = getDefinitionByName(SoundConfig.sSFX_TRANSITION_IN) as Class;
         }
         catch(_e:Error)
         {
            Logger.instance.logInfo("No in transition sfx");
         }
         try
         {
            this.cTransitionOut = getDefinitionByName(SoundConfig.sSFX_TRANSITION_OUT) as Class;
         }
         catch(_e:Error)
         {
            Logger.instance.logInfo("No out transition sfx");
         }
         this.initAutoBalanceSounds(BuilderSoundConfig.aSND_ELEMENT_DROP,BuilderSoundConfig.aSND_ELEMENT_ERASE,BuilderSoundConfig.aSND_ELEMENT_GRAB);
      }
      
      private function initAutoBalanceSounds(... args) : void
      {
         var _aSounds:Array = null;
         var _oClass:Class = null;
         for each(_aSounds in args)
         {
            for each(_oClass in _aSounds)
            {
               SoundManager.instance.enableVolumeAutoBalance(AssetReference.fromLibraryClass(_oClass));
            }
         }
      }
      
      private function initViewManager() : void
      {
         this.oViewManager = ViewManager.instance;
         this.initLayers();
         addChild(this.oViewManager);
      }
      
      private function initLayers() : void
      {
         this.oViewManager.depthManager.addLayer(sLAYER_SCREEN);
         this.oViewManager.depthManager.addLayer(sLAYER_SELECTION_WHEEL);
         this.oViewManager.depthManager.addLayer(sLAYER_HEADER);
         this.oViewManager.depthManager.addLayer(sLAYER_POPUP);
         this.oViewManager.depthManager.addLayer(sLAYER_LOADING);
      }
      
      private function initTransitions() : void
      {
         this.oViewManager.addAnimTransition(sDEFAULT_TRANSITION_IN,AssetReference.fromLibraryClass(mcTransitionIn));
         this.oViewManager.addAnimTransition(sDEFAULT_TRANSITION_OUT,AssetReference.fromLibraryClass(mcTransitionOut));
      }
      
      private function initPopups() : void
      {
         var _oHelpPopup:HelpPopup = new HelpPopup();
         this.oViewManager.addView(sPOPUP_HELP,_oHelpPopup);
         eventManager.addEventListener(sEVENT_MANAGER_ID,_oHelpPopup,PopupEvent.REQUEST_HIDE,this.onRequestHidePopup);
         var _oMenuPopup:MenuPopup = new MenuPopup("id_ui_popup_menu_button_quit_builder");
         this.oViewManager.addView(sPOPUP_MENU,_oMenuPopup);
         eventManager.addEventListener(sEVENT_MANAGER_ID,_oMenuPopup,PopupEvent.REQUEST_HIDE,this.onRequestHidePopup);
         eventManager.addEventListener(sEVENT_MANAGER_ID,_oMenuPopup,GamePlayerEvent.REQUEST_GAME_QUIT,this.onRequestQuit);
         eventManager.addEventListener(sEVENT_MANAGER_ID,_oMenuPopup,GamePlayerEvent.REQUEST_GAME_HELP,this.onRequestHelp);
         var _oQuitPopup:QuitPopup = new QuitPopup("id_ui_popup_quit_title_builder","id_ui_popup_quit_text_builder");
         this.oViewManager.addView(sPOPUP_QUIT,_oQuitPopup);
         eventManager.addEventListener(sEVENT_MANAGER_ID,_oQuitPopup,PopupEvent.REQUEST_HIDE,this.onRequestHidePopup);
         eventManager.addEventListener(sEVENT_MANAGER_ID,_oQuitPopup,GamePlayerEvent.REQUEST_GAME_QUIT,this.onQuitConfirm);
         eventManager.addEventListener(sEVENT_MANAGER_ID,_oQuitPopup,GamePlayerEvent.CANCEL_GAME_QUIT,this.onQuitCancel);
         var _oConfirmPopup:ConfirmPopup = new ConfirmPopup();
         this.oViewManager.addView(sPOPUP_CONFIRM,_oConfirmPopup);
         var _oSavePopup:SavePopup = new SavePopup();
         this.oViewManager.addView(sPOPUP_SAVE,_oSavePopup);
         var _oLoadConfirmPopup:LoadConfirmPopup = new LoadConfirmPopup();
         this.oViewManager.addView(sPOPUP_LOAD_CONFIRM,_oLoadConfirmPopup);
         var _oErrorPopup:MessagePopup = new MessagePopup();
         this.oViewManager.addView(sPOPUP_MESSAGE,_oErrorPopup);
      }
      
      private function onExternalConfigLoaded(_e:Event) : void
      {
         eventManager.cleanUp(sEVENT_PRELOAD_ID);
         this.initGameData();
         this.initLoadingScreen();
         this.initServices();
         this.initProxy();
      }
      
      private function onProxyLoaded(_e:Event) : void
      {
         eventManager.addEventListener(sEVENT_MANAGER_ID,ProxyManager.instance,GameLoadEvent.REQUEST_LOAD,this.onRequestLoad);
         this.loadSoundConfig();
      }
      
      private function onSoundConfigLoaded(_e:Event) : void
      {
         this.loadPropertyConfig();
      }
      
      private function onPropertyConfigLoaded(_e:Event) : void
      {
         this.initLocalizationManager();
      }
      
      private function onLocalizationReady(_e:LocalizationEvent) : void
      {
         dispatchEvent(new Event(sAPPLICATION_LOADED));
         this.preloadExternalAssets();
      }
      
      private function onExternalAssetLoaded(_e:ExternalAssetEvent) : void
      {
         if(ExternalAssetManager.instance.isCategoriesReady(BuilderConfig.sASSET_CATEGORY_APPLICATION))
         {
            this.initSoundManager();
            this.initTransitions();
            this.initPopups();
            this.tooltipManager.delay = 2;
            ToolTipManager.instance(stage).setConfiguration(AssetReference.fromLibraryClass(mcToolTip));
            ToolTipManager.instance(stage).maxWidth = 250;
            this.loadMediaList();
            dispatchEvent(new Event(sASSETS_LOADED));
         }
      }
      
      private function onMediaListLoaded(_e:Event) : void
      {
         eventManager.cleanUp(sEVENT_PRELOAD_ID);
         this.oMediaList = MediaManager.instance.getMediaList(this.oGameData.builderAlias,this.oGameData.propertyAlias);
         this.oGameData.sfxAlias = SfxMedia(this.oMediaList.getMediaFromType([SfxMedia.TYPE])[0]).alias;
         this.loadPreviewMedias();
      }
      
      private function onPreviewMediaLoaded(_e:Event) : void
      {
         this.renderPreviewMedias();
         dispatchEvent(new Event(sMEDIAS_LOADED));
      }
      
      private function onPreviewMediaRendered(_e:Event) : void
      {
         this.bGameLoaded = true;
         dispatchEvent(new Event(sMEDIAS_RENDERED));
      }
      
      private function onRequestLoad(_e:GameLoadEvent) : void
      {
         this.nPendingSlot = _e.slotID;
         if(this.bGameLoaded)
         {
            this.showPopup(sPOPUP_LOAD_CONFIRM,false);
         }
      }
      
      private function onGameLoaded(_e:GameLoadEvent) : void
      {
         this.nSlot = this.oLoadGameRequest.slotID;
         this.nPendingSlot = -1;
         this.templateData = this.oLoadGameRequest.templateData;
         this.gameData = this.oLoadGameRequest.gameData;
         eventManager.clearByTarget(this.oLoadGameRequest);
         if(Boolean(this.oLoadGameRequest))
         {
            this.oLoadGameRequest.destroy();
         }
         this.oLoadGameRequest = null;
      }
      
      private function onCheat(_e:CheatEvent) : void
      {
         switch(_e.ID)
         {
            case "loadSlot0":
               ProxyManager.instance.onLoadGame(0);
               break;
            case "loadSlot1":
               ProxyManager.instance.onLoadGame(1);
               break;
            case "loadSlot2":
               ProxyManager.instance.onLoadGame(2);
               break;
            case "loadSlot3":
               ProxyManager.instance.onLoadGame(3);
               break;
            case "loadSlot4":
               ProxyManager.instance.onLoadGame(4);
               break;
            case "loadSlot5":
               ProxyManager.instance.onLoadGame(5);
         }
      }
      
      private function onTransitionStartEnd(_e:TransitionEvent) : void
      {
         if(_e.transitionID == sDEFAULT_TRANSITION_IN)
         {
            if(Boolean(this.oTransitionIn))
            {
               this.oTransitionIn.start();
            }
            else if(Boolean(this.cTransitionIn))
            {
               this.oTransitionIn = SoundManager.instance.play(SoundConfig.sSOUND_CATEGORY_SOUNDS,AssetReference.fromLibraryClass(this.cTransitionIn),1,1,false);
            }
         }
         else if(_e.transitionID == sDEFAULT_TRANSITION_OUT)
         {
            if(Boolean(this.oTransitionOut))
            {
               this.oTransitionOut.start();
            }
            else if(Boolean(this.cTransitionOut))
            {
               this.oTransitionOut = SoundManager.instance.play(SoundConfig.sSOUND_CATEGORY_SOUNDS,AssetReference.fromLibraryClass(this.cTransitionOut),1,1,false);
            }
         }
      }
      
      private function onRequestHelp(_e:GamePlayerEvent) : void
      {
         this.showPopup(sPOPUP_HELP,false);
      }
      
      private function onRequestQuit(_e:GamePlayerEvent) : void
      {
         this.showPopup(sPOPUP_QUIT,false);
         var _oMenu:MenuPopup = this.oViewManager.getView(sPOPUP_MENU) as MenuPopup;
         _oMenu.mcState.transform.colorTransform = CommonConfig.oINACTIVE_COLOR_TRANSFORM;
      }
      
      private function onQuitConfirm(_e:GamePlayerEvent) : void
      {
         StepManager.instance.gotoStep(StepManager.sSTEP_BUILDER);
      }
      
      private function onQuitCancel(_e:GamePlayerEvent) : void
      {
         var _oMenu:MenuPopup = this.oViewManager.getView(sPOPUP_MENU) as MenuPopup;
         _oMenu.mcState.transform.colorTransform = new ColorTransform();
         this.hidePopup(sPOPUP_QUIT);
      }
      
      private function onRequestShowPopup(_e:PopupEvent) : void
      {
         this.showPopup(_e.sPopupViewID,false);
      }
      
      private function onRequestHidePopup(_e:PopupEvent) : void
      {
         this.hidePopup(_e.sPopupViewID);
      }
      
      public function onPublish() : void
      {
         this.oTemplateData = null;
         this.initGameData();
         ProxyManager.instance.onGameCreated();
         StepManager.instance.reset();
         StepManager.instance.start();
      }
      
      private function onConfigLoadError(_e:PreloadEvent) : void
      {
         this.showPreloadError(_e.error);
      }
      
      private function onLocaleLoadError(_e:PreloadEvent) : void
      {
         this.showPreloadError(_e.error);
      }
      
      private function onProxyLoadError(_e:IOErrorEvent) : void
      {
         this.showPreloadError(_e.text);
      }
      
      private function onMediaError(_e:MediaEvent) : void
      {
         this.showPreloadError(_e.errorMessage);
      }
      
      public function get gameData() : GameData
      {
         return this.oGameData;
      }
      
      public function set gameData(value:GameData) : void
      {
         this.oGameData = value;
         var _oCurrentStep:StepDefinition = StepManager.instance.currentStep;
         if(Boolean(_oCurrentStep) && Boolean(_oCurrentStep.id != StepManager.sSTEP_TEST) && _oCurrentStep.id != StepManager.sSTEP_PUBLISH)
         {
            BuilderManager.instance.builderData = new BuilderData(this.oGameData);
            BuilderManager.instance.updateBackground();
         }
         SfxManager.instance.playMusic(this.oMediaList.getMedia(this.oGameData.musicAlias) as MusicMedia);
         StepManager.instance.onGameLoading();
      }
      
      public function get mediaList() : MediaList
      {
         return this.oMediaList;
      }
      
      public function get templateData() : TemplateData
      {
         return this.oTemplateData;
      }
      
      public function set templateData(value:TemplateData) : void
      {
         this.oTemplateData = value;
      }
      
      public function get tooltipManager() : ToolTipManager
      {
         return ToolTipManager.instance(stage);
      }
      
      public function get builderPath() : String
      {
         return loaderInfo.parameters["builderPath"];
      }
      
      public function get category() : String
      {
         return loaderInfo.parameters["category"];
      }
   }
}

