package gamePlayer
{
   import com.sarbakan.sbdk.blitting.core.BitmappedAnimContainer;
   import com.sarbakan.sbdk.blitting.core.StillElement;
   import com.sarbakan.sbdk.blitting.core.StillGenerator;
   import com.sarbakan.sbdk.core.UpdateManager;
   import com.sarbakan.sbdk.events.StillGeneratorEvent;
   import com.sarbakan.sbdk.events.UpdateEvent;
   import com.sarbakan.sbdk.math.geom.AABB2;
   import com.sarbakan.sbdk.sound.SoundManager;
   import com.sarbakan.sbdk.utils.EventManager;
   import com.sarbakan.sbdk.view.DepthManager;
   import com.sarbakan.sbdk.view.ViewManager;
   import data.GameData;
   import data.GameDataElement;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.getTimer;
   import gamePlayer.elements.AbstractGameElement;
   import gamePlayer.elements.AbstractOpponent;
   import gamePlayer.elements.BonusCoin;
   import gamePlayer.elements.BonusExtraLife;
   import gamePlayer.elements.BonusInvincibility;
   import gamePlayer.elements.Goal;
   import gamePlayer.elements.OpponentJumper;
   import gamePlayer.elements.OpponentShooter;
   import gamePlayer.elements.OpponentWalker;
   import gamePlayer.elements.PlatformObject;
   import gamePlayer.elements.PlayableCharacter;
   import gamePlayer.elements.ShooterProjectile;
   import gamePlayer.elements.TileFatal;
   import gamePlayer.elements.TilePlatform;
   import gamePlayer.elements.TileSlippery;
   import gamePlayer.elements.TileSurface;
   import gamePlayer.events.GamePlayerEvent;
   import gamePlayer.physic.PhysEngine;
   import gamePlayer.physic.TileManager;
   import gamePlayer.ui.GamePlayerHUD;
   import gamePlayer.ui.popup.HelpPopup;
   import gamePlayer.viewport.Viewport;
   import media.MediaList;
   import media.MediaManager;
   import media.type.AbstractMedia;
   import media.type.BackgroundMedia;
   import media.type.BonusCoinMedia;
   import media.type.BonusExtraLifeMedia;
   import media.type.BonusInvincibilityMedia;
   import media.type.GoalMedia;
   import media.type.OpponentJumperMedia;
   import media.type.OpponentShooterMedia;
   import media.type.OpponentWalkerMedia;
   import media.type.PlatformObjectMedia;
   import media.type.PlayableCharacterMedia;
   import media.type.PropsMedia;
   import media.type.TileFatalMedia;
   import media.type.TilePlatformMedia;
   import media.type.TileSlipperyMedia;
   import media.type.TileSurfaceMedia;
   import sound.SfxManager;
   
   public class GamePlayer extends EventDispatcher
   {
      
      private static var oInstance:GamePlayer;
      
      private static const sEVENT_MANAGER_ID:String = "eventManager";
      
      private static const nMIN_GOAL_DISPLAY:uint = 2000;
      
      private static const sDEPTH_LEVEL:String = "depthLevel";
      
      private static const sDEPTH_DEBUG:String = "depthDebug";
      
      private static const sDEPTH_HUD:String = "depthHud";
      
      public static const sLAYER_TILES:String = "tileLayer";
      
      public static const sLAYER_CHARACTER:String = "characterLayer";
      
      public static const sLAYER_COLLECTABLES:String = "collectablesLayer";
      
      private static const nSPEED_PARALAX_BACK:Number = 0.6;
      
      private static const nSPEED_PARALAX_FRONT:Number = 0.8;
      
      public var oCheckpoint:Point;
      
      public var bGameCompleted:Boolean;
      
      private var mcContainer:MovieClip;
      
      private var oContainer:BitmappedAnimContainer;
      
      private var oStillGenerator:StillGenerator;
      
      private var oBackground:BackgroundManager;
      
      private var nLevelWidth:Number;
      
      private var nLevelHeight:Number;
      
      private var aLevelElements:Array;
      
      private var oPlayer:PlayableCharacter;
      
      private var bGameRestarted:Boolean;
      
      private var oHUD:GamePlayerHUD;
      
      private var oEventManager:EventManager;
      
      private var oDepthManager:DepthManager;
      
      private var nGenerationStartTime:int;
      
      private var nCurrentElementCreation:uint;
      
      private var oGameData:GameData;
      
      private var oMediaList:MediaList;
      
      private var oPosOffset:Point;
      
      private var oGoalDisplay:GoalDisplay;
      
      public function GamePlayer(_mcContainer:MovieClip, _oGameData:GameData)
      {
         super();
         oInstance = this;
         this.mcContainer = _mcContainer;
         this.oEventManager = new EventManager();
         this.oDepthManager = new DepthManager(this.mcContainer);
         this.oDepthManager.addLayer(sDEPTH_LEVEL);
         this.oDepthManager.addLayer(sDEPTH_DEBUG);
         this.oDepthManager.addLayer(sDEPTH_HUD);
         this.oGameData = _oGameData;
         this.oMediaList = MediaManager.instance.getMediaList(this.oGameData.builderAlias,this.oGameData.propertyAlias);
         this.initLevelBounds();
         GameSession.instance.reset();
         this.initHUD();
         this.initContainer();
         this.initBackground();
         this.scanGameElement();
         this.nGenerationStartTime = getTimer();
      }
      
      public static function get instance() : GamePlayer
      {
         return oInstance;
      }
      
      public function destroy() : void
      {
         HelpPopup.reset();
         if(Boolean(this.aLevelElements))
         {
            while(this.aLevelElements.length > 0)
            {
               this.removeElement(this.aLevelElements[0]);
            }
         }
         this.aLevelElements = null;
         if(Boolean(this.oHUD))
         {
            this.oDepthManager.getLayer(sDEPTH_HUD).removeChild(this.oHUD.mcRef);
            this.oHUD.destroy();
         }
         this.oHUD = null;
         SoundManager.instance.fadeVolume(SoundConfig.sSOUND_CATEGORY_MUSIC,SoundConfig.nDEFAULT_VOLUME_MUSIC,SoundConfig.nMUSIC_SWITCH_FADE_DURATION,false,false);
         TileManager.instance.destroy();
         PhysEngine.instance.destroy();
         Viewport.instance.destroy();
         SfxManager.instance.stopAllSFX();
         if(Boolean(this.oDepthManager))
         {
            this.oDepthManager.destroy();
         }
         this.oDepthManager = null;
         if(Boolean(this.oStillGenerator))
         {
            this.oStillGenerator.destroy();
         }
         this.oStillGenerator = null;
         if(Boolean(this.oBackground))
         {
            this.oBackground.destroy();
         }
         this.oBackground = null;
         if(Boolean(this.oContainer))
         {
            this.oContainer.destroy();
         }
         this.oContainer = null;
         if(Boolean(this.oEventManager))
         {
            this.oEventManager.destroy();
         }
         this.oEventManager = null;
         this.oGameData = null;
         this.oMediaList = null;
         this.oPosOffset = null;
         this.oCheckpoint = null;
         this.mcContainer = null;
         oInstance = null;
      }
      
      public function initElementsCreation() : void
      {
         this.aLevelElements = new Array();
         this.nCurrentElementCreation = 0;
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,UpdateManager.instance,UpdateEvent.UPDATE_PAUSED,this.onElementCreation);
         UpdateManager.instance.pause();
      }
      
      public function createElement(_oMedia:AbstractMedia, _oPos:Point, _bFlipped:Boolean = false, _sLinkage:String = null) : void
      {
         var _oElement:AbstractGameElement = null;
         var _oTile:AbstractGameElement = null;
         switch(_oMedia.type)
         {
            case PlatformObjectMedia.TYPE:
               _oTile = new PlatformObject(_oMedia,_oPos);
               this.oStillGenerator.addElement(PlatformObject(_oTile).stillElement);
               break;
            case TileFatalMedia.TYPE:
               _oTile = new TileFatal(_oMedia,_oPos,_sLinkage);
               this.oStillGenerator.addElement(TileFatal(_oTile).stillElement);
               break;
            case TilePlatformMedia.TYPE:
               _oTile = new TilePlatform(_oMedia,_oPos,_sLinkage);
               this.oStillGenerator.addElement(TilePlatform(_oTile).stillElement);
               break;
            case TileSurfaceMedia.TYPE:
               _oTile = new TileSurface(_oMedia,_oPos,_sLinkage);
               this.oStillGenerator.addElement(TileSurface(_oTile).stillElement);
               break;
            case TileSlipperyMedia.TYPE:
               _oTile = new TileSlippery(_oMedia,_oPos,_sLinkage);
               this.oStillGenerator.addElement(TileSlippery(_oTile).stillElement);
               break;
            case PlayableCharacterMedia.TYPE:
               _oElement = new PlayableCharacter(_oMedia,_oPos,_bFlipped);
               this.oPlayer = _oElement as PlayableCharacter;
               this.oContainer.addBitmappedAnimation(this.oPlayer.animStateMachine,sLAYER_CHARACTER);
               this.oContainer.addBitmappedAnimation(this.oPlayer.invinsibilityOverlay,sLAYER_CHARACTER);
               this.oPlayer.setControlsEnabled(true);
               this.oCheckpoint = new Point(this.oPlayer.animStateMachine.x,this.oPlayer.animStateMachine.y);
               Viewport.instance.easeTo(this.oPlayer,0.2);
               this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oPlayer,GamePlayerEvent.GAME_LOSE,this.onLose);
               break;
            case OpponentJumperMedia.TYPE:
               _oElement = new OpponentJumper(_oMedia,_oPos,_bFlipped);
               this.oContainer.addBitmappedAnimation(OpponentJumper(_oElement).animStateMachine,sLAYER_CHARACTER);
               this.oEventManager.addEventListener(sEVENT_MANAGER_ID,_oElement as AbstractOpponent,GamePlayerEvent.KILL_OPPONENT,this.onKillOpponnent);
               break;
            case OpponentShooterMedia.TYPE:
               _oElement = new OpponentShooter(_oMedia,_oPos,_bFlipped);
               this.oContainer.addBitmappedAnimation(OpponentShooter(_oElement).animStateMachine,sLAYER_CHARACTER);
               this.oEventManager.addEventListener(sEVENT_MANAGER_ID,_oElement as AbstractOpponent,GamePlayerEvent.KILL_OPPONENT,this.onKillOpponnent);
               break;
            case OpponentWalkerMedia.TYPE:
               _oElement = new OpponentWalker(_oMedia,_oPos,_bFlipped);
               this.oContainer.addBitmappedAnimation(OpponentWalker(_oElement).animStateMachine,sLAYER_CHARACTER);
               this.oEventManager.addEventListener(sEVENT_MANAGER_ID,_oElement as AbstractOpponent,GamePlayerEvent.KILL_OPPONENT,this.onKillOpponnent);
               break;
            case BonusCoinMedia.TYPE:
               _oElement = new BonusCoin(_oMedia,_oPos);
               this.oContainer.addBitmappedAnimation(BonusCoin(_oElement).animStateMachine,sLAYER_COLLECTABLES);
               this.oEventManager.addEventListener(sEVENT_MANAGER_ID,_oElement as BonusCoin,GamePlayerEvent.COLLECT_COIN,this.onCollectCoin);
               break;
            case BonusExtraLifeMedia.TYPE:
               _oElement = new BonusExtraLife(_oMedia,_oPos);
               this.oContainer.addBitmappedAnimation(BonusExtraLife(_oElement).animStateMachine,sLAYER_COLLECTABLES);
               break;
            case BonusInvincibilityMedia.TYPE:
               _oElement = new BonusInvincibility(_oMedia,_oPos);
               this.oContainer.addBitmappedAnimation(BonusInvincibility(_oElement).animStateMachine,sLAYER_COLLECTABLES);
               break;
            case GoalMedia.TYPE:
               _oElement = new Goal(_oMedia,_oPos);
               this.oContainer.addBitmappedAnimation(Goal(_oElement).animStateMachine,sLAYER_COLLECTABLES);
               this.oEventManager.addEventListener(sEVENT_MANAGER_ID,_oElement as Goal,GamePlayerEvent.COLLECT_GOAL,this.onCollectGoal);
               break;
            case PropsMedia.TYPE:
               this.oStillGenerator.addElement(new StillElement(PropsMedia(_oMedia).bitmapData,_oPos.x,_oPos.y));
         }
         if(Boolean(_oElement))
         {
            this.aLevelElements.push(_oElement);
         }
      }
      
      public function createProjectile(_oMedia:AbstractMedia, _oPos:Point, _bFlipped:Boolean = false) : void
      {
         var _oElement:AbstractGameElement = null;
         switch(_oMedia.type)
         {
            case OpponentShooterMedia.TYPE:
               _oElement = new ShooterProjectile(_oMedia,_oPos,_bFlipped);
               this.oContainer.addBitmappedAnimation(ShooterProjectile(_oElement).animStateMachine,sLAYER_CHARACTER);
         }
         this.aLevelElements.push(_oElement);
      }
      
      public function removeElement(_oElement:AbstractGameElement) : void
      {
         switch(_oElement.type)
         {
            case PlatformObjectMedia.TYPE:
            case TileFatalMedia.TYPE:
            case TilePlatformMedia.TYPE:
            case TileSurfaceMedia.TYPE:
            case TileSlipperyMedia.TYPE:
               break;
            case PlayableCharacterMedia.TYPE:
               this.oContainer.removeAnimation(this.oPlayer.animStateMachine);
               this.oEventManager.removeEventListener(sEVENT_MANAGER_ID,this.oPlayer,GamePlayerEvent.GAME_LOSE,this.onLose);
               this.oPlayer = null;
               break;
            case OpponentJumperMedia.TYPE:
               this.oContainer.removeAnimation(OpponentJumper(_oElement).animStateMachine);
               this.oEventManager.removeEventListener(sEVENT_MANAGER_ID,_oElement as AbstractOpponent,GamePlayerEvent.KILL_OPPONENT,this.onKillOpponnent);
               break;
            case OpponentShooterMedia.TYPE:
               this.oContainer.removeAnimation(OpponentShooter(_oElement).animStateMachine);
               this.oEventManager.removeEventListener(sEVENT_MANAGER_ID,_oElement as AbstractOpponent,GamePlayerEvent.KILL_OPPONENT,this.onKillOpponnent);
               break;
            case OpponentWalkerMedia.TYPE:
               this.oContainer.removeAnimation(OpponentWalker(_oElement).animStateMachine);
               this.oEventManager.removeEventListener(sEVENT_MANAGER_ID,_oElement as AbstractOpponent,GamePlayerEvent.KILL_OPPONENT,this.onKillOpponnent);
               break;
            case BonusCoinMedia.TYPE:
               this.oContainer.removeAnimation(BonusCoin(_oElement).animStateMachine);
               this.oEventManager.removeEventListener(sEVENT_MANAGER_ID,_oElement as BonusCoin,GamePlayerEvent.COLLECT_COIN,this.onCollectCoin);
               break;
            case BonusExtraLifeMedia.TYPE:
               this.oContainer.removeAnimation(BonusExtraLife(_oElement).animStateMachine);
               break;
            case BonusInvincibilityMedia.TYPE:
               this.oContainer.removeAnimation(BonusInvincibility(_oElement).animStateMachine);
               break;
            case GoalMedia.TYPE:
               this.oContainer.removeAnimation(Goal(_oElement).animStateMachine);
               this.oEventManager.removeEventListener(sEVENT_MANAGER_ID,_oElement as Goal,GamePlayerEvent.COLLECT_GOAL,this.onCollectGoal);
               break;
            case ShooterProjectile.TYPE:
               this.oContainer.removeAnimation(ShooterProjectile(_oElement).animStateMachine);
         }
         var _nPos:int = this.aLevelElements.indexOf(_oElement);
         if(_nPos != -1)
         {
            this.aLevelElements.splice(_nPos,1);
         }
         _oElement.destroy();
      }
      
      public function kamikaze() : void
      {
         this.oPlayer.gameRestarted = true;
         this.oPlayer.die();
      }
      
      private function initLevelBounds() : void
      {
         var _oBounds:Rectangle = this.oGameData.bounds.clone();
         _oBounds.top -= Math.max(1500,Math.abs(_oBounds.top));
         this.oPosOffset = _oBounds.topLeft.clone();
         if(this.mcContainer.stage.stageWidth > _oBounds.width)
         {
            this.nLevelWidth = this.mcContainer.stage.stageWidth;
            this.oPosOffset.x -= (this.mcContainer.stage.stageWidth - _oBounds.width) / 2;
         }
         else
         {
            this.nLevelWidth = _oBounds.width;
         }
         if(this.mcContainer.stage.stageHeight > _oBounds.height)
         {
            this.nLevelHeight = this.mcContainer.stage.stageHeight;
            this.oPosOffset.y -= (this.mcContainer.stage.stageHeight - _oBounds.height) / 2;
         }
         else
         {
            this.nLevelHeight = _oBounds.height;
         }
      }
      
      private function initHUD() : void
      {
         var _mcHUD:MovieClip = new mcHUD();
         this.oDepthManager.getLayer(sDEPTH_HUD).addChild(_mcHUD);
         this.oHUD = new GamePlayerHUD(_mcHUD);
         this.oHUD.enabled = false;
         GameSession.instance.hud = this.oHUD;
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oHUD,GamePlayerEvent.REQUEST_MENU,this.onRequestMenu);
      }
      
      private function initContainer() : void
      {
         var _mcLayerLevel:Sprite = this.oDepthManager.getLayer(sDEPTH_LEVEL);
         this.oContainer = new BitmappedAnimContainer(this.nLevelWidth,this.nLevelHeight,this.mcContainer.stage.stageWidth,this.mcContainer.stage.stageHeight);
         _mcLayerLevel.addChild(this.oContainer);
         this.oContainer.addLayer(sLAYER_TILES);
         this.oContainer.addLayer(sLAYER_COLLECTABLES);
         this.oContainer.addLayer(sLAYER_CHARACTER);
         this.oStillGenerator = new StillGenerator();
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oStillGenerator,StillGeneratorEvent.PANEL_ADDED,this.onStillPanelAdded);
         Viewport.instance.setContainer(this.oContainer,new AABB2(0,this.nLevelWidth,0,this.nLevelHeight));
      }
      
      private function initBackground() : void
      {
         var _oStage:Stage = ViewManager.instance.stage;
         var _oMedia:BackgroundMedia = this.oMediaList.getMedia(this.oGameData.backgroundAlias) as BackgroundMedia;
         this.oBackground = new BackgroundManager();
         this.oBackground.init(_oStage.stageWidth,_oStage.stageHeight,_oMedia,this.oPosOffset);
         this.oDepthManager.getLayer(sDEPTH_LEVEL).addChildAt(this.oBackground.bitmap,0);
      }
      
      private function scanGameElement() : void
      {
         var _oElement:GameDataElement = null;
         var _oMedia:AbstractMedia = null;
         var _oViewPos:Point = null;
         for(var i:uint = 0; i < this.oGameData.levelElements.length; i++)
         {
            _oElement = this.oGameData.levelElements[i];
            _oMedia = this.oMediaList.getMedia(_oElement.alias);
            if(_oMedia == null)
            {
               continue;
            }
            switch(_oMedia.type)
            {
               case PlayableCharacterMedia.TYPE:
                  _oViewPos = new Point(_oElement.x - this.oPosOffset.x,0);
                  Viewport.instance.targetPoint(_oViewPos);
                  this.oBackground.updatePos(this.oContainer.viewX,this.oContainer.viewY);
                  this.oGoalDisplay = new GoalDisplay(this.oContainer,this.oContainer.viewX,this.oContainer.viewY,sLAYER_CHARACTER,this.oGameData.goal);
                  break;
               case OpponentJumperMedia.TYPE:
               case OpponentShooterMedia.TYPE:
               case OpponentWalkerMedia.TYPE:
                  HelpPopup.addWatchOut(_oMedia);
                  ++GameSession.instance.opponentLeft;
                  break;
               case TileFatalMedia.TYPE:
                  HelpPopup.addWatchOut(_oMedia);
                  break;
               case BonusCoinMedia.TYPE:
                  HelpPopup.setCoinMedia(_oMedia as BonusCoinMedia);
                  this.oHUD.initCoinDisplay(_oMedia as BonusCoinMedia);
                  ++GameSession.instance.coinsLeft;
                  break;
               case GoalMedia.TYPE:
                  ++GameSession.instance.goalLeft;
            }
         }
      }
      
      private function onElementCreation(_e:UpdateEvent) : void
      {
         var _oElement:GameDataElement = null;
         var _oMedia:AbstractMedia = null;
         var _oPos:Point = null;
         var _nMaxTime:uint = getTimer() + 1000 / 35;
         var _nElementCount:uint = this.oGameData.levelElements.length;
         while(getTimer() < _nMaxTime && this.nCurrentElementCreation < _nElementCount)
         {
            _oElement = this.oGameData.levelElements[this.nCurrentElementCreation];
            _oMedia = this.oMediaList.getMedia(_oElement.alias);
            _oPos = new Point(_oElement.x - this.oPosOffset.x,_oElement.y - this.oPosOffset.y);
            if(Boolean(_oMedia))
            {
               this.createElement(_oMedia,_oPos,_oElement.flip,_oElement.linkage);
            }
            ++this.nCurrentElementCreation;
         }
         if(this.nCurrentElementCreation >= _nElementCount && getTimer() > this.nGenerationStartTime + nMIN_GOAL_DISPLAY)
         {
            this.onAllElementCreated();
         }
      }
      
      private function onAllElementCreated() : void
      {
         this.oEventManager.removeEventListener(sEVENT_MANAGER_ID,UpdateManager.instance,UpdateEvent.UPDATE_PAUSED,this.onElementCreation);
         UpdateManager.instance.resume();
         this.oHUD.enabled = true;
         TileManager.instance.initTilesPhysic();
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,UpdateManager.instance,UpdateEvent.UPDATE,this.onUpdate,false,1);
      }
      
      private function onUpdate(_e:UpdateEvent) : void
      {
         PhysEngine.instance.update();
         Viewport.instance.update();
         this.oBackground.updatePos(this.oContainer.viewX,this.oContainer.viewY);
      }
      
      private function onStillPanelAdded(_e:StillGeneratorEvent) : void
      {
         this.oContainer.addBitmappedAnimation(_e.panel,sLAYER_TILES);
      }
      
      private function onCollectGoal(_e:Event) : void
      {
         --GameSession.instance.goalLeft;
         if(GameSession.instance.goalLeft == 0)
         {
            this.bGameCompleted = true;
            this.oHUD.enabled = false;
            this.oPlayer.setControlsEnabled(false);
            dispatchEvent(new GamePlayerEvent(GamePlayerEvent.GAME_WIN));
         }
      }
      
      private function onCollectCoin(_e:Event) : void
      {
         --GameSession.instance.coinsLeft;
         ++GameSession.instance.coinsCollected;
         if(GameSession.instance.coinsLeft == 0 && this.oGameData.goal == CommonConfig.sGOAL_TYPE_COIN)
         {
            this.bGameCompleted = true;
            this.oHUD.enabled = false;
            this.oPlayer.setControlsEnabled(false);
            dispatchEvent(new GamePlayerEvent(GamePlayerEvent.GAME_WIN));
         }
      }
      
      private function onKillOpponnent(_e:Event) : void
      {
         --GameSession.instance.opponentLeft;
         if(GameSession.instance.opponentLeft == 0 && this.oGameData.goal == CommonConfig.sGOAL_TYPE_OPPONENT)
         {
            this.bGameCompleted = true;
            this.oHUD.enabled = false;
            this.oPlayer.setControlsEnabled(false);
            dispatchEvent(new GamePlayerEvent(GamePlayerEvent.GAME_WIN));
         }
      }
      
      private function onLose(_e:Event) : void
      {
         this.bGameCompleted = true;
         this.oHUD.enabled = false;
         this.oPlayer.setControlsEnabled(false);
         dispatchEvent(new GamePlayerEvent(GamePlayerEvent.GAME_LOSE));
      }
      
      private function onRequestMenu(_e:GamePlayerEvent) : void
      {
         dispatchEvent(new GamePlayerEvent(GamePlayerEvent.REQUEST_MENU));
      }
      
      public function get container() : BitmappedAnimContainer
      {
         return this.oContainer;
      }
      
      public function get levelWidth() : Number
      {
         return this.nLevelWidth;
      }
      
      public function get levelHeight() : Number
      {
         return this.nLevelHeight;
      }
      
      public function get mediaList() : MediaList
      {
         return this.oMediaList;
      }
      
      public function get gameData() : GameData
      {
         return this.oGameData;
      }
   }
}

