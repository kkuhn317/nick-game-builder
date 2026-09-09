package com.sarbakan.sbdk.input
{
   import com.sarbakan.sbdk.events.SequenceEvent;
   import com.sarbakan.sbdk.utils.EventManager;
   import com.sarbakan.sbdk.utils.FrameTimer;
   import com.sarbakan.sbdk.utils.ObjectList;
   import de.polygonal.ds.ArrayedQueue;
   import de.polygonal.ds.Iterator;
   import de.polygonal.ds.Set;
   import flash.display.Stage;
   import flash.events.EventDispatcher;
   import flash.events.KeyboardEvent;
   import flash.events.TimerEvent;
   import flash.ui.Keyboard;
   import flash.utils.getTimer;
   
   [Event(name="SEQUENCE_UNIT",type="com.sarbakan.sbdk.events.SequenceEvent")]
   [Event(name="SEQUENCE_FAILED",type="com.sarbakan.sbdk.events.SequenceEvent")]
   [Event(name="SEQUENCE_COMPLETED",type="com.sarbakan.sbdk.events.SequenceEvent")]
   public class KeySequence extends EventDispatcher
   {
      
      private static const sEVENT_MANAGER_ID:String = "keySequence";
      
      private var sID:String;
      
      private var oEventManager:EventManager;
      
      private var oStage:Stage;
      
      private var nMaxSize:int;
      
      private var bCaseSensitive:Boolean;
      
      private var nMaxTime:int;
      
      private var oTimer:FrameTimer;
      
      private var lSequence:ArrayedQueue;
      
      private var oIterator:Iterator;
      
      private var lUnendedPersistenceData:Set;
      
      private var oCurrentStruct:SequenceElementStruct;
      
      private var lCurrentPersistent:ObjectList;
      
      private var bSequenceStarted:Boolean;
      
      private var bCurrentDown:Boolean;
      
      private var bFireOnKeyDown:Boolean;
      
      public function KeySequence(_nMaxTime:int, _bCaseSensitive:Boolean = false, _nMaxSize:int = 32, _bFireOnKeyDown:Boolean = false)
      {
         super();
         this.nMaxTime = _nMaxTime;
         this.bCaseSensitive = _bCaseSensitive;
         this.nMaxSize = _nMaxSize;
         this.bFireOnKeyDown = _bFireOnKeyDown;
         this.init();
      }
      
      override public function toString() : String
      {
         var _aSequenceList:Array = this.lSequence.toArray();
         var _sString:String = this.sID + ": ";
         for(var i:int = 0; i < _aSequenceList.length; i++)
         {
            if(Boolean(_aSequenceList[i].bPersistenceStart))
            {
               _sString += "hold " + CharCode.KeyCodeToCharCode(_aSequenceList[i].nKeyCode) + ", ";
            }
            else if(Boolean(_aSequenceList[i].bPersistenceEnd))
            {
               _sString += "release " + CharCode.KeyCodeToCharCode(_aSequenceList[i].nKeyCode) + ", ";
            }
            else
            {
               _sString += CharCode.KeyCodeToCharCode(_aSequenceList[i].nKeyCode) + ", ";
            }
         }
         return _sString.slice(0,_sString.length - 1);
      }
      
      public function addKey(_nKeyCode:uint, _nMinTime:int = 0, _nMaxTime:int = 30, _bUpperCase:Boolean = false) : void
      {
         this.lSequence.enqueue(new SequenceElementStruct(_nKeyCode,_nMinTime,_nMaxTime,_bUpperCase,false,false));
      }
      
      public function addPersistentKey(_nKeyCode:uint, _nMinTime:int = 0, _nMaxTime:int = 30, _bUpperCase:Boolean = false) : void
      {
         this.lSequence.enqueue(new SequenceElementStruct(_nKeyCode,_nMinTime,_nMaxTime,_bUpperCase,true,false));
         this.lUnendedPersistenceData.set(_nKeyCode);
      }
      
      public function endPersistentKey(_nKeyCode:uint) : void
      {
         this.lSequence.enqueue(new SequenceElementStruct(_nKeyCode,0,0,false,false,true));
         this.lUnendedPersistenceData.remove(_nKeyCode);
      }
      
      public function endPersistentAll() : void
      {
         var _oIt:Iterator = this.lUnendedPersistenceData.getIterator();
         while(_oIt.hasNext())
         {
            this.endPersistentKey(_oIt.data);
            _oIt.next();
         }
      }
      
      internal function start(_sID:String, _oStage:Stage) : void
      {
         this.sID = _sID;
         this.oStage = _oStage;
         this.oTimer = new FrameTimer(this.nMaxTime,1);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oStage,KeyboardEvent.KEY_DOWN,this.onKeyDown);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oStage,KeyboardEvent.KEY_UP,this.onKeyUp);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oTimer,TimerEvent.TIMER,this.onTimeOut);
         this.reset();
      }
      
      public function destroy() : void
      {
         this.lSequence = null;
         this.lUnendedPersistenceData = null;
         this.oStage = null;
         this.oEventManager.destroy();
         this.oEventManager = null;
         this.oTimer.destroy();
         this.oTimer = null;
      }
      
      private function init() : void
      {
         this.lSequence = new ArrayedQueue(this.nMaxSize);
         this.lUnendedPersistenceData = new Set();
         this.oEventManager = new EventManager();
      }
      
      private function reset(_e:TimerEvent = null) : void
      {
         this.oIterator = this.lSequence.getIterator();
         this.oCurrentStruct = this.oIterator.next();
         this.bCurrentDown = false;
         this.bSequenceStarted = false;
         this.lCurrentPersistent = new ObjectList();
         this.oTimer.reset();
      }
      
      private function getPressDelay(_oSequenceElementStruct:SequenceElementStruct) : int
      {
         var _nPressDelay:int = getTimer() - _oSequenceElementStruct.nPressedAt;
         return int(_nPressDelay / 1000 * this.oStage.frameRate);
      }
      
      private function validateKeyDown(_e:KeyboardEvent) : void
      {
         var _bValidCase:Boolean = false;
         var _lFirstKey:SequenceElementStruct = null;
         var _oPersistentStruct:SequenceElementStruct = this.lCurrentPersistent.find(_e.keyCode.toString());
         if(_oPersistentStruct == null)
         {
            if(this.bCurrentDown == false)
            {
               _bValidCase = !(this.bCaseSensitive && this.isAlpha(String.fromCharCode(_e.charCode)) && this.oCurrentStruct.bUpperCase != this.isUpperCase(_e));
               if(_e.keyCode == this.oCurrentStruct.nKeyCode && _bValidCase)
               {
                  if(this.bSequenceStarted == false)
                  {
                     this.bSequenceStarted = true;
                     this.oTimer.start();
                  }
                  if(this.bSequenceStarted)
                  {
                     dispatchEvent(new SequenceEvent(SequenceEvent.SEQUENCE_UNIT,false,false,this.sID));
                  }
                  this.oCurrentStruct.nPressedAt = getTimer();
                  if(this.oCurrentStruct.bPersistenceStart)
                  {
                     this.lCurrentPersistent.insert(_e.keyCode.toString(),this.oCurrentStruct);
                     this.oCurrentStruct = this.oIterator.next();
                  }
                  else if(!this.oIterator.hasNext() && this.bFireOnKeyDown)
                  {
                     this.endSequenceStep();
                  }
                  else
                  {
                     this.bCurrentDown = true;
                  }
               }
               else if(!(this.bCaseSensitive && (_e.keyCode == KeyCode.SHIFT || _e.keyCode == KeyCode.CAPSLOCK)))
               {
                  if(this.bSequenceStarted)
                  {
                     dispatchEvent(new SequenceEvent(SequenceEvent.SEQUENCE_FAILED,false,false,this.sID));
                  }
                  this.reset();
                  _lFirstKey = this.lSequence.peek() as SequenceElementStruct;
                  if(_e.keyCode == _lFirstKey.nKeyCode && _bValidCase)
                  {
                     this.onKeyDown(_e);
                  }
               }
            }
         }
      }
      
      private function validateKeyUpRegular(_e:KeyboardEvent) : void
      {
         var _nPressDelay:int = 0;
         if(this.bCurrentDown == true)
         {
            if(_e.keyCode == this.oCurrentStruct.nKeyCode)
            {
               _nPressDelay = this.getPressDelay(this.oCurrentStruct);
               if(_nPressDelay >= this.oCurrentStruct.nMinTime && _nPressDelay <= this.oCurrentStruct.nMaxTime)
               {
                  this.bCurrentDown = false;
                  this.endSequenceStep();
               }
               else
               {
                  if(this.bSequenceStarted)
                  {
                     dispatchEvent(new SequenceEvent(SequenceEvent.SEQUENCE_FAILED,false,false,this.sID));
                  }
                  this.reset();
               }
            }
         }
      }
      
      private function validateKeyUpPersistent(_e:KeyboardEvent) : void
      {
         var _nPressDelay:int = 0;
         var _oPersistentStruct:SequenceElementStruct = this.lCurrentPersistent.find(_e.keyCode.toString());
         if(_oPersistentStruct != null)
         {
            if(this.oCurrentStruct.bPersistenceEnd == true)
            {
               if(_oPersistentStruct.nKeyCode == this.oCurrentStruct.nKeyCode)
               {
                  _nPressDelay = this.getPressDelay(_oPersistentStruct);
                  if(_nPressDelay >= _oPersistentStruct.nMinTime && _nPressDelay <= _oPersistentStruct.nMaxTime)
                  {
                     this.endSequenceStep();
                  }
                  else
                  {
                     if(this.bSequenceStarted)
                     {
                        dispatchEvent(new SequenceEvent(SequenceEvent.SEQUENCE_FAILED,false,false,this.sID));
                     }
                     this.reset();
                  }
               }
               else
               {
                  if(this.bSequenceStarted)
                  {
                     dispatchEvent(new SequenceEvent(SequenceEvent.SEQUENCE_FAILED,false,false,this.sID));
                  }
                  this.reset();
               }
            }
         }
      }
      
      private function endSequenceStep() : void
      {
         if(this.oIterator.hasNext())
         {
            this.oCurrentStruct = this.oIterator.next();
         }
         else
         {
            this.reset();
            dispatchEvent(new SequenceEvent(SequenceEvent.SEQUENCE_COMPLETED,false,false,this.sID));
         }
      }
      
      private function isAlpha(_sString:String) : Boolean
      {
         var _oRegExp:RegExp = /^[a-zA-Z]+$/;
         return _oRegExp.test(_sString);
      }
      
      private function isUpperCase(_e:KeyboardEvent) : Boolean
      {
         return Keyboard.capsLock || _e.shiftKey;
      }
      
      private function onKeyDown(_e:KeyboardEvent) : void
      {
         this.validateKeyDown(_e);
      }
      
      private function onKeyUp(_e:KeyboardEvent) : void
      {
         this.validateKeyUpRegular(_e);
         this.validateKeyUpPersistent(_e);
      }
      
      private function onTimeOut(_e:TimerEvent) : void
      {
         this.reset();
      }
      
      internal function get valid() : Boolean
      {
         return this.lUnendedPersistenceData.size == 0 && this.lSequence.size > 0;
      }
   }
}

class SequenceElementStruct
{
   
   public var nKeyCode:uint;
   
   public var nMinTime:int;
   
   public var nMaxTime:int;
   
   public var bUpperCase:Boolean;
   
   public var bPersistenceStart:Boolean;
   
   public var bPersistenceEnd:Boolean;
   
   public var nPressedAt:int;
   
   public function SequenceElementStruct(_nKeyCode:uint, _nMinTime:int, _nMaxTime:int, _bUpperCase:Boolean, _bPersistenceStart:Boolean, _bPersistenceEnd:Boolean)
   {
      super();
      this.nKeyCode = _nKeyCode;
      this.nMinTime = _nMinTime;
      this.nMaxTime = _nMaxTime;
      this.bUpperCase = _bUpperCase;
      this.bPersistenceStart = _bPersistenceStart;
      this.bPersistenceEnd = _bPersistenceEnd;
   }
}
