package
{
   import assets.ExternalAssetManager;
   import assets.events.ExternalAssetEvent;
   import builderManager.BuilderData;
   import builderManager.BuilderManager;
   import builderManager.ToolManager;
   import ui.selectionGrid.LibraryItemDefinition;
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
   import flash.display.MovieClip;
   import flash.events.KeyboardEvent;
   import flash.geom.Point;
   import flash.events.MouseEvent;
   import flash.net.FileReference;
   import data.GameDataElement;
   import media.type.TileSurfaceMedia;
   import builderManager.elements.BuilderElement;
   import flash.geom.Rectangle;
   import flash.geom.Matrix;
   import com.sarbakan.sbdk.blitting.core.BitmapDataCollection;
   import com.sarbakan.sbdk.blitting.core.ColliderInfo;
   import com.sarbakan.sbdk.math.SBKMath;
   import flash.utils.setTimeout;
   import gamePlayer.GamePlayer;
   import media.type.PlayableCharacterMedia;
   import com.sarbakan.sbdk.blitting.core.VectorToBitmapConverter;
   import com.sarbakan.sbdk.events.BitmappedEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.events.KeyboardEvent;
   import flash.utils.getTimer;
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
      
      public var editorPrototype:Boolean = true;
      private var editorSurface:MovieClip;
      private var editorToolbar:MovieClip;
      private var editorStatus:TextField;
      private var editorTool:String = "Paint";
      private var editorMusicPacks:Array = ["01","06","07","08","09","10","11","12","14","15","16","17","18"];
      private var editorMusicIndex:int = 0;
      private var editorMusic:MusicMedia;
      private var editorTesting:Boolean = false;
      private var editorHeld:Boolean = false;
      private var editorLastCell:String = "";
      private var editorFile:FileReference;
      private var harnessMedia:PlayableCharacterMedia;
      private var harnessGame:GamePlayer;
      private var harnessClip:MovieClip;
      private var diagnosticText:TextField;
      private var diagnosticHistory:String = "";
      private var diagnosticStarted:int = 0;

      public function diagnosticLog(message:String) : void
      {
         var line:String = "[" + (getTimer() - diagnosticStarted) + "ms] " + message;
         diagnosticHistory += line + "\n";
         trace(line);
         if(diagnosticText != null)
         {
            diagnosticText.text = diagnosticHistory;
            diagnosticText.scrollV = diagnosticText.maxScrollV;
         }
      }

      private function diagnosticError(event:Event) : void
      {
         if(diagnosticText != null) diagnosticText.visible=true;
         var detail:Object = Object(event)["error"];
         diagnosticLog("UNCAUGHT ERROR: " + String(detail));
         if(detail is Error)
         {
            var stack:String = detail.getStackTrace();
            if(stack != null) diagnosticLog(stack);
         }
      }

      private function diagnosticTop(event:Event) : void
      {
         if(stage != null && diagnosticText != null && diagnosticText.parent == stage)
            stage.setChildIndex(diagnosticText,stage.numChildren - 1);
      }

      private function diagnosticKey(event:KeyboardEvent) : void
      {
         if(event.keyCode == 113 && diagnosticText != null)
            diagnosticText.visible = !diagnosticText.visible;
      }

      private function diagnosticInit() : void
      {
         diagnosticText = new TextField();
         diagnosticText.defaultTextFormat = new TextFormat("_typewriter",13,0xFFFFFF);
         diagnosticText.background = true;
         diagnosticText.backgroundColor = 0x17212B;
         diagnosticText.multiline = true;
         diagnosticText.wordWrap = true;
         diagnosticText.selectable = true;
         diagnosticText.width = 960;
         diagnosticText.height = 150;
         stage.addChild(diagnosticText);
         addEventListener(Event.ENTER_FRAME,diagnosticTop);
         stage.addEventListener(KeyboardEvent.KEY_DOWN,diagnosticKey);
         diagnosticLog("EDITOR PROTOTYPE v2 - original BuilderManager, BuilderData and BuilderRenderer. F2 toggles log.");
         diagnosticLog("Select log text and copy with Ctrl+C. Mouse wheel scrolls history.");
         diagnosticLog("SWF: " + loaderInfo.url);
      }

      public function BuilderMain()
      {
         super();
         diagnosticStarted = getTimer();
         Object(loaderInfo)["uncaughtErrorEvents"].addEventListener("uncaughtError",diagnosticError);
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
         diagnosticInit();
         diagnosticLog("ENTER init");
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
      
      private function harnessRenderError(event:Event) : void
      {
         diagnosticLog("RENDER ERROR: " + event.toString());
      }
      private function harnessRendered(event:Event) : void
      {
         if(event != null) event.target.removeEventListener(BitmappedEvent.ALL_COMPLETE,harnessRendered);
         var musicXml:String='';
         for each(var pack:String in editorMusicPacks) musicXml+='<media alias="gs_sb_musicPack'+pack+'New"/>';
         oMediaList = new MediaList("spongebob","gb_danimals",'<response><medias><element name="playableCharacter"><media alias="__harness"/></element><element name="tileSurface"><media alias="__editor_floor"/></element><element name="music">'+musicXml+'</element></medias></response>');
         oGameData.heroAlias = "__harness";
         oGameData.backgroundAlias = null;
         oGameData.title = "Restoration test level";
         oGameData.levelElements = [new GameDataElement("__harness",90,300,false,null)];
         for(var x:int = 0; x < 960; x += 30) oGameData.levelElements.push(new GameDataElement("__editor_floor",x,420,false,"mcPlatform_tile03"));
         setupEditorToolbar();
         openEditor();
         stage.addEventListener(MouseEvent.MOUSE_UP,editorMouseUp);
         stage.addEventListener(KeyboardEvent.KEY_DOWN,harnessKey);
         diagnosticText.visible = false;
         diagnosticLog("EDITOR READY: original ToolManager, placement/data/renderer active. Move selects and drags; Hero centers camera.");
         selectEditorMusic();
      }
      private function setupEditorToolbar() : void
      {
         editorToolbar = new MovieClip(); addChild(editorToolbar);
         var names:Array = ["Paint","Erase","Move","Hero","Zoom","Test / Edit","Export XML","Music >","Mute"];
         for(var i:int=0;i<names.length;i++)
         {
            var button:TextField = new TextField(); button.name=names[i]; button.text=names[i];
            button.defaultTextFormat=new TextFormat("_sans",16,0xFFFFFF); button.setTextFormat(button.defaultTextFormat);
            button.background=true; button.backgroundColor=0x29485D; button.selectable=false;
            button.x=12+i*104; button.y=8; button.width=100; button.height=30;
            button.addEventListener(MouseEvent.CLICK,editorAction); editorToolbar.addChild(button);
         }
         editorStatus=new TextField(); editorStatus.defaultTextFormat=new TextFormat("_sans",14,0xFFFFFF);
         editorStatus.x=12; editorStatus.y=40; editorStatus.width=935; editorStatus.height=26; editorStatus.selectable=false;
         editorToolbar.addChild(editorStatus);
      }
      private function editorAction(event:MouseEvent) : void
      {
         var action:String=event.currentTarget.name;
         if(action == "Music >") { editorMusicIndex=(editorMusicIndex+1)%editorMusicPacks.length; selectEditorMusic(); return; }
         if(action == "Mute")
         {
            if(SoundManager.instance.isMuted(SoundConfig.sSOUND_CATEGORY_MUSIC)) SoundManager.instance.unmute(SoundConfig.sSOUND_CATEGORY_MUSIC);
            else SoundManager.instance.mute(SoundConfig.sSOUND_CATEGORY_MUSIC);
            TextField(event.currentTarget).text=SoundManager.instance.isMuted(SoundConfig.sSOUND_CATEGORY_MUSIC) ? "Unmute" : "Mute";
            return;
         }
         if(action == "Test / Edit") { toggleEditorTest(); return; }
         if(editorTesting) return;
         if(action == "Export XML")
         {
            BuilderManager.instance.builderData.copyToGameData(oGameData);
            editorFile=new FileReference(); editorFile.save(oGameData.xmlOut(),"restored-level.xml"); return;
         }
         if(action == "Zoom") { ToolManager.instance.editorZoom(); return; }
         if(action == "Hero") { BuilderManager.instance.targetHero(); return; }
         editorTool=action; selectEditorTool(); editorStatus.text="Tool: "+editorTool+" — click or drag on the grid. Uses original placement and tile-neighbor logic.";
      }
      private function selectEditorMusic() : void
      {
         var alias:String="gs_sb_musicPack"+editorMusicPacks[editorMusicIndex]+"New";
         editorMusic=oMediaList.getMedia(alias) as MusicMedia;
         oGameData.musicAlias=alias;
         editorStatus.text="Loading original music pack "+editorMusicPacks[editorMusicIndex]+"...";
         if(editorMusic.gameLoaded) { playEditorMusic(); return; }
         editorMusic.gameLoader.addEventListener(PreloadEvent.COMPLETE,editorMusicLoaded);
         editorMusic.gameLoader.addEventListener(PreloadEvent.ERROR,editorMusicError);
         if(!editorMusic.gameLoader.isLoading) editorMusic.gameLoader.start();
      }
      private function editorMusicLoaded(event:PreloadEvent) : void
      {
         event.target.removeEventListener(PreloadEvent.COMPLETE,editorMusicLoaded);
         event.target.removeEventListener(PreloadEvent.ERROR,editorMusicError);
         if(event.target == editorMusic.gameLoader) playEditorMusic();
      }
      private function editorMusicError(event:PreloadEvent) : void
      {
         event.target.removeEventListener(PreloadEvent.COMPLETE,editorMusicLoaded);
         event.target.removeEventListener(PreloadEvent.ERROR,editorMusicError);
         diagnosticLog("MUSIC LOAD ERROR: "+event.toString());
         diagnosticText.visible=true;
         if(event.target == editorMusic.gameLoader) editorStatus.text="Music could not load. F2: details; Music > tries another track.";
      }
      private function playEditorMusic() : void
      {
         SfxManager.instance.playMusic(editorMusic);
         editorStatus.text="Original music pack "+editorMusicPacks[editorMusicIndex]+" — Music > changes track; Mute toggles audio.";
         diagnosticLog("MUSIC: "+editorMusic.alias+" playing through original SfxManager.");
      }
      private function openEditor() : void
      {
         editorSurface=new MovieClip(); editorSurface.x=96; editorSurface.y=70; addChild(editorSurface);
         var area:MovieClip=new MovieClip(); area.name="mcRenderArea"; area.graphics.beginFill(0xC8E3EC); area.graphics.drawRect(0,0,768,400); area.graphics.endFill();
         editorSurface.addChild(area); editorSurface["mcRenderArea"]=area;
         var goal:MovieClip=new MovieClip(); var icon:MovieClip=new MovieClip(); var textClip:MovieClip=new MovieClip(); var count:TextField=new TextField();
         textClip["txtText"]=count; textClip.addChild(count); goal["mcIcon"]=icon; goal.addChild(icon); goal["mcText"]=textClip; goal.addChild(textClip);
         editorSurface["mcGoalDisplay"]=goal; editorSurface.addChild(goal);
         new BuilderManager(editorSurface);
         BuilderManager.instance.renderer.updateCenterPos(480,250);
         ToolManager.instance.init(); selectEditorTool();
         editorStatus.text="Original tools: Move drags objects or pans empty space. Arrows scroll. Hero centers view. F2: logs.";
         setChildIndex(editorToolbar,numChildren-1);
      }
      private function selectEditorTool() : void
      {
         if(editorTool == "Paint") ToolManager.instance.selectedItem=new LibraryItemDefinition(oMediaList.getMedia("__editor_floor"),"mcPlatform_tile03");
         else ToolManager.instance.currentTool=editorTool == "Erase" ? ToolManager.TOOL_ERASE : ToolManager.TOOL_NONE;
      }
      private function editorMouseUp(event:MouseEvent) : void { editorHeld=false; }
      private function toggleEditorTest() : void
      {
         editorHeld=false;
         if(!editorTesting)
         {
            BuilderManager.instance.builderData.copyToGameData(oGameData);
            ToolManager.instance.destroy(); BuilderManager.instance.destroy(); removeChild(editorSurface); editorSurface=null;
            harnessClip=new MovieClip(); addChild(harnessClip);
            harnessGame=new GamePlayer(harnessClip,oGameData); harnessGame.initElementsCreation();
            editorTesting=true; editorStatus.text="TEST: arrows/A-D move, Space jumps, R restarts. Test / Edit returns to your layout.";
            setChildIndex(editorToolbar,numChildren-1); stage.focus=stage;
         }
         else
         {
            diagnosticLog("RETURN TO EDIT: disposing test session.");
            harnessGame.editorDispose(); harnessGame=null; removeChild(harnessClip); harnessClip=null;
            editorTesting=false; openEditor();
            diagnosticLog("RETURN TO EDIT: editor restored.");
         }
      }
      private function harnessKey(event:KeyboardEvent) : void
      {
         if(event.keyCode == 82 && harnessGame != null)
         {
            harnessGame.editorDispose(); removeChild(harnessClip);
            harnessClip=new MovieClip(); addChild(harnessClip);
            harnessGame=new GamePlayer(harnessClip,oGameData); harnessGame.initElementsCreation();
            setChildIndex(editorToolbar,numChildren-1);
         }
      }
      public function startApplication() : void
      {
         diagnosticLog("ENTER startApplication");
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
         diagnosticLog("PRELOAD ERROR: " + _sMessage);
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
         diagnosticLog("ENTER loadExternalConfig");
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
         diagnosticLog("ENTER initGameData");
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
         diagnosticLog("ENTER initLoadingScreen");
         var _sPath:String = ExternalConfig.instance.getProperty(CommonConfig.sCONFIG_ASSETS_PATH) + "/" + this.oGameData.builderAlias + "/" + this.oGameData.propertyAlias + "/uiCommon/preloaderLib.swf";
         diagnosticLog("Loading screen asset: " + _sPath);
         diagnosticLog("Using built-in diagnostic loading view instead of missing preloaderLib.");
         this.oViewManager.addView(sSCREEN_LOADED,new LoadedScreen());
         this.oViewManager.showView(sSCREEN_LOADED,sLAYER_SCREEN);
      }
      
      private function initProxy() : void
      {
         diagnosticLog("ENTER initProxy");
         eventManager.addEventListener(sEVENT_PRELOAD_ID,ProxyManager.instance,ProxyManager.PROXY_LOADED,this.onProxyLoaded);
         eventManager.addEventListener(sEVENT_PRELOAD_ID,ProxyManager.instance,IOErrorEvent.IO_ERROR,this.onProxyLoadError);
         ProxyManager.instance.load();
      }
      
      private function initServices() : void
      {
         diagnosticLog("ENTER initServices");
         ServiceManager.instance.addService(new GameDataService());
         ServiceManager.instance.addService(new MediaService());
         ServiceManager.instance.addService(new BuilderService());
      }
      
      private function loadSoundConfig() : void
      {
         diagnosticLog("ENTER loadSoundConfig");
         eventManager.addEventListener(sEVENT_PRELOAD_ID,SfxManager.instance,Event.COMPLETE,this.onSoundConfigLoaded);
         eventManager.addEventListener(sEVENT_PRELOAD_ID,SfxManager.instance,PreloadEvent.ERROR,this.onConfigLoadError);
         SfxManager.instance.loadSoundConfig(this.sDataPath + CommonConfig.sPATH_CONFIG_SFX + this.oGameData.builderAlias + "_" + this.oGameData.propertyAlias + ".xml");
      }
      
      private function loadPropertyConfig() : void
      {
         diagnosticLog("ENTER loadPropertyConfig");
         eventManager.addEventListener(sEVENT_PRELOAD_ID,ExternalConfig.instance,Event.COMPLETE,this.onPropertyConfigLoaded);
         eventManager.addEventListener(sEVENT_PRELOAD_ID,ExternalConfig.instance,PreloadEvent.ERROR,this.onConfigLoadError);
         ExternalConfig.instance.loadConfig(this.sDataPath + CommonConfig.sPATH_CONFIG_PROPERTY + this.oGameData.builderAlias + "_" + this.oGameData.propertyAlias + ".xml");
      }
      
      private function initLocalizationManager() : void
      {
         diagnosticLog("ENTER initLocalizationManager");
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
         diagnosticLog("ENTER loadMediaList");
         eventManager.addEventListener(sEVENT_PRELOAD_ID,MediaManager.instance,MediaEvent.LIST_LOAD_COMPLETE,this.onMediaListLoaded);
         eventManager.addEventListener(sEVENT_PRELOAD_ID,MediaManager.instance,MediaEvent.LIST_LOAD_ERROR,this.onMediaError);
         MediaManager.instance.loadMediaList(this.oGameData.builderAlias,this.oGameData.propertyAlias);
      }
      
      private function loadPreviewMedias() : void
      {
         diagnosticLog("ENTER loadPreviewMedias");
         MediaManager.instance.addMediaToLoad(this.oMediaList.medias,true);
         eventManager.addEventListener(sEVENT_PRELOAD_ID,MediaManager.instance,MediaEvent.MEDIA_ALL_LOAD_COMPLETE,this.onPreviewMediaLoaded);
         eventManager.addEventListener(sEVENT_PRELOAD_ID,MediaManager.instance,MediaEvent.MEDIA_LOAD_ERROR,this.onMediaError);
         MediaManager.instance.startMediaLoading();
      }
      
      private function renderPreviewMedias() : void
      {
         diagnosticLog("ENTER renderPreviewMedias");
         MediaManager.instance.addMediaToRender(this.oMediaList.medias,true);
         eventManager.addEventListener(sEVENT_PRELOAD_ID,MediaManager.instance,MediaEvent.MEDIA_ALL_RENDERED,this.onPreviewMediaRendered);
         eventManager.addEventListener(sEVENT_PRELOAD_ID,MediaManager.instance,MediaEvent.MEDIA_RENDER_ERROR,this.onMediaError);
         MediaManager.instance.startMediaRendering();
      }
      
      private function preloadExternalAssets() : void
      {
         diagnosticLog("ENTER preloadExternalAssets");
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
         diagnosticLog("ENTER initSoundManager");
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
         diagnosticLog("ENTER initTransitions");
         this.oViewManager.addAnimTransition(sDEFAULT_TRANSITION_IN,AssetReference.fromLibraryClass(mcTransitionIn));
         this.oViewManager.addAnimTransition(sDEFAULT_TRANSITION_OUT,AssetReference.fromLibraryClass(mcTransitionOut));
      }
      
      private function initPopups() : void
      {
         diagnosticLog("ENTER initPopups");
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
         initGameData();
         diagnosticLog("Loading original physics settings; editor and website services are outside this harness.");
         loadPropertyConfig();
      }
      
      private function onProxyLoaded(_e:Event) : void
      {
         diagnosticLog("ENTER onProxyLoaded");
         eventManager.addEventListener(sEVENT_MANAGER_ID,ProxyManager.instance,GameLoadEvent.REQUEST_LOAD,this.onRequestLoad);
         this.loadSoundConfig();
      }
      
      private function onSoundConfigLoaded(_e:Event) : void
      {
         diagnosticLog("ENTER onSoundConfigLoaded");
         this.loadPropertyConfig();
      }
      
      private function prepareStaticPose(poseClass:Class,pose:MovieClip) : void
      {
         var bounds:Rectangle = pose.getBounds(pose);
         if(bounds.width <= 0 || bounds.height <= 0) throw new Error("Static pose has empty bounds.");
         var markers:Array = [pose.getChildByName("_body"),pose.getChildByName("_crouch")];
         for each(var marker:MovieClip in markers) marker.visible = false;
         var width:int = Math.ceil(bounds.width);
         var height:int = Math.ceil(bounds.height);
         var normal:BitmapData = new BitmapData(width,height,true,0);
         normal.draw(pose,new Matrix(1,0,0,1,-bounds.x,-bounds.y));
         if(normal.getColorBoundsRect(0xFF000000,0,false).isEmpty())
            throw new Error("Static pose rendered no visible pixels.");
         var flipped:BitmapData = new BitmapData(width,height,true,0);
         flipped.draw(normal,new Matrix(-1,0,0,1,width,0));
         for(var side:int = 0; side < 2; side++)
         {
            var colliders:Array = [];
            for each(var source:MovieClip in markers)
            {
               var rect:Rectangle = new Rectangle(source.x,source.y,source.width,source.height);
               if(rect.width <= 0 || rect.height <= 0) throw new Error("Empty collider " + source.name);
               if(side == 1) rect.x = -rect.right;
               var cx:Number = rect.x + rect.width/2;
               var cy:Number = rect.y + rect.height/2;
               colliders.push(new ColliderInfo(source.name.substr(1),rect,Math.sqrt(cx*cx+cy*cy),SBKMath.getAngle(0,0,cx,cy)));
            }
            var frameBounds:Rectangle = bounds.clone();
            if(side == 1) frameBounds.x = -frameBounds.right;
            var centerX:Number = frameBounds.x+frameBounds.width/2;
            var centerY:Number = frameBounds.y+frameBounds.height/2;
            BitmapDataCollection.instance.insertData(PlayableCharacterMedia.TYPE,poseClass,null,1,side == 0 ? normal : flipped,frameBounds,bounds.clone(),Math.sqrt(centerX*centerX+centerY*centerY),SBKMath.getAngle(0,0,centerX,centerY),null,colliders,side == 1);
         }
      }

      private function onPropertyConfigLoaded(_e:Event) : void
      {
         // Original GamePlayer.destroy fades music even when no tracks played.
         // Create its required categories without binding missing UI sounds.
         SoundManager.instance.addCategory(SoundConfig.sSOUND_CATEGORY_MUSIC,SoundConfig.nDEFAULT_VOLUME_MUSIC);
         SoundManager.instance.addCategory(SoundConfig.sSOUND_CATEGORY_SOUNDS,SoundConfig.nDEFAULT_VOLUME_SOUNDS);
         diagnosticLog("Physics settings loaded. Preparing procedural character and colliders.");
         harnessMedia = new PlayableCharacterMedia("__harness","");
         var testClass:Class = harnessMedia.getClass(PlayableCharacterMedia.LINKAGE_IDLE);
         var testPose:MovieClip = new testClass();
         if(testPose.getChildByName("_body") == null || testPose.getChildByName("_crouch") == null || testPose.width <= 0 || testPose.height <= 0)
            throw new Error("Harness asset contract failed: visible bounds and body/crouch markers required.");
         diagnosticLog("ASSET CHECK: visible pose and body/crouch collision markers present.");
         diagnosticLog("POSE timeline: currentFrame=" + testPose.currentFrame + " totalFrames=" + testPose.totalFrames);
         prepareStaticPose(testClass,testPose);
         diagnosticLog("STATIC FRAME READY: normal/flipped bitmap and body/crouch colliders registered.");
         harnessRendered(null);
      }
      
      private function onLocalizationReady(_e:LocalizationEvent) : void
      {
         diagnosticLog("ENTER onLocalizationReady");
         dispatchEvent(new Event(sAPPLICATION_LOADED));
         this.preloadExternalAssets();
      }
      
      private function diagnosticCheckUI() : Boolean
      {
         var required:Array = ["sndMouseRoll","sndMouseClick","sndPopupIn","sndPopupOut","mcTransitionIn","mcTransitionOut","mcToolTip","mcPopupHelp","mcPopupMenu","mcPopupQuit","mcPopupConfirm","mcPopupSave","mcPopupLoadConfirm","mcPopupMessage","mcLoadingOverlay","mcStepHeader","mcBuilderScreen"];
         var missing:Array = [];
         for each(var symbol:String in required)
         {
            try { getDefinitionByName(symbol); }
            catch(error:Error) { missing.push(symbol); }
         }
         if(missing.length == 0) return true;
         diagnosticLog("UI PREFLIGHT: " + missing.length + " missing required exported symbols (initial startup checklist, not the full asset contract).");
         for each(var absent:String in missing) diagnosticLog("MISSING UI SYMBOL: " + absent);
         showPreloadError("UI libraries downloaded but do not provide required symbols. See list above; startup remains stopped.");
         return false;
      }

      private function onExternalAssetLoaded(_e:ExternalAssetEvent) : void
      {
         diagnosticLog("ENTER onExternalAssetLoaded");
         if(ExternalAssetManager.instance.isCategoriesReady(BuilderConfig.sASSET_CATEGORY_APPLICATION))
         {
            if(!diagnosticCheckUI()) return;
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
         diagnosticLog("ENTER onMediaListLoaded");
         eventManager.cleanUp(sEVENT_PRELOAD_ID);
         this.oMediaList = MediaManager.instance.getMediaList(this.oGameData.builderAlias,this.oGameData.propertyAlias);
         this.oGameData.sfxAlias = SfxMedia(this.oMediaList.getMediaFromType([SfxMedia.TYPE])[0]).alias;
         this.loadPreviewMedias();
      }
      
      private function onPreviewMediaLoaded(_e:Event) : void
      {
         diagnosticLog("ENTER onPreviewMediaLoaded");
         this.renderPreviewMedias();
         dispatchEvent(new Event(sMEDIAS_LOADED));
      }
      
      private function onPreviewMediaRendered(_e:Event) : void
      {
         diagnosticLog("ENTER onPreviewMediaRendered");
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
