package com.sarbakan.sbdk.state
{
   import com.sarbakan.sbdk.core.UpdateManager;
   import com.sarbakan.sbdk.events.StateEvent;
   import com.sarbakan.sbdk.events.UpdateEvent;
   import com.sarbakan.sbdk.tools.*;
   import com.sarbakan.sbdk.utils.EventManager;
   import com.sarbakan.sbdk.utils.ObjectList;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   [Event(name="RESUME",type="com.sarbakan.sbdk.events.StateEvent")]
   [Event(name="PAUSE",type="com.sarbakan.sbdk.events.StateEvent")]
   [Event(name="STOP",type="com.sarbakan.sbdk.events.StateEvent")]
   [Event(name="START",type="com.sarbakan.sbdk.events.StateEvent")]
   public class StateMachine extends EventDispatcher
   {
      
      public static const nDEFAULT_TIMER_DELAY:int = 100;
      
      private static const sEVENT_MANAGER_ID_CURRENTSTATE:String = "currentState";
      
      protected var oStateStructs:ObjectList;
      
      protected var oCurrentStateStruct:StateStruct;
      
      protected var sState:String;
      
      protected var bPauseable:Boolean;
      
      protected var bDestroyed:Boolean;
      
      protected var bWeakReference:Boolean;
      
      protected var bPaused:Boolean;
      
      private var oUpdateTimer:Timer;
      
      private var oType:StateMachineType;
      
      private var bRunning:Boolean;
      
      private var oEventManager:EventManager;
      
      private var oPublicEventManager:EventManager;
      
      public function StateMachine(_oType:StateMachineType, _bPauseable:Boolean = true, _bWeakReference:Boolean = true)
      {
         super();
         this.oType = _oType;
         this.bPauseable = _bPauseable;
         this.bWeakReference = _bWeakReference;
         this.init();
      }
      
      public function destroy() : void
      {
         this.stop();
         if(this.oPublicEventManager != null)
         {
            this.oPublicEventManager.clearAll();
            this.oPublicEventManager.destroy();
            this.oPublicEventManager = null;
         }
         if(this.oEventManager != null)
         {
            this.oEventManager.destroy();
            this.oEventManager = null;
         }
         if(this.oStateStructs != null)
         {
            this.oStateStructs.destroy();
            this.oStateStructs = null;
         }
         this.oUpdateTimer = null;
         this.bDestroyed = true;
      }
      
      public function setState(_sStateID:String, _bResetState:Boolean = false) : void
      {
         if(this.sState == _sStateID && !_bResetState)
         {
            return;
         }
         this.sState = _sStateID;
         if(this.isRunning)
         {
            this.stop();
            this.start();
         }
         else
         {
            this.start();
         }
      }
      
      public function isState(... _sStates) : Boolean
      {
         var i:int = 0;
         var _bExist:Boolean = false;
         if(this.oCurrentStateStruct != null)
         {
            for(i = 0; i < _sStates.length; i++)
            {
               if(_sStates[i] == this.oCurrentStateStruct.sID)
               {
                  _bExist = true;
                  break;
               }
            }
         }
         return _bExist;
      }
      
      public function isNotState(... _sStates) : Boolean
      {
         var i:int = 0;
         var _bExist:Boolean = true;
         if(this.oCurrentStateStruct != null)
         {
            for(i = 0; i < _sStates.length; i++)
            {
               if(_sStates[i] == this.oCurrentStateStruct.sID)
               {
                  _bExist = false;
                  break;
               }
            }
         }
         return _bExist;
      }
      
      public function stateExist(_sStateID:String) : Boolean
      {
         return this.oStateStructs.find(_sStateID) != null;
      }
      
      public function addState(_sStateID:String, _fStateCallback:Function = null, _fStateInitCallback:Function = null, _fStateEndcallBack:Function = null) : void
      {
         var oStateStruct:StateStruct = new StateStruct();
         oStateStruct.sID = _sStateID;
         oStateStruct.fState = _fStateCallback;
         oStateStruct.fStateInit = _fStateInitCallback;
         oStateStruct.fStateEnd = _fStateEndcallBack;
         this.oStateStructs.insert(_sStateID,oStateStruct);
      }
      
      public function removeState(_sStateID:String) : void
      {
         var oStateStruct:StateStruct = this.oStateStructs.find(_sStateID);
         this.stop();
         if(oStateStruct != null)
         {
            this.oStateStructs.remove(_sStateID);
            oStateStruct = null;
            if(this.sState == _sStateID)
            {
               this.sState = null;
            }
         }
      }
      
      public function pause() : void
      {
         if(!this.bPaused && this.bPauseable)
         {
            if(this.oType == StateMachineType.TIME_BASED)
            {
               this.oUpdateTimer.stop();
            }
            this.oEventManager.cleanUp(sEVENT_MANAGER_ID_CURRENTSTATE);
            this.bPaused = true;
            dispatchEvent(new StateEvent(StateEvent.PAUSE,false,false,this.state));
         }
      }
      
      public function resume() : void
      {
         if(this.bPaused)
         {
            if(this.oType == StateMachineType.FRAME_BASED)
            {
               this.oEventManager.addEventListener(sEVENT_MANAGER_ID_CURRENTSTATE,UpdateManager.instance,UpdateEvent.UPDATE,this.onStateTick,false,0,this.bWeakReference);
               if(this.bPauseable == false)
               {
                  this.oEventManager.addEventListener(sEVENT_MANAGER_ID_CURRENTSTATE,UpdateManager.instance,UpdateEvent.UPDATE_PAUSED,this.onStateTick,false,0,this.bWeakReference);
               }
            }
            else if(this.oType == StateMachineType.TIME_BASED)
            {
               this.oEventManager.addEventListener(sEVENT_MANAGER_ID_CURRENTSTATE,this.oUpdateTimer,TimerEvent.TIMER,this.onStateTick,false,0,this.bWeakReference);
               this.oUpdateTimer.start();
            }
            this.bPaused = false;
            dispatchEvent(new StateEvent(StateEvent.RESUME,false,false,this.state));
         }
      }
      
      override public function toString() : String
      {
         return "[StateMachine: Current state = " + this.sState + ", Running = " + this.bRunning + "]";
      }
      
      internal function callInitCallBack() : void
      {
         if(this.oCurrentStateStruct.fStateInit != null)
         {
            this.oCurrentStateStruct.fStateInit();
         }
      }
      
      protected function start() : void
      {
         var _oStateStruct:StateStruct = null;
         if(!this.isRunning)
         {
            _oStateStruct = this.oStateStructs.find(this.state);
            if(_oStateStruct != null)
            {
               this.oCurrentStateStruct = _oStateStruct;
               if(this.oType == StateMachineType.FRAME_BASED)
               {
                  this.oEventManager.addEventListener(sEVENT_MANAGER_ID_CURRENTSTATE,UpdateManager.instance,UpdateEvent.UPDATE,this.onStateTick,false,0,this.bWeakReference);
                  if(this.bPauseable == false)
                  {
                     this.oEventManager.addEventListener(sEVENT_MANAGER_ID_CURRENTSTATE,UpdateManager.instance,UpdateEvent.UPDATE_PAUSED,this.onStateTick,false,0,this.bWeakReference);
                  }
               }
               else if(this.oType == StateMachineType.TIME_BASED)
               {
                  this.oEventManager.addEventListener(sEVENT_MANAGER_ID_CURRENTSTATE,this.oUpdateTimer,TimerEvent.TIMER,this.onStateTick,false,0,this.bWeakReference);
                  this.oUpdateTimer.start();
               }
               this.callInitCallBack();
               this.bRunning = true;
               dispatchEvent(new StateEvent(StateEvent.START,false,false,this.state));
            }
         }
      }
      
      protected function stop() : void
      {
         if(this.isRunning)
         {
            if(this.oCurrentStateStruct != null)
            {
               if(this.oType == StateMachineType.TIME_BASED)
               {
                  this.oUpdateTimer.stop();
               }
               if(this.oCurrentStateStruct.fStateEnd != null)
               {
                  this.oCurrentStateStruct.fStateEnd();
               }
               this.oEventManager.cleanUp(sEVENT_MANAGER_ID_CURRENTSTATE);
               this.bRunning = false;
               dispatchEvent(new StateEvent(StateEvent.STOP,false,false,this.state));
            }
         }
      }
      
      private function init() : void
      {
         this.oStateStructs = new ObjectList();
         this.oEventManager = new EventManager();
         this.bRunning = false;
         this.bPaused = false;
         if(this.oType == StateMachineType.TIME_BASED)
         {
            this.oUpdateTimer = new Timer(nDEFAULT_TIMER_DELAY);
         }
      }
      
      internal function onStateTick(_e:Event) : void
      {
         if(this.bDestroyed != true)
         {
            if(this.oCurrentStateStruct.fState != null)
            {
               this.oCurrentStateStruct.fState();
            }
         }
      }
      
      public function get timerDelay() : int
      {
         if(this.oUpdateTimer != null)
         {
            return this.oUpdateTimer.delay;
         }
         return -1;
      }
      
      public function set timerDelay(_nDelay:int) : void
      {
         if(this.oUpdateTimer != null)
         {
            this.oUpdateTimer.delay = _nDelay;
         }
      }
      
      public function get state() : String
      {
         return this.sState;
      }
      
      public function get isRunning() : Boolean
      {
         return this.bRunning;
      }
      
      public function get paused() : Boolean
      {
         return this.bPaused;
      }
      
      public function get type() : StateMachineType
      {
         return this.oType;
      }
      
      public function get pauseable() : Boolean
      {
         return this.bPauseable;
      }
      
      public function get eventManager() : EventManager
      {
         if(this.oPublicEventManager == null)
         {
            this.oPublicEventManager = new EventManager();
         }
         return this.oPublicEventManager;
      }
   }
}

