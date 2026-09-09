package com.sarbakan.sbdk.utils
{
   import com.sarbakan.sbdk.core.UpdateManager;
   import com.sarbakan.sbdk.errors.ErrorMessages;
   import com.sarbakan.sbdk.events.MonitorEvent;
   import com.sarbakan.sbdk.events.UpdateEvent;
   import com.sarbakan.sbdk.math.MovingAverage;
   import flash.display.DisplayObjectContainer;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   [Event(name="MAX",type="com.sarbakan.sbdk.events.MonitorEvent")]
   [Event(name="MIN",type="com.sarbakan.sbdk.events.MonitorEvent")]
   [Event(name="UPDATE",type="com.sarbakan.sbdk.events.MonitorEvent")]
   public class FPSMonitor extends EventDispatcher implements IMonitor, IGraphicallyDebuggable
   {
      
      private static var oInstance:FPSMonitor;
      
      private static const sEVENT_MANAGER_ID:String = "fpsMonitor";
      
      private static const nAVERAGE_MAX_SAMPLE:uint = 5;
      
      private static var bAllowConstruction:Boolean = false;
      
      private const sTIMER_EVENT:String = "TIMER_EVENT";
      
      private const sFPS_MONITOR:String = "FPS_MONITOR";
      
      private var oStage:Stage;
      
      private var oEventManager:EventManager;
      
      private var bRunning:Boolean;
      
      private var nCounterUpdate:int;
      
      private var nCurrentFPS:int;
      
      private var oMovingAverage:MovingAverage;
      
      private var nMinThreshold:int;
      
      private var nMaxThreshold:int;
      
      private var bDebug:Boolean;
      
      private var oUpdateTimer:Timer;
      
      public function FPSMonitor(_oStage:Stage)
      {
         super();
         if(!bAllowConstruction)
         {
            throw new Error(ErrorMessages.sSINGLETON_STAGE);
         }
         this.oStage = _oStage;
      }
      
      public static function instance(_oStage:Stage) : FPSMonitor
      {
         if(oInstance == null)
         {
            bAllowConstruction = true;
            oInstance = new FPSMonitor(_oStage);
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
            this.oEventManager.addEventListener(sEVENT_MANAGER_ID,UpdateManager.instance,UpdateEvent.UPDATE,this.enterFrame);
            this.oEventManager.addEventListener(sEVENT_MANAGER_ID,UpdateManager.instance,UpdateEvent.UPDATE_PAUSED,this.enterFrame);
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
         this.oStage = null;
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
            _sOutput = this.value + "fps 0 ( 0 s avg:  0 )";
            GraphicDebugTextManager.instance.createTextField(this.sFPS_MONITOR);
            GraphicDebugTextManager.instance.displayText(this.sFPS_MONITOR,_sOutput);
         }
      }
      
      public function disableGraphicDebug() : void
      {
         if(this.bDebug)
         {
            this.bDebug = false;
            GraphicDebugTextManager.instance.removeTextField(this.sFPS_MONITOR);
         }
      }
      
      override public function toString() : String
      {
         return "[FPSMonitor: Running = " + this.bRunning + ", Current FPS = " + this.nCurrentFPS + "]";
      }
      
      private function init() : void
      {
         this.nCurrentFPS = this.oStage.frameRate;
         this.nCounterUpdate = 0;
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
      
      private function calculateFrameRate() : void
      {
         this.nCurrentFPS = this.nCounterUpdate;
         this.nCounterUpdate = 0;
      }
      
      private function calculateAverage() : void
      {
         this.oMovingAverage.addSample(this.nCurrentFPS);
      }
      
      private function dispatchEvents() : void
      {
         dispatchEvent(new MonitorEvent(MonitorEvent.UPDATE,false,false,this.nCurrentFPS,this.average));
         if(this.nCurrentFPS <= this.nMinThreshold)
         {
            dispatchEvent(new MonitorEvent(MonitorEvent.MIN,false,false,this.nCurrentFPS,this.average));
         }
         if(this.nCurrentFPS >= this.nMaxThreshold)
         {
            dispatchEvent(new MonitorEvent(MonitorEvent.MAX,false,false,this.nCurrentFPS,this.average));
         }
      }
      
      private function updateDebug() : void
      {
         var _sOutput:String = this.value + " fps (" + nAVERAGE_MAX_SAMPLE + "s avg: " + Math.round(this.average) + ")";
         GraphicDebugTextManager.instance.displayText(this.sFPS_MONITOR,_sOutput);
      }
      
      private function enterFrame(_e:Event) : void
      {
         ++this.nCounterUpdate;
      }
      
      private function updateFrameRate(_e:TimerEvent) : void
      {
         this.calculateFrameRate();
         this.calculateAverage();
         this.dispatchEvents();
         this.updateDebug();
      }
      
      public function get value() : int
      {
         return this.nCurrentFPS;
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

