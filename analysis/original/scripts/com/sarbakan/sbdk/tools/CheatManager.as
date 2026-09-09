package com.sarbakan.sbdk.tools
{
   import com.sarbakan.sbdk.events.CheatEvent;
   import com.sarbakan.sbdk.events.KeyEvent;
   import com.sarbakan.sbdk.events.SequenceEvent;
   import com.sarbakan.sbdk.input.KeyCode;
   import com.sarbakan.sbdk.input.KeyCombinationManager;
   import com.sarbakan.sbdk.input.KeySequence;
   import com.sarbakan.sbdk.input.KeySequenceManager;
   import com.sarbakan.sbdk.utils.EventManager;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.utils.Timer;
   
   [Event(name="CHEAT_ACTIVATED",type="com.sarbakan.sbdk.events.CheatEvent")]
   public class CheatManager extends EventDispatcher
   {
      
      private static const sDEFAULT_MESSAGE:String = "List of available cheats :\n";
      
      private static const sDISPLAY_SEQUENCE:String = "DISPLAY_TEXT";
      
      private static const sKEY_EVENT:String = "KEY_EVENT";
      
      private static const sTIMER_EVENT:String = "TIMER_EVENT";
      
      private static const sFONT:String = "Verdana";
      
      private static const nCOLOR:int = 16777215;
      
      private static const nFONT_SIZE:int = 10;
      
      private static const nDISPLAY_TIME:int = 4000;
      
      private var oStage:Stage;
      
      private var oKeySequence:KeySequenceManager;
      
      private var okeyCombo:KeyCombinationManager;
      
      private var mcTextDisplay:Sprite;
      
      private var oFrontText:TextField;
      
      private var oBackText:TextField;
      
      private var oEventManager:EventManager;
      
      private var bDisplayed:Boolean;
      
      private var nDisplayX:int;
      
      private var nDisplayY:int;
      
      private var oDisplayTimer:Timer;
      
      private var bDefaultCheat:Boolean;
      
      public function CheatManager(_oStage:Stage, _nDisplayX:int = 0, _nDisplayY:int = 0, _bDefaultCheat:Boolean = true)
      {
         super();
         this.oStage = _oStage;
         this.nDisplayX = _nDisplayX;
         this.nDisplayY = _nDisplayY;
         this.bDefaultCheat = _bDefaultCheat;
         this.init();
      }
      
      public function destroy() : void
      {
         this.oEventManager.cleanUp(sKEY_EVENT);
         this.oEventManager.cleanUp(sTIMER_EVENT);
         this.oEventManager.destroy();
         this.oEventManager = null;
         this.oKeySequence.destroy();
         this.okeyCombo.destroy();
         this.oDisplayTimer.stop();
         this.oDisplayTimer = null;
         this.oKeySequence = null;
         this.okeyCombo = null;
      }
      
      public function addSequenceCheat(_sCheatID:String, _oKeySequence:KeySequence) : void
      {
         this.oKeySequence.addSequence(_sCheatID,_oKeySequence);
      }
      
      public function removeSequenceCheat(_sCheatID:String) : void
      {
         this.oKeySequence.removeSequence(_sCheatID);
      }
      
      public function addComboCheat(_sCheatID:String, ... _oKeyCode) : void
      {
         this.okeyCombo.addCombination(_sCheatID,_oKeyCode);
      }
      
      public function removeComboCheat(_sCheatID:String) : void
      {
         this.okeyCombo.removeCombination(_sCheatID);
      }
      
      public function displayCheatList() : void
      {
         var _sSequenceString:String = null;
         var _sComboString:String = null;
         var _nEndIndex:int = 0;
         if(!this.bDisplayed)
         {
            _sSequenceString = "";
            _sComboString = "";
            _sSequenceString = this.oKeySequence.toString();
            _sComboString = this.okeyCombo.toString();
            _nEndIndex = _sSequenceString.indexOf("\n",0);
            _sSequenceString = sDEFAULT_MESSAGE + _sSequenceString.substr(_nEndIndex + 1,_sSequenceString.length);
            this.oFrontText.appendText(_sSequenceString + "\n");
            this.oBackText.appendText(_sSequenceString + "\n");
            this.oFrontText.appendText(_sComboString + "\n");
            this.oBackText.appendText(_sComboString + "\n");
            this.mcTextDisplay.x = this.nDisplayX;
            this.mcTextDisplay.y = this.nDisplayY;
            this.oStage.addChild(this.mcTextDisplay);
            this.bDisplayed = true;
            this.oDisplayTimer.start();
         }
      }
      
      private function init() : void
      {
         var _oSequence:KeySequence = null;
         var _oFrontTextFormat:TextFormat = new TextFormat(sFONT,nFONT_SIZE,nCOLOR);
         var _oBackTextFormat:TextFormat = new TextFormat(sFONT,nFONT_SIZE);
         this.oDisplayTimer = new Timer(nDISPLAY_TIME);
         this.oDisplayTimer.repeatCount = 1;
         this.bDisplayed = false;
         this.mcTextDisplay = new Sprite();
         this.oFrontText = new TextField();
         this.oFrontText.autoSize = TextFieldAutoSize.LEFT;
         this.oFrontText.defaultTextFormat = _oFrontTextFormat;
         this.oBackText = new TextField();
         this.oBackText.autoSize = TextFieldAutoSize.LEFT;
         this.oBackText.defaultTextFormat = _oBackTextFormat;
         this.oBackText.x = 1;
         this.oBackText.y = 1;
         this.mcTextDisplay.addChild(this.oBackText);
         this.mcTextDisplay.addChild(this.oFrontText);
         this.oKeySequence = new KeySequenceManager(this.oStage);
         this.okeyCombo = new KeyCombinationManager(this.oStage);
         this.oEventManager = new EventManager();
         if(this.bDefaultCheat)
         {
            _oSequence = new KeySequence(1000);
            _oSequence.addKey(KeyCode.S);
            _oSequence.addKey(KeyCode.A);
            _oSequence.addKey(KeyCode.R);
            _oSequence.addKey(KeyCode.B);
            _oSequence.addKey(KeyCode.A);
            _oSequence.addKey(KeyCode.K);
            _oSequence.addKey(KeyCode.A);
            _oSequence.addKey(KeyCode.N);
            this.oKeySequence.addSequence(sDISPLAY_SEQUENCE,_oSequence);
         }
         this.oEventManager.addEventListener(sTIMER_EVENT,this.oDisplayTimer,TimerEvent.TIMER,this.onTimerUpdate);
         this.oEventManager.addEventListener(sKEY_EVENT,this.oKeySequence,SequenceEvent.SEQUENCE_COMPLETED,this.onSequenceComplete);
         this.oEventManager.addEventListener(sKEY_EVENT,this.okeyCombo,KeyEvent.KEY_COMBINATION_DOWN,this.onComboDown);
      }
      
      private function hideText() : void
      {
         this.oStage.removeChild(this.mcTextDisplay);
         this.mcTextDisplay.alpha = 1;
         this.oDisplayTimer.stop();
         this.bDisplayed = false;
         this.oFrontText.text = "";
         this.oBackText.text = "";
      }
      
      private function onTimerUpdate(_oEvent:TimerEvent) : void
      {
         this.hideText();
      }
      
      private function onSequenceComplete(_oEvent:SequenceEvent) : void
      {
         if(_oEvent.ID == sDISPLAY_SEQUENCE)
         {
            this.displayCheatList();
         }
         dispatchEvent(new CheatEvent(CheatEvent.CHEAT_ACTIVATED,false,false,_oEvent.ID));
      }
      
      private function onComboDown(_oEvent:KeyEvent) : void
      {
         dispatchEvent(new CheatEvent(CheatEvent.CHEAT_ACTIVATED,false,false,_oEvent.ID));
      }
   }
}

