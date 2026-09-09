package gamePlayer.ui.popup
{
   import com.sarbakan.sbdk.asset.AssetReference;
   import com.sarbakan.sbdk.core.UpdateManager;
   import com.sarbakan.sbdk.events.UIEvent;
   import com.sarbakan.sbdk.localization.LocalizedTextField;
   import com.sarbakan.sbdk.state.AnimStateLocation;
   import com.sarbakan.sbdk.ui.Button;
   import com.sarbakan.sbdk.view.AbstractInOutView;
   import gamePlayer.GamePlayer;
   import gamePlayer.events.GamePlayerEvent;
   import ui.events.PopupEvent;
   
   public class MenuPopup extends AbstractInOutView
   {
      
      private static var sEVENT_MANAGER_ID:String = "events";
      
      private var btResume:Button;
      
      private var btRestart:Button;
      
      private var btHelp:Button;
      
      private var btQuit:Button;
      
      private var oTitle:LocalizedTextField;
      
      private var sQuitBtnLocale:String;
      
      public function MenuPopup(_sQuitBtnLocale:String)
      {
         super(AnimStateLocation.TIMELINE);
         setTimelineAssetReference(AssetReference.fromLibraryClass(mcPopupMenu));
         this.sQuitBtnLocale = _sQuitBtnLocale;
      }
      
      override public function destroy() : void
      {
         eventManager.cleanUp(sEVENT_MANAGER_ID);
         this.destroyLocalizedContent();
         this.destroyButtons();
         super.destroy();
      }
      
      override public function onBeforeShow() : void
      {
         super.onBeforeShow();
         skipInOutStates = false;
      }
      
      override public function onShow() : void
      {
         UpdateManager.instance.pause();
      }
      
      override public function onBeforeHide() : void
      {
      }
      
      override public function onHide() : void
      {
         eventManager.cleanUp(sEVENT_MANAGER_ID);
         this.destroyLocalizedContent();
         this.destroyButtons();
         UpdateManager.instance.resume();
      }
      
      private function initLocalizedContent() : void
      {
         this.oTitle = new LocalizedTextField(mcState.mcPopup.txtMenu,"id_ui_popup_menu_title");
      }
      
      private function initButtons(_bClickable:Boolean = true) : void
      {
         this.btResume = new Button(mcState.mcPopup.btnResume);
         this.btResume.setLocalizedLabel("id_ui_popup_menu_button_resume");
         this.btRestart = new Button(mcState.mcPopup.btnRestart);
         this.btRestart.setLocalizedLabel("id_ui_popup_menu_button_restart");
         this.btHelp = new Button(mcState.mcPopup.btnHelp);
         this.btHelp.setLocalizedLabel("id_ui_popup_menu_button_howtoplay");
         this.btQuit = new Button(mcState.mcPopup.btnQuit);
         this.btQuit.setLocalizedLabel(this.sQuitBtnLocale);
         if(_bClickable)
         {
            eventManager.addEventListener(sEVENT_MANAGER_ID,this.btResume,UIEvent.RELEASE,this.onBtResume);
            eventManager.addEventListener(sEVENT_MANAGER_ID,this.btRestart,UIEvent.RELEASE,this.onBtRestart);
            eventManager.addEventListener(sEVENT_MANAGER_ID,this.btHelp,UIEvent.RELEASE,this.onBtHelp);
            eventManager.addEventListener(sEVENT_MANAGER_ID,this.btQuit,UIEvent.RELEASE,this.onBtQuit);
         }
      }
      
      private function destroyLocalizedContent() : void
      {
         if(this.oTitle != null)
         {
            this.oTitle.destroy();
         }
         this.oTitle = null;
      }
      
      private function destroyButtons() : void
      {
         if(this.btResume != null)
         {
            this.btResume.destroy();
         }
         this.btResume = null;
         if(this.btRestart != null)
         {
            this.btRestart.destroy();
         }
         this.btRestart = null;
         if(this.btHelp != null)
         {
            this.btHelp.destroy();
         }
         this.btHelp = null;
         if(this.btQuit != null)
         {
            this.btQuit.destroy();
         }
         this.btQuit = null;
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
      
      private function onBtResume(_e:UIEvent) : void
      {
         dispatchEvent(new PopupEvent(PopupEvent.REQUEST_HIDE,ID));
      }
      
      private function onBtRestart(_e:UIEvent) : void
      {
         GamePlayer.instance.kamikaze();
         dispatchEvent(new PopupEvent(PopupEvent.REQUEST_HIDE,ID));
      }
      
      private function onBtHelp(_e:UIEvent) : void
      {
         dispatchEvent(new GamePlayerEvent(GamePlayerEvent.REQUEST_GAME_HELP));
      }
      
      private function onBtQuit(_e:UIEvent) : void
      {
         dispatchEvent(new GamePlayerEvent(GamePlayerEvent.REQUEST_GAME_QUIT));
      }
   }
}

