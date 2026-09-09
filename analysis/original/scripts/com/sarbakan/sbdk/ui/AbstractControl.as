package com.sarbakan.sbdk.ui
{
   import com.sarbakan.sbdk.asset.AssetReference;
   import com.sarbakan.sbdk.errors.ErrorMessages;
   import com.sarbakan.sbdk.events.UIEvent;
   import com.sarbakan.sbdk.sound.SoundManager;
   import com.sarbakan.sbdk.utils.EventManager;
   import com.sarbakan.sbdk.utils.FrameTimer;
   import flash.display.MovieClip;
   import flash.errors.IllegalOperationError;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   [Event(name="DISABLE",type="com.sarbakan.sbdk.events.UIEvent")]
   [Event(name="ENABLE",type="com.sarbakan.sbdk.events.UIEvent")]
   public class AbstractControl extends EventDispatcher
   {
      
      private static var oDefaultSoundRoll:SoundStruct;
      
      private static var oDefaultSoundClick:SoundStruct;
      
      private static var oDefaultSoundClickDisabled:SoundStruct;
      
      private static const sEVENT_MANAGER_ID:String = "abstractControl";
      
      protected var mcContainerRef:MovieClip;
      
      protected var bEnabled:Boolean;
      
      protected var bAutomaticSoundsEnabled:Boolean = false;
      
      protected var oSoundRoll:SoundStruct;
      
      protected var oSoundClick:SoundStruct;
      
      protected var oSoundClickDisabled:SoundStruct;
      
      private var oEventManager:EventManager;
      
      private var oPublicEventManager:EventManager;
      
      private var oEventTimer:FrameTimer;
      
      private var aCallbackList:Array;
      
      public function AbstractControl(_mcRef:MovieClip)
      {
         super();
         if(Class(getDefinitionByName(getQualifiedClassName(this))) == AbstractControl)
         {
            throw new IllegalOperationError(ErrorMessages.sABSTRACT_CLASS_ERROR);
         }
         this.mcContainerRef = _mcRef;
         this.init();
      }
      
      public static function destroy() : void
      {
         if(oDefaultSoundClick != null)
         {
            oDefaultSoundClick.destroy();
            oDefaultSoundClick = null;
         }
         if(oDefaultSoundRoll != null)
         {
            oDefaultSoundRoll.destroy();
            oDefaultSoundRoll = null;
         }
         if(oDefaultSoundClickDisabled != null)
         {
            oDefaultSoundClickDisabled.destroy();
            oDefaultSoundClickDisabled = null;
         }
      }
      
      public static function setDefaultSoundRoll(_oSoundAsset:AssetReference, _sSoundCategory:String, _nVolume:Number = 1, _bLoop:Boolean = false) : void
      {
         oDefaultSoundRoll = new SoundStruct(_oSoundAsset,_sSoundCategory,_nVolume,_bLoop);
      }
      
      public static function setDefaultSoundClick(_oSoundAsset:AssetReference, _sSoundCategory:String, _nVolume:Number = 1) : void
      {
         oDefaultSoundClick = new SoundStruct(_oSoundAsset,_sSoundCategory,_nVolume);
      }
      
      public static function setDefaultSoundClickDisabled(_oSoundAsset:AssetReference, _sSoundCategory:String, _nVolume:Number = 1) : void
      {
         oDefaultSoundClickDisabled = new SoundStruct(_oSoundAsset,_sSoundCategory,_nVolume);
      }
      
      public function destroy() : void
      {
         this.stopSoundRoll();
         if(this.oSoundRoll != null)
         {
            this.oSoundRoll.destroy();
            this.oSoundRoll = null;
         }
         if(this.oSoundClick != null)
         {
            this.oSoundClick.destroy();
            this.oSoundClick = null;
         }
         if(this.oSoundClickDisabled != null)
         {
            this.oSoundClickDisabled.destroy();
            this.oSoundClickDisabled = null;
         }
         this.aCallbackList.splice(0,this.aCallbackList.length);
         this.aCallbackList = null;
         this.oEventManager.destroy();
         this.oEventManager = null;
         this.oPublicEventManager.destroy();
         this.oPublicEventManager = null;
      }
      
      public function setToolTip(_sContent:String, _iSpecialDelay:int = -1) : void
      {
         ToolTipManager.instance(this.mcContainerRef.stage).addTarget(this.mcContainerRef,_sContent,_iSpecialDelay);
      }
      
      public function setToolTipLocalized(_sStringID:String, _oReplacements:Object = null) : void
      {
         ToolTipManager.instance(this.mcContainerRef.stage).addTargetLocalized(this.mcContainerRef,_sStringID,_oReplacements);
      }
      
      public function setSoundRoll(_oSoundAsset:AssetReference, _sSoundCategory:String, _nVolume:Number = 1, _bLoop:Boolean = false) : void
      {
         this.oSoundRoll = new SoundStruct(_oSoundAsset,_sSoundCategory,_nVolume,_bLoop);
      }
      
      public function setSoundClick(_oSoundAsset:AssetReference, _sSoundCategory:String, _nVolume:Number = 1) : void
      {
         this.oSoundClick = new SoundStruct(_oSoundAsset,_sSoundCategory,_nVolume);
      }
      
      public function setSoundClickDisabled(_oSoundAsset:AssetReference, _sSoundCategory:String, _nVolume:Number = 1) : void
      {
         this.oSoundClickDisabled = new SoundStruct(_oSoundAsset,_sSoundCategory,_nVolume);
      }
      
      protected function disableAutomaticSounds() : void
      {
         this.bAutomaticSoundsEnabled = false;
      }
      
      protected function playSoundClick() : void
      {
         this.playSound(this.oSoundClick,oDefaultSoundClick);
      }
      
      protected function playSoundClickDisabled() : void
      {
         this.playSound(this.oSoundClickDisabled,oDefaultSoundClickDisabled);
      }
      
      protected function playSoundRoll() : void
      {
         this.stopSoundRoll();
         this.playSound(this.oSoundRoll,oDefaultSoundRoll);
      }
      
      protected function stopSoundRoll() : void
      {
         if(oDefaultSoundRoll != null)
         {
            if(oDefaultSoundRoll.oSound != null)
            {
               oDefaultSoundRoll.oSound.stop();
            }
         }
         else if(this.oSoundRoll != null)
         {
            if(this.oSoundRoll.oSound != null)
            {
               this.oSoundRoll.oSound.stop();
            }
         }
      }
      
      private function init() : void
      {
         this.oEventManager = new EventManager();
         this.oPublicEventManager = new EventManager();
         this.bEnabled = true;
         this.bAutomaticSoundsEnabled = true;
         this.aCallbackList = new Array();
         this.oEventTimer = new FrameTimer(1,0,false);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oEventTimer,TimerEvent.TIMER,this.onTimerUpdate);
         this.oEventTimer.start();
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.mcContainerRef,MouseEvent.CLICK,this.onClick);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.mcContainerRef,MouseEvent.ROLL_OVER,this.onRollOver);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.mcContainerRef,MouseEvent.ROLL_OUT,this.onRollOut);
      }
      
      private function playSound(_oInstanceSound:SoundStruct, _oDefaultSound:SoundStruct) : void
      {
         var _oSoundStruct:SoundStruct = null;
         var _nLoop:uint = 0;
         if(_oInstanceSound != null)
         {
            _oSoundStruct = _oInstanceSound;
         }
         else if(_oDefaultSound != null)
         {
            _oSoundStruct = _oDefaultSound;
         }
         if(_oSoundStruct != null)
         {
            _nLoop = 1;
            if(_oSoundStruct.bLoop)
            {
               _nLoop = 0;
            }
            if(!SoundManager.instance.isMuted(_oSoundStruct.sCategory))
            {
               if(_oSoundStruct.oSound == null)
               {
                  _oSoundStruct.oSound = SoundManager.instance.play(_oSoundStruct.sCategory,_oSoundStruct.oAsset,_oSoundStruct.nVolume,_nLoop,false);
               }
               else
               {
                  _oSoundStruct.oSound.start();
               }
            }
         }
      }
      
      private function onClick(_e:MouseEvent) : void
      {
         if(this.bAutomaticSoundsEnabled)
         {
            if(this.enabled)
            {
               this.aCallbackList.push(this.playSoundClick);
            }
            else
            {
               this.aCallbackList.push(this.playSoundClickDisabled);
            }
         }
      }
      
      private function onRollOver(_e:MouseEvent) : void
      {
         if(this.bAutomaticSoundsEnabled)
         {
            this.aCallbackList.push(this.playSoundRoll);
         }
      }
      
      private function onRollOut(_e:MouseEvent) : void
      {
         if(this.bAutomaticSoundsEnabled)
         {
            this.aCallbackList.push(this.stopSoundRoll);
         }
      }
      
      private function onTimerUpdate(_oEvent:TimerEvent) : void
      {
         var _fCallback:Function = null;
         if(this.aCallbackList.length > 0)
         {
            _fCallback = this.aCallbackList.shift();
            _fCallback();
         }
      }
      
      public function get mcContainer() : MovieClip
      {
         return this.mcContainerRef;
      }
      
      public function set mcContainer(_mcContainer:MovieClip) : void
      {
         this.mcContainerRef = _mcContainer;
      }
      
      public function get enabled() : Boolean
      {
         return this.bEnabled;
      }
      
      public function set enabled(_bEnabled:Boolean) : void
      {
         if(this.bEnabled != _bEnabled)
         {
            this.bEnabled = _bEnabled;
            switch(this.bEnabled)
            {
               case true:
                  dispatchEvent(new UIEvent(UIEvent.ENABLE));
                  break;
               case false:
                  dispatchEvent(new UIEvent(UIEvent.DISABLE));
            }
         }
      }
      
      protected function get eventManager() : EventManager
      {
         return this.oPublicEventManager;
      }
   }
}

import com.sarbakan.sbdk.asset.AssetReference;
import com.sarbakan.sbdk.sound.SoundUnit;

class SoundStruct
{
   
   public var oSound:SoundUnit;
   
   public var oAsset:AssetReference;
   
   public var sCategory:String;
   
   public var nVolume:Number;
   
   public var bLoop:Boolean;
   
   public function SoundStruct(_oAsset:AssetReference, _sCategory:String, _nVolume:Number, _bLoop:Boolean = false)
   {
      super();
      this.oAsset = _oAsset;
      this.sCategory = _sCategory;
      this.nVolume = _nVolume;
      this.bLoop = _bLoop;
   }
   
   public function destroy() : void
   {
      if(this.oSound != null)
      {
         this.oSound.destroy();
         this.oSound = null;
      }
      this.oAsset = null;
   }
}
