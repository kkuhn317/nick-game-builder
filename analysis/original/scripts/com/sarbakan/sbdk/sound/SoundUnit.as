package com.sarbakan.sbdk.sound
{
   import com.sarbakan.sbdk.core.UpdateManager;
   import com.sarbakan.sbdk.events.SoundEvent;
   import com.sarbakan.sbdk.math.SBKMath;
   import com.sarbakan.sbdk.utils.CallBackArguments;
   import com.sarbakan.sbdk.utils.EventManager;
   import com.sarbakan.sbdk.utils.FrameTimer;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.media.SoundTransform;
   import flash.utils.getTimer;
   
   [Event(name="ALL_SOUND_CHANNELS_USED",type="flash.events.SoundEvent")]
   [Event(name="PAN_VOLUME_COMPLETED",type="flash.events.SoundEvent")]
   [Event(name="FADE_VOLUME_COMPLETED",type="flash.events.SoundEvent")]
   [Event(name="COMPLETED",type="flash.events.SoundEvent")]
   [Event(name="READY",type="flash.events.SoundEvent")]
   public class SoundUnit extends EventDispatcher
   {
      
      private static const sEVENT_MANAGER_ID:String = "soundUnit";
      
      private static const sEVENT_MANAGER_ID_RESUME:String = "resume";
      
      private static const sTWEEN_EVENT:String = "tween_event";
      
      private static const sUP:String = "UP";
      
      private static const sDOWN:String = "DOWN";
      
      private var oEventManager:EventManager;
      
      private var oSound:Sound;
      
      private var oSoundChannel:SoundChannel;
      
      private var sAssetID:String;
      
      private var sCategoryID:String;
      
      private var bPauseable:Boolean;
      
      private var bCompleted:Boolean;
      
      private var bPlaying:Boolean;
      
      private var bDestroyed:Boolean;
      
      private var nStartPan:Number;
      
      private var nStartPosition:uint;
      
      private var bStartStop:Boolean;
      
      private var nTotalLoop:uint;
      
      private var bMuted:Boolean;
      
      private var nMutedVolume:Number;
      
      private var oFadeTimer:FrameTimer;
      
      private var nFadeStartTime:int;
      
      private var nFadeEndTime:int;
      
      private var bFadeStopEnd:Boolean;
      
      private var bFadeVolume:Boolean;
      
      private var bFadePan:Boolean;
      
      private var nCategoryVolume:Number;
      
      private var nVolume:Number;
      
      private var nFadeStep:Number;
      
      private var nDestVolume:Number;
      
      private var nCurrentVolume:Number;
      
      private var sFadeDir:String;
      
      private var bPaused:Boolean;
      
      private var oPauseTransform:SoundTransform;
      
      private var nStartTick:int;
      
      private var nPauseTick:int;
      
      private var nTotalAssetPlaying:int;
      
      private var bKillAfterPlayback:Boolean;
      
      public function SoundUnit(_sCategoryID:String, _nVolume:Number, _nLoop:uint, _bPauseable:Boolean)
      {
         super();
         this.bPauseable = _bPauseable;
         this.sCategoryID = _sCategoryID;
         this.nVolume = _nVolume;
         if(_nLoop == 0)
         {
            this.nTotalLoop = int.MAX_VALUE;
         }
         else
         {
            this.nTotalLoop = _nLoop;
         }
         this.init();
      }
      
      public function destroy() : void
      {
         if(!this.bDestroyed)
         {
            dispatchEvent(new SoundEvent(SoundEvent.DESTROYED,false,false,this));
            if(this.oEventManager != null)
            {
               this.oEventManager.destroy();
               this.oEventManager = null;
            }
            this.oSound = null;
            if(this.oSoundChannel != null)
            {
               this.oSoundChannel.stop();
               this.oSoundChannel = null;
            }
            this.oPauseTransform = null;
            this.bDestroyed = true;
            if(this.oFadeTimer != null)
            {
               this.oFadeTimer.stop();
               this.oFadeTimer = null;
            }
         }
      }
      
      public function stop() : void
      {
         if(this.ready && this.bPlaying)
         {
            this.bPlaying = false;
            this.bCompleted = true;
            this.oSoundChannel.stop();
            dispatchEvent(new SoundEvent(SoundEvent.COMPLETED,false,false,this));
         }
         else if(!this.ready)
         {
            this.bStartStop = true;
         }
      }
      
      public function start() : void
      {
         var _oSoundTransform:SoundTransform = null;
         if(!this.bPaused && !this.bDestroyed && !this.bPlaying)
         {
            _oSoundTransform = new SoundTransform(this.computedVolume,this.nStartPan);
            this.bCompleted = false;
            this.bPlaying = true;
            this.oSoundChannel.stop();
            this.oSoundChannel = this.oSound.play(this.nStartPosition,this.nTotalLoop,_oSoundTransform);
            this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oSoundChannel,Event.SOUND_COMPLETE,this.onSoundComplete);
         }
      }
      
      public function fadeVolume(_nVolumeDest:Number, _nDuration:int = 3000, _bStopAtEnd:Boolean = false, _bKillAfter:Boolean = false) : void
      {
         if(_nVolumeDest == this.individualVolume)
         {
            this.stop();
            dispatchEvent(new SoundEvent(SoundEvent.FADE_VOLUME_COMPLETED,false,false,this));
            return;
         }
         if(this.bPlaying)
         {
            if(this.oFadeTimer == null)
            {
               this.oFadeTimer = new FrameTimer(1,0,false);
            }
            else
            {
               this.oEventManager.cleanUp(sTWEEN_EVENT);
            }
            this.oFadeTimer.reset();
            this.nFadeStartTime = getTimer();
            this.nFadeEndTime = getTimer() + _nDuration;
            this.oEventManager.addEventListener(sTWEEN_EVENT,this.oFadeTimer,TimerEvent.TIMER,this.onFadeTweenUpdate,false,0,true,_bStopAtEnd);
            this.nCurrentVolume = this.individualVolume * 100;
            this.nDestVolume = _nVolumeDest * 100;
            if(this.nDestVolume > this.nCurrentVolume)
            {
               this.sFadeDir = sUP;
            }
            else
            {
               this.sFadeDir = sDOWN;
            }
            this.nFadeStep = (this.nDestVolume - this.nCurrentVolume) / (_nDuration / 1000 * UpdateManager.instance.stage.frameRate);
            if(this.ready)
            {
               this.oFadeTimer.start();
               this.bFadeVolume = true;
            }
            else
            {
               this.oFadeTimer.stop();
               this.bFadeVolume = false;
            }
            this.bKillAfterPlayback = _bKillAfter;
         }
      }
      
      public function fadePan(_nPanDest:Number, _nDuration:int = 3000, _bStopAtEnd:Boolean = false, _bKillAfter:Boolean = false) : void
      {
         if(this.pan == _nPanDest || _nPanDest == -1 && SBKMath.roundDecPl(this.pan,3) == -0.988)
         {
            return;
         }
         if(this.bPlaying)
         {
            if(this.oFadeTimer == null)
            {
               this.oFadeTimer = new FrameTimer(1);
            }
            this.oFadeTimer.reset();
            this.nFadeStartTime = getTimer();
            this.nFadeEndTime = getTimer() + _nDuration;
            this.oEventManager.addEventListener(sTWEEN_EVENT,this.oFadeTimer,TimerEvent.TIMER,this.onFadePanTweenUpdate,false,0,true,_bStopAtEnd);
            this.nCurrentVolume = this.pan * 100;
            this.nDestVolume = _nPanDest * 100;
            if(this.nCurrentVolume > this.nDestVolume)
            {
               this.nFadeStep = (Math.min(this.nDestVolume,this.nCurrentVolume) - Math.max(this.nDestVolume,this.nCurrentVolume)) / (_nDuration / 1000 * UpdateManager.instance.stage.frameRate);
               this.sFadeDir = sDOWN;
            }
            else
            {
               this.nFadeStep = (Math.max(this.nDestVolume,this.nCurrentVolume) - Math.min(this.nDestVolume,this.nCurrentVolume)) / (_nDuration / 1000 * UpdateManager.instance.stage.frameRate);
               this.sFadeDir = sUP;
            }
            if(this.ready)
            {
               this.oFadeTimer.start();
               this.bFadePan = true;
            }
            else
            {
               this.oFadeTimer.stop();
               this.bFadePan = false;
            }
            this.bKillAfterPlayback = _bKillAfter;
         }
      }
      
      public function mute() : void
      {
         if(!this.bMuted)
         {
            this.nMutedVolume = this.nVolume;
            this.nVolume = 0;
            this.bMuted = true;
            if(this.ready)
            {
               this.updateSoundTransform("volume",this.computedVolume);
            }
         }
      }
      
      public function unmute() : void
      {
         if(this.bMuted)
         {
            this.nVolume = this.nMutedVolume;
            this.bMuted = false;
            if(this.ready)
            {
               this.updateSoundTransform("volume",this.computedVolume);
            }
            if(this.oPauseTransform != null)
            {
               this.oPauseTransform.volume = this.individualVolume;
            }
         }
      }
      
      public function pause() : void
      {
         this.bPaused = true;
         if(this.ready && this.bPlaying)
         {
            this.nStartPosition = Math.round(this.oSoundChannel.position % this.oSound.length);
            this.nPauseTick = getTimer();
            this.oPauseTransform = this.oSoundChannel.soundTransform;
            this.oSoundChannel.stop();
            this.oEventManager.cleanUp(sEVENT_MANAGER_ID);
            if(this.bFadePan || this.bFadeVolume)
            {
               this.oFadeTimer.stop();
            }
         }
      }
      
      public function resume() : void
      {
         var _nLoop:int = 0;
         this.bPaused = false;
         if(this.ready && this.bPlaying)
         {
            this.nStartTick += getTimer() - this.nPauseTick;
            _nLoop = this.totalLoop - this.currentLoop;
            if(this.bMuted)
            {
               this.oPauseTransform.volume = 0;
               this.oSoundChannel = this.oSound.play(this.nStartPosition,1,this.oPauseTransform);
            }
            else
            {
               this.oSoundChannel = this.oSound.play(this.nStartPosition,1,this.oPauseTransform);
            }
            if(_nLoop > 1)
            {
               this.oEventManager.addEventListener(sEVENT_MANAGER_ID_RESUME,this.oSoundChannel,Event.SOUND_COMPLETE,CallBackArguments.create(this.onSoundResumeFirstLoopDone,_nLoop - 1));
            }
            else
            {
               this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oSoundChannel,Event.SOUND_COMPLETE,this.onSoundComplete);
            }
            if(this.bFadePan || this.bFadeVolume)
            {
               this.oFadeTimer.start();
            }
         }
      }
      
      override public function toString() : String
      {
         return "[SoundUnit: Asset ID = " + this.sAssetID + ", Category ID = " + this.sCategoryID + " Pause = " + String(this.bPaused) + ", Volume = " + String(this.nVolume) + "]";
      }
      
      internal function updateManagerPause() : void
      {
         if(this.bPauseable && !this.bPaused)
         {
            this.pause();
         }
      }
      
      internal function updateManagerResume() : void
      {
         if(this.bPauseable && this.bPaused)
         {
            this.resume();
         }
      }
      
      internal function setSoundPlaying(_bValue:Boolean) : void
      {
         this.bPlaying = _bValue;
      }
      
      internal function setSound(_oSound:Sound, _sAssetID:String, _nTotalAssetPlaying:uint) : void
      {
         var _oSoundTransform:SoundTransform = null;
         this.oSound = _oSound;
         this.sAssetID = _sAssetID;
         if(!this.bStartStop)
         {
            if(_nTotalAssetPlaying > 0)
            {
               this.nTotalAssetPlaying = _nTotalAssetPlaying;
               this.nVolume /= this.nTotalAssetPlaying;
            }
            _oSoundTransform = new SoundTransform(this.computedVolume,this.nStartPan);
            this.oSoundChannel = this.oSound.play(this.nStartPosition,this.nTotalLoop,_oSoundTransform);
            if(this.oSoundChannel != null)
            {
               this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oSoundChannel,Event.SOUND_COMPLETE,this.onSoundComplete);
               this.nStartTick = getTimer();
               if(this.bFadeVolume || this.bFadePan)
               {
                  this.oFadeTimer.start();
               }
               if(this.bPaused)
               {
                  this.bPaused = false;
                  this.pause();
               }
               this.bPlaying = true;
               dispatchEvent(new SoundEvent(SoundEvent.READY,false,false,this));
            }
            else
            {
               this.bCompleted = true;
               dispatchEvent(new SoundEvent(SoundEvent.ALL_SOUND_CHANNELS_USED,false,false,this));
            }
         }
         else
         {
            dispatchEvent(new SoundEvent(SoundEvent.READY,false,false,this));
            this.bCompleted = true;
            dispatchEvent(new SoundEvent(SoundEvent.COMPLETED,false,false,this));
            this.destroy();
         }
      }
      
      internal function get killAfterPlayback() : Boolean
      {
         return this.bKillAfterPlayback;
      }
      
      internal function set killAfterPlayback(_bValue:Boolean) : void
      {
         this.bKillAfterPlayback = _bValue;
      }
      
      private function init() : void
      {
         this.nStartPosition = 0;
         this.nStartPan = 0;
         this.nFadeStep = 0;
         this.nDestVolume = 0;
         this.nCurrentVolume = 0;
         this.nMutedVolume = -1;
         this.bKillAfterPlayback = false;
         this.bFadePan = false;
         this.bFadeVolume = false;
         this.bPlaying = false;
         this.oEventManager = new EventManager();
      }
      
      private function updateSoundTransform(_sProperty:String, _nValue:Number) : void
      {
         var _oSoundTransform:SoundTransform = this.oSoundChannel.soundTransform;
         _oSoundTransform[_sProperty] = _nValue;
         if(this.bPaused && this.oPauseTransform != null)
         {
            this.oPauseTransform[_sProperty] = _nValue;
         }
         this.oSoundChannel.soundTransform = _oSoundTransform;
      }
      
      private function onSoundResumeFirstLoopDone(_e:Event, _nLoop:int) : void
      {
         this.oEventManager.cleanUp(sEVENT_MANAGER_ID_RESUME);
         this.oSoundChannel = this.oSound.play(0,_nLoop,this.oPauseTransform);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oSoundChannel,Event.SOUND_COMPLETE,this.onSoundComplete);
      }
      
      private function onSoundComplete(_e:Event) : void
      {
         this.stop();
      }
      
      private function onFadeTweenUpdate(_oEvent:TimerEvent, _bStopAtEnd:Boolean) : void
      {
         if(this.sFadeDir == sUP)
         {
            if(getTimer() - this.nFadeStartTime < this.nFadeEndTime && this.nCurrentVolume < this.nDestVolume)
            {
               this.nCurrentVolume += this.nFadeStep;
               this.individualVolume = this.nCurrentVolume / 100;
               return;
            }
         }
         else if(this.sFadeDir == sDOWN)
         {
            if(getTimer() - this.nFadeStartTime < this.nFadeEndTime && this.nCurrentVolume > this.nDestVolume)
            {
               this.nCurrentVolume += this.nFadeStep;
               this.individualVolume = this.nCurrentVolume / 100;
               return;
            }
         }
         this.oEventManager.cleanUp(sTWEEN_EVENT);
         this.bFadeVolume = false;
         this.individualVolume = this.nDestVolume / 100;
         if(_bStopAtEnd)
         {
            this.stop();
         }
         dispatchEvent(new SoundEvent(SoundEvent.FADE_VOLUME_COMPLETED,false,false,this));
      }
      
      private function onFadePanTweenUpdate(_oEvent:TimerEvent, _bStopAtEnd:Boolean) : void
      {
         if(this.sFadeDir == sUP)
         {
            if(getTimer() - this.nFadeStartTime < this.nFadeEndTime && this.nCurrentVolume < this.nDestVolume)
            {
               this.nCurrentVolume += this.nFadeStep;
               this.pan = this.nCurrentVolume / 100;
               return;
            }
         }
         else if(this.sFadeDir == sDOWN)
         {
            if(getTimer() - this.nFadeStartTime < this.nFadeEndTime && this.nCurrentVolume > this.nDestVolume)
            {
               this.nCurrentVolume += this.nFadeStep;
               this.pan = this.nCurrentVolume / 100;
               return;
            }
         }
         this.oEventManager.cleanUp(sTWEEN_EVENT);
         dispatchEvent(new SoundEvent(SoundEvent.FADE_PAN_COMPLETED,false,false,this));
         this.bFadePan = false;
         this.pan = this.nDestVolume / 100;
         if(_bStopAtEnd)
         {
            this.stop();
         }
      }
      
      public function get ready() : Boolean
      {
         return this.oSoundChannel != null;
      }
      
      public function get completed() : Boolean
      {
         return this.bCompleted;
      }
      
      public function get playing() : Boolean
      {
         return this.bPlaying;
      }
      
      public function get assetID() : String
      {
         return this.sAssetID;
      }
      
      public function get categoryID() : String
      {
         return this.sCategoryID;
      }
      
      public function get muted() : Boolean
      {
         return this.bMuted;
      }
      
      public function get paused() : Boolean
      {
         return this.bPaused;
      }
      
      public function get pauseable() : Boolean
      {
         return this.bPauseable;
      }
      
      private function get computedVolume() : Number
      {
         return this.nVolume * this.categoryVolume;
      }
      
      public function get categoryVolume() : Number
      {
         return this.nCategoryVolume;
      }
      
      public function set categoryVolume(_nCatVolume:Number) : void
      {
         this.nCategoryVolume = _nCatVolume;
         if(this.ready)
         {
            this.updateSoundTransform("volume",this.computedVolume);
         }
      }
      
      public function get individualVolume() : Number
      {
         if(!this.bPlaying)
         {
            return 0;
         }
         if(this.bMuted)
         {
            return this.nMutedVolume;
         }
         if(this.ready)
         {
            return this.oSoundChannel.soundTransform.volume;
         }
         return this.nVolume;
      }
      
      public function set individualVolume(_nVolume:Number) : void
      {
         if(!this.bPlaying)
         {
            return;
         }
         if(this.nTotalAssetPlaying > 0)
         {
            _nVolume /= this.nTotalAssetPlaying;
         }
         if(this.bMuted)
         {
            this.nMutedVolume = _nVolume;
         }
         else
         {
            this.nVolume = _nVolume;
            if(this.ready)
            {
               this.updateSoundTransform("volume",this.computedVolume);
            }
         }
      }
      
      public function get pan() : Number
      {
         if(!this.bPlaying)
         {
            return 0;
         }
         if(this.ready)
         {
            return this.oSoundChannel.soundTransform.pan;
         }
         return this.nStartPan;
      }
      
      public function set pan(_nPan:Number) : void
      {
         if(!this.bPlaying)
         {
            return;
         }
         if(this.ready)
         {
            this.updateSoundTransform("pan",_nPan);
         }
         else
         {
            this.nStartPan = _nPan;
         }
      }
      
      public function get duration() : int
      {
         if(!this.bPlaying)
         {
            return 0;
         }
         if(this.ready)
         {
            return this.oSound.length;
         }
         return -1;
      }
      
      public function get position() : int
      {
         if(!this.bPlaying)
         {
            return 0;
         }
         if(this.ready && !this.bPaused)
         {
            return this.oSoundChannel.position;
         }
         if(this.bPaused)
         {
            return this.nStartPosition;
         }
         return 0;
      }
      
      public function set position(_nPosition:int) : void
      {
         var _nLoop:int = 0;
         if(!this.bPlaying)
         {
            return;
         }
         if(this.ready && !this.bPaused)
         {
            if(this.bPauseable)
            {
               this.pause();
               this.nStartPosition = _nPosition;
               this.resume();
            }
            else
            {
               this.oSoundChannel.stop();
               this.oEventManager.cleanUp(sEVENT_MANAGER_ID);
               this.oEventManager.cleanUp(sEVENT_MANAGER_ID_RESUME);
               this.nStartPosition = _nPosition;
               this.nStartTick -= this.nStartPosition;
               _nLoop = this.totalLoop - this.currentLoop;
               if(this.individualVolume > 0)
               {
                  this.oSoundChannel = this.oSound.play(this.nStartPosition,1,this.oPauseTransform);
               }
               else
               {
                  this.oSoundChannel = this.oSound.play(this.nStartPosition,1,this.oSoundChannel.soundTransform);
               }
               if(_nLoop > 1)
               {
                  this.oEventManager.addEventListener(sEVENT_MANAGER_ID_RESUME,this.oSoundChannel,Event.SOUND_COMPLETE,CallBackArguments.create(this.onSoundResumeFirstLoopDone,_nLoop - 1));
               }
               else
               {
                  this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oSoundChannel,Event.SOUND_COMPLETE,this.onSoundComplete);
               }
               if(this.muted)
               {
                  this.updateSoundTransform("volume",0);
               }
            }
         }
         else
         {
            this.nStartPosition = _nPosition;
         }
      }
      
      public function get currentLoop() : int
      {
         var _nProgressPercent:Number = NaN;
         if(this.completed)
         {
            return 0;
         }
         if(this.ready && this.nTotalLoop > 0)
         {
            if(this.bPaused)
            {
               _nProgressPercent = (this.nPauseTick - this.nStartTick) / (this.nTotalLoop * this.oSound.length);
            }
            else
            {
               _nProgressPercent = (getTimer() - this.nStartTick) / (this.nTotalLoop * this.oSound.length);
            }
            return Math.floor(_nProgressPercent * this.nTotalLoop);
         }
         return 0;
      }
      
      public function get totalLoop() : int
      {
         if(this.completed)
         {
            return 0;
         }
         return this.nTotalLoop;
      }
      
      public function get rightPeak() : Number
      {
         if(this.ready && !this.completed)
         {
            return this.oSoundChannel.rightPeak;
         }
         return 0;
      }
      
      public function get leftPeak() : Number
      {
         if(this.ready && !this.completed)
         {
            return this.oSoundChannel.leftPeak;
         }
         return 0;
      }
      
      public function get leftToLeft() : Number
      {
         if(!this.ready || this.completed)
         {
            return 0;
         }
         return this.oSoundChannel.soundTransform.leftToLeft;
      }
      
      public function set leftToLeft(_nValue:Number) : void
      {
         if(this.ready && !this.completed)
         {
            this.updateSoundTransform("leftToLeft",_nValue);
         }
      }
      
      public function get leftToRight() : Number
      {
         if(!this.ready || this.completed)
         {
            return 0;
         }
         return this.oSoundChannel.soundTransform.leftToRight;
      }
      
      public function set leftToRight(_nValue:Number) : void
      {
         if(this.ready && !this.completed)
         {
            this.updateSoundTransform("leftToRight",_nValue);
         }
      }
      
      public function get rightToLeft() : Number
      {
         if(!this.ready || this.completed)
         {
            return 0;
         }
         return this.oSoundChannel.soundTransform.rightToLeft;
      }
      
      public function set rightToLeft(_nValue:Number) : void
      {
         if(this.ready && !this.completed)
         {
            this.updateSoundTransform("rightToLeft",_nValue);
         }
      }
      
      public function get rightToRight() : Number
      {
         if(!this.ready || this.completed)
         {
            return 0;
         }
         return this.oSoundChannel.soundTransform.rightToRight;
      }
      
      public function set rightToRight(_nValue:Number) : void
      {
         if(!this.ready || this.ready && !this.completed)
         {
            this.updateSoundTransform("rightToRight",_nValue);
         }
      }
   }
}

