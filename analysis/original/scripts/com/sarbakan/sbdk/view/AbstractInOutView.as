package com.sarbakan.sbdk.view
{
   import com.sarbakan.sbdk.asset.AssetReference;
   import com.sarbakan.sbdk.errors.ErrorMessages;
   import com.sarbakan.sbdk.events.ViewEvent;
   import com.sarbakan.sbdk.sound.SoundManager;
   import com.sarbakan.sbdk.state.AnimStateLocation;
   import com.sarbakan.sbdk.state.AnimStateMachine;
   import com.sarbakan.sbdk.utils.FrameTimer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.errors.IllegalOperationError;
   import flash.events.TimerEvent;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public class AbstractInOutView extends AbstractView
   {
      
      private static var oDefaultInSoundInfo:SoundInfoStruct;
      
      private static var oDefaultOutSoundInfo:SoundInfoStruct;
      
      protected static const sIN:String = "in";
      
      protected static const sOUT:String = "out";
      
      protected static const sIDLE:String = "idle";
      
      private static const sFRAME_TIMER_EVENT:String = "FRAME_TIMER_EVENT";
      
      private static var nInstanceCmpt:int = 0;
      
      private var oAnimLocation:AnimStateLocation;
      
      private var oAnimStateMachine:AnimStateMachine;
      
      private var oInAssetReference:AssetReference;
      
      private var oIdleAssetReference:AssetReference;
      
      private var oOutAssetReference:AssetReference;
      
      private var bSkipInOutStates:Boolean;
      
      private var oCustomInSoundInfo:SoundInfoStruct;
      
      private var oCustomOutSoundInfo:SoundInfoStruct;
      
      private var bGoHide:Boolean;
      
      private var oShowHideTimer:FrameTimer;
      
      private var mcUnderMouseBlocker:Sprite;
      
      public function AbstractInOutView(_oAnimLocation:AnimStateLocation, _bUseMouseBlocker:Boolean = true, _bTransitionPausable:Boolean = false)
      {
         super();
         if(Class(getDefinitionByName(getQualifiedClassName(this))) == AbstractInOutView)
         {
            throw new IllegalOperationError(ErrorMessages.sABSTRACT_CLASS_ERROR);
         }
         bUseMouseBlocker = _bUseMouseBlocker;
         this.oAnimLocation = _oAnimLocation;
         this.mcUnderMouseBlocker = null;
         transitionPausable = _bTransitionPausable;
         ++nInstanceCmpt;
         initialize();
      }
      
      public static function setDefaultInSound(_oSoundAsset:AssetReference, _sCategory:String, _nVolume:Number = 1, _bLoop:Boolean = false) : void
      {
         if(oDefaultInSoundInfo != null)
         {
            oDefaultInSoundInfo.destroy();
            oDefaultInSoundInfo = null;
         }
         oDefaultInSoundInfo = new SoundInfoStruct(_oSoundAsset,_sCategory,_nVolume,_bLoop);
      }
      
      public static function setDefaultOutSound(_oSoundAsset:AssetReference, _sCategory:String, _nVolume:Number = 1, _bLoop:Boolean = false) : void
      {
         if(oDefaultOutSoundInfo != null)
         {
            oDefaultOutSoundInfo.destroy();
            oDefaultOutSoundInfo = null;
         }
         oDefaultOutSoundInfo = new SoundInfoStruct(_oSoundAsset,_sCategory,_nVolume,_bLoop);
      }
      
      override public function destroy() : void
      {
         if(this.oAnimStateMachine != null)
         {
            this.oAnimStateMachine.destroy();
            this.oAnimStateMachine = null;
         }
         this.oIdleAssetReference = null;
         this.oOutAssetReference = null;
         this.oInAssetReference = null;
         this.oShowHideTimer.stop();
         this.oShowHideTimer.destroy();
         this.oShowHideTimer = null;
         --nInstanceCmpt;
         if(nInstanceCmpt <= 0)
         {
            if(oDefaultInSoundInfo != null)
            {
               oDefaultInSoundInfo.destroy();
               oDefaultInSoundInfo = null;
            }
            if(oDefaultOutSoundInfo != null)
            {
               oDefaultOutSoundInfo.destroy();
               oDefaultOutSoundInfo = null;
            }
         }
         if(this.oCustomInSoundInfo != null)
         {
            this.oCustomInSoundInfo.destroy();
            this.oCustomInSoundInfo = null;
         }
         if(this.oCustomOutSoundInfo != null)
         {
            this.oCustomOutSoundInfo.destroy();
            this.oCustomOutSoundInfo = null;
         }
         super.destroy();
      }
      
      override protected function init() : void
      {
         this.bGoHide = true;
         this.oShowHideTimer = new FrameTimer(1,0,false);
         eventManager.addEventListener(sFRAME_TIMER_EVENT,this.oShowHideTimer,TimerEvent.TIMER,this.onTimerTick);
      }
      
      public function setLibraryAssetReference(_oInAssetReference:AssetReference, _oIdleAssetReference:AssetReference, _oOutAssetReference:AssetReference) : void
      {
         this.oInAssetReference = _oInAssetReference;
         this.oIdleAssetReference = _oIdleAssetReference;
         this.oOutAssetReference = _oOutAssetReference;
      }
      
      public function setTimelineAssetReference(_oAssetReference:AssetReference) : void
      {
         assetLocation = _oAssetReference;
      }
      
      public function setCustomInSound(_oSoundAsset:AssetReference, _sCategory:String, _nVolume:Number = 1, _bLoop:Boolean = false) : void
      {
         if(this.oCustomInSoundInfo != null)
         {
            this.oCustomInSoundInfo.destroy();
            this.oCustomInSoundInfo = null;
         }
         this.oCustomInSoundInfo = new SoundInfoStruct(_oSoundAsset,_sCategory,_nVolume,_bLoop);
      }
      
      public function setCustomOutSound(_oSoundAsset:AssetReference, _sCategory:String, _nVolume:Number = 1, _bLoop:Boolean = false) : void
      {
         if(this.oCustomOutSoundInfo != null)
         {
            this.oCustomOutSoundInfo.destroy();
            this.oCustomOutSoundInfo = null;
         }
         this.oCustomOutSoundInfo = new SoundInfoStruct(_oSoundAsset,_sCategory,_nVolume,_bLoop);
      }
      
      override internal function show() : void
      {
         if(bUseMouseBlocker)
         {
            showMouseBlocker();
            this.showUnderMouseBlocker();
         }
         showContainer();
         this.initStateMachine();
         cleanUpTransition();
         dispatchEvent(new ViewEvent(ViewEvent.SHOW,false,false,ID));
         if(this.bSkipInOutStates)
         {
            this.oAnimStateMachine.setState(sIDLE);
         }
         onShow();
      }
      
      override internal function beforeHide() : void
      {
         if(this.bSkipInOutStates)
         {
            super.beforeHide();
         }
         else if(this.bGoHide)
         {
            this.oAnimStateMachine.setState(sOUT);
            if(this.oCustomOutSoundInfo != null)
            {
               if(this.oCustomOutSoundInfo.oSound == null)
               {
                  this.oCustomOutSoundInfo.oSound = SoundManager.instance.play(this.oCustomOutSoundInfo.sCategory,this.oCustomOutSoundInfo.oSoundAsset,this.oCustomOutSoundInfo.nVolume,this.oCustomOutSoundInfo.nLoop,false);
               }
               else
               {
                  this.oCustomOutSoundInfo.oSound.start();
               }
            }
            else if(oDefaultOutSoundInfo != null)
            {
               if(oDefaultOutSoundInfo.oSound == null)
               {
                  oDefaultOutSoundInfo.oSound = SoundManager.instance.play(oDefaultOutSoundInfo.sCategory,oDefaultOutSoundInfo.oSoundAsset,oDefaultOutSoundInfo.nVolume,oDefaultOutSoundInfo.nLoop,false);
               }
               else
               {
                  oDefaultOutSoundInfo.oSound.start();
               }
            }
         }
         else
         {
            this.oShowHideTimer.start();
         }
      }
      
      override internal function hide() : void
      {
         if(bUseMouseBlocker)
         {
            this.hideUnderMouseBlocker();
         }
         if(this.oAnimStateMachine != null)
         {
            this.oAnimStateMachine.destroy();
            this.oAnimStateMachine = null;
         }
         super.hide();
      }
      
      override public function preventHide() : void
      {
         this.bGoHide = false;
      }
      
      override public function resumeHide() : void
      {
         this.bGoHide = true;
      }
      
      override public function onPause() : void
      {
         if(this.oAnimStateMachine != null)
         {
            if(this.oAnimStateMachine.isRunning)
            {
               this.oAnimStateMachine.pause();
            }
         }
      }
      
      override public function onResume() : void
      {
         if(this.oAnimStateMachine != null)
         {
            this.oAnimStateMachine.resume();
         }
      }
      
      protected function showUnderMouseBlocker() : void
      {
         if(this.mcUnderMouseBlocker == null)
         {
            this.mcUnderMouseBlocker = new Sprite();
            this.mcUnderMouseBlocker.graphics.beginFill(0);
            this.mcUnderMouseBlocker.graphics.drawRect(0,0,mcContainer.stage.stageWidth,mcContainer.stage.stageHeight);
            this.mcUnderMouseBlocker.graphics.endFill();
            this.mcUnderMouseBlocker.alpha = 0;
            mcContainer.addChildAt(this.mcUnderMouseBlocker,0);
         }
      }
      
      protected function hideUnderMouseBlocker() : void
      {
         if(Boolean(this.mcUnderMouseBlocker))
         {
            mcContainer.removeChild(this.mcUnderMouseBlocker);
            this.mcUnderMouseBlocker = null;
         }
      }
      
      private function onTimerTick(_oEvent:TimerEvent) : void
      {
         if(this.bGoHide)
         {
            this.oShowHideTimer.stop();
            this.oAnimStateMachine.setState(sOUT);
         }
      }
      
      private function initStateMachine() : void
      {
         if(this.oAnimLocation == AnimStateLocation.TIMELINE)
         {
            this.oAnimStateMachine = new AnimStateMachine(mcContent,transitionPausable,false);
         }
         else
         {
            this.oAnimStateMachine = new AnimStateMachine(mcContainer,transitionPausable,false);
         }
         mcContainer.x = x;
         mcContainer.y = y;
         if(this.oAnimLocation == AnimStateLocation.TIMELINE)
         {
            this.oAnimStateMachine.addState(sIN,this.state_in,this.state_in_init,this.state_in_end);
            this.oAnimStateMachine.addState(sIDLE,this.state_idle,this.state_idle_init,this.state_idle_end);
            this.oAnimStateMachine.addState(sOUT,this.state_out,this.state_out_init,this.state_out_end);
         }
         else if(this.oAnimLocation == AnimStateLocation.ASSET)
         {
            this.oAnimStateMachine.setAnimLocation(this.oAnimLocation);
            this.oAnimStateMachine.addStateFromAsset(sIN,this.oInAssetReference,this.state_in,this.state_in_init,null);
            this.oAnimStateMachine.addStateFromAsset(sIDLE,this.oIdleAssetReference,this.state_idle,this.state_idle_init,null);
            this.oAnimStateMachine.addStateFromAsset(sOUT,this.oOutAssetReference,this.state_out,this.state_out_init,null);
         }
         if(!this.bSkipInOutStates)
         {
            this.oAnimStateMachine.setState(sIN);
         }
         if(this.oCustomInSoundInfo != null)
         {
            if(this.oCustomInSoundInfo.oSound == null)
            {
               this.oCustomInSoundInfo.oSound = SoundManager.instance.play(this.oCustomInSoundInfo.sCategory,this.oCustomInSoundInfo.oSoundAsset,this.oCustomInSoundInfo.nVolume,this.oCustomInSoundInfo.nLoop,false);
            }
            else
            {
               this.oCustomInSoundInfo.oSound.start();
            }
         }
         else if(oDefaultInSoundInfo != null)
         {
            if(oDefaultInSoundInfo.oSound == null)
            {
               oDefaultInSoundInfo.oSound = SoundManager.instance.play(oDefaultInSoundInfo.sCategory,oDefaultInSoundInfo.oSoundAsset,oDefaultInSoundInfo.nVolume,oDefaultInSoundInfo.nLoop,false);
            }
            else
            {
               oDefaultInSoundInfo.oSound.start();
            }
         }
      }
      
      protected function state_in_init() : void
      {
      }
      
      protected function state_in() : void
      {
         if(this.oAnimStateMachine != null)
         {
            if(this.oAnimStateMachine.isLastFrame)
            {
               this.oAnimStateMachine.setState(sIDLE);
            }
         }
      }
      
      protected function state_in_end() : void
      {
      }
      
      protected function state_idle_init() : void
      {
         if(bUseMouseBlocker)
         {
            hideMouseBlocker();
         }
      }
      
      protected function state_idle() : void
      {
      }
      
      protected function state_idle_end() : void
      {
      }
      
      protected function state_out_init() : void
      {
      }
      
      protected function state_out() : void
      {
         if(this.oAnimStateMachine.isLastFrame)
         {
            this.hide();
         }
      }
      
      protected function state_out_end() : void
      {
      }
      
      public function get mcState() : MovieClip
      {
         return this.oAnimStateMachine.mcState as MovieClip;
      }
      
      public function get skipInOutStates() : Boolean
      {
         return this.bSkipInOutStates;
      }
      
      public function set skipInOutStates(_bSkipInOutStates:Boolean) : void
      {
         this.bSkipInOutStates = _bSkipInOutStates;
      }
      
      public function get animStateMachine() : AnimStateMachine
      {
         return this.oAnimStateMachine;
      }
   }
}

import com.sarbakan.sbdk.asset.AssetReference;
import com.sarbakan.sbdk.sound.SoundUnit;

class SoundInfoStruct
{
   
   public var oSound:SoundUnit;
   
   public var oSoundAsset:AssetReference;
   
   public var nVolume:Number;
   
   public var nLoop:int;
   
   public var sCategory:String;
   
   public function SoundInfoStruct(_oSoundAsset:AssetReference, _sCategory:String, _nVolume:Number, _bLoop:Boolean)
   {
      super();
      this.oSoundAsset = _oSoundAsset;
      this.nVolume = _nVolume;
      this.sCategory = _sCategory;
      if(_bLoop)
      {
         this.nLoop = 999;
      }
      else
      {
         this.nLoop = 1;
      }
   }
   
   public function destroy() : void
   {
      if(this.oSound != null)
      {
         this.oSound.destroy();
         this.oSound = null;
      }
      this.oSoundAsset = null;
   }
}
