package com.sarbakan.sbdk.utils
{
   import com.sarbakan.sbdk.errors.ErrorMessages;
   import com.sarbakan.sbdk.events.MonitorEvent;
   import com.sarbakan.sbdk.math.MovingAverage;
   import flash.display.DisplayObjectContainer;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.system.System;
   import flash.text.TextField;
   import flash.utils.Timer;
   
   [Event(name="MAX",type="com.sarbakan.sbdk.events.MonitorEvent")]
   [Event(name="MIN",type="com.sarbakan.sbdk.events.MonitorEvent")]
   [Event(name="UPDATE",type="com.sarbakan.sbdk.events.MonitorEvent")]
   public class MemoryMonitor extends EventDispatcher implements IMonitor, IGraphicallyDebuggable
   {
      
      private static var oInstance:MemoryMonitor;
      
      private static const sEVENT_MANAGER_ID:String = "fpsMonitor";
      
      private static const nAVERAGE_MAX_SAMPLE:uint = 5;
      
      private static var bAllowConstruction:Boolean = false;
      
      private const sTIMER_EVENT:String = "TIMER_EVENT";
      
      private const sMEMORY_MONITOR:String = "MEMORY_MONITOR";
      
      private var oEventManager:EventManager;
      
      private var bRunning:Boolean;
      
      private var nCurrentMemory:uint;
      
      private var oMovingAverage:MovingAverage;
      
      private var nMinThreshold:int;
      
      private var nMaxThreshold:int;
      
      private var bDebug:Boolean;
      
      private var txtText:TextField;
      
      private var oUpdateTimer:Timer;
      
      public function MemoryMonitor()
      {
         super();
         if(!bAllowConstruction)
         {
            throw new Error(ErrorMessages.sSINGLETON_STAGE);
         }
      }
      
      public static function get instance() : MemoryMonitor
      {
         if(oInstance == null)
         {
            bAllowConstruction = true;
            oInstance = new MemoryMonitor();
            bAllowConstruction = false;
         }
         return oInstance;
      }
      
      public function start() : void
      {
         if(this.bRunning != true)
         {
            this.bRunning = true;
            this.init();
            this.oUpdateTimer.start();
         }
      }
      
      public function stop() : void
      {
         this.bRunning = false;
         if(this.oUpdateTimer != null)
         {
            this.oUpdateTimer.stop();
         }
         if(this.oEventManager != null)
         {
            this.oEventManager.cleanUp(this.sTIMER_EVENT);
            this.oEventManager.cleanUp(sEVENT_MANAGER_ID);
         }
      }
      
      public function destroy() : void
      {
         this.stop();
         this.oUpdateTimer = null;
         if(this.oEventManager != null)
         {
            this.oEventManager.destroy();
         }
         this.oEventManager = null;
         oInstance = null;
         this.disableGraphicDebug();
      }
      
      public function enableGraphicDebug(_mcTarget:DisplayObjectContainer) : void
      {
         var _sOutput:String = null;
         if(!this.bDebug)
         {
            this.bDebug = true;
            GraphicDebugTextManager.instance.setDisplayContainer(_mcTarget);
            _sOutput = "0 KB Memory (0s avg 0 KB)";
            GraphicDebugTextManager.instance.createTextField(this.sMEMORY_MONITOR);
            GraphicDebugTextManager.instance.displayText(this.sMEMORY_MONITOR,_sOutput);
         }
      }
      
      public function disableGraphicDebug() : void
      {
         if(this.bDebug)
         {
            this.bDebug = false;
            GraphicDebugTextManager.instance.removeTextField(this.sMEMORY_MONITOR);
         }
      }
      
      override public function toString() : String
      {
         return "[MemoryMonitor: Running = " + this.bRunning + ", Current memory = " + this.nCurrentMemory + "]";
      }
      
      private function init() : void
      {
         if(this.oUpdateTimer == null)
         {
            this.oUpdateTimer = new Timer(1000);
         }
         if(this.oMovingAverage == null)
         {
            this.oMovingAverage = new MovingAverage(nAVERAGE_MAX_SAMPLE);
         }
         else
         {
            this.oMovingAverage.reset();
         }
         if(this.oEventManager == null)
         {
            this.oEventManager = new EventManager();
         }
         else
         {
            this.oEventManager.clearAll();
         }
         this.oEventManager.addEventListener(this.sTIMER_EVENT,this.oUpdateTimer,TimerEvent.TIMER,this.updateFrameRate);
      }
      
      private function calculateAverage() : void
      {
         this.oMovingAverage.addSample(this.nCurrentMemory);
      }
      
      private function dispatchEvents() : void
      {
         dispatchEvent(new MonitorEvent(MonitorEvent.UPDATE,false,false,this.nCurrentMemory,this.average));
         if(this.nCurrentMemory <= this.nMinThreshold)
         {
            dispatchEvent(new MonitorEvent(MonitorEvent.MIN,false,false,this.nCurrentMemory,this.average));
         }
         if(this.nCurrentMemory >= this.nMaxThreshold)
         {
            dispatchEvent(new MonitorEvent(MonitorEvent.MAX,false,false,this.nCurrentMemory,this.average));
         }
      }
      
      private function updateDebug() : void
      {
         var _sOutput:String = StringFormatter.formatByte(this.value,2) + " (" + nAVERAGE_MAX_SAMPLE + "s avg: " + StringFormatter.formatByte(this.average,2) + ")";
         GraphicDebugTextManager.instance.displayText(this.sMEMORY_MONITOR,_sOutput);
      }
      
      private function updateFrameRate(_e:TimerEvent) : void
      {
         this.nCurrentMemory = System.totalMemory;
         this.calculateAverage();
         this.dispatchEvents();
         this.updateDebug();
      }
      
      public function get value() : int
      {
         return this.nCurrentMemory;
      }
      
      public function get average() : Number
      {
         return this.oMovingAverage.average;
      }
      
      public function get min() : int
      {
         return this.nMinThreshold;
      }
      
      public function set min(_nMin:int) : void
      {
         this.nMinThreshold = _nMin;
      }
      
      public function get max() : int
      {
         return this.nMaxThreshold;
      }
      
      public function set max(_nMax:int) : void
      {
         this.nMaxThreshold = _nMax;
      }
      
      public function get running() : Boolean
      {
         return this.bRunning;
      }
   }
}

