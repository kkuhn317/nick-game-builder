package builderManager
{
   import builderManager.elements.BuilderElement;
   import builderManager.elements.FatalElement;
   import builderManager.elements.GoalElement;
   import builderManager.elements.OpponentElement;
   import builderManager.elements.PlatformElement;
   import builderManager.elements.PlayableCharacterElement;
   import builderManager.elements.PropsElement;
   import builderManager.elements.TileElement;
   import com.sarbakan.sbdk.core.UpdateManager;
   import com.sarbakan.sbdk.data.spatialIndexing.ISpatialIndexElement;
   import com.sarbakan.sbdk.data.spatialIndexing.sweepAndPrune.SweepAndPruneScene;
   import com.sarbakan.sbdk.events.UpdateEvent;
   import com.sarbakan.sbdk.math.geom.AABB2;
   import com.sarbakan.sbdk.utils.EventManager;
   import data.GameData;
   import data.GameDataElement;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Rectangle;
   import media.MediaList;
   import media.type.AbstractMedia;
   import media.type.BonusCoinMedia;
   import media.type.GoalMedia;
   import media.type.OpponentJumperMedia;
   import media.type.OpponentShooterMedia;
   import media.type.OpponentWalkerMedia;
   import media.type.PlayableCharacterMedia;
   import media.type.PropsMedia;
   import media.type.TileFatalMedia;
   import media.type.TilePlatformMedia;
   import media.type.TileSlipperyMedia;
   import media.type.TileSurfaceMedia;
   
   public class BuilderData extends EventDispatcher
   {
      
      private static const sEVENT_MANAGER_ID:String = "eventManager";
      
      private var oEventManager:EventManager;
      
      private var aElements:Array;
      
      private var oSAP:SweepAndPruneScene;
      
      private var aElementToInvalidate:Array;
      
      private var bInvalidate:Boolean;
      
      private var bIsTemplate:Boolean;
      
      private var nCoinCount:uint;
      
      private var nOpponentCount:uint;
      
      private var nGoalCount:uint;
      
      private var oPlayer:PlayableCharacterElement;
      
      private var oGoal:GoalElement;
      
      public function BuilderData(_oGameData:GameData, _bIsTemplate:Boolean = false)
      {
         super();
         this.init();
         this.populateFromGameData(_oGameData,_bIsTemplate);
         this.bIsTemplate = _bIsTemplate;
      }
      
      public static function createElementFromMedia(_nX:Number, _nY:Number, _oMedia:AbstractMedia, _bFlip:Boolean, _sLinkage:String = null) : BuilderElement
      {
         var _oReturn:BuilderElement = null;
         switch(_oMedia.type)
         {
            case PlayableCharacterMedia.TYPE:
               _oReturn = new PlayableCharacterElement(_nX,_nY,_oMedia,_bFlip);
               break;
            case OpponentJumperMedia.TYPE:
            case OpponentWalkerMedia.TYPE:
            case OpponentShooterMedia.TYPE:
               _oReturn = new OpponentElement(_nX,_nY,_oMedia,_bFlip);
               break;
            case GoalMedia.TYPE:
               _oReturn = new GoalElement(_nX,_nY,_oMedia,_bFlip);
               break;
            case TileSurfaceMedia.TYPE:
            case TileSlipperyMedia.TYPE:
               _oReturn = new TileElement(_nX,_nY,_oMedia,_bFlip,_sLinkage);
               break;
            case TileFatalMedia.TYPE:
               _oReturn = new FatalElement(_nX,_nY,_oMedia,_bFlip);
               break;
            case TilePlatformMedia.TYPE:
               _oReturn = new PlatformElement(_nX,_nY,_oMedia,_bFlip);
               break;
            case PropsMedia.TYPE:
               _oReturn = new PropsElement(_nX,_nY,_oMedia,_bFlip);
               break;
            default:
               _oReturn = new BuilderElement(_nX,_nY,_oMedia,_bFlip);
         }
         return _oReturn;
      }
      
      public function destroy() : void
      {
         var _oElement:BuilderElement = null;
         if(Boolean(this.oSAP))
         {
            this.oSAP.destroy();
         }
         this.oSAP = null;
         if(Boolean(this.aElements))
         {
            for each(_oElement in this.aElements)
            {
               _oElement.destroy();
            }
         }
         this.aElements = null;
         this.oPlayer = null;
         this.oGoal = null;
         if(Boolean(this.oEventManager))
         {
            this.oEventManager.destroy();
         }
         this.oEventManager = null;
      }
      
      public function addElement(_oElement:BuilderElement, _bKeepAsTemplate:Boolean = false) : void
      {
         var _bInstantUpdate:Boolean = false;
         _oElement.spatialIndex = this.oSAP.addElement(_oElement.bounds,_oElement);
         this.aElements.push(_oElement);
         this.invalidateSurrounding(_oElement.bounds);
         this.addElementToInvalidate(_oElement);
         if(_oElement.mediaType == BonusCoinMedia.TYPE)
         {
            ++this.nCoinCount;
            _bInstantUpdate = Boolean(this.bIsTemplate && _bKeepAsTemplate);
         }
         else if(_oElement.mediaType == OpponentJumperMedia.TYPE || _oElement.mediaType == OpponentShooterMedia.TYPE || _oElement.mediaType == OpponentWalkerMedia.TYPE)
         {
            ++this.nOpponentCount;
            _bInstantUpdate = Boolean(this.bIsTemplate && _bKeepAsTemplate);
         }
         else if(_oElement.mediaType == PlayableCharacterMedia.TYPE)
         {
            this.oPlayer = _oElement as PlayableCharacterElement;
            _bInstantUpdate = this.bIsTemplate;
         }
         else if(_oElement.mediaType == GoalMedia.TYPE)
         {
            ++this.nGoalCount;
            this.oGoal = _oElement as GoalElement;
            _bInstantUpdate = this.bIsTemplate;
         }
         this.bInvalidate = true;
         if(_bInstantUpdate)
         {
            this.onUpdate(null);
            this.bIsTemplate = true;
         }
      }
      
      public function removeElement(_oElement:BuilderElement) : void
      {
         this.invalidateSurrounding(_oElement.bounds);
         if(_oElement.mediaType == BonusCoinMedia.TYPE)
         {
            --this.nCoinCount;
         }
         else if(_oElement.mediaType == OpponentJumperMedia.TYPE || _oElement.mediaType == OpponentShooterMedia.TYPE || _oElement.mediaType == OpponentWalkerMedia.TYPE)
         {
            --this.nOpponentCount;
         }
         else if(_oElement.mediaType == PlayableCharacterMedia.TYPE)
         {
            this.oPlayer = null;
         }
         else if(_oElement.mediaType == GoalMedia.TYPE)
         {
            --this.nGoalCount;
            this.oGoal = null;
         }
         this.aElements.splice(this.aElements.indexOf(_oElement),1);
         this.oSAP.removeElement(_oElement.spatialIndex);
         _oElement.destroy();
         this.bInvalidate = true;
      }
      
      public function updateElementPos(_oElement:BuilderElement, _nNewX:int, _nNewY:int) : void
      {
         this.invalidateSurrounding(_oElement.bounds);
         var _nOffsetX:Number = _nNewX - _oElement.bounds.nXMin;
         var _nOffsetY:Number = _nNewY - _oElement.bounds.nYMin;
         _oElement.bounds.offset(_nOffsetX,_nOffsetY);
         this.invalidateSurrounding(_oElement.bounds);
         _oElement.spatialIndex.setPositionBox(_oElement.bounds);
         this.addElementToInvalidate(_oElement);
         this.bInvalidate = true;
      }
      
      public function queryRegion(_oRegion:AABB2) : Array
      {
         return this.oSAP.queryBounds(_oRegion.nXMin,_oRegion.nXMax,_oRegion.nYMin,_oRegion.nYMax);
      }
      
      public function queryBounds(_nXMin:Number, _nXMax:Number, _nYMin:Number, _nYMax:Number) : Array
      {
         return this.oSAP.queryBounds(_nXMin,_nXMax,_nYMin,_nYMax);
      }
      
      public function queryRectangle(_oRect:Rectangle) : Array
      {
         return this.oSAP.queryRectangle(_oRect);
      }
      
      public function invalidateSurrounding(_oBounds:AABB2) : void
      {
         var _oIndex:ISpatialIndexElement = null;
         var _oSurrounding:AABB2 = _oBounds.clone();
         _oSurrounding.nXMin -= CommonConfig.nCELL_SIZE;
         _oSurrounding.nXMax += CommonConfig.nCELL_SIZE;
         _oSurrounding.nYMin -= CommonConfig.nCELL_SIZE;
         _oSurrounding.nYMax += CommonConfig.nCELL_SIZE;
         var _aElements:Array = this.queryRegion(_oSurrounding);
         for each(_oIndex in _aElements)
         {
            this.addElementToInvalidate(_oIndex.data as BuilderElement);
         }
      }
      
      public function copyToGameData(_oGameData:GameData) : void
      {
         var _oElement:BuilderElement = null;
         var _oElemBounds:AABB2 = null;
         var _oBounds:Rectangle = new Rectangle(NaN,NaN,NaN,NaN);
         var _aElements:Array = new Array();
         for each(_oElement in this.aElements)
         {
            _oElemBounds = _oElement.bounds;
            _aElements.push(new GameDataElement(_oElement.mediaAlias,_oElemBounds.nXMin,_oElemBounds.nYMin,_oElement.flip,_oElement.linkage));
            if(isNaN(_oBounds.left) || _oBounds.left > _oElemBounds.nXMin)
            {
               _oBounds.left = _oElemBounds.nXMin;
            }
            if(isNaN(_oBounds.right) || _oBounds.right < _oElemBounds.nXMax)
            {
               _oBounds.right = _oElemBounds.nXMax;
            }
            if(isNaN(_oBounds.top) || _oBounds.top > _oElemBounds.nYMin)
            {
               _oBounds.top = _oElemBounds.nYMin;
            }
            if(isNaN(_oBounds.bottom) || _oBounds.bottom < _oElemBounds.nYMax)
            {
               _oBounds.bottom = _oElemBounds.nYMax;
            }
         }
         _oGameData.levelElements = _aElements;
         _oGameData.bounds = _oBounds;
      }
      
      public function getElementsFromType(... _aTypes) : Array
      {
         var _oElem:BuilderElement = null;
         var _sType:String = null;
         var _aReturn:Array = new Array();
         for each(_oElem in this.aElements)
         {
            for each(_sType in _aTypes)
            {
               if(_oElem.mediaType == _sType)
               {
                  _aReturn.push(_oElem);
                  break;
               }
            }
         }
         return _aReturn;
      }
      
      private function init() : void
      {
         this.oEventManager = new EventManager();
         this.oSAP = new SweepAndPruneScene();
         this.aElements = new Array();
         this.aElementToInvalidate = new Array();
         this.nCoinCount = 0;
         this.nOpponentCount = 0;
         this.nGoalCount = 0;
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,UpdateManager.instance,UpdateEvent.UPDATE,this.onUpdate);
      }
      
      private function populateFromGameData(_oGameData:GameData, _bIsTemplate:Boolean = false) : void
      {
         var _oMedia:AbstractMedia = null;
         var _oElement:GameDataElement = null;
         var _oMediaList:MediaList = BuilderMain.instance.mediaList;
         for each(_oElement in _oGameData.levelElements)
         {
            _oMedia = _oMediaList.getMedia(_oElement.alias);
            if(Boolean(_oMedia))
            {
               if(_bIsTemplate == false || _oMedia.type != PlayableCharacterMedia.TYPE && _oMedia.type != BonusCoinMedia.TYPE && _oMedia.type != GoalMedia.TYPE && _oMedia.type != OpponentJumperMedia.TYPE && _oMedia.type != OpponentShooterMedia.TYPE && _oMedia.type != OpponentWalkerMedia.TYPE)
               {
                  this.addElement(createElementFromMedia(_oElement.x,_oElement.y,BuilderMain.instance.mediaList.getMedia(_oElement.alias),_oElement.flip,_oElement.linkage));
               }
            }
         }
         this.bInvalidate = false;
         this.onUpdate(null);
      }
      
      private function addElementToInvalidate(_oElement:BuilderElement) : void
      {
         if(this.aElementToInvalidate.indexOf(_oElement) == -1)
         {
            this.aElementToInvalidate.push(_oElement);
         }
      }
      
      private function onUpdate(_e:UpdateEvent) : void
      {
         if(this.bInvalidate || this.aElementToInvalidate.length > 0)
         {
            this.oSAP.update();
            while(this.aElementToInvalidate.length > 0)
            {
               BuilderElement(this.aElementToInvalidate.pop()).invalidate();
            }
            this.bIsTemplate = false;
            dispatchEvent(new Event(Event.CHANGE));
         }
         this.bInvalidate = false;
      }
      
      public function get coinCount() : uint
      {
         return this.nCoinCount;
      }
      
      public function get hasCoin() : Boolean
      {
         return Boolean(this.coinCount > 0);
      }
      
      public function get opponentCount() : uint
      {
         return this.nOpponentCount;
      }
      
      public function get hasOpponent() : Boolean
      {
         return Boolean(this.opponentCount > 0);
      }
      
      public function get player() : PlayableCharacterElement
      {
         return this.oPlayer;
      }
      
      public function get goal() : GoalElement
      {
         return this.oGoal;
      }
      
      public function get hasGoal() : Boolean
      {
         return Boolean(this.nGoalCount > 0);
      }
      
      public function get isTemplate() : Boolean
      {
         return this.bIsTemplate;
      }
      
      public function get bounds() : AABB2
      {
         return this.oSAP.bounds;
      }
   }
}

