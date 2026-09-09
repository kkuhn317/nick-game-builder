package com.sarbakan.sbdk.view
{
   import com.sarbakan.sbdk.asset.AssetManager;
   import com.sarbakan.sbdk.asset.AssetReference;
   import com.sarbakan.sbdk.asset.DisplayAsset;
   import com.sarbakan.sbdk.errors.AssetError;
   import com.sarbakan.sbdk.errors.ErrorMessages;
   import com.sarbakan.sbdk.events.TransitionEvent;
   import com.sarbakan.sbdk.events.ViewEvent;
   import com.sarbakan.sbdk.utils.EventManager;
   import com.sarbakan.sbdk.utils.FrameTimer;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.errors.IllegalOperationError;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   import flash.utils.getQualifiedSuperclassName;
   
   [Event(name="ERROR",type="com.sarbakan.sbdk.events.ViewEvent")]
   [Event(name="HIDE",type="com.sarbakan.sbdk.events.ViewEvent")]
   [Event(name="SHOW",type="com.sarbakan.sbdk.events.ViewEvent")]
   public class AbstractView extends EventDispatcher
   {
      
      private static const sASSET_EVENT:String = "ASSET_EVENT";
      
      private static const sTRANSITION_EVENT:String = "TRANSITION_EVENT";
      
      private static const sTIMER_EVENT:String = "TIMER_EVENT";
      
      private static const sTRANSITION_IN:String = "TRANSITION_IN";
      
      private static const sTRANSITION_OUT:String = "TRANSITION_OUT";
      
      private static const sEFFECT_TRANSITION:String = "com.sarbakan.sbdk.view::AbstractEffectTransition";
      
      private static const sANIM_TRANSITION:String = "com.sarbakan.sbdk.view::AbstractTransition";
      
      private static const sSHOW_STATUS:String = "SHOW_STATUS";
      
      private static const sHIDE_STATUS:String = "HIDE_STATUS";
      
      protected var bUseMouseBlocker:Boolean;
      
      private var sId:String;
      
      private var oAssetRef:DisplayAsset;
      
      private var mcContainerRef:Sprite;
      
      private var oEventManager:EventManager;
      
      private var oAssetLocation:AssetReference;
      
      private var oAssetManager:AssetManager;
      
      private var oViewCache:BitmapData;
      
      private var mcAssetCache:Bitmap;
      
      private var nX:int;
      
      private var nY:int;
      
      private var sLayerID:String;
      
      private var nDepth:int;
      
      private var bIsDisplayed:Boolean;
      
      private var oTransition:AbstractTransition;
      
      private var bTransiting:Boolean;
      
      private var sTransitionMode:String;
      
      private var bTransitionPausable:Boolean;
      
      private var bPersistentAsset:Boolean;
      
      private var bHide:Boolean;
      
      private var bShow:Boolean;
      
      private var oShowHideTimer:FrameTimer;
      
      private var sShowHideStatus:String;
      
      private var mcMouseBlocker:Sprite;
      
      private var bPlayTransitionOnTop:Boolean;
      
      private var bPaused:Boolean;
      
      public function AbstractView(_oAssetLocation:AssetReference = null, _bPersistentAsset:Boolean = false, _bUseMouseBlocker:Boolean = true)
      {
         super();
         if(Class(getDefinitionByName(getQualifiedClassName(this))) == AbstractView)
         {
            throw new IllegalOperationError(ErrorMessages.sABSTRACT_CLASS_ERROR);
         }
         this.oAssetLocation = _oAssetLocation;
         this.bPersistentAsset = _bPersistentAsset;
         this.bUseMouseBlocker = _bUseMouseBlocker;
         this.initialize();
      }
      
      protected function init() : void
      {
      }
      
      protected function showContainer() : void
      {
         this.mcContainerRef.visible = true;
      }
      
      protected function showMouseBlocker() : void
      {
         if(this.mcMouseBlocker == null)
         {
            this.mcMouseBlocker = new Sprite();
            this.mcMouseBlocker.graphics.beginFill(0);
            this.mcMouseBlocker.graphics.drawRect(0,0,this.mcContainerRef.stage.stageWidth,this.mcContainerRef.stage.stageHeight);
            this.mcMouseBlocker.graphics.endFill();
            this.mcMouseBlocker.alpha = 0;
            this.mcContainer.addChild(this.mcMouseBlocker);
         }
      }
      
      protected function hideMouseBlocker() : void
      {
         if(Boolean(this.mcMouseBlocker))
         {
            this.mcContainer.removeChild(this.mcMouseBlocker);
            this.mcMouseBlocker = null;
         }
      }
      
      public function destroy() : void
      {
         if(!this.bPersistentAsset)
         {
            this.oAssetRef = null;
            this.mcContainerRef = null;
         }
         this.oAssetManager = null;
         this.oEventManager.clearAll();
         this.oEventManager.destroy();
         this.oEventManager = null;
         this.oShowHideTimer.stop();
         this.oShowHideTimer = null;
      }
      
      public function onAssetInit() : void
      {
      }
      
      public function onBeforeShow() : void
      {
      }
      
      public function onShow() : void
      {
      }
      
      public function onBeforeHide() : void
      {
      }
      
      public function onHide() : void
      {
      }
      
      public function onDisable() : void
      {
      }
      
      public function onEnable() : void
      {
      }
      
      public function preventHide() : void
      {
         this.bHide = false;
      }
      
      public function resumeHide() : void
      {
         this.bHide = true;
      }
      
      public function preventShow() : void
      {
         this.bShow = false;
      }
      
      public function resumeShow() : void
      {
         this.bShow = true;
      }
      
      public function pause() : void
      {
         if(this.bTransitionPausable)
         {
            if(this.oTransition != null)
            {
               if(this.oTransition.isPlaying)
               {
                  this.oTransition.pause();
               }
            }
         }
         this.bPaused = true;
         this.onPause();
      }
      
      public function onPause() : void
      {
      }
      
      public function resume() : void
      {
         if(this.bTransitionPausable)
         {
            if(this.oTransition != null)
            {
               if(this.oTransition.isPlaying)
               {
                  this.oTransition.resume();
               }
            }
         }
         this.bPaused = false;
         this.onResume();
      }
      
      public function onResume() : void
      {
      }
      
      override public function toString() : String
      {
         return "[AbstractView: ID = " + this.sId + ", X = " + this.nX + ", Y = " + this.nY + ", Layer = " + this.sLayerID + ", Depth = " + this.nDepth + ", Displayed = " + this.bIsDisplayed + ", Transiting = " + this.bIsDisplayed + ", Persistent asset = " + this.bPersistentAsset + "]";
      }
      
      internal function show() : void
      {
         if(this.asset != null)
         {
            this.mcContainer.visible = true;
            if(this.oTransition != null)
            {
               this.manageTransitionType();
            }
            else
            {
               dispatchEvent(new ViewEvent(ViewEvent.SHOW,false,false,this.ID,null));
               this.onShow();
            }
         }
         else
         {
            dispatchEvent(new ViewEvent(ViewEvent.SHOW,false,false,this.ID,null));
            this.onShow();
         }
      }
      
      internal function beforeShow() : void
      {
         this.sShowHideStatus = sSHOW_STATUS;
         this.bShow = true;
         this.onBeforeShow();
         if(!this.bShow)
         {
            this.oShowHideTimer.start();
         }
         else
         {
            this.show();
         }
      }
      
      internal function hide() : void
      {
         this.bIsDisplayed = false;
         this.resetContentAnimation();
         this.mcAssetCache = this.captureView();
         this.cleanUpTransition();
         this.killAsset();
         this.onHide();
         dispatchEvent(new ViewEvent(ViewEvent.HIDE,false,false,this.ID,this.mcAssetCache));
         this.oViewCache.dispose();
         this.mcAssetCache = null;
         this.oViewCache = null;
      }
      
      internal function beforeHide() : void
      {
         this.sShowHideStatus = sHIDE_STATUS;
         this.onBeforeHide();
         if(!this.bHide)
         {
            this.oShowHideTimer.start();
         }
         else
         {
            this.initHide();
         }
      }
      
      internal function display() : void
      {
         this.bIsDisplayed = true;
         this.onAssetInit();
         if(this.oAssetLocation != null)
         {
            if(this.oAssetRef == null)
            {
               this.oAssetManager.requestAsset(this.oAssetLocation,this.onAssetComplete,this.onAssetError);
            }
            else if(!this.mcContainer.contains(this.oAssetRef.content))
            {
               this.mcContainer.addChild(this.oAssetRef.content);
               this.beforeShow();
            }
         }
         else
         {
            this.beforeShow();
         }
      }
      
      internal function setCurrentTransition(_oTransitionRef:AbstractTransition, _bInMode:Boolean, _bPlayTransitionOnTop:Boolean = false) : void
      {
         this.oTransition = _oTransitionRef;
         this.bPlayTransitionOnTop = _bPlayTransitionOnTop;
         if(_bInMode)
         {
            this.sTransitionMode = sTRANSITION_IN;
         }
         else
         {
            this.sTransitionMode = sTRANSITION_OUT;
            this.beforeHide();
         }
      }
      
      internal function initialize() : void
      {
         this.bPaused = false;
         this.bIsDisplayed = false;
         this.bTransiting = false;
         this.bHide = true;
         this.bShow = true;
         this.bPlayTransitionOnTop = false;
         this.mcMouseBlocker = null;
         this.bTransitionPausable = false;
         this.x = 0;
         this.y = 0;
         this.mcContainerRef = new Sprite();
         this.mcContainer.x = this.x;
         this.mcContainer.y = this.y;
         this.oEventManager = new EventManager();
         this.oShowHideTimer = new FrameTimer(1,0,false);
         this.oEventManager.addEventListener(sTIMER_EVENT,this.oShowHideTimer,TimerEvent.TIMER,this.onTimerTick);
         this.oAssetManager = AssetManager.instance;
         this.init();
      }
      
      internal function cleanUpTransition() : void
      {
         if(this.oTransition != null)
         {
            if(!this.bPlayTransitionOnTop)
            {
               if(this.mcContainer.contains(this.oTransition.mcContainer))
               {
                  this.mcContainer.removeChild(this.oTransition.mcContainer);
               }
            }
            else if(this.mcContainer.parent.parent.contains(this.oTransition.mcContainer))
            {
               this.mcContainer.parent.parent.removeChild(this.oTransition.mcContainer);
            }
            this.oTransition.destroy();
            this.oTransition = null;
         }
      }
      
      private function initHide() : void
      {
         if(this.oTransition != null)
         {
            this.manageTransitionType();
         }
         else
         {
            this.hide();
         }
      }
      
      private function resetContentAnimation() : void
      {
         var i:int = 0;
         var _mc:DisplayObject = null;
         if(this.mcContent != null)
         {
            for(i = 0; i < this.mcContent.numChildren; i++)
            {
               _mc = this.mcContent.getChildAt(i);
               if(_mc is MovieClip)
               {
                  MovieClip(_mc).stop();
               }
            }
         }
      }
      
      private function captureView() : Bitmap
      {
         var _nCaptureWidth:int = 0;
         var _nCaptureHeight:int = 0;
         if(this.mcContainer.stage != null)
         {
            _nCaptureWidth = Math.min(this.mcContainer.width,this.mcContainer.stage.stageWidth);
            _nCaptureHeight = Math.min(this.mcContainer.height,this.mcContainer.stage.stageHeight);
         }
         if(_nCaptureWidth <= 0)
         {
            _nCaptureWidth = 1;
         }
         if(_nCaptureHeight <= 0)
         {
            _nCaptureHeight = 1;
         }
         this.oViewCache = new BitmapData(_nCaptureWidth,_nCaptureHeight,false,0);
         this.oViewCache.draw(this.mcContainer);
         return new Bitmap(this.oViewCache);
      }
      
      private function killAsset() : void
      {
         if(this.oAssetRef != null)
         {
            if(this.mcContainer.contains(this.oAssetRef.content))
            {
               this.mcContainer.removeChild(this.oAssetRef.content);
            }
            if(!this.bPersistentAsset)
            {
               this.oAssetRef = null;
            }
         }
         if(this.mcContainer.parent != null)
         {
            this.mcContainer.parent.removeChild(this.mcContainer);
         }
      }
      
      private function startEffectTransition() : void
      {
         if(this.oAssetRef != null)
         {
            if(this.bUseMouseBlocker)
            {
               this.showMouseBlocker();
            }
            if(!this.bPlayTransitionOnTop)
            {
               this.mcContainer.addChild(this.oTransition.mcContainer);
            }
            else
            {
               this.mcContainer.parent.parent.addChildAt(this.oTransition.mcContainer,this.mcContainer.parent.parent.numChildren);
            }
            this.oTransition.start(this.oAssetRef.content);
            this.bTransiting = true;
            this.oEventManager.addEventListener(sTRANSITION_EVENT,this.oTransition,TransitionEvent.COMPLETE,this.onTransitionComplete);
         }
      }
      
      private function startAnimTransition() : void
      {
         this.bTransiting = true;
         this.oEventManager.addEventListener(sTRANSITION_EVENT,this.oTransition,TransitionEvent.START,this.onTransitionStart);
         AnimTransition(this.oTransition).display();
      }
      
      private function manageTransitionType() : void
      {
         if(getQualifiedSuperclassName(this.oTransition) == sEFFECT_TRANSITION)
         {
            this.startEffectTransition();
         }
         else if(getQualifiedSuperclassName(this.oTransition) == sANIM_TRANSITION)
         {
            this.startAnimTransition();
         }
      }
      
      private function onTimerTick(_oEvent:TimerEvent) : void
      {
         if(this.sShowHideStatus == sSHOW_STATUS)
         {
            if(this.bShow)
            {
               this.oShowHideTimer.stop();
               this.show();
            }
         }
         else if(this.sShowHideStatus == sHIDE_STATUS)
         {
            if(this.bHide)
            {
               this.oShowHideTimer.stop();
               this.initHide();
            }
         }
      }
      
      private function onTransitionComplete(_oEvent:TransitionEvent) : void
      {
         this.oEventManager.cleanUp(sTRANSITION_EVENT);
         this.bTransiting = false;
         this.cleanUpTransition();
         if(this.bUseMouseBlocker)
         {
            this.hideMouseBlocker();
         }
         if(this.sTransitionMode == sTRANSITION_OUT)
         {
            this.hide();
         }
         else if(this.sTransitionMode == sTRANSITION_IN)
         {
            dispatchEvent(new ViewEvent(ViewEvent.SHOW,false,false,this.ID,null));
            this.onShow();
         }
      }
      
      private function onTransitionStart(_oEvent:TransitionEvent) : void
      {
         if(!this.bPlayTransitionOnTop)
         {
            this.mcContainer.addChild(this.oTransition.mcContainer);
         }
         else
         {
            this.mcContainer.parent.parent.addChildAt(this.oTransition.mcContainer,this.mcContainer.parent.parent.numChildren);
         }
         if(this.bUseMouseBlocker)
         {
            this.showMouseBlocker();
         }
         this.oEventManager.cleanUp(sTRANSITION_EVENT);
         this.oEventManager.addEventListener(sTRANSITION_EVENT,this.oTransition,TransitionEvent.COMPLETE,this.onTransitionComplete);
      }
      
      protected function onAssetComplete(_oAsset:DisplayAsset) : void
      {
         this.oAssetRef = _oAsset;
         this.mcContainer.x = this.x;
         this.mcContainer.y = this.y;
         this.mcContainer.visible = false;
         if(!this.mcContainer.contains(this.oAssetRef.content))
         {
            this.mcContainer.addChild(this.oAssetRef.content);
            this.beforeShow();
         }
      }
      
      protected function onAssetError(_oError:AssetError) : void
      {
         dispatchEvent(new ViewEvent(ViewEvent.ERROR,false,false,_oError.ID,null,_oError.error));
      }
      
      public function get isTransiting() : Boolean
      {
         return this.bTransiting;
      }
      
      public function get mcContainer() : Sprite
      {
         return this.mcContainerRef;
      }
      
      public function get asset() : DisplayAsset
      {
         return this.oAssetRef;
      }
      
      public function get mcContent() : MovieClip
      {
         if(this.oAssetRef != null)
         {
            return this.oAssetRef.content as MovieClip;
         }
         return null;
      }
      
      public function get ID() : String
      {
         return this.sId;
      }
      
      public function set ID(_sId:String) : void
      {
         if(this.sId == null)
         {
            this.sId = _sId;
         }
      }
      
      protected function get assetLocation() : AssetReference
      {
         return this.oAssetLocation;
      }
      
      protected function set assetLocation(_oLocation:AssetReference) : void
      {
         this.oAssetLocation = _oLocation;
      }
      
      protected function get eventManager() : EventManager
      {
         return this.oEventManager;
      }
      
      internal function get depth() : int
      {
         return this.nDepth;
      }
      
      internal function set depth(_nDepth:int) : void
      {
         this.nDepth = _nDepth;
      }
      
      internal function get layerID() : String
      {
         return this.sLayerID;
      }
      
      internal function set layerID(_sId:String) : void
      {
         this.sLayerID = _sId;
      }
      
      internal function get x() : int
      {
         return this.nX;
      }
      
      internal function set x(_nX:int) : void
      {
         this.nX = _nX;
      }
      
      internal function get y() : int
      {
         return this.nY;
      }
      
      internal function set y(_nY:int) : void
      {
         this.nY = _nY;
      }
      
      public function get paused() : Boolean
      {
         return this.bPaused;
      }
      
      public function get isDisplayed() : Boolean
      {
         return this.bIsDisplayed;
      }
      
      public function get transitionPausable() : Boolean
      {
         return this.bTransitionPausable;
      }
      
      public function set transitionPausable(_bPausable:Boolean) : void
      {
         this.bTransitionPausable = _bPausable;
      }
   }
}

