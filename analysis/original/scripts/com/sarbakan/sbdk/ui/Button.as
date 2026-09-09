package com.sarbakan.sbdk.ui
{
   import com.sarbakan.sbdk.events.UIEvent;
   import com.sarbakan.sbdk.input.MouseUtils;
   import com.sarbakan.sbdk.localization.LocalizedTextField;
   import com.sarbakan.sbdk.state.AnimStateMachine;
   import com.sarbakan.sbdk.utils.DisplayObjectUtils;
   import com.sarbakan.sbdk.utils.FrameTimer;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   
   [Event(name="RELEASE_OUTSIDE",type="com.sarbakan.sbdk.events.UIEvent")]
   [Event(name="RELEASE",type="com.sarbakan.sbdk.events.UIEvent")]
   [Event(name="ROLL_OUT",type="com.sarbakan.sbdk.events.UIEvent")]
   [Event(name="ROLL_OVER",type="com.sarbakan.sbdk.events.UIEvent")]
   [Event(name="PRESS",type="com.sarbakan.sbdk.events.UIEvent")]
   public class Button extends AbstractControl
   {
      
      private static var oButtonCurrentlyDown:Button;
      
      public static const sSTATE_UP:String = "up";
      
      public static const sSTATE_OVER:String = "over";
      
      public static const sSTATE_DOWN:String = "down";
      
      public static const sSTATE_DISABLED:String = "disabled";
      
      private static const sEVENT_MANAGER_ID_BUTTON_UP:String = "upID";
      
      private static const sEVENT_MANAGER_ID_BUTTON_OVER:String = "overID";
      
      private static const sEVENT_MANAGER_ID_BUTTON_DOWN:String = "downID";
      
      private static const sEVENT_MANAGER_ID_BUTTON_DISABLED:String = "disabledID";
      
      private static const sEVENT_MANAGER_ID_TIMER:String = "timer_event";
      
      private static const sEVENT_MANAGER_ID:String = "general";
      
      protected var oAnimStateMachine:AnimStateMachine;
      
      private var sLabel:String = "";
      
      private var bStateUp:Boolean;
      
      private var bStateOver:Boolean;
      
      private var bStateDown:Boolean;
      
      private var bStateDisabled:Boolean;
      
      private var bMouseOutside:Boolean;
      
      private var bUseHandCursor:Boolean;
      
      private var bButtonMode:Boolean;
      
      protected var bLocalizedText:Boolean = false;
      
      private var sLocalizationStringID:String;
      
      private var oLocalizationReplacements:Object;
      
      private var oLocalizedTextField:LocalizedTextField;
      
      private var oFrameTimer:FrameTimer;
      
      private var aEventList:Array;
      
      private var sNextState:String;
      
      private var bDestroyed:Boolean;
      
      private var bForceRollover:Boolean;
      
      private var bDebug:Boolean;
      
      public function Button(_mcRef:MovieClip, _bDegug:Boolean = false)
      {
         this.bDebug = _bDegug;
         super(_mcRef);
         this.init();
      }
      
      internal static function get currentDownButton() : Button
      {
         return oButtonCurrentlyDown;
      }
      
      internal static function set currentDownButton(_oBt:Button) : void
      {
         oButtonCurrentlyDown = _oBt;
      }
      
      public function setLabel(_sLabel:String) : void
      {
         this.bLocalizedText = false;
         this.sLabel = _sLabel;
         this.render();
      }
      
      public function setLocalizedLabel(_sLocalizationStringID:String, _oLocalizationReplacements:Object = null) : void
      {
         this.bLocalizedText = true;
         this.sLocalizationStringID = _sLocalizationStringID;
         this.oLocalizationReplacements = _oLocalizationReplacements;
         this.render();
      }
      
      override public function destroy() : void
      {
         eventManager.cleanUp(sEVENT_MANAGER_ID_TIMER);
         if(this.oFrameTimer != null)
         {
            this.oFrameTimer.stop();
            this.oFrameTimer.destroy();
            this.oFrameTimer = null;
         }
         if(this.oLocalizedTextField != null)
         {
            this.oLocalizedTextField.destroy();
         }
         this.oLocalizedTextField = null;
         if(Button.currentDownButton == this)
         {
            Button.currentDownButton = null;
         }
         this.aEventList.splice(0,this.aEventList.length);
         this.aEventList = null;
         this.oAnimStateMachine.destroy();
         this.oAnimStateMachine = null;
         super.destroy();
         this.bDestroyed = true;
      }
      
      public function setButtonState(_sStateID:String) : void
      {
         if(this.bDebug)
         {
            trace(" ");
         }
         this.oAnimStateMachine.setState(_sStateID);
         switch(_sStateID)
         {
            case sSTATE_UP:
               this.setListenerUp();
               break;
            case sSTATE_OVER:
               this.setListenerOver();
               break;
            case sSTATE_DOWN:
               this.setListenerDown();
         }
      }
      
      override public function toString() : String
      {
         return "[Button: Label = " + this.sLabel + "]";
      }
      
      internal function forcePress() : void
      {
         this.onPress(null);
      }
      
      protected function validStates() : void
      {
         this.bStateUp = DisplayObjectUtils.labelExists(sSTATE_UP,this.oAnimStateMachine.mcContainer as MovieClip);
         this.oAnimStateMachine.addState(sSTATE_UP,this.state_up,this.state_up_load,this.state_up_unload);
         this.bStateOver = DisplayObjectUtils.labelExists(sSTATE_OVER,this.oAnimStateMachine.mcContainer as MovieClip);
         this.oAnimStateMachine.addState(sSTATE_OVER,this.state_over,this.state_over_load,this.state_over_unload);
         this.bStateDown = DisplayObjectUtils.labelExists(sSTATE_DOWN,this.oAnimStateMachine.mcContainer as MovieClip);
         this.oAnimStateMachine.addState(sSTATE_DOWN,this.state_down,this.state_down_load,this.state_down_unload);
         this.bStateDisabled = DisplayObjectUtils.labelExists(sSTATE_DISABLED,this.oAnimStateMachine.mcContainer as MovieClip);
         if(this.bStateDisabled)
         {
            this.oAnimStateMachine.addState(sSTATE_DISABLED,this.state_disabled,this.state_disabled_load,this.state_disabled_unload);
         }
      }
      
      protected function state_up_load() : void
      {
         this.render();
      }
      
      protected function state_up() : void
      {
      }
      
      protected function state_up_unload() : void
      {
         eventManager.cleanUp(sEVENT_MANAGER_ID_BUTTON_UP);
      }
      
      protected function state_over_load() : void
      {
         this.render();
      }
      
      protected function state_over() : void
      {
      }
      
      protected function state_over_unload() : void
      {
         eventManager.cleanUp(sEVENT_MANAGER_ID_BUTTON_OVER);
      }
      
      protected function state_down_load() : void
      {
         this.render();
      }
      
      protected function state_down() : void
      {
      }
      
      protected function state_down_unload() : void
      {
         eventManager.cleanUp(sEVENT_MANAGER_ID_BUTTON_DOWN);
      }
      
      protected function state_disabled_load() : void
      {
         this.render();
      }
      
      protected function state_disabled() : void
      {
         eventManager.clearAll();
      }
      
      protected function state_disabled_unload() : void
      {
      }
      
      final protected function render() : void
      {
         if(this.oAnimStateMachine != null)
         {
            if(this.oAnimStateMachine.mcState != null)
            {
               if(this.oAnimStateMachine.mcState.mcText != null)
               {
                  if(this.oAnimStateMachine.mcState.mcText.txtText != null)
                  {
                     if(this.bLocalizedText)
                     {
                        if(this.oLocalizedTextField != null)
                        {
                           this.oLocalizedTextField.destroy();
                        }
                        this.oLocalizedTextField = new LocalizedTextField(this.oAnimStateMachine.mcState.mcText.txtText,this.sLocalizationStringID,this.oLocalizationReplacements);
                     }
                     else
                     {
                        this.oAnimStateMachine.mcState.mcText.txtText.text = this.sLabel;
                     }
                  }
               }
               if(this.oAnimStateMachine.mcState != null)
               {
                  this.onRender();
               }
            }
         }
      }
      
      private function init() : void
      {
         this.bForceRollover = false;
         this.bUseHandCursor = true;
         this.bButtonMode = true;
         if(mcContainer.mcHitArea != null)
         {
            mcContainer.hitArea = mcContainer.mcHitArea;
            mcContainer.mcHitArea.visible = false;
         }
         mcContainer.mouseChildren = false;
         mcContainer.mouseEnabled = true;
         mcContainer.buttonMode = this.bButtonMode;
         mcContainer.useHandCursor = this.bUseHandCursor;
         this.oAnimStateMachine = new AnimStateMachine(mcContainer,false);
         this.validStates();
         if(mcContainer.stage != null)
         {
            this.setBaseState();
         }
         else
         {
            eventManager.addEventListener(sEVENT_MANAGER_ID,mcContainer,Event.ADDED_TO_STAGE,this.onAddedToStage);
         }
         this.aEventList = new Array();
         this.oFrameTimer = new FrameTimer(1,0,false);
         eventManager.addEventListener(sEVENT_MANAGER_ID_TIMER,this.oFrameTimer,TimerEvent.TIMER,this.onTimerUpdate);
         this.oFrameTimer.start();
         this.bDestroyed = false;
      }
      
      private function setBaseState() : void
      {
         if(enabled)
         {
            if(MouseUtils.instance(mcContainer.stage).isMouseOver(mcContainer))
            {
               this.setButtonState(sSTATE_OVER);
               this.bForceRollover = true;
            }
            else
            {
               this.setButtonState(sSTATE_UP);
            }
         }
         else
         {
            this.setButtonState(sSTATE_DISABLED);
         }
      }
      
      private function setListenerUp() : void
      {
         if(this.bDestroyed)
         {
            return;
         }
         eventManager.cleanUp(sEVENT_MANAGER_ID_BUTTON_UP);
         eventManager.cleanUp(sEVENT_MANAGER_ID_BUTTON_OVER);
         eventManager.cleanUp(sEVENT_MANAGER_ID_BUTTON_DOWN);
         if(bEnabled)
         {
            eventManager.addEventListener(sEVENT_MANAGER_ID_BUTTON_UP,mcContainer,MouseEvent.ROLL_OVER,this.onRollOver);
            eventManager.addEventListener(sEVENT_MANAGER_ID_BUTTON_UP,mcContainer,MouseEvent.MOUSE_UP,this.onReleaseOver);
         }
      }
      
      private function setListenerOver() : void
      {
         if(this.bDestroyed)
         {
            return;
         }
         eventManager.cleanUp(sEVENT_MANAGER_ID_BUTTON_UP);
         eventManager.cleanUp(sEVENT_MANAGER_ID_BUTTON_OVER);
         eventManager.cleanUp(sEVENT_MANAGER_ID_BUTTON_DOWN);
         eventManager.addEventListener(sEVENT_MANAGER_ID_BUTTON_OVER,mcContainer,MouseEvent.MOUSE_DOWN,this.onPress);
         eventManager.addEventListener(sEVENT_MANAGER_ID_BUTTON_OVER,mcContainer,MouseEvent.ROLL_OUT,this.onRollOut);
      }
      
      private function setListenerDown() : void
      {
         if(this.bDestroyed)
         {
            return;
         }
         eventManager.cleanUp(sEVENT_MANAGER_ID_BUTTON_UP);
         eventManager.cleanUp(sEVENT_MANAGER_ID_BUTTON_OVER);
         eventManager.cleanUp(sEVENT_MANAGER_ID_BUTTON_DOWN);
         eventManager.addEventListener(sEVENT_MANAGER_ID_BUTTON_DOWN,mcContainer,MouseEvent.ROLL_OUT,this.onRollOutWhileDown);
         eventManager.addEventListener(sEVENT_MANAGER_ID_BUTTON_DOWN,mcContainer.stage,MouseEvent.MOUSE_UP,this.onRelease,false);
      }
      
      private function onAddedToStage(_e:Event) : void
      {
         this.setBaseState();
         eventManager.removeEventListener(sEVENT_MANAGER_ID,mcContainer,Event.ADDED_TO_STAGE,this.onAddedToStage);
      }
      
      private function onTimerUpdate(_oEvent:TimerEvent) : void
      {
         if(this.bDestroyed)
         {
            return;
         }
         if(this.bForceRollover && mcContainer != null && mcContainer.stage != null)
         {
            if(!MouseUtils.instance(mcContainer.stage).isMouseOver(mcContainer))
            {
               this.setButtonState(sSTATE_UP);
               this.bForceRollover = false;
            }
         }
         if(this.aEventList != null)
         {
            while(!this.bDestroyed && this.aEventList.length > 0)
            {
               dispatchEvent(this.aEventList.shift());
            }
         }
         if(this.oAnimStateMachine != null)
         {
            if(this.sNextState != null)
            {
               this.oAnimStateMachine.setState(this.sNextState);
               this.sNextState = null;
            }
         }
      }
      
      protected function onReleaseOver(_e:MouseEvent) : void
      {
         if(this.bDestroyed)
         {
            return;
         }
         if(this.oAnimStateMachine.state == sSTATE_OVER)
         {
            this.setListenerOver();
            this.aEventList.push(new UIEvent(UIEvent.RELEASE));
            this.sNextState = sSTATE_OVER;
         }
         else if(MouseUtils.instance(mcContainer.stage).isMouseOver(mcContainer))
         {
            this.onRollOver(null,true);
         }
      }
      
      protected function onRollOver(_e:MouseEvent, _bForce:Boolean = false) : void
      {
         if(this.bDestroyed)
         {
            return;
         }
         if(this.bDebug)
         {
            trace(" ");
         }
         if(Button.currentDownButton == null || _bForce)
         {
            this.setListenerOver();
            this.sNextState = sSTATE_OVER;
            this.aEventList.push(new UIEvent(UIEvent.ROLL_OVER));
         }
      }
      
      protected function onRollOut(_e:MouseEvent) : void
      {
         if(this.bDestroyed)
         {
            return;
         }
         this.setListenerUp();
         this.sNextState = sSTATE_UP;
         this.aEventList.push(new UIEvent(UIEvent.ROLL_OUT));
         Button.currentDownButton = null;
      }
      
      protected function onRollOutWhileDown(_e:MouseEvent) : void
      {
         if(this.bDestroyed)
         {
            return;
         }
         this.bMouseOutside = true;
         eventManager.cleanUp(sEVENT_MANAGER_ID_BUTTON_DOWN);
         eventManager.addEventListener(sEVENT_MANAGER_ID_BUTTON_DOWN,mcContainer,MouseEvent.ROLL_OVER,this.onRollOverWhileDown);
         eventManager.addEventListener(sEVENT_MANAGER_ID_BUTTON_DOWN,mcContainer.stage,MouseEvent.MOUSE_UP,this.onRelease);
      }
      
      protected function onRollOverWhileDown(_e:MouseEvent) : void
      {
         if(this.bDestroyed)
         {
            return;
         }
         this.bMouseOutside = false;
         eventManager.cleanUp(sEVENT_MANAGER_ID_BUTTON_DOWN);
         eventManager.addEventListener(sEVENT_MANAGER_ID_BUTTON_DOWN,mcContainer,MouseEvent.ROLL_OUT,this.onRollOutWhileDown);
         eventManager.addEventListener(sEVENT_MANAGER_ID_BUTTON_DOWN,mcContainer,MouseEvent.MOUSE_UP,this.onRelease);
      }
      
      protected function onPress(_e:MouseEvent) : void
      {
         if(this.bDestroyed)
         {
            return;
         }
         this.bMouseOutside = false;
         this.setListenerDown();
         this.sNextState = sSTATE_DOWN;
         Button.currentDownButton = this;
         this.aEventList.push(new UIEvent(UIEvent.PRESS));
      }
      
      protected function onRelease(_e:MouseEvent) : void
      {
         if(Button.currentDownButton == this)
         {
            Button.currentDownButton = null;
         }
         if(this.bDestroyed)
         {
            return;
         }
         if(this.bMouseOutside)
         {
            this.setListenerUp();
            this.sNextState = sSTATE_UP;
            this.aEventList.push(new UIEvent(UIEvent.RELEASE_OUTSIDE));
         }
         else
         {
            this.setListenerOver();
            this.sNextState = sSTATE_OVER;
            this.aEventList.push(new UIEvent(UIEvent.RELEASE));
         }
      }
      
      protected function onRender() : void
      {
      }
      
      public function get buttonMode() : Boolean
      {
         return this.bButtonMode;
      }
      
      public function set buttonMode(_bButtonMode:Boolean) : void
      {
         this.bButtonMode = _bButtonMode;
         mcContainer.buttonMode = this.bButtonMode;
      }
      
      public function get useHandCursor() : Boolean
      {
         return this.bUseHandCursor;
      }
      
      public function set useHandCursor(_bMode:Boolean) : void
      {
         this.bUseHandCursor = _bMode;
         mcContainer.useHandCursor = this.bUseHandCursor;
      }
      
      override public function set enabled(_bEnabled:Boolean) : void
      {
         super.enabled = _bEnabled;
         if(enabled)
         {
            this.setButtonState(sSTATE_UP);
            mcContainer.mouseEnabled = true;
            mcContainer.buttonMode = this.bButtonMode;
            eventManager.addEventListener(sEVENT_MANAGER_ID_TIMER,this.oFrameTimer,TimerEvent.TIMER,this.onTimerUpdate);
            this.oFrameTimer.start();
         }
         else
         {
            if(this.bStateDisabled)
            {
               this.oAnimStateMachine.setState(sSTATE_DISABLED);
               Button.currentDownButton = null;
            }
            else
            {
               eventManager.clearAll();
            }
            this.oFrameTimer.stop();
            eventManager.cleanUp(sEVENT_MANAGER_ID_TIMER);
            this.sNextState = null;
            mcContainer.mouseEnabled = false;
            mcContainer.buttonMode = false;
         }
      }
      
      public function get animLoopingUp() : Boolean
      {
         return this.oAnimStateMachine.getLooping(sSTATE_UP);
      }
      
      public function set animLoopingUp(_bLooping:Boolean) : void
      {
         this.oAnimStateMachine.setLooping(sSTATE_UP,_bLooping);
      }
      
      public function get animLoopingOver() : Boolean
      {
         return this.oAnimStateMachine.getLooping(sSTATE_OVER);
      }
      
      public function set animLoopingOver(_bLooping:Boolean) : void
      {
         this.oAnimStateMachine.setLooping(sSTATE_OVER,_bLooping);
      }
      
      public function get animLoopingDown() : Boolean
      {
         return this.oAnimStateMachine.getLooping(sSTATE_DOWN);
      }
      
      public function set animLoopingDown(_bLooping:Boolean) : void
      {
         this.oAnimStateMachine.setLooping(sSTATE_DOWN,_bLooping);
      }
      
      public function get animLoopingDisabled() : Boolean
      {
         if(this.bStateDisabled)
         {
            return this.oAnimStateMachine.getLooping(sSTATE_DISABLED);
         }
         return false;
      }
      
      public function set animLoopingDisabled(_bLooping:Boolean) : void
      {
         if(this.bStateDisabled)
         {
            this.oAnimStateMachine.setLooping(sSTATE_DISABLED,_bLooping);
         }
      }
      
      protected function get animStateMachine() : AnimStateMachine
      {
         return this.oAnimStateMachine;
      }
   }
}

