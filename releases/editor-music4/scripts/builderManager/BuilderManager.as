package builderManager
{
   import builderManager.elements.BuilderElement;
   import builderManager.elements.GoalElement;
   import builderManager.elements.PlayableCharacterElement;
   import com.sarbakan.sbdk.data.spatialIndexing.ISpatialIndexElement;
   import com.sarbakan.sbdk.math.geom.AABB2;
   import com.sarbakan.sbdk.utils.EventManager;
   import com.sarbakan.sbdk.view.ViewManager;
   import data.GameDataElement;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   import media.type.AbstractMedia;
   import media.type.BonusCoinMedia;
   import media.type.GoalMedia;
   import media.type.OpponentJumperMedia;
   import media.type.OpponentShooterMedia;
   import media.type.OpponentWalkerMedia;
   import media.type.PlayableCharacterMedia;
   import ui.events.PopupEvent;
   import ui.popups.ConfirmPopup;
   
   public class BuilderManager
   {
      
      private static var oInstance:BuilderManager;
      
      private static const sEVENT_MANAGER_ID:String = "eventManager";
      
      private var mcContent:MovieClip;
      
      private var mcGoalIcon:MovieClip;
      
      private var oEventManager:EventManager;
      
      private var oRenderer:BuilderRenderer;
      
      private var oBuilderData:BuilderData;
      
      public function BuilderManager(_mcContent:MovieClip)
      {
         super();
         oInstance = this;
         this.mcContent = _mcContent;
         this.oEventManager = new EventManager();
         this.oBuilderData = new BuilderData(BuilderMain.instance.gameData);
         this.oRenderer = new BuilderRenderer(this.mcContent,this.oBuilderData);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oBuilderData,Event.CHANGE,this.onDataChange);
         this.changeGoalDisplayType();
         this.targetHero();
      }
      
      public static function get instance() : BuilderManager
      {
         return oInstance;
      }
      
      public function destroy() : void
      {
         if(Boolean(this.oRenderer))
         {
            this.oRenderer.destroy();
         }
         this.oRenderer = null;
         if(Boolean(this.oBuilderData))
         {
            this.oBuilderData.destroy();
         }
         this.oBuilderData = null;
         if(Boolean(this.oEventManager))
         {
            this.oEventManager.destroy();
         }
         this.oEventManager = null;
         oInstance = null;
      }
      
      public function copyToGameData() : void
      {
         this.oRenderer.takeSnapshot(this.oBuilderData.bounds);
         this.oBuilderData.copyToGameData(BuilderMain.instance.gameData);
      }
      
      public function updateBackground() : void
      {
         this.oRenderer.updateBackground();
      }
      
      public function updateHero() : void
      {
         var _oPlayerPos:Point = null;
         var _aElements:Array = null;
         var _oElement:BuilderElement = null;
         var _oGoalMedia:GoalMedia = null;
         var _oPos:Point = null;
         var _oPlayer:PlayableCharacterElement = this.oBuilderData.player;
         if(Boolean(_oPlayer))
         {
            this.removeElement(_oPlayer);
         }
         var _oPlayerMedia:PlayableCharacterMedia = BuilderMain.instance.mediaList.getMedia(BuilderMain.instance.gameData.heroAlias) as PlayableCharacterMedia;
         if(Boolean(_oPlayerMedia))
         {
            if(Boolean(BuilderMain.instance.templateData))
            {
               _oPlayerPos = BuilderMain.instance.templateData.getPlayerPos(_oPlayerMedia);
            }
            else
            {
               _oPlayerPos = new Point();
            }
            _oPlayer = new PlayableCharacterElement(_oPlayerPos.x,_oPlayerPos.y,_oPlayerMedia,false);
            _aElements = this.getElementInRegion(_oPlayer.bounds);
            for each(_oElement in _aElements)
            {
               if(_oElement.mediaType == GoalMedia.TYPE)
               {
                  _oGoalMedia = BuilderMain.instance.mediaList.getMedia(_oElement.mediaAlias) as GoalMedia;
                  _oPos = BuilderMain.instance.templateData.getGoalPos(_oGoalMedia);
                  this.updateElementPos(_oElement,_oPos.x,_oPos.y);
                  break;
               }
            }
            this.addElement(_oPlayer,true);
            this.oRenderer.centerOnElement(_oPlayer);
         }
      }
      
      public function updateGoal() : void
      {
         var _oFocusElement:BuilderElement = null;
         var _aExisting:Array = null;
         var _oExisting:BuilderElement = null;
         var _bCanAdd:Boolean = false;
         var _oGoal:GoalElement = null;
         var _oMedia:AbstractMedia = null;
         var _aOldElements:Array = null;
         var _aNewElements:Array = null;
         var _oElement:GameDataElement = null;
         var _oGoalPos:Point = null;
         var _oPlayerMedia:PlayableCharacterMedia = null;
         var _oPos:Point = null;
         var _sGoalType:String = BuilderMain.instance.gameData.goal;
         if(Boolean(_sGoalType))
         {
            _oGoal = this.oBuilderData.goal;
            if(this.isTemplate)
            {
               _aOldElements = this.oBuilderData.getElementsFromType(OpponentJumperMedia.TYPE,OpponentShooterMedia.TYPE,OpponentWalkerMedia.TYPE,BonusCoinMedia.TYPE);
               for each(_oExisting in _aOldElements)
               {
                  this.removeElement(_oExisting);
               }
            }
            if(_sGoalType != CommonConfig.sGOAL_TYPE_DOOR)
            {
               if(Boolean(_oGoal))
               {
                  _aOldElements = this.oBuilderData.getElementsFromType(GoalMedia.TYPE);
                  for each(_oExisting in _aOldElements)
                  {
                     this.removeElement(_oExisting);
                  }
               }
               if(_sGoalType == CommonConfig.sGOAL_TYPE_COIN)
               {
                  _aNewElements = BuilderMain.instance.templateData.coins;
               }
               else if(_sGoalType == CommonConfig.sGOAL_TYPE_OPPONENT)
               {
                  _aNewElements = BuilderMain.instance.templateData.opponents;
               }
               for each(_oElement in _aNewElements)
               {
                  _oMedia = BuilderMain.instance.mediaList.getMedia(_oElement.alias);
                  _oFocusElement = BuilderData.createElementFromMedia(_oElement.x,_oElement.y,_oMedia,_oElement.flip,_oElement.linkage);
                  _bCanAdd = true;
                  _aExisting = this.getElementInRegion(_oFocusElement.bounds);
                  for each(_oExisting in _aExisting)
                  {
                     if(_oExisting.isUnique)
                     {
                        _bCanAdd = false;
                        break;
                     }
                  }
                  if(_bCanAdd)
                  {
                     this.addElement(_oFocusElement,true);
                  }
                  else
                  {
                     _oFocusElement.destroy();
                  }
               }
            }
            else if(_oGoal == null)
            {
               _oMedia = BuilderMain.instance.mediaList.getMediaFromType([GoalMedia.TYPE])[0];
               _oGoalPos = BuilderMain.instance.templateData.getGoalPos(_oMedia as GoalMedia);
               _oGoal = new GoalElement(_oGoalPos.x,_oGoalPos.y,_oMedia,false);
               _aExisting = this.getElementInRegion(_oGoal.bounds);
               for each(_oExisting in _aExisting)
               {
                  if(_oExisting.mediaType == PlayableCharacterMedia.TYPE)
                  {
                     _oPlayerMedia = BuilderMain.instance.mediaList.getMedia(_oExisting.mediaAlias) as PlayableCharacterMedia;
                     _oPos = BuilderMain.instance.templateData.getPlayerPos(_oPlayerMedia);
                     this.updateElementPos(_oExisting,_oPos.x,_oPos.y);
                     break;
                  }
               }
               this.addElement(_oGoal,true);
               _oFocusElement = _oGoal;
            }
            else
            {
               _oFocusElement = _oGoal;
            }
         }
      }
      
      public function targetHero() : void
      {
         var _oPos:Point = null;
         if(Boolean(this.oBuilderData.player))
         {
            this.oRenderer.centerOnElement(this.oBuilderData.player);
         }
         else
         {
            if(Boolean(BuilderMain.instance.templateData))
            {
               _oPos = BuilderMain.instance.templateData.getPlayerPos(null);
            }
            else
            {
               _oPos = new Point();
            }
            this.oRenderer.updateCenterPos(_oPos.x,_oPos.y);
         }
      }
      
      public function targetGoal() : void
      {
         var _oPos:Point = null;
         if(Boolean(this.oBuilderData.goal))
         {
            this.oRenderer.centerOnElement(this.oBuilderData.goal);
         }
         else
         {
            if(Boolean(BuilderMain.instance.templateData))
            {
               _oPos = BuilderMain.instance.templateData.getGoalPos(null);
            }
            else
            {
               _oPos = new Point();
            }
            this.oRenderer.updateCenterPos(_oPos.x,_oPos.y);
         }
      }
      
      public function addElement(_oElement:BuilderElement, _bKeepAsTemplate:Boolean = false) : void
      {
         this.eraseAllUnderElement(_oElement);
         this.oBuilderData.addElement(_oElement,_bKeepAsTemplate);
         this.updateGoalDisplay();
      }
      
      public function removeElement(_oElement:BuilderElement) : void
      {
         this.oBuilderData.removeElement(_oElement);
         this.updateGoalDisplay();
      }
      
      public function updateElementPos(_oElement:BuilderElement, _nNewX:int, _nNewY:int) : void
      {
         this.oBuilderData.updateElementPos(_oElement,_nNewX,_nNewY);
         this.eraseAllUnderElement(_oElement);
      }
      
      public function getElementAt(_nX:int, _nY:int) : BuilderElement
      {
         var _oElement:BuilderElement = null;
         var _aElements:Array = this.oBuilderData.queryBounds(_nX,_nX,_nY,_nY);
         if(_aElements.length > 0)
         {
            _oElement = ISpatialIndexElement(_aElements[0]).data as BuilderElement;
         }
         return _oElement;
      }
      
      public function getElementInRegion(_oRegion:AABB2) : Array
      {
         var _aReturn:Array = null;
         var _oIndex:ISpatialIndexElement = null;
         var _aElements:Array = this.oBuilderData.queryRegion(_oRegion);
         if(_aElements.length > 0)
         {
            _aReturn = new Array();
            for each(_oIndex in _aElements)
            {
               _aReturn.push(_oIndex.data);
            }
         }
         return _aReturn;
      }
      
      public function invalidateSurrounding(_oBounds:AABB2) : void
      {
         this.oBuilderData.invalidateSurrounding(_oBounds);
      }
      
      public function findEmptySpot(_oElementToPlace:BuilderElement, _nOrignalX:Number) : void
      {
         var _oElement:BuilderElement = null;
         var _aElements:Array = this.getElementInRegion(_oElementToPlace.bounds);
         var _bCanPlace:Boolean = true;
         for each(_oElement in _aElements)
         {
            if(_oElement.isUnique)
            {
               if(_oElementToPlace.mediaType != _oElement.mediaType)
               {
                  _bCanPlace = false;
                  break;
               }
            }
         }
         if(_bCanPlace == false)
         {
            if(_nOrignalX < 0)
            {
               _oElementToPlace.bounds.offset(CommonConfig.nCELL_SIZE,0);
            }
            else
            {
               _oElementToPlace.bounds.offset(-CommonConfig.nCELL_SIZE,0);
            }
            this.findEmptySpot(_oElementToPlace,_nOrignalX);
         }
      }
      
      public function validateLevelContent() : Boolean
      {
         var _sValidationLocale:String = null;
         var _oPopup:ConfirmPopup = null;
         var _bValid:Boolean = false;
         switch(BuilderMain.instance.gameData.goal)
         {
            case CommonConfig.sGOAL_TYPE_DOOR:
               _bValid = this.oBuilderData.hasGoal;
               _sValidationLocale = "id_ui_step_play_invalidGameConfirmText_goal";
               break;
            case CommonConfig.sGOAL_TYPE_COIN:
               _bValid = this.oBuilderData.hasCoin;
               _sValidationLocale = "id_ui_step_play_invalidGameConfirmText_coin";
               break;
            case CommonConfig.sGOAL_TYPE_OPPONENT:
               _bValid = this.oBuilderData.hasOpponent;
               _sValidationLocale = "id_ui_step_play_invalidGameConfirmText_opponent";
         }
         if(!_bValid)
         {
            _oPopup = ViewManager.instance.getView(BuilderMain.sPOPUP_CONFIRM) as ConfirmPopup;
            this.oEventManager.addEventListener(sEVENT_MANAGER_ID,_oPopup,PopupEvent.CONFIRM,this.onTestConfirm);
            this.oEventManager.addEventListener(sEVENT_MANAGER_ID,_oPopup,PopupEvent.CANCEL,this.onTestCancel);
            BuilderMain.instance.showConfirmPopup("id_ui_step_play_invalidGameConfirmTitle",_sValidationLocale,"id_ui_step_play_invalidGame_btnConfirm","id_ui_step_play_invalidGame_btnCancel");
         }
         return _bValid;
      }
      
      public function changeGoalDisplayType() : void
      {
         var _nScale:Number = NaN;
         var _mcContainer:MovieClip = this.mcContent.mcGoalDisplay;
         var _mcIcon:MovieClip = _mcContainer.mcIcon;
         if(Boolean(this.mcGoalIcon))
         {
            _mcIcon.removeChild(this.mcGoalIcon);
         }
         switch(BuilderMain.instance.gameData.goal)
         {
            case CommonConfig.sGOAL_TYPE_COIN:
               this.mcGoalIcon = new mcCoinGoalIcon();
               break;
            case CommonConfig.sGOAL_TYPE_OPPONENT:
               this.mcGoalIcon = new mcOpponentGoalIcon();
               break;
            default:
               this.mcGoalIcon = null;
         }
         if(Boolean(this.mcGoalIcon))
         {
            _nScale = Math.min(1,_mcIcon.width / this.mcGoalIcon.width,_mcIcon.height / this.mcGoalIcon.height);
            this.mcGoalIcon.scaleX = _nScale;
            this.mcGoalIcon.scaleY = _nScale;
            _mcIcon.addChild(this.mcGoalIcon);
            _mcContainer.visible = true;
         }
         else
         {
            _mcContainer.visible = false;
         }
         this.updateGoalDisplay();
      }
      
      private function updateGoalDisplay() : void
      {
         var _nCount:uint = 0;
         switch(BuilderMain.instance.gameData.goal)
         {
            case CommonConfig.sGOAL_TYPE_COIN:
               _nCount = this.oBuilderData.coinCount;
               break;
            case CommonConfig.sGOAL_TYPE_OPPONENT:
               _nCount = this.oBuilderData.opponentCount;
         }
         this.mcContent.mcGoalDisplay.mcText.txtText.text = "x" + _nCount;
      }
      
      private function eraseAllUnderElement(_oElement:BuilderElement) : void
      {
         var _oIndex:ISpatialIndexElement = null;
         var _oEraseElement:BuilderElement = null;
         var _aElements:Array = this.oBuilderData.queryRegion(_oElement.bounds);
         for each(_oIndex in _aElements)
         {
            _oEraseElement = _oIndex.data as BuilderElement;
            if(_oEraseElement != _oElement)
            {
               this.removeElement(_oEraseElement);
            }
         }
      }
      
      private function onDataChange(_e:Event) : void
      {
         if(BuilderMain.instance.editorPrototype) return;
         StepManager.instance.enableStep(StepManager.sSTEP_PUBLISH,false);
      }
      
      private function onTestConfirm(_e:PopupEvent) : void
      {
         this.oEventManager.removeEventListener(sEVENT_MANAGER_ID,_e.target as ConfirmPopup,PopupEvent.CONFIRM,this.onTestConfirm);
         this.oEventManager.removeEventListener(sEVENT_MANAGER_ID,_e.target as ConfirmPopup,PopupEvent.CANCEL,this.onTestCancel);
         StepManager.instance.gotoStep(StepManager.sSTEP_TEST);
      }
      
      private function onTestCancel(_e:PopupEvent) : void
      {
         this.oEventManager.removeEventListener(sEVENT_MANAGER_ID,_e.target as ConfirmPopup,PopupEvent.CONFIRM,this.onTestConfirm);
         this.oEventManager.removeEventListener(sEVENT_MANAGER_ID,_e.target as ConfirmPopup,PopupEvent.CANCEL,this.onTestCancel);
         BuilderMain.instance.hidePopup(BuilderMain.sPOPUP_CONFIRM);
      }
      
      public function get container() : MovieClip
      {
         return this.mcContent;
      }
      
      public function get renderer() : BuilderRenderer
      {
         return this.oRenderer;
      }
      
      public function get builderData() : BuilderData
      {
         return this.oBuilderData;
      }
      
      public function set builderData(_oValue:BuilderData) : void
      {
         this.oEventManager.cleanUp(sEVENT_MANAGER_ID);
         if(Boolean(this.oBuilderData))
         {
            this.oBuilderData.destroy();
         }
         this.oBuilderData = _oValue;
         this.oRenderer.builderData = this.oBuilderData;
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oBuilderData,Event.CHANGE,this.onDataChange);
         this.updateGoal();
         this.updateHero();
         var _oNewBounds:AABB2 = this.oBuilderData.bounds;
         this.oRenderer.updateCenterPos(_oNewBounds.nXMin + (_oNewBounds.nXMax - _oNewBounds.nXMin) / 2,_oNewBounds.nYMin + (_oNewBounds.nYMax - _oNewBounds.nYMin) / 2);
         this.changeGoalDisplayType();
      }
      
      public function get isTemplate() : Boolean
      {
         return Boolean(this.oBuilderData != null && this.oBuilderData.isTemplate);
      }
   }
}

