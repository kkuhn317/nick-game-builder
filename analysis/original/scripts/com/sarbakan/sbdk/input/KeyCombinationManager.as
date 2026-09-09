package com.sarbakan.sbdk.input
{
   import com.sarbakan.sbdk.events.KeyEvent;
   import com.sarbakan.sbdk.utils.EventManager;
   import flash.display.Stage;
   import flash.events.EventDispatcher;
   import flash.events.KeyboardEvent;
   
   [Event(name="KEY_COMBINATION_UP",type="com.sarbakan.sbdk.events.KeyboardEvent")]
   [Event(name="KEY_COMBINATION_DOWN",type="com.sarbakan.sbdk.events.KeyboardEvent")]
   public class KeyCombinationManager extends EventDispatcher
   {
      
      private static const sEVENT_MANAGER_ID:String = "keyCombination";
      
      private var oEventManager:EventManager;
      
      private var oStage:Stage;
      
      private var oKeyManager:KeyManager;
      
      private var oCombinations:Object;
      
      public function KeyCombinationManager(_oStage:Stage)
      {
         super();
         this.oStage = _oStage;
         this.init();
      }
      
      public function addCombination(_sCombinationID:String, ... _oKeyCodes) : void
      {
         this.oCombinations[_sCombinationID] = new CombinationStruct(_sCombinationID,_oKeyCodes);
      }
      
      override public function toString() : String
      {
         var i:CombinationStruct = null;
         var _sString:String = "";
         for each(i in this.oCombinations)
         {
            _sString += i.sID + ": " + i.toString() + "\n";
         }
         return _sString;
      }
      
      public function removeCombination(_sCombinationID:String) : void
      {
         if(this.oCombinations[_sCombinationID] != null)
         {
            delete this.oCombinations[_sCombinationID];
         }
      }
      
      public function destroy() : void
      {
         this.oCombinations = null;
         this.oKeyManager.destroy();
         this.oKeyManager = null;
         this.oEventManager.destroy();
         this.oEventManager = null;
         this.oStage = null;
      }
      
      private function init() : void
      {
         this.oCombinations = new Object();
         this.oKeyManager = new KeyManager(this.oStage);
         this.oEventManager = new EventManager();
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oStage,KeyboardEvent.KEY_DOWN,this.onKeyDown);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oStage,KeyboardEvent.KEY_UP,this.onKeyUp);
      }
      
      private function checkCombinations() : void
      {
         var _sComboID:String = null;
         var _oCombo:CombinationStruct = null;
         var _bDown:Boolean = false;
         for(_sComboID in this.oCombinations)
         {
            _oCombo = this.oCombinations[_sComboID];
            _bDown = this.oKeyManager.isCombinationDown(_oCombo.aKeyCodes);
            if(_bDown == true)
            {
               _oCombo.bDown = true;
               dispatchEvent(new KeyEvent(KeyEvent.KEY_COMBINATION_DOWN,false,false,_sComboID));
            }
            else if(_oCombo.bDown == true)
            {
               _oCombo.bDown = false;
               dispatchEvent(new KeyEvent(KeyEvent.KEY_COMBINATION_UP,false,false,_sComboID));
            }
         }
      }
      
      private function onKeyDown(_e:KeyboardEvent) : void
      {
         this.checkCombinations();
      }
      
      private function onKeyUp(_e:KeyboardEvent) : void
      {
         this.checkCombinations();
      }
   }
}

class CombinationStruct
{
   
   public var aKeyCodes:Array;
   
   public var bDown:Boolean;
   
   public var sID:String;
   
   public function CombinationStruct(_sID:String, _aKeyCodes:Array)
   {
      super();
      this.aKeyCodes = _aKeyCodes[0];
      this.sID = _sID;
      this.bDown = false;
   }
   
   public function toString() : String
   {
      var _sKeys:String = "";
      for(var i:int = 0; i < this.aKeyCodes.length; i++)
      {
         _sKeys += CharCode.KeyCodeToCharCode(this.aKeyCodes[i]) + "+";
      }
      return _sKeys.slice(0,_sKeys.length - 1);
   }
}
