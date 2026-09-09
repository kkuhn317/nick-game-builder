package
{
   import builderManager.BuilderManager;
   import com.sarbakan.sbdk.errors.ErrorMessages;
   import com.sarbakan.sbdk.events.UIEvent;
   import com.sarbakan.sbdk.events.ViewEvent;
   import com.sarbakan.sbdk.localization.LocalizationManager;
   import com.sarbakan.sbdk.utils.EventManager;
   import com.sarbakan.sbdk.view.AbstractInOutView;
   import com.sarbakan.sbdk.view.ViewManager;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import gamePlayer.events.GamePlayerEvent;
   import tutorial.TutorialOverlay;
   import ui.StepDefinition;
   import ui.header.StepHeader;
   import ui.popups.TestLoadingPopup;
   import ui.screens.BuilderScreen;
   import ui.screens.PublishScreen;
   import ui.screens.TestScreen;
   import ui.selectionPopup.BackgroundSelectionPopup;
   import ui.selectionPopup.GoalSelectionPopup;
   import ui.selectionPopup.HeroSelectionPopup;
   import ui.selectionPopup.LayoutSelectionPopup;
   import ui.selectionPopup.MusicSelectionPopup;
   import ui.selectionPopup.ToolsPopup;
   
   public class StepManager extends EventDispatcher
   {
      
      private static var oInstance:StepManager;
      
      private static const sEVENT_MANAGER_ID:String = "eventManager";
      
      private static const sEVENT_TRANSITION_ID:String = "transitioEvent";
      
      public static const sSTEP_BACKGROUND:String = "background";
      
      public static const sSTEP_LAYOUT:String = "layout";
      
      public static const sSTEP_HERO:String = "hero";
      
      public static const sSTEP_GOAL:String = "goal";
      
      public static const sSTEP_MUSIC:String = "music";
      
      public static const sSTEP_BUILDER:String = "builder";
      
      public static const sSTEP_TEST:String = "test";
      
      public static const sSTEP_PUBLISH:String = "publish";
      
      private static const sSCREEN_HEADER:String = "screenHeader";
      
      private static const sSCREEN_TUTORIAL:String = "screenTutorial";
      
      private static const sSCREEN_BUILDER:String = "screenBuilder";
      
      private static const sSCREEN_TEST:String = "screenTest";
      
      private static const sSCREEN_PUBLISH:String = "screenPublish";
      
      private static const sPOPUP_BACKGROUND:String = "popupBackground";
      
      private static const sPOPUP_LAYOUT:String = "popupLayout";
      
      private static const sPOPUP_HERO:String = "popupHero";
      
      private static const sPOPUP_GOAL:String = "popupGoal";
      
      private static const sPOPUP_MUSIC:String = "popupMusic";
      
      private static const sPOPUP_TOOLS:String = "popupTools";
      
      private static const sPOPUP_TEST_LOADING:String = "popupTestLoading";
      
      private static var bAllowConstruction:Boolean = false;
      
      private var oEventManager:EventManager;
      
      private var oViewManager:ViewManager;
      
      private var aStepsDefinition:Array;
      
      private var nCurrentStep:int;
      
      private var nMaxStep:uint;
      
      private var oHeader:StepHeader;
      
      private var mcLoading:MovieClip;
      
      private var aDisplayedTutorial:Array;
      
      public function StepManager()
      {
         super();
         if(!bAllowConstruction)
         {
            throw new Error(ErrorMessages.sSINGLETON_ERROR);
         }
         this.init();
      }
      
      public static function get instance() : StepManager
      {
         if(!oInstance)
         {
            bAllowConstruction = true;
            oInstance = new StepManager();
            bAllowConstruction = false;
         }
         return oInstance;
      }
      
      public function destroy() : void
      {
         if(Boolean(this.oHeader))
         {
            this.oHeader.destroy();
         }
         this.oHeader = null;
         this.mcLoading = null;
         if(Boolean(this.oEventManager))
         {
            this.oEventManager.destroy();
         }
         this.oEventManager = null;
         this.oViewManager = null;
         oInstance = null;
      }
      
      public function start() : void
      {
         var _oFirstStep:StepDefinition = this.aStepsDefinition[0];
         _oFirstStep.enabled = true;
         this.gotoStep(_oFirstStep.id);
      }
      
      public function reset() : void
      {
         var _oStep:StepDefinition = null;
         this.nMaxStep = 0;
         for each(_oStep in this.aStepsDefinition)
         {
            _oStep.enabled = false;
         }
         this.oHeader.updateButtonDisplay(false);
      }
      
      public function onGameLoading() : void
      {
         this.enableStep(StepManager.sSTEP_HERO);
         this.highlightStep(StepManager.sSTEP_HERO,false);
         this.enableStep(StepManager.sSTEP_BACKGROUND);
         this.highlightStep(StepManager.sSTEP_BACKGROUND,false);
         this.enableStep(StepManager.sSTEP_LAYOUT);
         this.highlightStep(StepManager.sSTEP_LAYOUT,false);
         this.enableStep(StepManager.sSTEP_MUSIC);
         this.highlightStep(StepManager.sSTEP_MUSIC,false);
         this.enableStep(StepManager.sSTEP_GOAL);
         this.highlightStep(StepManager.sSTEP_GOAL,false);
         this.enableStep(StepManager.sSTEP_BUILDER);
         this.highlightStep(StepManager.sSTEP_BUILDER,false);
         this.enableStep(StepManager.sSTEP_TEST);
         this.highlightStep(StepManager.sSTEP_TEST,true);
         this.enableStep(StepManager.sSTEP_PUBLISH,false);
         this.highlightStep(StepManager.sSTEP_PUBLISH,false);
         if(this.currentStep == null || this.currentStep.id != sSTEP_BUILDER)
         {
            this.gotoStep(sSTEP_BUILDER);
         }
         else
         {
            BuilderManager.instance.targetHero();
         }
         this.aDisplayedTutorial = [sSTEP_BACKGROUND,sSTEP_LAYOUT,sSTEP_HERO,sSTEP_MUSIC,sSTEP_GOAL,sSTEP_BUILDER];
      }
      
      public function next() : void
      {
         var _oStep:StepDefinition = null;
         var _oMaxStep:StepDefinition = this.aStepsDefinition[this.nMaxStep];
         for(var i:uint = 0; i <= this.nMaxStep; i++)
         {
            _oStep = this.aStepsDefinition[i];
            _oStep.radio.highlight = false;
         }
         this.gotoStep(_oMaxStep.id);
      }
      
      public function showHeader() : void
      {
         this.oHeader.updateMute();
         this.oHeader.mcContent.mcNavigation.visible = true;
      }
      
      public function hideHeader() : void
      {
         this.oHeader.mcContent.mcNavigation.visible = false;
      }
      
      public function showTutorial(_bUserRequest:Boolean = false) : void
      {
         if(_bUserRequest || this.aDisplayedTutorial.indexOf(this.currentStep.id) == -1)
         {
            if(!_bUserRequest)
            {
               this.aDisplayedTutorial.push(this.currentStep.id);
            }
            this.oViewManager.showView(sSCREEN_TUTORIAL,BuilderMain.sLAYER_SCREEN);
         }
      }
      
      public function hideTutorial() : void
      {
         this.oViewManager.hideView(sSCREEN_TUTORIAL);
      }
      
      public function showLoading(_sLocale:String = null, _nX:Number = 480, _nY:Number = 250) : void
      {
         this.hideLoading();
         if(_sLocale == null)
         {
            _sLocale = "id_ui_loading_loading";
         }
         LocalizationManager.instance.setTextField(this.mcLoading.mcContent.mcText.txtText,_sLocale);
         this.mcLoading.mcContent.x = _nX;
         this.mcLoading.mcContent.y = _nY;
         this.oViewManager.depthManager.getLayer(BuilderMain.sLAYER_LOADING).addChild(this.mcLoading);
      }
      
      public function hideLoading() : void
      {
         if(Boolean(this.mcLoading.parent))
         {
            this.mcLoading.parent.removeChild(this.mcLoading);
         }
      }
      
      public function gotoStep(_sID:String) : void
      {
         var _oPreviousStep:StepDefinition = null;
         var _sCurrentView:String = null;
         var _oNextStep:StepDefinition = null;
         var _oStep:StepDefinition = null;
         this.oEventManager.cleanUp(sEVENT_TRANSITION_ID);
         if(this.nCurrentStep != -1)
         {
            _oPreviousStep = this.aStepsDefinition[this.nCurrentStep];
            _sCurrentView = _oPreviousStep.screen.ID;
         }
         else
         {
            _sCurrentView = BuilderMain.sSCREEN_LOADED;
         }
         for(var i:uint = 0; i < this.aStepsDefinition.length; i++)
         {
            _oStep = this.aStepsDefinition[i];
            if(_oStep.id == _sID)
            {
               _oNextStep = _oStep;
               this.nCurrentStep = i;
               this.oHeader.updateTitle(i + 1,_oStep);
               break;
            }
         }
         if(Boolean(_oNextStep.radio))
         {
            this.oHeader.selected = _oNextStep.radio;
         }
         if(_oNextStep.screen.ID != _sCurrentView && _oNextStep.screen.isTransiting == false)
         {
            this.oViewManager.transitView(_sCurrentView,_oNextStep.screen.ID,BuilderMain.sDEFAULT_TRANSITION_IN,BuilderMain.sDEFAULT_TRANSITION_OUT,false,true);
            this.oEventManager.addEventListener(sEVENT_TRANSITION_ID,this.oViewManager.getView(_sCurrentView),ViewEvent.HIDE,this.onTransitionDone,false,0,true,_oPreviousStep,_oNextStep);
         }
         else
         {
            this.onTransitionDone(null,_oPreviousStep,_oNextStep);
         }
      }
      
      public function enableStep(_sID:String, _bValue:Boolean = true) : void
      {
         var _oStep:StepDefinition = null;
         if(_sID == sSTEP_BUILDER)
         {
            this.oHeader.btnSave.enabled = _bValue;
            this.oHeader.updateButtonDisplay(_bValue);
         }
         for(var i:uint = 0; i < this.aStepsDefinition.length; i++)
         {
            _oStep = this.aStepsDefinition[i];
            if(_oStep.id == _sID)
            {
               _oStep.enabled = _bValue;
               if(_bValue == false && this.nMaxStep >= i)
               {
                  this.nMaxStep = i - 1;
               }
               break;
            }
         }
      }
      
      public function highlightStep(_sID:String, _bValue:Boolean = true) : void
      {
         var _oStep:StepDefinition = null;
         for(var i:uint = 0; i < this.aStepsDefinition.length; i++)
         {
            _oStep = this.aStepsDefinition[i];
            if(_oStep.id == _sID)
            {
               _oStep.radio.highlight = _bValue;
               break;
            }
         }
      }
      
      public function isStepEnabled(_sID:String) : Boolean
      {
         var _oStep:StepDefinition = null;
         var _bReturn:Boolean = false;
         for each(_oStep in this.aStepsDefinition)
         {
            if(_oStep.id == _sID)
            {
               _bReturn = _oStep.enabled;
               break;
            }
         }
         return _bReturn;
      }
      
      public function disableAllStep() : void
      {
         var _oStep:StepDefinition = null;
         for each(_oStep in this.aStepsDefinition)
         {
            _oStep.enabled = false;
         }
      }
      
      private function init() : void
      {
         this.oEventManager = new EventManager();
         this.mcLoading = new mcLoadingOverlay();
         this.oViewManager = ViewManager.instance;
         this.initStepDefinitions();
         this.initHeader();
         this.initTutorial();
         this.reset();
         this.nCurrentStep = -1;
      }
      
      private function initStepDefinitions() : void
      {
         var _oBuilderScreen:BuilderScreen = new BuilderScreen();
         this.oViewManager.addView(sSCREEN_BUILDER,_oBuilderScreen);
         var _oBackgroundPopup:BackgroundSelectionPopup = new BackgroundSelectionPopup();
         this.oViewManager.addView(sPOPUP_BACKGROUND,_oBackgroundPopup);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,_oBackgroundPopup,Event.SELECT,this.onSelection);
         var _oLayoutPopup:LayoutSelectionPopup = new LayoutSelectionPopup();
         this.oViewManager.addView(sPOPUP_LAYOUT,_oLayoutPopup);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,_oLayoutPopup,Event.SELECT,this.onSelection);
         var _oHeroPopup:HeroSelectionPopup = new HeroSelectionPopup();
         this.oViewManager.addView(sPOPUP_HERO,_oHeroPopup);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,_oHeroPopup,Event.SELECT,this.onSelection);
         var _oGoalPopup:GoalSelectionPopup = new GoalSelectionPopup();
         this.oViewManager.addView(sPOPUP_GOAL,_oGoalPopup);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,_oGoalPopup,Event.SELECT,this.onSelection);
         var _oMusicPopup:MusicSelectionPopup = new MusicSelectionPopup();
         this.oViewManager.addView(sPOPUP_MUSIC,_oMusicPopup);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,_oMusicPopup,Event.SELECT,this.onSelection);
         var _oToolPopup:ToolsPopup = new ToolsPopup();
         this.oViewManager.addView(sPOPUP_TOOLS,_oToolPopup);
         var _oTestScreen:TestScreen = new TestScreen();
         this.oViewManager.addView(sSCREEN_TEST,_oTestScreen);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,_oTestScreen,GamePlayerEvent.REQUEST_MENU,this.onRequestMenu);
         var _oTestLoadingPopup:TestLoadingPopup = new TestLoadingPopup();
         this.oViewManager.addView(sPOPUP_TEST_LOADING,_oTestLoadingPopup);
         var _oPublishScreen:PublishScreen = new PublishScreen();
         this.oViewManager.addView(sSCREEN_PUBLISH,_oPublishScreen);
         this.aStepsDefinition = [new StepDefinition(sSTEP_BACKGROUND,"id_ui_step_background_title1","id_ui_step_background_title2","id_ui_step_background_button","mcStep1",_oBuilderScreen,_oBackgroundPopup),new StepDefinition(sSTEP_LAYOUT,"id_ui_step_layout_title1","id_ui_step_layout_title2","id_ui_step_layout_button","mcStep2",_oBuilderScreen,_oLayoutPopup),new StepDefinition(sSTEP_HERO,"id_ui_step_hero_title1","id_ui_step_hero_title2","id_ui_step_hero_button","mcStep3",_oBuilderScreen,_oHeroPopup),new StepDefinition(sSTEP_MUSIC,"id_ui_step_music_title1","id_ui_step_music_title2","id_ui_step_music_button","mcStep4",_oBuilderScreen,_oMusicPopup),new StepDefinition(sSTEP_GOAL,"id_ui_step_goal_title1","id_ui_step_goal_title2","id_ui_step_goal_button","mcStep5",_oBuilderScreen,_oGoalPopup),new StepDefinition(sSTEP_BUILDER,"id_ui_step_builder_title1","id_ui_step_builder_title2","id_ui_step_builder_button","mcStep6",_oBuilderScreen,_oToolPopup),new StepDefinition(sSTEP_TEST,null,null,"id_ui_step_play_button"
         ,"mcStep7",_oTestScreen,_oTestLoadingPopup),new StepDefinition(sSTEP_PUBLISH,"id_ui_step_publish_title1","id_ui_step_publish_title2","id_ui_step_publish_button","mcStep8",_oPublishScreen)];
      }
      
      private function initHeader() : void
      {
         var _oStep:StepDefinition = null;
         this.oHeader = new StepHeader();
         this.oViewManager.addView(sSCREEN_HEADER,this.oHeader);
         this.oViewManager.showView(sSCREEN_HEADER,BuilderMain.sLAYER_HEADER);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oHeader,UIEvent.CHANGE,this.onStepNavigation);
         for(var i:uint = 0; i < this.aStepsDefinition.length; i++)
         {
            _oStep = this.aStepsDefinition[i];
            this.oHeader.addRadio(_oStep,i + 1);
         }
         this.oHeader.updateButtonDisplay(false);
         this.hideHeader();
      }
      
      private function initTutorial() : void
      {
         this.aDisplayedTutorial = [];
         var _oTutorial:TutorialOverlay = new TutorialOverlay();
         this.oViewManager.addView(sSCREEN_TUTORIAL,_oTutorial);
      }
      
      private function onSelection(_e:Event) : void
      {
         var _oNextStep:StepDefinition = null;
         if(this.aStepsDefinition.length > this.nCurrentStep + 1)
         {
            _oNextStep = this.aStepsDefinition[this.nCurrentStep + 1];
            if(_oNextStep.enabled == false)
            {
               this.enableStep(_oNextStep.id,true);
               _oNextStep.radio.highlight = true;
            }
            if(_oNextStep.id == sSTEP_BUILDER)
            {
               this.enableStep(sSTEP_TEST);
               this.highlightStep(sSTEP_TEST);
            }
            if(this.nMaxStep < this.nCurrentStep + 1)
            {
               this.nMaxStep = this.nCurrentStep + 1;
            }
         }
      }
      
      private function onStepNavigation(_e:UIEvent) : void
      {
         var i:uint = 0;
         var _oStep:StepDefinition = null;
         var _sNewStep:String = this.oHeader.selected.value;
         if(_sNewStep == sSTEP_TEST && this.currentStep.screen.ID == sSCREEN_BUILDER && BuilderManager.instance.validateLevelContent() == false)
         {
            this.oHeader.selected = this.currentStep.radio;
         }
         else
         {
            this.gotoStep(_sNewStep);
            for(i = 0; i < this.aStepsDefinition.length; i++)
            {
               _oStep = this.aStepsDefinition[i];
               _oStep.radio.highlight = false;
               if(_oStep.id == _sNewStep)
               {
                  break;
               }
            }
         }
      }
      
      private function onRequestMenu(_e:GamePlayerEvent) : void
      {
         BuilderMain.instance.showPopup(BuilderMain.sPOPUP_MENU,false);
      }
      
      private function onTransitionDone(_e:ViewEvent, _oPreviousStep:StepDefinition, _oNextStep:StepDefinition) : void
      {
         this.oEventManager.cleanUp(sEVENT_TRANSITION_ID);
         if(Boolean(_oPreviousStep) && Boolean(_oPreviousStep.popup) && _oPreviousStep.popup.isDisplayed)
         {
            if(_oNextStep.screen.isTransiting && _oPreviousStep.popup is AbstractInOutView)
            {
               AbstractInOutView(_oPreviousStep.popup).skipInOutStates = true;
            }
            this.oEventManager.addEventListener(sEVENT_TRANSITION_ID,_oPreviousStep.popup,ViewEvent.HIDE,this.onTransitionDone,false,0,true,null,_oNextStep);
            this.oViewManager.hideView(_oPreviousStep.popup.ID);
         }
         else
         {
            if(Boolean(_oNextStep.popup))
            {
               if(_oNextStep.screen.isTransiting && _oNextStep.popup is AbstractInOutView)
               {
                  AbstractInOutView(_oNextStep.popup).skipInOutStates = true;
               }
               this.oViewManager.showView(_oNextStep.popup.ID,BuilderMain.sLAYER_SELECTION_WHEEL,-1,0,0,null,true);
            }
            this.showTutorial();
         }
      }
      
      public function get currentStep() : StepDefinition
      {
         return StepDefinition(this.aStepsDefinition[this.nCurrentStep]);
      }
      
      public function get currentStepNumber() : int
      {
         return this.nCurrentStep;
      }
      
      public function get header() : StepHeader
      {
         return this.oHeader;
      }
   }
}

