package com.sarbakan.sbdk.blitting.core
{
   import com.sarbakan.sbdk.data.spatialIndexing.ISpatialIndexElement;
   import com.sarbakan.sbdk.events.BitmappedEvent;
   import com.sarbakan.sbdk.events.StateEvent;
   import com.sarbakan.sbdk.state.StateMachine;
   import com.sarbakan.sbdk.state.StateMachineType;
   import com.sarbakan.sbdk.utils.ObjectList;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import flash.geom.Rectangle;
   import flash.utils.getQualifiedClassName;
   
   [Event(name="RESUME",type="com.sarbakan.sbdk.events.StateEvent")]
   [Event(name="PAUSE",type="com.sarbakan.sbdk.events.StateEvent")]
   [Event(name="STOP",type="com.sarbakan.sbdk.events.StateEvent")]
   [Event(name="START",type="com.sarbakan.sbdk.events.StateEvent")]
   [Event(name="HIDE",type="flash.events.Event")]
   [Event(name="SHOW",type="flash.events.Event")]
   [Event(name="ENTER_FRAME",type="flash.events.Event")]
   [Event(name="MOUSE_OUT",type="flash.events.MouseEvent")]
   [Event(name="MOUSE_OVER",type="flash.events.MouseEvent")]
   [Event(name="MOUSE_DOWN",type="flash.events.MouseEvent")]
   [Event(name="MOUSE_UP",type="flash.events.MouseEvent")]
   [Event(name="MOUSE_MOVE",type="flash.events.MouseEvent")]
   public class BitmappedAnimStateMachine extends AbstractBitmappedAnimation implements IBitmappedAnimation
   {
      
      private static const sMCANIMATION:String = "com.sarbakan.sbdk.blitting.core::MCAnimation";
      
      private static const sBITMAPPED_ANIM:String = "com.sarbakan.sbdk.blitting.core::BitmappedAnimation";
      
      private static const sSTATE_EVENT:String = "STATE_EVENT";
      
      private static const sEVENT_ID:String = "EVENT_ID";
      
      private var lStateConfigList:ObjectList;
      
      private var oStateMachine:StateMachine;
      
      private var bPausable:Boolean;
      
      private var bWeakReference:Boolean;
      
      private var bChacheTransform:Boolean;
      
      private var oCurrentState:IBitmappedAnimation;
      
      private var oBitmapDataCollection:BitmapDataCollection;
      
      private var oBitmappedContainer:BitmappedAnimContainer;
      
      private var nX:Number;
      
      private var nY:Number;
      
      private var oSpatialIndex:ISpatialIndexElement;
      
      private var bSmoothing:Boolean;
      
      private var nFrameRate:int;
      
      private var bShowColliders:Boolean;
      
      private var bShowRedrawRegion:Boolean;
      
      private var oTransform:ColorTransform;
      
      private var bUpdateWhenOutbound:Boolean;
      
      private var bLoop:Boolean;
      
      private var lCacheStateList:ObjectList;
      
      private var bChacheState:Boolean;
      
      public function BitmappedAnimStateMachine(_bPausable:Boolean = true, _bWeakReference:Boolean = true, _bCacheTransform:Boolean = false)
      {
         super();
         this.bPausable = _bPausable;
         this.bWeakReference = _bWeakReference;
         this.bChacheTransform = _bCacheTransform;
         this.init();
      }
      
      override public function destroy() : void
      {
         var i:IBitmappedAnimation = null;
         super.destroy();
         this.oBitmapDataCollection = null;
         if(this.lStateConfigList != null)
         {
            this.lStateConfigList.clear();
            this.lStateConfigList = null;
         }
         if(this.oStateMachine != null)
         {
            this.oStateMachine.destroy();
            this.oStateMachine = null;
         }
         for each(i in this.lCacheStateList.object)
         {
            i.destroy();
         }
         this.lCacheStateList.clear();
         this.lCacheStateList.destroy();
         this.lCacheStateList = null;
         this.oCurrentState = null;
      }
      
      public function addBitmappedState(_sStateID:String, _oClassRef:Class, _sClassVariantID:String = null, _fStateCallback:Function = null, _fStateInitCallback:Function = null, _fStateEndCallback:Function = null) : void
      {
         this.oStateMachine.addState(_sStateID,_fStateCallback,_fStateInitCallback,_fStateEndCallback);
         this.lStateConfigList.insert(_sStateID,new StateInfoStruct(_oClassRef,_sClassVariantID,sBITMAPPED_ANIM,false,""));
      }
      
      public function removeBitmappedState(_sStateID:String) : void
      {
         var _oStateInfo:StateInfoStruct = this.lStateConfigList.find(_sStateID);
         if(_oStateInfo != null)
         {
            if(this.oCurrentState != null && this.oCurrentState.ID.className == String(_oStateInfo.oClassRef))
            {
               this.oCurrentState.destroy();
               this.oCurrentState = null;
            }
            this.lStateConfigList.remove(_sStateID);
         }
         this.oStateMachine.removeState(_sStateID);
      }
      
      public function addMCState(_sStateID:String, _oClassRef:Class, _sType:String, _bCheckForCollider:Boolean = false, _fStateCallback:Function = null, _fStateInitCallback:Function = null, _fStateEndCallback:Function = null) : void
      {
         this.oStateMachine.addState(_sStateID,_fStateCallback,_fStateInitCallback,_fStateEndCallback);
         this.lStateConfigList.insert(_sStateID,new StateInfoStruct(_oClassRef,"",sMCANIMATION,_bCheckForCollider,_sType));
      }
      
      public function setState(_sStateID:String, _bResetState:Boolean = false) : void
      {
         var _oChacheState:IBitmappedAnimation = null;
         if(this.state == _sStateID && !_bResetState)
         {
            return;
         }
         var _oStateInfoStruct:StateInfoStruct = this.lStateConfigList.find(_sStateID);
         var _oLastState:IBitmappedAnimation = this.oCurrentState;
         if(_oStateInfoStruct.sType == sBITMAPPED_ANIM)
         {
            if(this.bChacheState)
            {
               _oChacheState = this.lCacheStateList.find(_oStateInfoStruct.oClassRef.toString());
               if(_oChacheState != null)
               {
                  this.oCurrentState = _oChacheState;
               }
               else
               {
                  this.oCurrentState = new BitmappedAnimation(_oStateInfoStruct.oClassRef,_oStateInfoStruct.sVariantID,this.bPausable,-1,this.bChacheTransform);
               }
            }
            else
            {
               this.oCurrentState = new BitmappedAnimation(_oStateInfoStruct.oClassRef,_oStateInfoStruct.sVariantID,this.bPausable,-1,this.bChacheTransform);
            }
            if(bMouseEnabled)
            {
               this.setEventListener(this.oCurrentState,sBITMAPPED_ANIM);
            }
         }
         else if(_oStateInfoStruct.sType == sMCANIMATION)
         {
            if(this.bChacheState)
            {
               _oChacheState = this.lCacheStateList.find(_oStateInfoStruct.oClassRef.toString());
               if(_oChacheState != null)
               {
                  this.oCurrentState = _oChacheState;
               }
               else
               {
                  this.oCurrentState = new MCAnimation(_oStateInfoStruct.oClassRef,0,0,"",-1,_oStateInfoStruct.sMCType,_oStateInfoStruct.bCheckForCollider);
               }
            }
            else
            {
               this.oCurrentState = new MCAnimation(_oStateInfoStruct.oClassRef,0,0,"",-1,_oStateInfoStruct.sMCType,_oStateInfoStruct.bCheckForCollider);
            }
            if(bMouseEnabled)
            {
               this.setEventListener(this.oCurrentState,sMCANIMATION);
            }
         }
         if(this.oCurrentState != null)
         {
            if(this.oBitmappedContainer != null)
            {
               this.oCurrentState.setContainer(this.oBitmappedContainer);
               this.oCurrentState.spatialIndexHandler = this.oSpatialIndex;
            }
            if(_oLastState != null)
            {
               this.copyProperties(_oLastState,this.oCurrentState);
               if(this.bChacheState)
               {
                  _oLastState.gotoAndStop(1);
                  if(!this.lCacheStateList.contains(_oLastState))
                  {
                     this.lCacheStateList.insert(_oLastState.ID.className,_oLastState);
                  }
               }
               else
               {
                  _oLastState.destroy();
               }
               _oLastState = null;
            }
            else
            {
               this.applyProperties();
            }
            this.oCurrentState.looping = _oStateInfoStruct.bLoop;
            this.oStateMachine.setState(_sStateID,_bResetState);
            this.oCurrentState.play();
         }
      }
      
      override public function gotoAndStop(_oFrameOrLabel:Object) : void
      {
         if(this.oCurrentState != null)
         {
            this.oCurrentState.gotoAndStop(_oFrameOrLabel);
         }
      }
      
      override public function gotoAndPlay(_oFrameOrLabel:Object) : void
      {
         if(this.oCurrentState != null)
         {
            this.oCurrentState.gotoAndPlay(_oFrameOrLabel);
         }
      }
      
      override public function nextFrame() : void
      {
         if(this.oCurrentState != null)
         {
            this.oCurrentState.nextFrame();
         }
      }
      
      override public function prevFrame() : void
      {
         if(this.oCurrentState != null)
         {
            this.oCurrentState.prevFrame();
         }
      }
      
      override public function play() : void
      {
         if(this.oCurrentState != null)
         {
            this.oCurrentState.play();
         }
      }
      
      override public function stop() : void
      {
         if(this.oCurrentState != null)
         {
            this.oCurrentState.stop();
         }
      }
      
      override public function setDisplayed(_bValue:Boolean) : void
      {
         if(bDisplayed != _bValue)
         {
            bDisplayed = _bValue;
            if(_bValue)
            {
               dispatchEvent(new BitmappedEvent(BitmappedEvent.SHOW,false,false,null));
            }
            else
            {
               dispatchEvent(new BitmappedEvent(BitmappedEvent.HIDE,false,false,null));
            }
         }
      }
      
      override public function getColliderByName(_sName:String, _bGlobal:Boolean = false) : ColliderInfo
      {
         if(this.oCurrentState != null)
         {
            return this.oCurrentState.getColliderByName(_sName,_bGlobal);
         }
         return null;
      }
      
      override public function hitTestObject(_oBmpAnimRef:IBitmappedAnimation, _bPixelPerfect:Boolean = true) : Boolean
      {
         if(this.oCurrentState != null)
         {
            return this.oCurrentState.hitTestObject(_oBmpAnimRef,_bPixelPerfect);
         }
         return false;
      }
      
      override public function hitTestPoint(_nX:int, _nY:int, _bPixelPerfect:Boolean = true) : Boolean
      {
         if(this.oCurrentState != null)
         {
            return this.oCurrentState.hitTestPoint(_nX,_nY,_bPixelPerfect);
         }
         return false;
      }
      
      override public function hitTestRect(_oRect:Rectangle, _bPixelPerfect:Boolean = true) : Boolean
      {
         if(this.oCurrentState != null)
         {
            return this.oCurrentState.hitTestRect(_oRect,_bPixelPerfect);
         }
         return false;
      }
      
      override public function hitTestMovieClip(_mcRef:DisplayObject, _bPixelPerfect:Boolean = true) : Boolean
      {
         if(this.oCurrentState != null)
         {
            return this.oCurrentState.hitTestMovieClip(_mcRef,_bPixelPerfect);
         }
         return false;
      }
      
      override public function setContainer(_oContainerRef:BitmappedAnimContainer) : void
      {
         this.oBitmappedContainer = _oContainerRef;
         if(this.oCurrentState != null)
         {
            this.oCurrentState.setContainer(this.oBitmappedContainer);
            this.applyProperties();
         }
      }
      
      public function setStateLooping(_sStateID:String, _bLoop:Boolean) : void
      {
         var _oStateInfoStruct:StateInfoStruct = null;
         if(this.isState(_sStateID))
         {
            this.oCurrentState.looping = _bLoop;
         }
         else
         {
            _oStateInfoStruct = this.lStateConfigList.find(_sStateID);
            if(_oStateInfoStruct != null)
            {
               _oStateInfoStruct.bLoop = _bLoop;
            }
         }
      }
      
      public function getStateLooping(_sStateID:String) : Boolean
      {
         var _oStateInfoStruct:StateInfoStruct = null;
         if(this.isState(_sStateID))
         {
            return this.oCurrentState.looping;
         }
         _oStateInfoStruct = this.lStateConfigList.find(_sStateID);
         if(_oStateInfoStruct != null)
         {
            return _oStateInfoStruct.bLoop;
         }
         return false;
      }
      
      public function pause() : void
      {
         if(this.oCurrentState != null)
         {
            if(!bPaused)
            {
               bPaused = true;
               this.oCurrentState.stop();
               this.oStateMachine.pause();
            }
         }
      }
      
      public function resume() : void
      {
         if(this.oCurrentState != null)
         {
            if(bPaused)
            {
               bPaused = false;
               this.oCurrentState.play();
               this.oStateMachine.resume();
            }
         }
      }
      
      public function isState(... _sStates) : Boolean
      {
         return this.oStateMachine.isState.apply(this.oStateMachine,_sStates);
      }
      
      public function isNotState(... _sStates) : Boolean
      {
         return this.oStateMachine.isNotState.apply(this.oStateMachine,_sStates);
      }
      
      public function stateExist(_sStateID:String) : Boolean
      {
         return this.oStateMachine.stateExist(_sStateID);
      }
      
      public function clearCachedState() : void
      {
         this.lCacheStateList.clear();
      }
      
      internal function draw() : void
      {
         if(this.oCurrentState is MCAnimation)
         {
            MCAnimation(this.oCurrentState).draw();
         }
      }
      
      override public function onMouseEvent(_oEvent:MouseEvent) : void
      {
         if(this.oCurrentState != null)
         {
            this.oCurrentState.onMouseEvent(_oEvent);
         }
      }
      
      override public function onMouseOut(_oEvent:MouseEvent) : void
      {
         if(this.oCurrentState != null)
         {
            this.oCurrentState.onMouseOut(_oEvent);
         }
      }
      
      override protected function init() : void
      {
         super.init();
         this.oStateMachine = new StateMachine(StateMachineType.FRAME_BASED,this.bPausable,this.bWeakReference);
         this.lStateConfigList = new ObjectList();
         oEventManager.addEventListener(sEVENT_ID,this.oStateMachine,StateEvent.COMPLETE,this.onStateMachineEvent);
         this.oBitmapDataCollection = BitmapDataCollection.instance;
         this.nX = 0;
         this.nY = 0;
         nWidth = 1;
         nHeight = 1;
         this.bSmoothing = false;
         bVisible = true;
         this.bShowColliders = false;
         this.bShowRedrawRegion = false;
         nRotation = 0;
         nAlpha = 1;
         nScaleX = 1;
         nScaleY = 1;
         this.bUpdateWhenOutbound = true;
         bMouseEnabled = false;
         bMoving = false;
         this.bLoop = true;
         nDepth = -1;
         this.nFrameRate = -1;
         bPixelSnapping = false;
         bDisplayed = false;
         bPaused = false;
         this.bChacheState = false;
         this.lCacheStateList = new ObjectList();
         aTransformList[sSMOOTHING] = false;
         aTransformList[sVISIBLE] = false;
         aTransformList[sSHOW_COLLIDER] = false;
         aTransformList[sREDRAW_REGION] = false;
         aTransformList[sROTATION] = false;
         aTransformList[sALPHA] = false;
         aTransformList[sSCALE_X] = false;
         aTransformList[sSCALE_Y] = false;
         aTransformList[sCOLOR_TRANSFORM] = false;
         aTransformList[sMOUSE_ENABLED] = false;
         aTransformList[sX] = false;
         aTransformList[sY] = false;
         aTransformList[sWIDTH] = false;
         aTransformList[sHEIGHT] = false;
         aTransformList[sLOOP] = false;
         aTransformList[sFLIP] = false;
         aTransformList[sFRAME_RATE] = false;
         aTransformList[sPIXEL_SNAPPING] = false;
      }
      
      private function copyProperties(_oLastState:IBitmappedAnimation, _oNewState:IBitmappedAnimation) : void
      {
         _oNewState.smoothing = _oLastState.smoothing;
         _oNewState.visible = _oLastState.visible;
         _oNewState.showColliders = _oLastState.showColliders;
         _oNewState.showRedrawRegion = _oLastState.showRedrawRegion;
         _oNewState.rotation = _oLastState.rotation;
         _oNewState.alpha = _oLastState.alpha;
         _oNewState.flip = _oLastState.flip;
         for(var i:int = 0; i < _oLastState.filters.length; i++)
         {
            _oNewState.filters[i] = _oLastState.filters[i];
         }
         _oNewState.x = this.nX;
         _oNewState.y = this.nY;
         _oNewState.frameRate = _oLastState.frameRate;
         _oNewState.scaleX = _oLastState.scaleX;
         _oNewState.scaleY = _oLastState.scaleY;
         _oNewState.colorTransform = _oLastState.colorTransform;
         _oNewState.mouseEnabled = _oLastState.mouseEnabled;
         _oNewState.pixelSnapping = _oLastState.pixelSnapping;
      }
      
      private function applyProperties() : void
      {
         var i:int = 0;
         if(Boolean(aTransformList[sX]))
         {
            this.oCurrentState.x = this.nX;
            aTransformList[sX] = false;
         }
         if(Boolean(aTransformList[sY]))
         {
            this.oCurrentState.y = this.nY;
            aTransformList[sY] = false;
         }
         if(Boolean(aTransformList[sWIDTH]))
         {
            this.oCurrentState.width = nWidth;
            aTransformList[sWIDTH] = false;
         }
         if(Boolean(aTransformList[sHEIGHT]))
         {
            this.oCurrentState.height = nHeight;
            aTransformList[sHEIGHT] = false;
         }
         if(Boolean(aTransformList[sSMOOTHING]))
         {
            this.oCurrentState.smoothing = this.bSmoothing;
            aTransformList[sSMOOTHING] = false;
         }
         if(Boolean(aTransformList[sVISIBLE]))
         {
            this.oCurrentState.visible = bVisible;
            aTransformList[sVISIBLE] = false;
         }
         if(Boolean(aTransformList[sSHOW_COLLIDER]))
         {
            this.oCurrentState.showColliders = this.bShowColliders;
            aTransformList[sSHOW_COLLIDER] = false;
         }
         if(Boolean(aTransformList[sREDRAW_REGION]))
         {
            this.oCurrentState.showRedrawRegion = this.bShowRedrawRegion;
            aTransformList[sREDRAW_REGION] = false;
         }
         if(Boolean(aTransformList[sROTATION]))
         {
            this.oCurrentState.rotation = nRotation;
            aTransformList[sROTATION] = false;
         }
         if(Boolean(aTransformList[sALPHA]))
         {
            this.oCurrentState.alpha = nAlpha;
            aTransformList[sALPHA] = false;
         }
         if(Boolean(aTransformList[sSCALE_X]))
         {
            this.oCurrentState.scaleX = nScaleX;
            aTransformList[sSCALE_X] = false;
         }
         if(Boolean(aTransformList[sSCALE_Y]))
         {
            this.oCurrentState.scaleY = nScaleY;
            aTransformList[sSCALE_Y] = false;
         }
         if(Boolean(aTransformList[sCOLOR_TRANSFORM]))
         {
            this.oCurrentState.colorTransform = this.oTransform;
            aTransformList[sCOLOR_TRANSFORM] = false;
         }
         if(Boolean(aTransformList[sMOUSE_ENABLED]))
         {
            this.oCurrentState.mouseEnabled = bMouseEnabled;
            aTransformList[sMOUSE_ENABLED] = false;
         }
         if(Boolean(aTransformList[sLOOP]))
         {
            this.oCurrentState.looping = this.bLoop;
            aTransformList[sLOOP] = false;
         }
         if(Boolean(aTransformList[sFLIP]))
         {
            this.oCurrentState.flip = bFlip;
            aTransformList[sFLIP] = false;
         }
         if(Boolean(aTransformList[sFRAME_RATE]))
         {
            this.oCurrentState.frameRate = this.nFrameRate;
            aTransformList[sFRAME_RATE] = false;
         }
         if(Boolean(aTransformList[sPIXEL_SNAPPING]))
         {
            this.oCurrentState.pixelSnapping = bPixelSnapping;
            aTransformList[sPIXEL_SNAPPING] = false;
         }
         if(aFilters != null)
         {
            for(i = 0; i < aFilters.length; i++)
            {
               this.oCurrentState.filters[i] = aFilters[i];
            }
         }
      }
      
      private function setEventListener(_oTargetState:IBitmappedAnimation, _sClassType:String) : void
      {
         oEventManager.cleanUp(sSTATE_EVENT);
         switch(_sClassType)
         {
            case sBITMAPPED_ANIM:
               oEventManager.addEventListener(sSTATE_EVENT,BitmappedAnimation(this.oCurrentState),MouseEvent.MOUSE_MOVE,this.mouseEventRedispatcher);
               oEventManager.addEventListener(sSTATE_EVENT,BitmappedAnimation(this.oCurrentState),MouseEvent.MOUSE_OUT,this.mouseEventRedispatcher);
               oEventManager.addEventListener(sSTATE_EVENT,BitmappedAnimation(this.oCurrentState),MouseEvent.MOUSE_OVER,this.mouseEventRedispatcher);
               oEventManager.addEventListener(sSTATE_EVENT,BitmappedAnimation(this.oCurrentState),MouseEvent.MOUSE_DOWN,this.mouseEventRedispatcher);
               oEventManager.addEventListener(sSTATE_EVENT,BitmappedAnimation(this.oCurrentState),MouseEvent.MOUSE_UP,this.mouseEventRedispatcher);
               oEventManager.addEventListener(sSTATE_EVENT,BitmappedAnimation(this.oCurrentState),Event.ENTER_FRAME,this.onStateEnterframe);
               break;
            case sMCANIMATION:
               oEventManager.addEventListener(sSTATE_EVENT,MCAnimation(this.oCurrentState),MouseEvent.MOUSE_MOVE,this.mouseEventRedispatcher);
               oEventManager.addEventListener(sSTATE_EVENT,MCAnimation(this.oCurrentState),MouseEvent.MOUSE_OUT,this.mouseEventRedispatcher);
               oEventManager.addEventListener(sSTATE_EVENT,MCAnimation(this.oCurrentState),MouseEvent.MOUSE_OVER,this.mouseEventRedispatcher);
               oEventManager.addEventListener(sSTATE_EVENT,MCAnimation(this.oCurrentState),MouseEvent.MOUSE_DOWN,this.mouseEventRedispatcher);
               oEventManager.addEventListener(sSTATE_EVENT,MCAnimation(this.oCurrentState),MouseEvent.MOUSE_UP,this.mouseEventRedispatcher);
               oEventManager.addEventListener(sSTATE_EVENT,MCAnimation(this.oCurrentState),Event.ENTER_FRAME,this.onStateEnterframe);
         }
      }
      
      private function onStateMachineEvent(_oEvent:StateEvent) : void
      {
         dispatchEvent(_oEvent);
      }
      
      private function onStateEnterframe(_oEvent:Event) : void
      {
         dispatchEvent(_oEvent);
      }
      
      private function mouseEventRedispatcher(_oEvent:MouseEvent) : void
      {
         dispatchEvent(_oEvent);
      }
      
      override public function get ID() : BitmappedObjID
      {
         if(this.oCurrentState != null)
         {
            return this.oCurrentState.ID;
         }
         return null;
      }
      
      override public function get currentFrame() : uint
      {
         if(this.oCurrentState != null)
         {
            return this.oCurrentState.currentFrame;
         }
         return 0;
      }
      
      public function get isFirstFrame() : Boolean
      {
         if(this.oCurrentState != null)
         {
            return this.oCurrentState.currentFrame == 1;
         }
         return false;
      }
      
      public function get isLastFrame() : Boolean
      {
         if(this.oCurrentState != null)
         {
            return this.currentFrame == this.totalFrames;
         }
         return false;
      }
      
      override public function get colliders() : Array
      {
         if(this.oCurrentState != null)
         {
            return this.oCurrentState.colliders;
         }
         return null;
      }
      
      override public function get totalFrames() : uint
      {
         if(this.oCurrentState != null)
         {
            return this.oCurrentState.totalFrames;
         }
         return 0;
      }
      
      override public function get smoothing() : Boolean
      {
         if(this.oCurrentState != null)
         {
            return this.oCurrentState.smoothing;
         }
         return this.bSmoothing;
      }
      
      override public function set smoothing(_bValue:Boolean) : void
      {
         this.bSmoothing = _bValue;
         if(this.oCurrentState != null)
         {
            this.oCurrentState.smoothing = this.bSmoothing;
         }
         else
         {
            aTransformList[sSMOOTHING] = true;
         }
      }
      
      override public function get pixelSnapping() : Boolean
      {
         if(this.oCurrentState != null)
         {
            return this.oCurrentState.pixelSnapping;
         }
         return bPixelSnapping;
      }
      
      override public function set pixelSnapping(_bValue:Boolean) : void
      {
         bPixelSnapping = _bValue;
         if(this.oCurrentState != null)
         {
            this.oCurrentState.pixelSnapping = bPixelSnapping;
         }
         else
         {
            aTransformList[sPIXEL_SNAPPING] = true;
         }
      }
      
      override public function get visible() : Boolean
      {
         if(this.oCurrentState != null)
         {
            return this.oCurrentState.visible;
         }
         return bVisible;
      }
      
      override public function set visible(_bValue:Boolean) : void
      {
         bVisible = _bValue;
         if(this.oCurrentState != null)
         {
            this.oCurrentState.visible = bVisible;
         }
         else
         {
            aTransformList[sVISIBLE] = true;
         }
      }
      
      override public function get frameRate() : int
      {
         if(this.oCurrentState != null)
         {
            return this.oCurrentState.frameRate;
         }
         return this.nFrameRate;
      }
      
      override public function set frameRate(_nValue:int) : void
      {
         this.nFrameRate = _nValue;
         if(this.oCurrentState != null)
         {
            this.oCurrentState.frameRate = this.nFrameRate;
         }
         else
         {
            aTransformList[sFRAME_RATE] = true;
         }
      }
      
      override public function get showColliders() : Boolean
      {
         if(this.oCurrentState != null)
         {
            return this.oCurrentState.showColliders;
         }
         return false;
      }
      
      override public function set showColliders(_bValue:Boolean) : void
      {
         this.bShowColliders = _bValue;
         if(this.oCurrentState != null)
         {
            this.oCurrentState.showColliders = this.bShowColliders;
         }
         else
         {
            aTransformList[sSHOW_COLLIDER] = true;
         }
      }
      
      override public function get rect() : Rectangle
      {
         if(this.oCurrentState != null)
         {
            return this.oCurrentState.rect;
         }
         return new Rectangle(0,0,10,10);
      }
      
      override public function get frameRect() : Rectangle
      {
         if(this.oCurrentState != null)
         {
            return this.oCurrentState.frameRect;
         }
         return new Rectangle(0,0,10,10);
      }
      
      override public function get showRedrawRegion() : Boolean
      {
         if(this.oCurrentState != null)
         {
            return this.oCurrentState.showRedrawRegion;
         }
         return this.bShowRedrawRegion;
      }
      
      override public function set showRedrawRegion(_bValue:Boolean) : void
      {
         this.bShowRedrawRegion = _bValue;
         if(this.oCurrentState != null)
         {
            this.oCurrentState.showRedrawRegion = this.bShowRedrawRegion;
         }
         else
         {
            aTransformList[sREDRAW_REGION] = true;
         }
      }
      
      override public function get rotation() : Number
      {
         if(this.oCurrentState != null)
         {
            return this.oCurrentState.rotation;
         }
         return nRotation;
      }
      
      override public function set rotation(_nValue:Number) : void
      {
         nRotation = _nValue;
         if(this.oCurrentState != null)
         {
            this.oCurrentState.rotation = nRotation;
         }
         else
         {
            aTransformList[sROTATION] = true;
         }
      }
      
      override public function get alpha() : Number
      {
         if(this.oCurrentState != null)
         {
            return this.oCurrentState.alpha;
         }
         return nAlpha;
      }
      
      override public function set alpha(_nValue:Number) : void
      {
         nAlpha = _nValue;
         if(this.oCurrentState != null)
         {
            this.oCurrentState.alpha = nAlpha;
         }
         else
         {
            aTransformList[sALPHA] = true;
         }
      }
      
      override public function get scaleX() : Number
      {
         if(this.oCurrentState != null)
         {
            return this.oCurrentState.scaleX;
         }
         return nScaleX;
      }
      
      override public function set scaleX(_nValue:Number) : void
      {
         nScaleX = _nValue;
         if(this.oCurrentState != null)
         {
            this.oCurrentState.scaleX = nScaleX;
         }
         else
         {
            aTransformList[sSCALE_X] = true;
         }
      }
      
      override public function get scaleY() : Number
      {
         if(this.oCurrentState != null)
         {
            return this.oCurrentState.scaleY;
         }
         return nScaleY;
      }
      
      override public function set scaleY(_nValue:Number) : void
      {
         nScaleY = _nValue;
         if(this.oCurrentState != null)
         {
            this.oCurrentState.scaleY = nScaleY;
         }
         else
         {
            aTransformList[sSCALE_Y] = true;
         }
      }
      
      override public function get colorTransform() : ColorTransform
      {
         if(this.oCurrentState != null)
         {
            return this.oCurrentState.colorTransform;
         }
         return this.oTransform;
      }
      
      override public function set colorTransform(_oValue:ColorTransform) : void
      {
         this.oTransform = _oValue;
         if(this.oCurrentState != null)
         {
            this.oCurrentState.colorTransform = this.oTransform;
         }
         else
         {
            aTransformList[sCOLOR_TRANSFORM] = true;
         }
      }
      
      override public function get filters() : Array
      {
         if(aFilters == null)
         {
            aFilters = new Array();
         }
         if(this.oCurrentState != null)
         {
            return this.oCurrentState.filters;
         }
         return aFilters;
      }
      
      override public function get frameData() : BitmapData
      {
         if(this.oCurrentState != null)
         {
            return this.oCurrentState.frameData;
         }
         return null;
      }
      
      override public function get x() : Number
      {
         if(this.oCurrentState != null)
         {
            return this.oCurrentState.x;
         }
         return this.nX;
      }
      
      override public function set x(_nValue:Number) : void
      {
         this.nX = _nValue;
         if(this.oCurrentState != null && this.oCurrentState.container != null)
         {
            this.oCurrentState.x = this.nX;
         }
         else
         {
            aTransformList[sX] = true;
         }
      }
      
      override public function get y() : Number
      {
         if(this.oCurrentState != null)
         {
            return this.oCurrentState.y;
         }
         return this.nY;
      }
      
      override public function set y(_nValue:Number) : void
      {
         this.nY = _nValue;
         if(this.oCurrentState != null && this.oCurrentState.container != null)
         {
            this.oCurrentState.y = this.nY;
         }
         else
         {
            aTransformList[sY] = true;
         }
      }
      
      override public function get width() : uint
      {
         if(this.oCurrentState != null)
         {
            return this.oCurrentState.width;
         }
         return nWidth;
      }
      
      override public function set width(_nValue:uint) : void
      {
         if(nWidth != _nValue)
         {
            nWidth = _nValue;
            if(this.oCurrentState != null)
            {
               this.oCurrentState.width = nWidth;
            }
            else
            {
               aTransformList[sWIDTH] = true;
            }
         }
      }
      
      override public function get height() : uint
      {
         if(this.oCurrentState != null)
         {
            return this.oCurrentState.height;
         }
         return nHeight;
      }
      
      override public function set height(_nValue:uint) : void
      {
         if(nHeight != _nValue)
         {
            nHeight = _nValue;
            if(this.oCurrentState != null)
            {
               this.oCurrentState.height = nHeight;
            }
            else
            {
               aTransformList[sHEIGHT] = true;
            }
         }
      }
      
      override public function get flip() : Boolean
      {
         return bFlip;
      }
      
      override public function set flip(_bFlip:Boolean) : void
      {
         bFlip = _bFlip;
         if(this.oCurrentState != null)
         {
            this.oCurrentState.flip = bFlip;
         }
         else
         {
            aTransformList[sFLIP] = true;
         }
      }
      
      override public function get mouseEnabled() : Boolean
      {
         if(this.oCurrentState != null)
         {
            return this.oCurrentState.mouseEnabled;
         }
         return bMouseEnabled;
      }
      
      override public function set mouseEnabled(_bValue:Boolean) : void
      {
         bMouseEnabled = _bValue;
         if(this.oCurrentState != null)
         {
            this.oCurrentState.mouseEnabled = bMouseEnabled;
            this.setEventListener(this.oCurrentState,getQualifiedClassName(this.oCurrentState));
         }
         else
         {
            aTransformList[sMOUSE_ENABLED] = true;
         }
      }
      
      public function get state() : String
      {
         return this.oStateMachine.state;
      }
      
      override public function get depth() : int
      {
         return nDepth;
      }
      
      override public function set depth(_nValue:int) : void
      {
         nDepth = _nValue;
      }
      
      override public function get layer() : String
      {
         return sLayer;
      }
      
      override public function set layer(_sValue:String) : void
      {
         sLayer = _sValue;
      }
      
      override public function get spatialIndexHandler() : ISpatialIndexElement
      {
         if(this.oCurrentState != null)
         {
            return this.oCurrentState.spatialIndexHandler;
         }
         return this.oSpatialIndex;
      }
      
      override public function set spatialIndexHandler(_oHandler:ISpatialIndexElement) : void
      {
         this.oSpatialIndex = _oHandler;
         if(this.oCurrentState != null)
         {
            this.oCurrentState.spatialIndexHandler = this.oSpatialIndex;
         }
      }
      
      override public function get moving() : Boolean
      {
         return bMoving;
      }
      
      override public function set moving(_bValue:Boolean) : void
      {
         var _oLayerInfo:LayerInfoStruct = null;
         bMoving = _bValue;
         if(this.oCurrentState != null)
         {
            if(this.oCurrentState.container != null)
            {
               _oLayerInfo = this.oCurrentState.container.getLayer(this.oCurrentState.layer);
               if(this.oCurrentState.moving != _bValue && _oLayerInfo != null)
               {
                  this.oCurrentState.moving = bMoving;
               }
            }
         }
      }
      
      public function get cacheState() : Boolean
      {
         return this.bChacheState;
      }
      
      public function set cacheState(_bValue:Boolean) : void
      {
         this.bChacheState = _bValue;
      }
      
      override public function get looping() : Boolean
      {
         return this.bLoop;
      }
      
      override public function set looping(_bLoop:Boolean) : void
      {
         this.bLoop = _bLoop;
         if(this.oCurrentState != null)
         {
            this.oCurrentState.looping = this.bLoop;
         }
         else
         {
            aTransformList[sLOOP] = true;
         }
      }
      
      override public function get displayed() : Boolean
      {
         return bDisplayed;
      }
      
      override public function get container() : BitmappedAnimContainer
      {
         if(this.oCurrentState != null)
         {
            return this.oCurrentState.container;
         }
         return this.oBitmappedContainer;
      }
   }
}

class StateInfoStruct
{
   
   public var oClassRef:Class;
   
   public var sVariantID:String;
   
   public var sType:String;
   
   public var bCheckForCollider:Boolean;
   
   public var sMCType:String;
   
   public var bLoop:Boolean;
   
   public function StateInfoStruct(_oClassRef:Class, _sVariantID:String, _sType:String, _bCheckForCollider:Boolean, _sMCType:String)
   {
      super();
      this.oClassRef = _oClassRef;
      this.sVariantID = _sVariantID;
      this.sType = _sType;
      this.bCheckForCollider = _bCheckForCollider;
      this.bLoop = true;
   }
}
