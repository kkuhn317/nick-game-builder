package com.sarbakan.sbdk.state
{
   import com.sarbakan.sbdk.asset.AssetManager;
   import com.sarbakan.sbdk.asset.AssetReference;
   import com.sarbakan.sbdk.asset.DisplayAsset;
   import com.sarbakan.sbdk.core.UpdateManager;
   import com.sarbakan.sbdk.errors.AssetError;
   import com.sarbakan.sbdk.events.UpdateEvent;
   import com.sarbakan.sbdk.utils.DisplayObjectUtils;
   import com.sarbakan.sbdk.utils.ObjectList;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class AnimStateMachine extends StateMachine
   {
      
      public static const sDEFAULT_STATE_MC_NAME:String = "mcState";
      
      private static const sEVENT_MANAGER_ID_INIT:String = "initCallBack";
      
      private static const sEVENT_MANAGER_ID_PAUSE:String = "pauseRender";
      
      private static const sEVENT_MANAGER_ID_RESUME:String = "resumeRender";
      
      private static const sEVENT_MANAGER_ID_PAUSEABLE:String = "pauseable";
      
      private static const sEVENT_MANAGER_ID_DELAYED:String = "delayed";
      
      private var mcContainerRef:DisplayObjectContainer;
      
      private var sStateMcName:String;
      
      private var oAnimLocation:AnimStateLocation;
      
      private var bInstantUpdate:Boolean;
      
      private var oStateAssetList:ObjectList;
      
      private var oStateAssetRefList:ObjectList;
      
      private var mcStateReference:MovieClip;
      
      private var bFirstStart:Boolean;
      
      private var bCacheAssetState:Boolean;
      
      public function AnimStateMachine(_mcContainer:DisplayObjectContainer, _bPauseable:Boolean = true, _bInstantUpdate:Boolean = true, _bWeakReference:Boolean = true)
      {
         super(StateMachineType.FRAME_BASED,_bPauseable,_bWeakReference);
         this.mcContainerRef = _mcContainer;
         this.bInstantUpdate = _bInstantUpdate;
         this.sStateMcName = sDEFAULT_STATE_MC_NAME;
         this.setAnimLocation(AnimStateLocation.TIMELINE);
         this.bFirstStart = true;
         this.bCacheAssetState = false;
      }
      
      override public function destroy() : void
      {
         super.destroy();
         if(this.oAnimLocation == AnimStateLocation.ASSET)
         {
            if(this.oStateAssetList != null)
            {
               this.oStateAssetList.clear();
               this.oStateAssetList.destroy();
               this.oStateAssetList = null;
            }
            if(this.mcStateReference != null)
            {
               if(this.mcContainerRef.contains(this.mcStateReference))
               {
                  this.mcContainerRef.removeChild(this.mcStateReference);
               }
            }
            if(this.oStateAssetRefList != null)
            {
               this.oStateAssetRefList.clear();
               this.oStateAssetRefList.destroy();
               this.oStateAssetRefList = null;
            }
         }
         this.mcContainerRef = null;
         this.mcStateReference = null;
      }
      
      public function setAnimLocation(_oAnimLocation:AnimStateLocation) : void
      {
         if(oStateStructs.length == 0)
         {
            this.oAnimLocation = _oAnimLocation;
         }
      }
      
      override public function addState(_sStateID:String, _fStateCallback:Function = null, _fStateInitCallback:Function = null, _fStateEndcallBack:Function = null) : void
      {
         var _bLabelExists:Boolean = DisplayObjectUtils.labelExists(_sStateID,this.mcContainerRef as MovieClip);
         if(this.oAnimLocation == AnimStateLocation.TIMELINE && _bLabelExists)
         {
            super.addState(_sStateID,_fStateCallback,_fStateInitCallback,_fStateEndcallBack);
            this.setLooping(_sStateID,true);
         }
      }
      
      override public function removeState(_sStateID:String) : void
      {
         super.removeState(_sStateID);
         if(this.oStateAssetRefList != null)
         {
            this.oStateAssetRefList.remove(_sStateID);
         }
      }
      
      public function addStateFromAsset(_sStateID:String, _oAssetReference:AssetReference, _fStateCallback:Function = null, _fStateInitCallback:Function = null, _fStateEndcallBack:Function = null) : void
      {
         if(this.oAnimLocation == AnimStateLocation.ASSET)
         {
            if(this.cacheAssetState)
            {
               if(this.oStateAssetList == null)
               {
                  this.oStateAssetList = new ObjectList();
               }
               this.oStateAssetList.insert(_sStateID,null);
            }
            super.addState(_sStateID,_fStateCallback,_fStateInitCallback,_fStateEndcallBack);
            this.setLooping(_sStateID,true);
            if(this.oStateAssetRefList == null)
            {
               this.oStateAssetRefList = new ObjectList();
            }
            this.oStateAssetRefList.insert(_sStateID,_oAssetReference);
         }
      }
      
      public function setLooping(_sStateID:String, _bLoop:Boolean) : void
      {
         var _oStateStruct:StateStruct = oStateStructs.find(_sStateID);
         if(_oStateStruct != null)
         {
            _oStateStruct.bLoop = _bLoop;
         }
      }
      
      public function getLooping(_sStateID:String) : Boolean
      {
         var _bLoop:Boolean = false;
         var _oStateStruct:StateStruct = oStateStructs.find(_sStateID);
         if(_oStateStruct != null)
         {
            _bLoop = _oStateStruct.bLoop;
         }
         return _bLoop;
      }
      
      override public function pause() : void
      {
         if(!bPaused && bPauseable)
         {
            super.pause();
            if(this.mcState == null)
            {
               eventManager.addEventListener(sEVENT_MANAGER_ID_PAUSE,this.mcContainerRef,Event.ADDED,this.onPauseRender);
            }
            else
            {
               this.mcState.stop();
            }
         }
      }
      
      override public function resume() : void
      {
         if(bPaused)
         {
            super.resume();
            if(this.mcState == null)
            {
               eventManager.addEventListener(sEVENT_MANAGER_ID_RESUME,this.mcContainerRef,Event.ADDED,this.onResumeRender);
            }
            else if(!(oCurrentStateStruct.bLoop == false && this.isLastFrame))
            {
               this.mcState.play();
            }
         }
      }
      
      public function isAtFrame(_nFrame:int) : Boolean
      {
         if(this.mcState != null)
         {
            return this.mcState.currentFrame == _nFrame;
         }
         return false;
      }
      
      public function flushAssetCache() : void
      {
         if(this.bCacheAssetState && this.oStateAssetList != null)
         {
            this.oStateAssetList.clear();
         }
      }
      
      override public function toString() : String
      {
         return "[AnimStateMachine: Pause = " + this.sStateMcName + "]";
      }
      
      override internal function callInitCallBack() : void
      {
         if(oCurrentStateStruct.fStateInit != null)
         {
            if(Boolean(this.mcState))
            {
               oCurrentStateStruct.fStateInit();
            }
            else
            {
               eventManager.cleanUp(sEVENT_MANAGER_ID_INIT);
               eventManager.addEventListener(sEVENT_MANAGER_ID_INIT,this.mcContainerRef,Event.ADDED,this.onInitCallBackAdded);
            }
         }
      }
      
      override protected function start() : void
      {
         if(this.bInstantUpdate)
         {
            this.startAnimState();
         }
         else if(this.bFirstStart && sState != null)
         {
            this.onDelayedStart(null);
            this.bFirstStart = false;
         }
         else
         {
            eventManager.addEventListener(sEVENT_MANAGER_ID_DELAYED,UpdateManager.instance,UpdateEvent.UPDATE,this.onDelayedStart,false,0,bWeakReference);
            if(bPauseable == false)
            {
               eventManager.addEventListener(sEVENT_MANAGER_ID_DELAYED,UpdateManager.instance,UpdateEvent.UPDATE_PAUSED,this.onDelayedStart,false,0,bWeakReference);
            }
         }
      }
      
      override protected function stop() : void
      {
         super.stop();
         eventManager.cleanUp(sEVENT_MANAGER_ID_DELAYED);
         if(bPauseable)
         {
            eventManager.cleanUp(sEVENT_MANAGER_ID_PAUSEABLE);
         }
      }
      
      private function stateAssetCallback(_oAsset:DisplayAsset) : void
      {
         if(this.mcStateReference != null)
         {
            this.mcStateReference.stop();
            this.mcContainerRef.removeChild(this.mcStateReference);
         }
         this.mcStateReference = _oAsset.content as MovieClip;
         this.mcContainerRef.addChild(this.mcStateReference);
         if(this.bCacheAssetState)
         {
            if(this.oStateAssetList.find(state) == null)
            {
               this.oStateAssetList.insert(state,this.mcStateReference);
            }
         }
         if(UpdateManager.instance.paused && bPauseable)
         {
            this.mcStateReference.stop();
         }
         super.start();
         if(bPauseable)
         {
            eventManager.addEventListener(sEVENT_MANAGER_ID_PAUSEABLE,UpdateManager.instance,UpdateEvent.PAUSE,this.onPause,false,0,bWeakReference);
            eventManager.addEventListener(sEVENT_MANAGER_ID_PAUSEABLE,UpdateManager.instance,UpdateEvent.RESUME,this.onResume,false,0,bWeakReference);
         }
      }
      
      private function stateAssetErrorCallback(_oAssetError:AssetError) : void
      {
         throw new Error(_oAssetError.error);
      }
      
      private function startAnimState() : void
      {
         var _mcState:MovieClip = null;
         var _oAssetRef:AssetReference = null;
         if(!isRunning)
         {
            if(this.oAnimLocation == AnimStateLocation.TIMELINE)
            {
               MovieClip(this.mcContainerRef).gotoAndStop(sState);
               super.start();
               if(bPauseable)
               {
                  eventManager.addEventListener(sEVENT_MANAGER_ID_PAUSEABLE,UpdateManager.instance,UpdateEvent.PAUSE,this.onPause,false,0,bWeakReference);
                  eventManager.addEventListener(sEVENT_MANAGER_ID_PAUSEABLE,UpdateManager.instance,UpdateEvent.RESUME,this.onResume,false,0,bWeakReference);
               }
            }
            else
            {
               if(this.cacheAssetState)
               {
                  _mcState = this.oStateAssetList.find(state) as MovieClip;
               }
               if(_mcState == null)
               {
                  _oAssetRef = this.oStateAssetRefList.find(sState);
                  if(_oAssetRef != null)
                  {
                     AssetManager.instance.requestAsset(_oAssetRef,this.stateAssetCallback,this.stateAssetErrorCallback);
                  }
               }
               else
               {
                  if(this.mcStateReference != null)
                  {
                     this.mcStateReference.stop();
                     this.mcContainerRef.removeChild(this.mcStateReference);
                  }
                  this.mcStateReference = _mcState;
                  this.mcContainerRef.addChild(this.mcStateReference);
                  this.mcStateReference.gotoAndPlay(1);
                  if(UpdateManager.instance.paused)
                  {
                     this.mcStateReference.stop();
                  }
                  super.start();
                  if(bPauseable)
                  {
                     eventManager.addEventListener(sEVENT_MANAGER_ID_PAUSEABLE,UpdateManager.instance,UpdateEvent.PAUSE,this.onPause,false,0,bWeakReference);
                     eventManager.addEventListener(sEVENT_MANAGER_ID_PAUSEABLE,UpdateManager.instance,UpdateEvent.RESUME,this.onResume,false,0,bWeakReference);
                  }
               }
            }
         }
      }
      
      override internal function onStateTick(_e:Event) : void
      {
         if(bDestroyed != true)
         {
            if(oCurrentStateStruct.bLoop == false && this.isLastFrame)
            {
               this.mcState.stop();
            }
            if(this.mcState != null)
            {
               super.onStateTick(_e);
            }
         }
      }
      
      private function onDelayedStart(_e:UpdateEvent) : void
      {
         if(!bDestroyed)
         {
            eventManager.cleanUp(sEVENT_MANAGER_ID_DELAYED);
            this.startAnimState();
         }
      }
      
      private function onInitCallBackAdded(_e:Event) : void
      {
         if(oCurrentStateStruct.fStateInit != null)
         {
            if(_e.target == this.mcState)
            {
               eventManager.cleanUp(sEVENT_MANAGER_ID_INIT);
               oCurrentStateStruct.fStateInit();
               if(bPaused || UpdateManager.instance.paused && bPauseable)
               {
                  this.mcState.stop();
               }
            }
         }
      }
      
      private function onPause(_e:Event) : void
      {
         if(isRunning)
         {
            this.pause();
         }
      }
      
      private function onResume(_e:Event) : void
      {
         if(isRunning)
         {
            this.resume();
         }
      }
      
      private function onPauseRender(_e:Event) : void
      {
         this.pause();
         eventManager.cleanUp(sEVENT_MANAGER_ID_PAUSE);
      }
      
      private function onResumeRender(_e:Event) : void
      {
         this.resume();
         eventManager.cleanUp(sEVENT_MANAGER_ID_RESUME);
      }
      
      public function get stateMcName() : String
      {
         return this.sStateMcName;
      }
      
      public function set stateMcName(_sName:String) : void
      {
         if(isRunning != true)
         {
            this.sStateMcName = _sName;
         }
      }
      
      public function get cacheAssetState() : Boolean
      {
         return this.bCacheAssetState;
      }
      
      public function set cacheAssetState(_bValue:Boolean) : void
      {
         if(this.oStateAssetList == null)
         {
            this.bCacheAssetState = _bValue;
         }
      }
      
      public function get mcContainer() : DisplayObjectContainer
      {
         return this.mcContainerRef;
      }
      
      public function get mcState() : MovieClip
      {
         if(this.oAnimLocation == AnimStateLocation.TIMELINE)
         {
            return this.mcContainerRef.getChildByName(this.sStateMcName) as MovieClip;
         }
         return this.mcStateReference;
      }
      
      public function get currentFrame() : int
      {
         if(this.mcState != null)
         {
            return this.mcState.currentFrame;
         }
         return -1;
      }
      
      public function get isFirstFrame() : Boolean
      {
         if(this.mcState != null)
         {
            return this.mcState.currentFrame == 1;
         }
         return false;
      }
      
      public function get isLastFrame() : Boolean
      {
         if(this.mcState != null)
         {
            return this.mcState.currentFrame == this.mcState.totalFrames;
         }
         return false;
      }
   }
}

