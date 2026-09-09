package gamePlayer.ui
{
   import com.sarbakan.sbdk.events.PreloadEvent;
   import com.sarbakan.sbdk.events.UIEvent;
   import com.sarbakan.sbdk.localization.LocalizationManager;
   import com.sarbakan.sbdk.state.StateMachine;
   import com.sarbakan.sbdk.state.StateMachineType;
   import com.sarbakan.sbdk.ui.Button;
   import com.sarbakan.sbdk.utils.DisplayObjectUtils;
   import com.sarbakan.sbdk.utils.EventManager;
   import com.sarbakan.sbdk.utils.StringFormatter;
   import flash.display.MovieClip;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import gamePlayer.GamePlayer;
   import gamePlayer.GamePlayerConfig;
   import gamePlayer.GameSession;
   import gamePlayer.events.GamePlayerEvent;
   import media.type.BonusCoinMedia;
   import media.type.PlayableCharacterMedia;
   import ui.controls.MuteButton;
   
   public class GamePlayerHUD extends EventDispatcher
   {
      
      private static const sEVENT_MANAGER_ID:String = "eventManager";
      
      private static const sSTATE_IDLE:String = "state_idle";
      
      private var mcContainer:MovieClip;
      
      private var oStateMachine:StateMachine;
      
      private var oEventManager:EventManager;
      
      private var btMenu:Button;
      
      private var btMute:MuteButton;
      
      private var nShownScore:Number;
      
      private var nShownLife:Number;
      
      public function GamePlayerHUD(_mcContainer:MovieClip)
      {
         super();
         this.mcContainer = _mcContainer;
         this.nShownScore = -1;
         this.nShownLife = -1;
         this.oEventManager = new EventManager();
         this.oStateMachine = new StateMachine(StateMachineType.FRAME_BASED);
         this.oStateMachine.addState(sSTATE_IDLE,this.state_idle);
         this.oStateMachine.setState(sSTATE_IDLE);
         if(BuilderMain.instance.editorPrototype)
         {
            var labels:Array=["mcLife","mcScore","mcCoinsCollected","mcGoalDisplay"];
            for(var i:int=0;i<labels.length;i++)
            {
               var clip:MovieClip=new MovieClip(); var text:TextField=new TextField();
               text.defaultTextFormat=new TextFormat("_sans",14,0x102030); text.width=200; text.height=24;
               clip["txtText"]=text; clip.addChild(text); clip.x=12+i*220; clip.y=475;
               this.mcContainer[labels[i]]=clip; this.mcContainer.addChild(clip);
            }
            this.updateLife(); this.updateScore(); return;
         }
         this.mcContainer.mcCoinsCollected.visible = false;
         this.initButtons();
         this.initPlayerDisplay();
         this.initGoalDisplay();
         this.updateLife();
         this.updateCoinsCollected();
         this.updateScore();
      }
      
      public function destroy() : void
      {
         this.destroyButtons();
         if(Boolean(this.oEventManager))
         {
            this.oEventManager.destroy();
         }
         this.oEventManager = null;
         if(Boolean(this.oStateMachine))
         {
            this.oStateMachine.destroy();
         }
         this.oStateMachine = null;
         this.mcContainer = null;
      }
      
      public function updateScore() : void
      {
         if(BuilderMain.instance.editorPrototype) { this.mcContainer.mcScore.txtText.text="Score: "+GameSession.instance.score; return; }
         var _sScore:String = null;
         if(this.nShownScore != GameSession.instance.score)
         {
            this.nShownScore += GamePlayerConfig.nHUD_COUNTER_SPEED;
            this.nShownScore = Math.min(Math.max(0,this.nShownScore),GameSession.instance.score);
            _sScore = StringFormatter.formatNumber(this.nShownScore,""," ");
            LocalizationManager.instance.setTextField(this.mcContainer.mcScore.txtText,"id_ui_hud_score",{"$value$":_sScore});
         }
      }
      
      public function updateLife() : void
      {
         if(BuilderMain.instance.editorPrototype) { this.mcContainer.mcLife.txtText.text="Lives: "+GameSession.instance.lives; return; }
         var _sLife:String = null;
         if(this.nShownLife != GameSession.instance.lives)
         {
            _sLife = StringFormatter.formatNumber(GameSession.instance.lives,""," ");
            LocalizationManager.instance.setTextField(this.mcContainer.mcLife.txtText,"id_ui_hud_life",{"$value$":_sLife});
         }
      }
      
      public function updateCoinsCollected() : void
      {
         if(BuilderMain.instance.editorPrototype) { this.mcContainer.mcCoinsCollected.txtText.text="Coins: "+GameSession.instance.coinsCollected; return; }
         var _sCoinsCollected:String = StringFormatter.formatNumber(GameSession.instance.coinsCollected,""," ");
         LocalizationManager.instance.setTextField(this.mcContainer.mcCoinsCollected.txtText,"id_ui_hud_coins_collected",{"$value$":_sCoinsCollected});
         trace(_sCoinsCollected);
      }
      
      public function updateCoinsLeft() : void
      {
         var _sCoinsLeft:String = null;
         if(GamePlayer.instance.gameData.goal == CommonConfig.sGOAL_TYPE_COIN)
         {
            _sCoinsLeft = StringFormatter.formatNumber(GameSession.instance.coinsLeft,""," ");
            LocalizationManager.instance.setTextField(this.mcContainer.mcGoalDisplay.txtText,"id_ui_hud_coins_left",{"$value$":_sCoinsLeft});
         }
      }
      
      public function updateOpponentsLeft() : void
      {
         var _sOpponentsLeft:String = null;
         if(GamePlayer.instance.gameData.goal == CommonConfig.sGOAL_TYPE_OPPONENT)
         {
            _sOpponentsLeft = StringFormatter.formatNumber(GameSession.instance.opponentLeft,""," ");
            LocalizationManager.instance.setTextField(this.mcContainer.mcGoalDisplay.txtText,"id_ui_hud_opponents_left",{"$value$":_sOpponentsLeft});
         }
      }
      
      public function updateGoalsLeft() : void
      {
         var _sGoalsLeft:String = null;
         if(GamePlayer.instance.gameData.goal == CommonConfig.sGOAL_TYPE_DOOR)
         {
            _sGoalsLeft = StringFormatter.formatNumber(GameSession.instance.goalLeft,""," ");
            LocalizationManager.instance.setTextField(this.mcContainer.mcGoalDisplay.txtText,"id_ui_hud_opponents_left",{"$value$":_sGoalsLeft});
         }
      }
      
      public function initCoinDisplay(_oCoinMedia:BonusCoinMedia) : void
      {
         var _cClass:Class = null;
         var _mcIcon:MovieClip = null;
         var i:uint = 0;
         if(this.mcContainer.mcCoinsCollected.visible == false)
         {
            if(_oCoinMedia.gameLoaded)
            {
               this.mcContainer.mcCoinsCollected.visible = true;
               _cClass = _oCoinMedia.getClass(BonusCoinMedia.LINKAGE_IDLE);
               _mcIcon = new _cClass();
               _mcIcon.stop();
               for(i = 0; i < _mcIcon.numChildren; i++)
               {
                  if(_mcIcon.getChildAt(i).name.charAt(0) == "_")
                  {
                     _mcIcon.removeChild(_mcIcon.getChildAt(i));
                     i--;
                  }
               }
               DisplayObjectUtils.fitIconInFrame(_mcIcon,this.mcContainer.mcCoinsCollected.mcIcon);
            }
            else
            {
               this.oEventManager.addEventListener(sEVENT_MANAGER_ID,_oCoinMedia.gameLoader,PreloadEvent.COMPLETE,this.onCoinLoaded,false,0,true,_oCoinMedia);
            }
         }
      }
      
      private function initButtons() : void
      {
         this.btMenu = new Button(this.mcContainer.btnMenu);
         this.btMenu.setLocalizedLabel("id_ui_hud_button_menu");
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.btMenu,UIEvent.RELEASE,this.onBtMenu);
         this.btMute = new MuteButton(this.mcContainer.btnMute);
      }
      
      private function destroyButtons() : void
      {
         if(this.btMenu != null)
         {
            this.btMenu.destroy();
         }
         this.btMenu = null;
         if(Boolean(this.btMute))
         {
            this.btMute.destroy();
         }
         this.btMute = null;
      }
      
      private function initPlayerDisplay() : void
      {
         var _oPlayer:PlayableCharacterMedia = GamePlayer.instance.mediaList.getMedia(GamePlayer.instance.gameData.heroAlias) as PlayableCharacterMedia;
         var _cPlayerClass:Class = _oPlayer.getClass(PlayableCharacterMedia.LINKAGE_TITLE_CHARACTER);
         DisplayObjectUtils.fitIconInFrame(new _cPlayerClass(),this.mcContainer.mcLife.mcIcon);
      }
      
      private function initGoalDisplay() : void
      {
         var _mcGoalContainer:MovieClip = this.mcContainer.mcGoalDisplay.mcIcon;
         switch(GamePlayer.instance.gameData.goal)
         {
            case CommonConfig.sGOAL_TYPE_COIN:
               DisplayObjectUtils.fitIconInFrame(new mcCoinGoalIcon(),_mcGoalContainer);
               this.updateCoinsLeft();
               break;
            case CommonConfig.sGOAL_TYPE_OPPONENT:
               DisplayObjectUtils.fitIconInFrame(new mcOpponentGoalIcon(),_mcGoalContainer);
               this.updateOpponentsLeft();
               break;
            default:
               this.mcContainer.mcGoalDisplay.visible = false;
         }
      }
      
      private function state_idle() : void
      {
         this.updateScore();
      }
      
      private function onBtMenu(_e:UIEvent) : void
      {
         dispatchEvent(new GamePlayerEvent(GamePlayerEvent.REQUEST_MENU));
      }
      
      private function onCoinLoaded(_e:Event, _oMedia:BonusCoinMedia) : void
      {
         this.initCoinDisplay(_oMedia);
      }
      
      public function get mcRef() : MovieClip
      {
         return this.mcContainer;
      }
      
      public function get enabled() : Boolean
      {
         if(BuilderMain.instance.editorPrototype) return this.mcContainer.mouseEnabled;
         return this.btMenu.enabled;
      }
      
      public function set enabled(_bValue:Boolean) : void
      {
         if(BuilderMain.instance.editorPrototype) { this.mcContainer.mouseEnabled=_bValue; return; }
         this.btMenu.enabled = _bValue;
      }
   }
}

