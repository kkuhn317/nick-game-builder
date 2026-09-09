package com.sarbakan.sbdk.utils
{
   import com.sarbakan.sbdk.core.UpdateManager;
   import com.sarbakan.sbdk.events.UpdateEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   
   [Event(name="TIMER_COMPLETE",type="flash.events.TimerEvent")]
   [Event(name="TIMER",type="flash.events.TimerEvent")]
   public class FrameTimer extends EventDispatcher
   {
      
      private static const sEVENT_MANAGER_ID:String = "frameTimer";
      
      private var nDelay:int;
      
      private var nCounterDelay:int;
      
      private var oEventManager:EventManager;
      
      private var nRepeatCount:int;
      
      private var nCounterRepeat:int;
      
      private var bRunning:Boolean;
      
      private var bPauseable:Boolean;
      
      private var bDestroyed:Boolean;
      
      public function FrameTimer(_nDelay:uint, _nRepeatCount:uint = 0, _bPauseable:Boolean = true)
      {
         super();
         this.nDelay = _nDelay;
         this.nRepeatCount = _nRepeatCount;
         this.bPauseable = _bPauseable;
         this.init();
      }
      
      public function start() : void
      {
         this.bRunning = true;
      }
      
      public function stop() : void
      {
         this.bRunning = false;
      }
      
      public function reset() : void
      {
         this.stop();
         this.nCounterDelay = 0;
         this.nCounterRepeat = 0;
      }
      
      public function destroy() : void
      {
         if(!this.bDestroyed)
         {
            this.stop();
            this.oEventManager.destroy();
            this.oEventManager = null;
            this.bDestroyed = true;
         }
      }
      
      override public function toString() : String
      {
         return "[FrameTimer: Running = " + this.bRunning + ", Delay = " + this.nDelay + ", Current count = " + this.currentCount + ", Repeat count = " + this.repeatCount + "]";
      }
      
      private function init() : void
      {
         this.oEventManager = new EventManager();
         this.reset();
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,UpdateManager.instance,UpdateEvent.UPDATE,this.onUpdate);
         if(this.bPauseable == false)
         {
            this.oEventManager.addEventListener(sEVENT_MANAGER_ID,UpdateManager.instance,UpdateEvent.UPDATE_PAUSED,this.onUpdate);
         }
      }
      
      private function onUpdate(_e:Event) : void
      {
         var _bDispatchTimer:Boolean = false;
         var _bDispatchComplete:Boolean = false;
         if(!this.bDestroyed && this.bRunning)
         {
            _bDispatchTimer = false;
            _bDispatchComplete = false;
            if(++this.nCounterDelay == this.nDelay)
            {
               _bDispatchTimer = true;
               ++this.nCounterRepeat;
               if(this.nRepeatCount == 0 || this.nCounterRepeat < this.nRepeatCount)
               {
                  this.nCounterDelay = 0;
               }
               else
               {
                  _bDispatchComplete = true;
                  this.stop();
               }
            }
            if(_bDispatchTimer)
            {
               dispatchEvent(new TimerEvent(TimerEvent.TIMER));
            }
            if(_bDispatchComplete)
            {
               dispatchEvent(new TimerEvent(TimerEvent.TIMER_COMPLETE));
            }
         }
      }
      
      public function get currentCount() : int
      {
         return this.nCounterRepeat + 1;
      }
      
      public function get delay() : int
      {
         return this.nDelay;
      }
      
      public function set delay(_nDelay:int) : void
      {
         this.nDelay = Math.max(1,_nDelay);
         this.nCounterDelay = 0;
      }
      
      public function get delayMillisecond() : int
      {
         return this.nDelay / UpdateManager.instance.stage.frameRate * 1000;
      }
      
      public function set delayMillisecond(_nDelay:int) : void
      {
         this.delay = Math.round(_nDelay / 1000 * UpdateManager.instance.stage.frameRate);
      }
      
      public function get remainingMillisecond() : int
      {
         return (this.nDelay - this.nCounterDelay) / UpdateManager.instance.stage.frameRate * 1000;
      }
      
      public function get repeatCount() : int
      {
         return this.nRepeatCount;
      }
      
      public function set repeatCount(_nRepeatCount:int) : void
      {
         if(this.nCounterRepeat > _nRepeatCount)
         {
            this.stop();
         }
         else
         {
            this.nRepeatCount = _nRepeatCount;
         }
      }
      
      public function get running() : Boolean
      {
         return this.bRunning;
      }
   }
}

