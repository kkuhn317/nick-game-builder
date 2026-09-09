package ui.screens
{
   import com.sarbakan.sbdk.asset.AssetReference;
   import com.sarbakan.sbdk.events.TransitionEvent;
   import com.sarbakan.sbdk.view.ViewManager;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.events.Event;
   import gamePlayer.GamePlayer;
   import gamePlayer.events.GamePlayerEvent;
   import gamePlayer.ui.popup.MenuPopup;
   import gamePlayer.ui.popup.QuitPopup;
   import services.ProxyManager;
   import ui.events.PopupEvent;
   import ui.popups.ConfirmPopup;
   import ui.popups.TestLoadingPopup;
   
   public class TestScreen extends AbstractBuilderStepScreen
   {
      
      private static const sEVENT_GAME_ID:String = "eventManager_game";
      
      private static const sEVENT_CONFIRM_ID:String = "eventManager_confirm";
      
      private var oGameEngine:GamePlayer;
      
      private var oSnapshot:Bitmap;
      
      private var oLoadingPopup:TestLoadingPopup;
      
      public function TestScreen()
      {
         super(AssetReference.fromLibraryClass(mcTestScreen));
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.destroyGame();
         this.destroySnapshot();
         this.oLoadingPopup = null;
      }
      
      override public function onBeforeShow() : void
      {
         super.onBeforeShow();
         StepManager.instance.hideHeader();
         ProxyManager.instance.onGameTested();
         this.initGame();
         this.oLoadingPopup = StepManager.instance.currentStep.popup as TestLoadingPopup;
         eventManager.addEventListener(sEVENT_MANAGER_ID,this.oLoadingPopup,Event.COMPLETE,this.onLoadingComplete);
      }
      
      override public function onHide() : void
      {
         super.onHide();
         eventManager.cleanUp(sEVENT_CONFIRM_ID);
         eventManager.cleanUp(sEVENT_GAME_ID);
         eventManager.cleanUp(sEVENT_MANAGER_ID);
         var _oMenuPopup:MenuPopup = ViewManager.instance.getView(BuilderMain.sPOPUP_MENU) as MenuPopup;
         if(_oMenuPopup.isDisplayed)
         {
            _oMenuPopup.skipInOutStates = true;
            ViewManager.instance.hideView(BuilderMain.sPOPUP_MENU);
         }
         var _oQuitPopup:QuitPopup = ViewManager.instance.getView(BuilderMain.sPOPUP_QUIT) as QuitPopup;
         if(_oQuitPopup.isDisplayed)
         {
            _oQuitPopup.skipInOutStates = true;
            ViewManager.instance.hideView(BuilderMain.sPOPUP_QUIT);
         }
         var _oConfirmPopup:ConfirmPopup = ViewManager.instance.getView(BuilderMain.sPOPUP_CONFIRM) as ConfirmPopup;
         if(_oConfirmPopup.isDisplayed)
         {
            _oConfirmPopup.skipInOutStates = true;
            ViewManager.instance.hideView(BuilderMain.sPOPUP_CONFIRM);
         }
         this.destroyGame();
         this.destroySnapshot();
         this.oLoadingPopup = null;
      }
      
      public function takeSnapshot() : void
      {
         var _oBD:BitmapData = new BitmapData(960,500);
         _oBD.draw(mcContent);
         this.oSnapshot = new Bitmap(_oBD);
         mcContent.addChild(this.oSnapshot);
         this.destroyGame();
      }
      
      private function initGame() : void
      {
         this.oGameEngine = new GamePlayer(mcContent,BuilderMain.instance.gameData);
         eventManager.addEventListener(sEVENT_GAME_ID,this.oGameEngine,GamePlayerEvent.GAME_WIN,this.onWin);
         eventManager.addEventListener(sEVENT_GAME_ID,this.oGameEngine,GamePlayerEvent.GAME_LOSE,this.onLose);
         eventManager.addEventListener(sEVENT_GAME_ID,this.oGameEngine,GamePlayerEvent.REQUEST_MENU,this.onRequestMenu);
      }
      
      private function destroyGame() : void
      {
         eventManager.cleanUp(sEVENT_GAME_ID);
         if(Boolean(this.oGameEngine))
         {
            this.oGameEngine.destroy();
         }
         this.oGameEngine = null;
      }
      
      private function destroySnapshot() : void
      {
         if(Boolean(this.oSnapshot))
         {
            this.oSnapshot.bitmapData.dispose();
         }
         this.oSnapshot = null;
      }
      
      private function onLoadingComplete(_e:Event) : void
      {
         eventManager.cleanUp(sEVENT_MANAGER_ID);
         this.oGameEngine.initElementsCreation();
      }
      
      private function onWin(_e:GamePlayerEvent) : void
      {
         StepManager.instance.enableStep(StepManager.sSTEP_PUBLISH);
         var _oPopup:ConfirmPopup = ViewManager.instance.getView(BuilderMain.sPOPUP_CONFIRM) as ConfirmPopup;
         eventManager.addEventListener(sEVENT_CONFIRM_ID,_oPopup,PopupEvent.CONFIRM,this.onMoveToPublish);
         eventManager.addEventListener(sEVENT_CONFIRM_ID,_oPopup,PopupEvent.CANCEL,this.onBackToBuilder);
         BuilderMain.instance.showConfirmPopup("id_ui_step_play_win_confirmTitle","id_ui_step_play_win_confirmText","id_ui_step_play_win_btnConfirm","id_ui_step_play_win_btnCancel",1.3);
      }
      
      private function onLose(_e:GamePlayerEvent) : void
      {
         var _oPopup:ConfirmPopup = ViewManager.instance.getView(BuilderMain.sPOPUP_CONFIRM) as ConfirmPopup;
         eventManager.addEventListener(sEVENT_CONFIRM_ID,_oPopup,PopupEvent.CONFIRM,this.onTryAgain);
         eventManager.addEventListener(sEVENT_CONFIRM_ID,_oPopup,PopupEvent.CANCEL,this.onBackToBuilder);
         BuilderMain.instance.showConfirmPopup("id_ui_step_play_lose_confirmTitle","id_ui_step_play_lose_confirmText","id_ui_step_play_lose_btnConfirm","id_ui_step_play_lose_btnCancel");
      }
      
      private function onRequestMenu(_e:GamePlayerEvent) : void
      {
         dispatchEvent(new GamePlayerEvent(GamePlayerEvent.REQUEST_MENU));
      }
      
      private function onMoveToPublish(_e:PopupEvent) : void
      {
         StepManager.instance.gotoStep(StepManager.sSTEP_PUBLISH);
      }
      
      private function onBackToBuilder(_e:PopupEvent) : void
      {
         StepManager.instance.gotoStep(StepManager.sSTEP_BUILDER);
      }
      
      private function onTryAgain(_e:PopupEvent) : void
      {
         eventManager.addEventListener(sEVENT_MANAGER_ID,ViewManager.instance,TransitionEvent.COMPLETE,this.onTryAgainTranstionDone);
         ViewManager.instance.playTransitionOnTop(BuilderMain.sDEFAULT_TRANSITION_IN);
      }
      
      private function onTryAgainTranstionDone(_e:Event) : void
      {
         this.onHide();
         this.onBeforeShow();
         this.onLoadingComplete(null);
         ViewManager.instance.playTransitionOnTop(BuilderMain.sDEFAULT_TRANSITION_OUT);
      }
   }
}

