package com.sarbakan.sbdk.ui
{
   import com.sarbakan.sbdk.asset.AssetReference;
   import com.sarbakan.sbdk.errors.ErrorMessages;
   import com.sarbakan.sbdk.events.UIEvent;
   import com.sarbakan.sbdk.state.AnimStateMachine;
   import flash.display.MovieClip;
   import flash.errors.IllegalOperationError;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   [Event(name="CHANGE",type="com.sarbakan.sbdk.events.UIEvent")]
   [Event(name="ROLL_OUT",type="com.sarbakan.sbdk.events.UIEvent")]
   [Event(name="ROLL_OVER",type="com.sarbakan.sbdk.events.UIEvent")]
   [Event(name="RELEASE",type="com.sarbakan.sbdk.events.UIEvent")]
   [Event(name="PRESS",type="com.sarbakan.sbdk.events.UIEvent")]
   internal class AbstractToggleControl extends AbstractControl
   {
      
      private static const sSTATE_CHECKED:String = "checked";
      
      private static const sSTATE_UNCHECKED:String = "unchecked";
      
      private static const sEVENT_MANAGER_ID:String = "abstractToggleControl";
      
      protected var oAnimStateMachine:AnimStateMachine;
      
      protected var oCurrentStateButton:Button;
      
      private var sLabel:String = "";
      
      private var oValue:*;
      
      private var bButtonMode:Boolean;
      
      private var bChecked:Boolean;
      
      private var bAnimLoopingUp:Boolean;
      
      private var bAnimLoopingOver:Boolean;
      
      private var bAnimLoopingDown:Boolean;
      
      private var bAnimLoopingDisabled:Boolean;
      
      private var bLocalizedText:Boolean = false;
      
      private var sLocalizationStringID:String;
      
      private var oLocalizationReplacements:Object;
      
      public function AbstractToggleControl(_mcRef:MovieClip, _oValue:* = null, _bButtonMode:Boolean = true)
      {
         super(_mcRef);
         if(Class(getDefinitionByName(getQualifiedClassName(this))) == AbstractToggleControl)
         {
            throw new IllegalOperationError(ErrorMessages.sABSTRACT_CLASS_ERROR);
         }
         this.oValue = _oValue;
         this.bButtonMode = _bButtonMode;
         this.init();
      }
      
      override public function destroy() : void
      {
         this.oAnimStateMachine.destroy();
         this.oAnimStateMachine = null;
         super.destroy();
      }
      
      public function setLabel(_sLabel:String) : void
      {
         this.bLocalizedText = false;
         this.sLabel = _sLabel;
         if(this.oCurrentStateButton != null)
         {
            this.oCurrentStateButton.setLabel(this.sLabel);
         }
      }
      
      public function setLocalizedLabel(_sLocalizationStringID:String, _oLocalizationReplacements:Object = null) : void
      {
         this.bLocalizedText = true;
         this.sLocalizationStringID = _sLocalizationStringID;
         this.oLocalizationReplacements = _oLocalizationReplacements;
         if(this.oCurrentStateButton != null)
         {
            this.oCurrentStateButton.setLocalizedLabel(this.sLocalizationStringID,this.oLocalizationReplacements);
         }
      }
      
      public function toggle() : Boolean
      {
         if(this.checked == true)
         {
            this.checked = false;
         }
         else
         {
            this.checked = true;
         }
         return this.checked;
      }
      
      override public function toString() : String
      {
         return "[AbstractToggleControl: Label = " + this.sLabel + ", Checked = " + this.bChecked + ", Value = " + this.oValue + "]";
      }
      
      protected function state_unchecked_load() : void
      {
         this.createButton();
         this.initButton();
      }
      
      protected function state_unchecked() : void
      {
      }
      
      protected function state_unchecked_unload() : void
      {
         this.destroyButton();
      }
      
      protected function state_checked_load() : void
      {
         this.createButton();
         this.initButton();
      }
      
      protected function state_checked() : void
      {
      }
      
      protected function state_checked_unload() : void
      {
         this.destroyButton();
      }
      
      private function init() : void
      {
         this.oAnimStateMachine = new AnimStateMachine(mcContainer,false);
         this.oAnimStateMachine.addState(sSTATE_CHECKED,this.state_checked,this.state_checked_load,this.state_checked_unload);
         this.oAnimStateMachine.addState(sSTATE_UNCHECKED,this.state_unchecked,this.state_unchecked_load,this.state_unchecked_unload);
         this.oAnimStateMachine.setState(sSTATE_UNCHECKED);
         this.bAnimLoopingUp = true;
         this.bAnimLoopingOver = true;
         this.bAnimLoopingDown = true;
         this.bAnimLoopingDisabled = true;
      }
      
      protected function createButton() : void
      {
         this.oCurrentStateButton = new Button(this.oAnimStateMachine.mcState);
      }
      
      private function initButton() : void
      {
         if(this.bLocalizedText)
         {
            this.oCurrentStateButton.setLocalizedLabel(this.sLocalizationStringID,this.oLocalizationReplacements);
         }
         else
         {
            this.oCurrentStateButton.setLabel(this.sLabel);
         }
         if(enabled == false)
         {
            this.oCurrentStateButton.enabled = false;
         }
         this.oCurrentStateButton.animLoopingUp = this.bAnimLoopingUp;
         this.oCurrentStateButton.animLoopingOver = this.bAnimLoopingOver;
         this.oCurrentStateButton.animLoopingDown = this.bAnimLoopingDown;
         this.oCurrentStateButton.animLoopingDisabled = this.bAnimLoopingDisabled;
         if(this.bButtonMode)
         {
            eventManager.addEventListener(sEVENT_MANAGER_ID,this.oCurrentStateButton,UIEvent.PRESS,this.onPress);
            eventManager.addEventListener(sEVENT_MANAGER_ID,this.oCurrentStateButton,UIEvent.RELEASE,this.onRelease);
         }
         eventManager.addEventListener(sEVENT_MANAGER_ID,this.oCurrentStateButton,UIEvent.ROLL_OVER,this.onRollOver);
         eventManager.addEventListener(sEVENT_MANAGER_ID,this.oCurrentStateButton,UIEvent.ROLL_OUT,this.onRollOut);
         if(Boolean(oSoundClick))
         {
            this.oCurrentStateButton.setSoundClick(oSoundClick.oAsset,oSoundClick.sCategory,oSoundClick.nVolume);
         }
         if(Boolean(oSoundClickDisabled))
         {
            this.oCurrentStateButton.setSoundClickDisabled(oSoundClickDisabled.oAsset,oSoundClickDisabled.sCategory,oSoundClickDisabled.nVolume);
         }
         if(Boolean(oSoundRoll))
         {
            this.oCurrentStateButton.setSoundRoll(oSoundRoll.oAsset,oSoundRoll.sCategory,oSoundRoll.nVolume,oSoundRoll.bLoop);
         }
      }
      
      override public function setSoundClick(_oSoundAsset:AssetReference, _sSoundCategory:String, _nVolume:Number = 1) : void
      {
         super.setSoundClick(_oSoundAsset,_sSoundCategory,_nVolume);
         if(Boolean(this.oCurrentStateButton))
         {
            this.oCurrentStateButton.setSoundClick(_oSoundAsset,_sSoundCategory,_nVolume);
         }
      }
      
      override public function setSoundClickDisabled(_oSoundAsset:AssetReference, _sSoundCategory:String, _nVolume:Number = 1) : void
      {
         super.setSoundClickDisabled(_oSoundAsset,_sSoundCategory,_nVolume);
         if(Boolean(this.oCurrentStateButton))
         {
            this.oCurrentStateButton.setSoundClickDisabled(_oSoundAsset,_sSoundCategory,_nVolume);
         }
      }
      
      override public function setSoundRoll(_oSoundAsset:AssetReference, _sSoundCategory:String, _nVolume:Number = 1, _bLoop:Boolean = false) : void
      {
         super.setSoundRoll(_oSoundAsset,_sSoundCategory,_nVolume,_bLoop);
         if(Boolean(this.oCurrentStateButton))
         {
            this.oCurrentStateButton.setSoundRoll(_oSoundAsset,_sSoundCategory,_nVolume,_bLoop);
         }
      }
      
      private function destroyButton() : void
      {
         if(this.oCurrentStateButton != null)
         {
            this.oCurrentStateButton.destroy();
         }
         eventManager.cleanUp(sEVENT_MANAGER_ID);
         this.oCurrentStateButton = null;
      }
      
      protected function onPress(_e:UIEvent) : void
      {
         dispatchEvent(_e);
      }
      
      protected function onRelease(_e:UIEvent) : void
      {
         this.toggle();
         dispatchEvent(_e);
      }
      
      protected function onRollOver(_e:UIEvent) : void
      {
         dispatchEvent(_e);
      }
      
      protected function onRollOut(_e:UIEvent) : void
      {
         dispatchEvent(_e);
      }
      
      public function get value() : *
      {
         return this.oValue;
      }
      
      public function set value(_oValue:*) : void
      {
         this.oValue = _oValue;
      }
      
      public function get checked() : Boolean
      {
         return this.bChecked;
      }
      
      public function set checked(_bChecked:Boolean) : void
      {
         if(_bChecked != this.bChecked)
         {
            this.bChecked = _bChecked;
            switch(this.bChecked)
            {
               case true:
                  this.oAnimStateMachine.setState(sSTATE_CHECKED);
                  break;
               case false:
                  this.oAnimStateMachine.setState(sSTATE_UNCHECKED);
            }
            dispatchEvent(new UIEvent(UIEvent.CHANGE));
         }
      }
      
      override public function set enabled(_bEnabled:Boolean) : void
      {
         super.enabled = _bEnabled;
         if(this.oCurrentStateButton != null)
         {
            this.oCurrentStateButton.enabled = _bEnabled;
         }
      }
      
      public function get animLoopingUp() : Boolean
      {
         return this.bAnimLoopingUp;
      }
      
      public function set animLoopingUp(_bLooping:Boolean) : void
      {
         this.bAnimLoopingUp = _bLooping;
         if(this.oCurrentStateButton != null)
         {
            this.oCurrentStateButton.animLoopingUp = _bLooping;
         }
      }
      
      public function get animLoopingOver() : Boolean
      {
         return this.bAnimLoopingOver;
      }
      
      public function set animLoopingOver(_bLooping:Boolean) : void
      {
         this.bAnimLoopingOver = _bLooping;
         if(this.oCurrentStateButton != null)
         {
            this.oCurrentStateButton.animLoopingOver = _bLooping;
         }
      }
      
      public function get animLoopingDown() : Boolean
      {
         return this.bAnimLoopingDown;
      }
      
      public function set animLoopingDown(_bLooping:Boolean) : void
      {
         this.bAnimLoopingDown = _bLooping;
         if(this.oCurrentStateButton != null)
         {
            this.oCurrentStateButton.animLoopingDown = _bLooping;
         }
      }
      
      public function get animLoopingDisabled() : Boolean
      {
         return this.bAnimLoopingDisabled;
      }
      
      public function set animLoopingDisabled(_bLooping:Boolean) : void
      {
         this.bAnimLoopingDisabled = _bLooping;
         if(this.oCurrentStateButton != null)
         {
            this.oCurrentStateButton.animLoopingDisabled = _bLooping;
         }
      }
   }
}

