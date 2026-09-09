package gamePlayer.ui.popup
{
   import com.sarbakan.sbdk.asset.AssetReference;
   import com.sarbakan.sbdk.events.UIEvent;
   import com.sarbakan.sbdk.localization.LocalizedTextField;
   import com.sarbakan.sbdk.state.AnimStateLocation;
   import com.sarbakan.sbdk.ui.Button;
   import com.sarbakan.sbdk.view.AbstractInOutView;
   import gamePlayer.events.GamePlayerEvent;
   
   public class QuitPopup extends AbstractInOutView
   {
      
      private static var sEVENT_MANAGER_ID:String = "events";
      
      private var btConfirm:Button;
      
      private var btCancel:Button;
      
      private var oTitle:LocalizedTextField;
      
      private var oText:LocalizedTextField;
      
      private var sTitleID:String;
      
      private var sTextID:String;
      
      public function QuitPopup(_sTitleID:String, _sTextID:String)
      {
         super(AnimStateLocation.TIMELINE);
         setTimelineAssetReference(AssetReference.fromLibraryClass(mcPopupQuit));
         this.sTitleID = _sTitleID;
         this.sTextID = _sTextID;
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
      
      override public function onBeforeHide() : void
      {
      }
      
      override public function onHide() : void
      {
         eventManager.cleanUp(sEVENT_MANAGER_ID);
         this.destroyLocalizedContent();
         this.destroyButtons();
      }
      
      private function initLocalizedContent() : void
      {
         this.oTitle = new LocalizedTextField(mcState.mcPopup.txtQuitTitle,this.sTitleID);
         this.oText = new LocalizedTextField(mcState.mcPopup.txtQuitText,this.sTextID);
      }
      
      private function initButtons(_bClickable:Boolean = true) : void
      {
         this.btConfirm = new Button(mcState.mcPopup.btnYes);
         this.btConfirm.setLocalizedLabel("id_ui_popup_quit_button_yes");
         this.btCancel = new Button(mcState.mcPopup.btnNo);
         this.btCancel.setLocalizedLabel("id_ui_popup_quit_button_no");
         if(_bClickable)
         {
            eventManager.addEventListener(sEVENT_MANAGER_ID,this.btConfirm,UIEvent.RELEASE,this.onBtConfirm);
            eventManager.addEventListener(sEVENT_MANAGER_ID,this.btCancel,UIEvent.RELEASE,this.onBtCancel);
         }
      }
      
      private function destroyLocalizedContent() : void
      {
         if(this.oTitle != null)
         {
            this.oTitle.destroy();
         }
         this.oTitle = null;
         if(this.oText != null)
         {
            this.oText.destroy();
         }
         this.oText = null;
      }
      
      private function destroyButtons() : void
      {
         if(this.btConfirm != null)
         {
            this.btConfirm.destroy();
         }
         this.btConfirm = null;
         if(this.btCancel != null)
         {
            this.btCancel.destroy();
         }
         this.btCancel = null;
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
      
      private function onBtConfirm(_e:UIEvent) : void
      {
         dispatchEvent(new GamePlayerEvent(GamePlayerEvent.REQUEST_GAME_QUIT));
         this.btConfirm.enabled = false;
      }
      
      private function onBtCancel(_e:UIEvent) : void
      {
         dispatchEvent(new GamePlayerEvent(GamePlayerEvent.CANCEL_GAME_QUIT));
      }
   }
}

