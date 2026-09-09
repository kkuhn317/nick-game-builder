package com.sarbakan.sbdk.ui
{
   import com.sarbakan.sbdk.localization.LocalizedTextField;
   import com.sarbakan.sbdk.state.AnimStateMachine;
   import com.sarbakan.sbdk.utils.DisplayObjectUtils;
   import flash.display.MovieClip;
   
   public class AbstractRangeControl extends AbstractControl
   {
      
      private static const sSTATE_IDLE:String = "idle";
      
      private static const sSTATE_DISABLED:String = "disabled";
      
      private static const sEVENT_MANAGER_ID:String = "abstractRangeControl";
      
      private var nMin:Number;
      
      private var nMax:Number;
      
      private var nValue:Number;
      
      private var nStepSize:Number;
      
      private var nFactor:Number;
      
      private var sLabel:String = "";
      
      private var bStateDisabled:Boolean;
      
      private var bButtonMode:Boolean = true;
      
      protected var bAllowDecimal:Boolean;
      
      private var oAnimStateMachine:AnimStateMachine;
      
      protected var bLocalizedLabel:Boolean;
      
      protected var bLocalizedValue:Boolean;
      
      protected var sLabelLocalizationStringID:String;
      
      protected var sValueLocalizationStringID:String;
      
      protected var sValueReplacementKey:String;
      
      protected var oLabelLocalizationReplacements:Object;
      
      protected var oValueLocalizationReplacements:Object;
      
      protected var oLocalizedTextFieldLabel:LocalizedTextField;
      
      protected var oLocalizedTextFieldValue:LocalizedTextField;
      
      public function AbstractRangeControl(_mcRef:MovieClip, _nMinValue:Number = 0, _nMaxValue:Number = 1, _nStartValue:Number = 0, _nStepSize:Number = 1, _bAllowDecimal:Boolean = false, _bAnimStateMachinePauseable:Boolean = false)
      {
         super(_mcRef);
         this.nMin = _nMinValue;
         this.nMax = _nMaxValue;
         this.nStepSize = _nStepSize;
         this.bAllowDecimal = _bAllowDecimal;
         this.nValue = _nStartValue;
         this.factor = this.getFactorFromValue(_nStartValue);
         this.oAnimStateMachine = new AnimStateMachine(mcContainer,_bAnimStateMachinePauseable,true);
         this.validateStates();
      }
      
      public function setLabel(_sLabel:String) : void
      {
         this.bLocalizedLabel = false;
         this.sLabel = _sLabel;
         this.showLabel();
      }
      
      public function setLocalizedLabel(_sLabelLocalizationStringID:String, _oLabelLocalizationReplacements:Object = null) : void
      {
         this.bLocalizedLabel = true;
         this.sLabelLocalizationStringID = _sLabelLocalizationStringID;
         this.oLabelLocalizationReplacements = _oLabelLocalizationReplacements;
         this.showLabel();
      }
      
      public function setLocalizedValue(_sValueLocalizationStringID:String, _oValueLocalizationReplacements:Object = null, _sValueReplacementKey:String = null) : void
      {
         this.bLocalizedValue = true;
         this.sValueLocalizationStringID = _sValueLocalizationStringID;
         this.sValueReplacementKey = _sValueReplacementKey;
         if(_oValueLocalizationReplacements == null)
         {
            _oValueLocalizationReplacements = {};
         }
         this.oValueLocalizationReplacements = _oValueLocalizationReplacements;
         this.showValue();
      }
      
      public function stopStateUpdate() : void
      {
         this.oAnimStateMachine.pause();
      }
      
      public function startStateUpdate() : void
      {
         this.oAnimStateMachine.resume();
      }
      
      override public function toString() : String
      {
         return "[AbstractRangeControl: Value = " + this.nValue + ", Min = " + this.nMin + ", Max = " + this.nMax + ", Step size = " + this.nStepSize + "]";
      }
      
      protected function validateStates() : void
      {
         this.bStateDisabled = DisplayObjectUtils.labelExists(sSTATE_DISABLED,this.animStateMachine.mcContainer as MovieClip);
      }
      
      protected function state_idle_load() : void
      {
         this.initButton();
         this.showLabel();
         this.showValue();
      }
      
      protected function state_idle() : void
      {
      }
      
      protected function state_idle_unload() : void
      {
      }
      
      protected function state_disabled_load() : void
      {
         this.initButton();
         this.showLabel();
         this.showValue();
      }
      
      protected function state_disabled() : void
      {
      }
      
      protected function state_disabled_unload() : void
      {
      }
      
      override public function destroy() : void
      {
         this.oAnimStateMachine.destroy();
         this.oAnimStateMachine = null;
         super.destroy();
      }
      
      protected function init() : void
      {
         this.oAnimStateMachine.addState(sSTATE_IDLE,this.state_idle,this.state_idle_load,this.state_idle_unload);
         if(this.bStateDisabled)
         {
            this.oAnimStateMachine.addState(sSTATE_DISABLED,this.state_disabled,this.state_disabled_load,this.state_disabled_unload);
         }
         this.oAnimStateMachine.setState(sSTATE_IDLE);
      }
      
      protected function initButton() : void
      {
      }
      
      protected function destroyButton() : void
      {
      }
      
      protected function showLabel() : void
      {
         if(this.oAnimStateMachine != null)
         {
            if(this.oAnimStateMachine.mcState.mcText != null)
            {
               MovieClip(this.oAnimStateMachine.mcState.mcText).mouseChildren = false;
               MovieClip(this.oAnimStateMachine.mcState.mcText).mouseEnabled = false;
               if(this.oAnimStateMachine.mcState.mcText.txtText != null)
               {
                  if(this.bLocalizedLabel)
                  {
                     if(this.oLocalizedTextFieldLabel != null)
                     {
                        this.oLocalizedTextFieldLabel.destroy();
                     }
                     this.oLocalizedTextFieldLabel = new LocalizedTextField(this.oAnimStateMachine.mcState.mcText.txtText,this.sLabelLocalizationStringID,this.oLabelLocalizationReplacements);
                  }
                  else
                  {
                     this.oAnimStateMachine.mcState.mcText.txtText.text = this.sLabel;
                  }
               }
            }
         }
      }
      
      protected function showValue() : void
      {
         if(this.oAnimStateMachine.mcState != null)
         {
            if(this.oAnimStateMachine.mcState.mcOutput != null)
            {
               if(this.oAnimStateMachine.mcState.mcOutput.txtText != null)
               {
                  if(this.bLocalizedValue)
                  {
                     if(this.oLocalizedTextFieldValue != null)
                     {
                        this.oLocalizedTextFieldValue.destroy();
                     }
                     this.oValueLocalizationReplacements[this.sValueReplacementKey] = this.formatValue;
                     this.oLocalizedTextFieldValue = new LocalizedTextField(this.oAnimStateMachine.mcState.mcOutput.txtText,this.sValueLocalizationStringID,this.oValueLocalizationReplacements);
                  }
                  else
                  {
                     this.oAnimStateMachine.mcState.mcOutput.txtText.text = this.formatValue;
                  }
               }
            }
         }
      }
      
      protected function getFactorFromValue(_nValue:Number) : Number
      {
         return (_nValue - this.minValue) / (this.maxValue - this.minValue);
      }
      
      protected function updateValue() : void
      {
      }
      
      public function get factor() : Number
      {
         return this.nFactor;
      }
      
      public function set factor(_nFactor:Number) : void
      {
         this.nFactor = _nFactor;
      }
      
      public function get buttonMode() : Boolean
      {
         return this.bButtonMode;
      }
      
      public function set buttonMode(_bButtonMode:Boolean) : void
      {
         this.bButtonMode = _bButtonMode;
      }
      
      public function get value() : Number
      {
         return this.nValue;
      }
      
      public function set value(_nValue:Number) : void
      {
         this.nValue = _nValue;
         this.updateValue();
      }
      
      public function get formatValue() : Number
      {
         return this.value;
      }
      
      public function get minValue() : Number
      {
         return this.nMin;
      }
      
      public function set minValue(_nValue:Number) : void
      {
         this.nMin = _nValue;
         if(this.value < this.nMin)
         {
            this.value = this.nMin;
         }
         this.updateValue();
      }
      
      public function get maxValue() : Number
      {
         return this.nMax;
      }
      
      public function set maxValue(_nValue:Number) : void
      {
         this.nMax = _nValue;
         if(this.value > this.nMax)
         {
            this.value = this.nMax;
         }
         this.updateValue();
      }
      
      public function get stepSize() : Number
      {
         return this.nStepSize;
      }
      
      internal function get animStateMachine() : AnimStateMachine
      {
         return this.oAnimStateMachine;
      }
      
      override public function set enabled(_bEnabled:Boolean) : void
      {
         if(_bEnabled != enabled)
         {
            super.enabled = _bEnabled;
            if(enabled)
            {
               this.oAnimStateMachine.setState(sSTATE_IDLE);
            }
            else if(this.bStateDisabled)
            {
               eventManager.clearAll();
               this.oAnimStateMachine.setState(sSTATE_DISABLED);
            }
            else
            {
               eventManager.clearAll();
            }
         }
      }
   }
}

