package com.sarbakan.sbdk.utils
{
   import com.sarbakan.sbdk.tools.*;
   import flash.events.IEventDispatcher;
   import flash.utils.Dictionary;
   
   public class EventManager
   {
      
      private var oEventList:Dictionary;
      
      public function EventManager()
      {
         super();
         this.init();
      }
      
      public function destroy() : void
      {
         this.clearAll();
         this.oEventList = null;
      }
      
      public function addEventListener(_sGroupID:String, _oTargetObject:IEventDispatcher, _sEvent:String, _fCallback:Function, _bUseCapture:Boolean = false, _nPriority:int = 0, _bUseWeakReference:Boolean = true, ... args) : void
      {
         var oConfig:ListenerStruct = new ListenerStruct();
         oConfig.sGroupID = _sGroupID;
         oConfig.sEvent = _sEvent;
         if(args.length > 0)
         {
            oConfig.fOriginalCallback = _fCallback;
            oConfig.fCallback = CallBackArguments.create.apply(this,[_fCallback].concat(args));
         }
         else
         {
            oConfig.fCallback = _fCallback;
         }
         oConfig.bUseCapture = _bUseCapture;
         oConfig.nPriority = _nPriority;
         oConfig.bUseWeakReference = _bUseWeakReference;
         _oTargetObject.addEventListener(oConfig.sEvent,oConfig.fCallback,oConfig.bUseCapture,oConfig.nPriority,oConfig.bUseWeakReference);
         if(this.oEventList[_oTargetObject] == null)
         {
            this.oEventList[_oTargetObject] = new Array();
         }
         this.oEventList[_oTargetObject].push(oConfig);
      }
      
      public function removeEventListener(_sGroupID:String, _oTargetObject:IEventDispatcher, _sEvent:String, _fCallback:Function, _bUseCapture:Boolean = false) : void
      {
         var _aListeners:Array = null;
         var i:int = 0;
         if(this.oEventList[_oTargetObject] != null)
         {
            _aListeners = this.oEventList[_oTargetObject];
            for(i = 0; i < _aListeners.length; i++)
            {
               if(_aListeners[i].fOriginalCallback == null)
               {
                  if(_aListeners[i].sEvent == _sEvent && _aListeners[i].fCallback == _fCallback && _aListeners[i].bUseCapture == _bUseCapture)
                  {
                     (_oTargetObject as IEventDispatcher).removeEventListener(_sEvent,_fCallback,_bUseCapture);
                     _aListeners.splice(i,1);
                     break;
                  }
               }
               else if(_aListeners[i].sEvent == _sEvent && _aListeners[i].fOriginalCallback == _fCallback && _aListeners[i].bUseCapture == _bUseCapture)
               {
                  (_oTargetObject as IEventDispatcher).removeEventListener(_sEvent,_aListeners[i].fCallback,_bUseCapture);
                  _aListeners.splice(i,1);
                  break;
               }
            }
         }
      }
      
      public function cleanUp(_sGroupID:String) : void
      {
         var i:Object = null;
         var j:int = 0;
         for(i in this.oEventList)
         {
            for(j = 0; j < this.oEventList[i].length; j++)
            {
               if(this.oEventList[i][j].sGroupID == _sGroupID)
               {
                  (i as IEventDispatcher).removeEventListener(this.oEventList[i][j].sEvent,this.oEventList[i][j].fCallback,this.oEventList[i][j].bUseCapture);
                  this.oEventList[i].splice(j,1);
                  j--;
                  if(this.oEventList[i].length <= 0)
                  {
                     delete this.oEventList[i];
                     break;
                  }
               }
            }
         }
      }
      
      public function clearAll() : void
      {
         var i:Object = null;
         var j:int = 0;
         for(i in this.oEventList)
         {
            for(j = 0; j < this.oEventList[i].length; j++)
            {
               (i as IEventDispatcher).removeEventListener(this.oEventList[i][j].sEvent,this.oEventList[i][j].fCallback,this.oEventList[i][j].bUseCapture);
            }
            this.oEventList[i].splice(0,this.oEventList[i].length);
            delete this.oEventList[i];
         }
      }
      
      public function clearByTarget(_oTargetObject:*) : void
      {
         var i:Object = null;
         var j:int = 0;
         for(i in this.oEventList)
         {
            if(i == _oTargetObject)
            {
               for(j = 0; j < this.oEventList[i].length; j++)
               {
                  (i as IEventDispatcher).removeEventListener(this.oEventList[i][j].sEvent,this.oEventList[i][j].fCallback,this.oEventList[i][j].bUseCapture);
               }
               this.oEventList[i].splice(0,this.oEventList[i].length);
               delete this.oEventList[i];
               break;
            }
         }
      }
      
      private function init() : void
      {
         this.oEventList = new Dictionary(true);
      }
   }
}

class ListenerStruct
{
   
   public var sGroupID:String;
   
   public var sEvent:String;
   
   public var fCallback:Function;
   
   public var fOriginalCallback:Function;
   
   public var bUseCapture:Boolean;
   
   public var nPriority:int;
   
   public var bUseWeakReference:Boolean;
   
   public function ListenerStruct()
   {
      super();
   }
}
