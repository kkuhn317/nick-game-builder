package com.sarbakan.sbdk.view
{
   import com.sarbakan.sbdk.asset.AssetReference;
   import com.sarbakan.sbdk.core.UpdateManager;
   import com.sarbakan.sbdk.errors.ErrorMessages;
   import com.sarbakan.sbdk.events.TransitionEvent;
   import com.sarbakan.sbdk.events.UpdateEvent;
   import com.sarbakan.sbdk.events.ViewEvent;
   import com.sarbakan.sbdk.utils.EventManager;
   import com.sarbakan.sbdk.utils.ObjectList;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.utils.getQualifiedSuperclassName;
   
   [Event(name="RESUME",type="com.sarbakan.sbdk.events.TransitionEvent")]
   [Event(name="PAUSE",type="com.sarbakan.sbdk.events.TransitionEvent")]
   [Event(name="COMPLETE",type="com.sarbakan.sbdk.events.TransitionEvent")]
   [Event(name="STOP",type="com.sarbakan.sbdk.events.TransitionEvent")]
   [Event(name="START",type="com.sarbakan.sbdk.events.TransitionEvent")]
   [Event(name="ERROR",type="com.sarbakan.sbdk.events.ViewEvent")]
   [Event(name="HIDE",type="com.sarbakan.sbdk.events.ViewEvent")]
   [Event(name="SHOW",type="com.sarbakan.sbdk.events.ViewEvent")]
   public class ViewManager extends Sprite
   {
      
      private static var oInstance:ViewManager;
      
      private static var bAllowConstruction:Boolean = false;
      
      private const sTRANSITION_EVENT:String = "TRANSITION_EVENT";
      
      private const sSTAGE_EVENT:String = "STAGE_EVENT";
      
      private const sUPDATE_EVENT:String = "UPDATE_EVENT";
      
      private const sEFFECT_TRANSITION:String = "com.sarbakan.sbdk.view::AbstractEffectTransition";
      
      private const sANIM_TRANSITION:String = "com.sarbakan.sbdk.view::AbstractTransition";
      
      private var lViewList:ObjectList;
      
      private var oDepthManager:DepthManager;
      
      private var oEventManager:EventManager;
      
      private var oTransitionManager:TransitionManager;
      
      private var oUpdateManager:UpdateManager;
      
      private var mcMouseBlocker:Sprite;
      
      private var lCrossTransitList:ObjectList;
      
      private var bOnTopTransition:Boolean;
      
      private var bOnTopTransitionPausable:Boolean;
      
      private var oOnTopTransition:AbstractTransition;
      
      public function ViewManager()
      {
         super();
         if(!bAllowConstruction)
         {
            throw new Error(ErrorMessages.sSINGLETON_ERROR);
         }
         this.init();
      }
      
      public static function get instance() : ViewManager
      {
         if(!oInstance)
         {
            bAllowConstruction = true;
            oInstance = new ViewManager();
            bAllowConstruction = false;
         }
         return oInstance;
      }
      
      public function destroy() : void
      {
         var i:AbstractView = null;
         if(this.lCrossTransitList != null)
         {
            this.lCrossTransitList.clear();
            this.lCrossTransitList.destroy();
            this.lCrossTransitList = null;
         }
         if(this.oTransitionManager != null)
         {
            this.oTransitionManager.destroy();
            this.oTransitionManager = null;
         }
         if(this.oDepthManager != null)
         {
            this.oDepthManager.destroy();
            this.oDepthManager = null;
         }
         if(this.lViewList != null)
         {
            for each(i in this.lViewList.object)
            {
               i.destroy();
            }
            this.lViewList.clear();
            this.lViewList.destroy();
            this.lViewList = null;
         }
         if(this.oEventManager != null)
         {
            this.oEventManager.clearAll();
            this.oEventManager.destroy();
            this.oEventManager = null;
         }
         oInstance = null;
         this.oUpdateManager = null;
      }
      
      public function addView(_sViewId:String, _oViewRef:AbstractView) : void
      {
         this.lViewList.insert(_sViewId,_oViewRef);
         _oViewRef.ID = _sViewId;
         this.oEventManager.addEventListener(_sViewId,_oViewRef,ViewEvent.SHOW,this.onViewShow);
         this.oEventManager.addEventListener(_sViewId,_oViewRef,ViewEvent.HIDE,this.onViewHide);
         this.oEventManager.addEventListener(_sViewId,_oViewRef,ViewEvent.ERROR,this.onViewError);
      }
      
      public function removeView(_sViewId:String) : void
      {
         var _oView:AbstractView = this.lViewList.find(_sViewId);
         if(_oView != null)
         {
            this.oEventManager.cleanUp(_sViewId);
            this.lViewList.remove(_sViewId);
         }
      }
      
      public function showView(_sViewId:String, _sLayerID:String, _nDepth:int = -1, _nX:int = 0, _nY:int = 0, _sTransitionID:String = null, _bTransitionPausable:Boolean = false, _bPlayTransitionOnTop:Boolean = false) : void
      {
         var _oTransition:AbstractTransition = null;
         var _oTargetView:AbstractView = this.lViewList.find(_sViewId);
         if(_oTargetView != null && !_oTargetView.isTransiting && !_oTargetView.isDisplayed)
         {
            _oTargetView.x = _nX;
            _oTargetView.y = _nY;
            _oTargetView.layerID = _sLayerID;
            _oTargetView.depth = _nDepth;
            _oTargetView.transitionPausable = _bTransitionPausable;
            if(_sTransitionID != null)
            {
               _oTransition = this.oTransitionManager.getTransition(_sTransitionID);
               if(_oTransition != null)
               {
                  _oTargetView.setCurrentTransition(_oTransition,true);
               }
            }
            this.oDepthManager.addDisplayObject(_oTargetView.ID,_oTargetView.mcContainer,_oTargetView.layerID,_oTargetView.depth);
            _oTargetView.display();
         }
      }
      
      public function playTransitionOnTop(_sTransitionID:String, _bPausable:Boolean = true, _nX:uint = 0, _nY:uint = 0, _bUseMouseBlocker:Boolean = true) : void
      {
         var _oTransition:AbstractTransition = this.oTransitionManager.getTransition(_sTransitionID);
         if(_oTransition != null && !this.bOnTopTransition)
         {
            this.bOnTopTransitionPausable = _bPausable;
            this.oOnTopTransition = _oTransition;
            _oTransition.mcContainer.x = _nX;
            _oTransition.mcContainer.y = _nY;
            addChildAt(_oTransition.mcContainer,numChildren);
            if(_bUseMouseBlocker)
            {
               this.mcMouseBlocker = new Sprite();
               this.mcMouseBlocker.graphics.beginFill(0);
               this.mcMouseBlocker.graphics.drawRect(0,0,stage.stageWidth,stage.stageHeight);
               this.mcMouseBlocker.graphics.endFill();
               this.mcMouseBlocker.alpha = 0;
               addChildAt(this.mcMouseBlocker,numChildren);
            }
            if(getQualifiedSuperclassName(_oTransition) == this.sEFFECT_TRANSITION)
            {
               _oTransition.start(this.stage);
            }
            else if(getQualifiedSuperclassName(_oTransition) == this.sANIM_TRANSITION)
            {
               AnimTransition(_oTransition).display();
            }
            this.bOnTopTransition = true;
         }
      }
      
      public function playTransitionAtLayer(_sTransitionID:String, _sLayerID:String, _bPausable:Boolean = true, _nX:uint = 0, _nY:uint = 0, _bUseMouseBlocker:Boolean = true) : void
      {
         var _oLayer:Sprite = null;
         var _oTransition:AbstractTransition = this.oTransitionManager.getTransition(_sTransitionID);
         if(_oTransition != null && !this.bOnTopTransition)
         {
            this.bOnTopTransitionPausable = _bPausable;
            this.oOnTopTransition = _oTransition;
            _oTransition.mcContainer.x = _nX;
            _oTransition.mcContainer.y = _nY;
            _oLayer = this.oDepthManager.getLayer(_sLayerID);
            if(_oLayer != null)
            {
               _oLayer.addChild(_oTransition.mcContainer);
               if(_bUseMouseBlocker)
               {
                  this.mcMouseBlocker = new Sprite();
                  this.mcMouseBlocker.graphics.beginFill(0);
                  this.mcMouseBlocker.graphics.drawRect(0,0,stage.stageWidth,stage.stageHeight);
                  this.mcMouseBlocker.graphics.endFill();
                  this.mcMouseBlocker.alpha = 0;
                  _oLayer.addChild(this.mcMouseBlocker);
               }
            }
            if(getQualifiedSuperclassName(_oTransition) == this.sEFFECT_TRANSITION)
            {
               _oTransition.start(this.stage);
            }
            else if(getQualifiedSuperclassName(_oTransition) == this.sANIM_TRANSITION)
            {
               AnimTransition(_oTransition).display();
            }
            this.bOnTopTransition = true;
         }
      }
      
      public function transitView(_sOriginViewID:String, _sDestinationViewID:String, _sOriginTransitionID:String = null, _sDestinationTransitionID:String = null, _bTransitionPausable:Boolean = false, _bPlayTransitionOnTop:Boolean = false) : void
      {
         var oTransInfo:TransitionStruct = null;
         var _oOriginView:AbstractView = this.lViewList.find(_sOriginViewID);
         var _oDestinationView:AbstractView = this.lViewList.find(_sDestinationViewID);
         if(_oOriginView != null && !_oOriginView.isTransiting)
         {
            if(_oOriginView.isDisplayed)
            {
               oTransInfo = new TransitionStruct();
               oTransInfo.sTargetShowViewID = _sDestinationViewID;
               oTransInfo.sLayerID = _oOriginView.layerID;
               oTransInfo.nDepth = _oOriginView.depth;
               oTransInfo.nX = _oOriginView.x;
               oTransInfo.nY = _oOriginView.y;
               oTransInfo.sTargetTransition = _sDestinationTransitionID;
               oTransInfo.bTransitionPausable = _bTransitionPausable;
               oTransInfo.bPlayTransitionOnTop = _bPlayTransitionOnTop;
               this.lCrossTransitList.insert(_sOriginViewID,oTransInfo);
               this.hideView(_sOriginViewID,_sOriginTransitionID,_bTransitionPausable,_bPlayTransitionOnTop);
            }
         }
      }
      
      public function hideView(_sViewId:String, _sTransitionID:String = null, _bTransitionPausable:Boolean = false, _bPlayTransitionOnTop:Boolean = false) : void
      {
         var _oTransition:AbstractTransition = null;
         var _oTargetView:AbstractView = this.lViewList.find(_sViewId);
         if(_oTargetView != null && !_oTargetView.isTransiting)
         {
            _oTargetView.transitionPausable = _bTransitionPausable;
            if(_sTransitionID == null)
            {
               _oTargetView.beforeHide();
            }
            else
            {
               _oTransition = this.oTransitionManager.getTransition(_sTransitionID);
               if(_oTransition != null)
               {
                  _oTargetView.setCurrentTransition(_oTransition,false,_bPlayTransitionOnTop);
               }
            }
         }
      }
      
      public function disableView(_sViewId:String) : void
      {
         var _oTargetView:AbstractView = this.lViewList.find(_sViewId);
         if(_oTargetView != null)
         {
            _oTargetView.onDisable();
         }
      }
      
      public function enableView(_sViewId:String) : void
      {
         var _oTargetView:AbstractView = this.lViewList.find(_sViewId);
         if(_oTargetView != null)
         {
            _oTargetView.onEnable();
         }
      }
      
      public function getView(_sViewId:String) : AbstractView
      {
         return this.lViewList.find(_sViewId);
      }
      
      public function isViewDisplayed(_sViewId:String) : Boolean
      {
         var _oTargetView:AbstractView = this.lViewList.find(_sViewId);
         if(_oTargetView != null)
         {
            return _oTargetView.isDisplayed;
         }
         return false;
      }
      
      public function addAnimTransition(_sTransitionID:String, _oAnimAsset:AssetReference) : void
      {
         this.oTransitionManager.addAnimTransition(_sTransitionID,_oAnimAsset);
      }
      
      public function addEffectTransition(_sTransitionID:String, _oEffectTransition:AbstractEffectTransition) : void
      {
         this.oTransitionManager.addEffectTransition(_sTransitionID,_oEffectTransition);
      }
      
      public function removeTransition(_sTransitionID:String) : void
      {
         this.oTransitionManager.removeTransition(_sTransitionID);
      }
      
      public function getTransition(_sTransitionID:String) : AbstractTransition
      {
         return this.oTransitionManager.getTransition(_sTransitionID);
      }
      
      private function pauseView() : void
      {
         var i:AbstractView = null;
         for each(i in this.lViewList.object)
         {
            if(i.isDisplayed)
            {
               i.pause();
            }
         }
      }
      
      private function resumeView() : void
      {
         var i:AbstractView = null;
         for each(i in this.lViewList.object)
         {
            if(i.isDisplayed)
            {
               i.resume();
            }
         }
      }
      
      private function init() : void
      {
         this.lCrossTransitList = new ObjectList();
         this.bOnTopTransitionPausable = true;
         this.bOnTopTransition = false;
         this.oDepthManager = new DepthManager(this);
         this.lViewList = new ObjectList();
         this.oEventManager = new EventManager();
         this.oTransitionManager = new TransitionManager();
         this.oEventManager.addEventListener(this.sTRANSITION_EVENT,this.oTransitionManager,TransitionEvent.COMPLETE,this.onTransitionEvent);
         this.oEventManager.addEventListener(this.sTRANSITION_EVENT,this.oTransitionManager,TransitionEvent.ERROR,this.onTransitionEvent);
         this.oEventManager.addEventListener(this.sTRANSITION_EVENT,this.oTransitionManager,TransitionEvent.PAUSE,this.onTransitionEvent);
         this.oEventManager.addEventListener(this.sTRANSITION_EVENT,this.oTransitionManager,TransitionEvent.RESUME,this.onTransitionEvent);
         this.oEventManager.addEventListener(this.sTRANSITION_EVENT,this.oTransitionManager,TransitionEvent.START,this.onTransitionEvent);
         this.oEventManager.addEventListener(this.sTRANSITION_EVENT,this.oTransitionManager,TransitionEvent.STOP,this.onTransitionEvent);
         this.oEventManager.addEventListener(this.sSTAGE_EVENT,this,Event.ADDED_TO_STAGE,this.onAddedToStage);
      }
      
      private function crossShowView(_sTargetViewID:String, _sLayerID:String, _nDepth:int, _nX:int, _nY:int, _mcOriginViewAssetRef:DisplayObject, _sTransitionID:String = null, _bTransitionPausable:Boolean = false, _bPlayTransitionOnTop:Boolean = false) : void
      {
         var _oTransition:AbstractTransition = null;
         var _oTargetView:AbstractView = this.lViewList.find(_sTargetViewID);
         if(_oTargetView != null)
         {
            _oTargetView.x = _nX;
            _oTargetView.y = _nY;
            _oTargetView.layerID = _sLayerID;
            _oTargetView.depth = _nDepth;
            _oTargetView.transitionPausable = _bTransitionPausable;
            if(_sTransitionID != null)
            {
               _oTransition = this.oTransitionManager.getTransition(_sTransitionID);
               if(_oTransition != null)
               {
                  _oTransition.originViewAssetRef = _mcOriginViewAssetRef;
                  _oTargetView.setCurrentTransition(_oTransition,true,_bPlayTransitionOnTop);
               }
            }
            this.oDepthManager.addDisplayObject(_oTargetView.ID,_oTargetView.mcContainer,_oTargetView.layerID,_oTargetView.depth);
            _oTargetView.display();
         }
      }
      
      private function setUpdateManager() : void
      {
         this.oUpdateManager = UpdateManager.instance;
         this.oEventManager.addEventListener(this.sUPDATE_EVENT,this.oUpdateManager,UpdateEvent.PAUSE,this.onUpdateEvent);
         this.oEventManager.addEventListener(this.sUPDATE_EVENT,this.oUpdateManager,UpdateEvent.RESUME,this.onUpdateEvent);
      }
      
      private function onViewError(_oEvent:ViewEvent) : void
      {
         dispatchEvent(_oEvent);
      }
      
      private function onViewShow(_oEvent:ViewEvent) : void
      {
         dispatchEvent(_oEvent);
      }
      
      private function onViewHide(_oEvent:ViewEvent) : void
      {
         var _oTransitConfig:TransitionStruct = null;
         if(this.lCrossTransitList.find(_oEvent.viewID) != null)
         {
            _oTransitConfig = this.lCrossTransitList.find(_oEvent.viewID);
            this.crossShowView(_oTransitConfig.sTargetShowViewID,_oTransitConfig.sLayerID,_oTransitConfig.nDepth,_oTransitConfig.nX,_oTransitConfig.nY,_oEvent.assetRef,_oTransitConfig.sTargetTransition,_oTransitConfig.bTransitionPausable,_oTransitConfig.bPlayTransitionOnTop);
            this.lCrossTransitList.remove(_oEvent.viewID);
         }
         dispatchEvent(_oEvent);
      }
      
      private function onAddedToStage(_oEvent:Event) : void
      {
         this.oEventManager.cleanUp(this.sSTAGE_EVENT);
         this.setUpdateManager();
      }
      
      private function onUpdateEvent(_oEvent:UpdateEvent) : void
      {
         switch(_oEvent.type)
         {
            case UpdateEvent.PAUSE:
               this.pauseView();
               if(this.bOnTopTransition && this.bOnTopTransitionPausable)
               {
                  this.oOnTopTransition.pause();
               }
               break;
            case UpdateEvent.RESUME:
               this.resumeView();
               if(this.bOnTopTransition && this.bOnTopTransitionPausable)
               {
                  this.oOnTopTransition.resume();
               }
         }
      }
      
      private function onTransitionEvent(_oEvent:TransitionEvent) : void
      {
         if(_oEvent.type == TransitionEvent.COMPLETE && this.bOnTopTransition)
         {
            this.bOnTopTransition = false;
            _oEvent.asset.parent.removeChild(_oEvent.asset);
            if(this.mcMouseBlocker != null)
            {
               this.mcMouseBlocker.parent.removeChild(this.mcMouseBlocker);
               this.mcMouseBlocker = null;
            }
         }
         dispatchEvent(_oEvent);
      }
      
      public function get depthManager() : DepthManager
      {
         return this.oDepthManager;
      }
   }
}

class TransitionStruct
{
   
   public var sTargetShowViewID:String;
   
   public var sLayerID:String;
   
   public var nDepth:int;
   
   public var nX:uint;
   
   public var nY:uint;
   
   public var sTargetTransition:String;
   
   public var bTransitionPausable:Boolean;
   
   public var bPlayTransitionOnTop:Boolean;
   
   public function TransitionStruct()
   {
      super();
   }
}
