package gamePlayer.ui.popup
{
   import com.sarbakan.sbdk.asset.AssetReference;
   import com.sarbakan.sbdk.events.UIEvent;
   import com.sarbakan.sbdk.localization.LocalizationManager;
   import com.sarbakan.sbdk.state.AnimStateLocation;
   import com.sarbakan.sbdk.ui.Button;
   import com.sarbakan.sbdk.utils.DisplayObjectUtils;
   import com.sarbakan.sbdk.view.AbstractInOutView;
   import flash.display.MovieClip;
   import gamePlayer.GamePlayer;
   import gamePlayer.GamePlayerConfig;
   import media.type.AbstractMedia;
   import media.type.BonusCoinMedia;
   import media.type.OpponentJumperMedia;
   import media.type.OpponentShooterMedia;
   import media.type.OpponentWalkerMedia;
   import media.type.PlayableCharacterMedia;
   import media.type.TileFatalMedia;
   import ui.events.PopupEvent;
   
   public class HelpPopup extends AbstractInOutView
   {
      
      private static var aWatchOut:Array;
      
      private static var oCoinMedia:BonusCoinMedia;
      
      private static var sEVENT_MANAGER_ID:String = "events";
      
      private var btBack:Button;
      
      public function HelpPopup()
      {
         super(AnimStateLocation.TIMELINE);
         setTimelineAssetReference(AssetReference.fromLibraryClass(mcPopupHelp));
         aWatchOut = new Array();
      }
      
      public static function addWatchOut(_oMedia:AbstractMedia) : void
      {
         if(aWatchOut.indexOf(_oMedia) == -1)
         {
            aWatchOut.push(_oMedia);
         }
      }
      
      public static function setCoinMedia(_oMedia:BonusCoinMedia) : void
      {
         oCoinMedia = _oMedia;
      }
      
      public static function reset() : void
      {
         aWatchOut = new Array();
         oCoinMedia = null;
      }
      
      override public function destroy() : void
      {
         eventManager.cleanUp(sEVENT_MANAGER_ID);
         this.destroyButtons();
         aWatchOut = null;
         oCoinMedia = null;
         super.destroy();
      }
      
      override public function onHide() : void
      {
         eventManager.cleanUp(sEVENT_MANAGER_ID);
         this.destroyButtons();
      }
      
      private function initDisplay() : void
      {
         LocalizationManager.instance.setTextField(mcState.mcPopup.txtTitle,"id_ui_howtoplay_title");
         this.initMouvementDisplay();
         this.initGoalDisplay();
         this.initCoinDisplay();
         this.initWatchOutDisplay();
      }
      
      private function initMouvementDisplay() : void
      {
         var _mcContent:MovieClip = mcState.mcPopup.mcMovement;
         LocalizationManager.instance.setTextField(_mcContent.txtTitle,"id_how_to_play_movement_title");
         LocalizationManager.instance.setTextField(_mcContent.txtMove,"id_how_to_play_movement_move");
         LocalizationManager.instance.setTextField(_mcContent.txtSprint,"id_how_to_play_movement_sprint");
         LocalizationManager.instance.setTextField(_mcContent.txtJump,"id_how_to_play_movement_jump");
         LocalizationManager.instance.setTextField(_mcContent.txtCrouch,"id_how_to_play_movement_crouch");
         LocalizationManager.instance.setTextField(_mcContent.txtSpacebar,"id_how_to_play_movement_spacebar");
      }
      
      private function initGoalDisplay() : void
      {
         var _sGoalLocale:String = null;
         var _mcIcon:MovieClip = null;
         var _mcContent:MovieClip = mcState.mcPopup.mcGoal;
         switch(GamePlayer.instance.gameData.goal)
         {
            case CommonConfig.sGOAL_TYPE_COIN:
               _sGoalLocale = "id_how_to_play_goal_coins";
               _mcIcon = new mcCoinGoalIcon();
               break;
            case CommonConfig.sGOAL_TYPE_DOOR:
               _sGoalLocale = "id_how_to_play_goal_door";
               _mcIcon = new mcDoorGoalIcon();
               break;
            case CommonConfig.sGOAL_TYPE_OPPONENT:
               _sGoalLocale = "id_how_to_play_goal_opponent";
               _mcIcon = new mcOpponentGoalIcon();
         }
         LocalizationManager.instance.setTextField(_mcContent.txtTitle,"id_how_to_play_goal_title");
         LocalizationManager.instance.setTextField(_mcContent.txtText,_sGoalLocale);
         DisplayObjectUtils.fitIconInFrame(_mcIcon,_mcContent.mcGoalIcon);
      }
      
      private function initCoinDisplay() : void
      {
         var _sHeroAlias:String = null;
         var _oPlayerMedia:AbstractMedia = null;
         var _mcContent:MovieClip = mcState.mcPopup.mcCoinLife;
         if(Boolean(oCoinMedia))
         {
            LocalizationManager.instance.setTextField(_mcContent.txtCoin,"id_how_to_play_coinForLife",{"$value$":GamePlayerConfig.uCOINS_FOR_LIFE});
            LocalizationManager.instance.setTextField(_mcContent.txtLife,"id_how_to_play_lifeUp");
            DisplayObjectUtils.fitIconInFrame(this.getMcFromMedia(oCoinMedia),_mcContent.mcCoinIcon,Number.MAX_VALUE);
            _sHeroAlias = GamePlayer.instance.gameData.heroAlias;
            _oPlayerMedia = GamePlayer.instance.mediaList.getMedia(_sHeroAlias);
            DisplayObjectUtils.fitIconInFrame(this.getMcFromMedia(_oPlayerMedia),_mcContent.mcLifeIcon);
         }
         else
         {
            _mcContent.visible = false;
         }
      }
      
      private function initWatchOutDisplay() : void
      {
         var i:uint = 0;
         var _mcContainer:MovieClip = null;
         var _mcIcon:MovieClip = null;
         var _mcContent:MovieClip = mcState.mcPopup.mcWatchOut;
         if(aWatchOut.length > 0)
         {
            LocalizationManager.instance.setTextField(_mcContent.txtTitle,"id_how_to_play_watchOut_title");
            for(i = 0; i < aWatchOut.length; i++)
            {
               _mcContainer = _mcContent.getChildByName("mc" + (i + 1)) as MovieClip;
               _mcIcon = this.getMcFromMedia(aWatchOut[i] as AbstractMedia);
               DisplayObjectUtils.fitIconInFrame(_mcIcon,_mcContainer);
            }
         }
         else
         {
            _mcContent.visible = false;
         }
      }
      
      private function initButtons(_bClickable:Boolean = true) : void
      {
         this.btBack = new Button(mcState.mcPopup.btnBack);
         this.btBack.setLocalizedLabel("id_ui_howtoplay_button_back");
         if(_bClickable)
         {
            eventManager.addEventListener(sEVENT_MANAGER_ID,this.btBack,UIEvent.RELEASE,this.onBtBack);
         }
      }
      
      private function destroyButtons() : void
      {
         if(this.btBack != null)
         {
            this.btBack.destroy();
         }
         this.btBack = null;
      }
      
      private function getMcFromMedia(_oMedia:AbstractMedia) : MovieClip
      {
         var _cClass:Class = null;
         switch(_oMedia.type)
         {
            case PlayableCharacterMedia.TYPE:
               _cClass = _oMedia.getClass(PlayableCharacterMedia.LINKAGE_TITLE_CHARACTER);
               break;
            case OpponentJumperMedia.TYPE:
               _cClass = _oMedia.getClass(OpponentJumperMedia.LINKAGE_JUMP_UP);
               break;
            case OpponentShooterMedia.TYPE:
               _cClass = _oMedia.getClass(OpponentShooterMedia.LINKAGE_IDLE);
               break;
            case OpponentWalkerMedia.TYPE:
               _cClass = _oMedia.getClass(OpponentWalkerMedia.LINKAGE_WALK);
               break;
            case BonusCoinMedia.TYPE:
               _cClass = _oMedia.getClass(BonusCoinMedia.LINKAGE_IDLE);
               break;
            case TileFatalMedia.TYPE:
               _cClass = _oMedia.getClass(_oMedia.previewLinkages[0]);
         }
         var _mc:MovieClip = new _cClass();
         _mc.stop();
         for(var i:uint = 0; i < _mc.numChildren; i++)
         {
            if(_mc.getChildAt(i).name.charAt(0) == "_")
            {
               _mc.removeChild(_mc.getChildAt(i));
               i--;
            }
         }
         return _mc;
      }
      
      override protected function state_in_init() : void
      {
         super.state_in_init();
         this.initDisplay();
         this.initButtons(false);
      }
      
      override protected function state_idle_init() : void
      {
         super.state_idle_init();
         this.initDisplay();
         this.initButtons();
      }
      
      override protected function state_out_init() : void
      {
         super.state_out_init();
         this.initDisplay();
         this.initButtons(false);
      }
      
      private function onBtBack(_e:UIEvent) : void
      {
         dispatchEvent(new PopupEvent(PopupEvent.REQUEST_HIDE,ID));
      }
   }
}

