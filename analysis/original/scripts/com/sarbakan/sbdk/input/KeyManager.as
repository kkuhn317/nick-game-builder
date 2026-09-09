package com.sarbakan.sbdk.input
{
   import com.sarbakan.sbdk.events.KeyEvent;
   import com.sarbakan.sbdk.utils.EventManager;
   import com.sarbakan.sbdk.utils.ObjectList;
   import de.polygonal.ds.Set;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.ContextMenuEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.KeyboardEvent;
   import flash.ui.ContextMenu;
   
   [Event(name="KEY_UP",type="com.sarbakan.sbdk.events.KeyEvent")]
   [Event(name="KEY_DOWN",type="com.sarbakan.sbdk.events.KeyEvent")]
   public class KeyManager extends EventDispatcher
   {
      
      private static const sEVENT_MANAGER_ID:String = "keyManager";
      
      private var oEventManager:EventManager;
      
      private var oStage:Stage;
      
      private var lWatchedKeys:Set;
      
      private var lKeyStatus:ObjectList;
      
      private var bDestroyed:Boolean;
      
      private var oContextMenu:ContextMenu;
      
      public function KeyManager(_oStage:Stage)
      {
         super();
         this.oStage = _oStage;
         this.init();
      }
      
      public function addKey(_nKeyCode:uint) : void
      {
         this.lWatchedKeys.set(_nKeyCode);
      }
      
      public function removeKey(_nKeyCode:uint) : void
      {
         this.lWatchedKeys.remove(_nKeyCode);
      }
      
      public function isKeyUp(_nKeyCode:uint) : Boolean
      {
         var _oKeyStatus:KeyStatusStruct = this.lKeyStatus.find(String(_nKeyCode));
         if(_oKeyStatus != null)
         {
            return _oKeyStatus.bKeyDown != true;
         }
         return true;
      }
      
      public function isKeyJustReleased(_nKeyCode:uint) : Boolean
      {
         var _oKeyStatus:KeyStatusStruct = this.lKeyStatus.find(String(_nKeyCode));
         if(_oKeyStatus != null)
         {
            return !_oKeyStatus.bKeyDown && _oKeyStatus.nNbrFrame == 1;
         }
         return false;
      }
      
      public function isKeyDown(_nKeyCode:uint) : Boolean
      {
         var _oKeyStatus:KeyStatusStruct = this.lKeyStatus.find(String(_nKeyCode));
         if(_oKeyStatus != null)
         {
            return _oKeyStatus.bKeyDown;
         }
         return false;
      }
      
      public function isOneOfKeyDown(_aKeyCodes:Array) : Boolean
      {
         var _nKey:uint = 0;
         for each(_nKey in _aKeyCodes)
         {
            if(this.isKeyDown(_nKey))
            {
               return true;
            }
         }
         return false;
      }
      
      public function isOneOfKeyJustPressed(_aKeyCodes:Array) : Boolean
      {
         var _nKey:uint = 0;
         var _oKeyStatus:KeyStatusStruct = null;
         for each(_nKey in _aKeyCodes)
         {
            _oKeyStatus = this.lKeyStatus.find(String(_nKey));
            if(_oKeyStatus != null)
            {
               return _oKeyStatus.bKeyDown && _oKeyStatus.nNbrFrame == 0;
            }
         }
         return false;
      }
      
      public function isKeyJustPressed(_nKeyCode:uint) : Boolean
      {
         var _oKeyStatus:KeyStatusStruct = this.lKeyStatus.find(String(_nKeyCode));
         if(_oKeyStatus != null)
         {
            return _oKeyStatus.bKeyDown && _oKeyStatus.nNbrFrame == 0;
         }
         return false;
      }
      
      public function isCombinationUp(_aKeyCodes:Array) : Boolean
      {
         var _nKeyCode:int = 0;
         var _oKeyStatus:KeyStatusStruct = null;
         var _bUp:Boolean = true;
         for each(_nKeyCode in _aKeyCodes)
         {
            _oKeyStatus = this.lKeyStatus.find(String(_nKeyCode));
            if(_oKeyStatus != null)
            {
               if(_oKeyStatus.bKeyDown == true)
               {
                  _bUp = false;
                  break;
               }
            }
         }
         return _bUp;
      }
      
      public function isCombinationDown(_aKeyCodes:Array) : Boolean
      {
         var _nKeyCode:int = 0;
         var _oKeyStatus:KeyStatusStruct = null;
         var _bDown:Boolean = true;
         for each(_nKeyCode in _aKeyCodes)
         {
            _oKeyStatus = this.lKeyStatus.find(String(_nKeyCode));
            if(_oKeyStatus == null)
            {
               _bDown = false;
               break;
            }
            if(_oKeyStatus.bKeyDown != true)
            {
               _bDown = false;
               break;
            }
         }
         return _bDown;
      }
      
      public function destroy() : void
      {
         this.oEventManager.clearAll();
         this.oEventManager = null;
         this.lWatchedKeys = null;
         this.lKeyStatus.clear();
         this.lKeyStatus = null;
         this.oStage = null;
         this.bDestroyed = true;
      }
      
      private function init() : void
      {
         this.lWatchedKeys = new Set();
         this.lKeyStatus = new ObjectList();
         this.bDestroyed = false;
         var _mcMainContainer:Sprite = this.oStage.getChildAt(0) as Sprite;
         this.oEventManager = new EventManager();
         if(_mcMainContainer != null && _mcMainContainer.contextMenu != null)
         {
            this.oEventManager.addEventListener(sEVENT_MANAGER_ID,_mcMainContainer.contextMenu,ContextMenuEvent.MENU_SELECT,this.onContextMenu);
         }
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oStage,KeyboardEvent.KEY_UP,this.onKeyUp);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oStage,KeyboardEvent.KEY_DOWN,this.onKeyDown);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oStage,Event.ENTER_FRAME,this.onUpdate);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oStage,Event.DEACTIVATE,this.onStageDeactivate);
      }
      
      private function resetKeyStatus() : void
      {
         var i:KeyStatusStruct = null;
         for each(i in this.lKeyStatus.object)
         {
            i.bKeyDown = false;
            i.nNbrFrame = 0;
         }
      }
      
      private function onStageDeactivate(_oEvent:Event) : void
      {
         this.resetKeyStatus();
      }
      
      private function onContextMenu(_oEvent:ContextMenuEvent) : void
      {
         this.resetKeyStatus();
      }
      
      private function onUpdate(_oEvent:Event) : void
      {
         var i:KeyStatusStruct = null;
         if(this.bDestroyed)
         {
            return;
         }
         for each(i in this.lKeyStatus.object)
         {
            if(i.bTryUp && i.nNbrFrame > 0)
            {
               i.bKeyDown = false;
               i.bTryUp = false;
            }
            if(!i.bKeyDown && i.nNbrFrame > 0)
            {
               this.lKeyStatus.remove(String(i.nKeyCode));
            }
            ++i.nNbrFrame;
         }
      }
      
      private function onKeyUp(_e:KeyboardEvent) : void
      {
         var _oKeyStatus:KeyStatusStruct = this.lKeyStatus.find(String(_e.keyCode));
         if(_oKeyStatus == null)
         {
            _oKeyStatus = this.lKeyStatus.insert(String(_e.keyCode),new KeyStatusStruct()) as KeyStatusStruct;
         }
         _oKeyStatus.bTryUp = true;
         _oKeyStatus.nKeyCode = _e.keyCode;
         _oKeyStatus.bKeyDown = false;
         if(this.lWatchedKeys.contains(_e.keyCode) == true)
         {
            dispatchEvent(new KeyEvent(KeyEvent.KEY_UP,false,false,_e.keyCode.toString(),_e.charCode,_e.keyCode,_e.keyLocation,_e.ctrlKey,_e.altKey,_e.shiftKey));
         }
      }
      
      private function onKeyDown(_e:KeyboardEvent) : void
      {
         var _oKeyStatus:KeyStatusStruct = this.lKeyStatus.find(String(_e.keyCode));
         if(_oKeyStatus == null)
         {
            _oKeyStatus = this.lKeyStatus.insert(String(_e.keyCode),new KeyStatusStruct()) as KeyStatusStruct;
         }
         if(!_oKeyStatus.bKeyDown)
         {
            _oKeyStatus.nNbrFrame = 0;
            _oKeyStatus.bKeyDown = true;
            _oKeyStatus.nKeyCode = _e.keyCode;
            if(this.lWatchedKeys.contains(_e.keyCode) == true)
            {
               dispatchEvent(new KeyEvent(KeyEvent.KEY_DOWN,false,false,_e.keyCode.toString(),_e.charCode,_e.keyCode,_e.keyLocation,_e.ctrlKey,_e.altKey,_e.shiftKey));
            }
         }
      }
   }
}

class KeyStatusStruct
{
   
   public var bTryUp:Boolean;
   
   public var bKeyDown:Boolean;
   
   public var nNbrFrame:int;
   
   public var nKeyCode:int;
   
   public function KeyStatusStruct()
   {
      super();
      this.bTryUp = false;
      this.bKeyDown = false;
      this.nNbrFrame = 0;
   }
}
