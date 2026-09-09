package com.sarbakan.sbdk.ui
{
   import com.sarbakan.sbdk.events.UIEvent;
   import com.sarbakan.sbdk.localization.LocalizedTextField;
   import com.sarbakan.sbdk.math.SBKMath;
   import flash.display.MovieClip;
   
   [Event(name="COMPLETE",type="com.sarbakan.sbdk.events.UIEvent")]
   public class ProgressBar extends AbstractRangeControl
   {
      
      private static const sPROGRESSIVE:String = "PROGRESSIVE";
      
      private static const sDEGRESSIVE:String = "DEGRESSIVE";
      
      protected var nShownValue:Number;
      
      protected var nStepSize:Number;
      
      protected var sDisplaySign:String;
      
      protected var nStartValue:Number;
      
      protected var sDir:String;
      
      public function ProgressBar(_mcRef:MovieClip, _sDisplaySign:String = "", _bPausable:Boolean = true, _nMinValue:Number = 0, _nMaxValue:Number = 1, _nStartValue:Number = 0, _nStepSize:Number = 1, _bAllowDecimal:Boolean = false)
      {
         super(_mcRef,_nMinValue,_nMaxValue,_nStartValue,_nStepSize,_bAllowDecimal,_bPausable);
         this.sDisplaySign = _sDisplaySign;
         this.nStepSize = _nStepSize;
         this.nStartValue = _nStartValue;
         if(_nStartValue > _nMinValue)
         {
            this.sDir = sDEGRESSIVE;
         }
         else
         {
            this.sDir = sPROGRESSIVE;
         }
         bAutomaticSoundsEnabled = false;
         this.nShownValue = value;
         init();
      }
      
      override public function destroy() : void
      {
         super.destroy();
      }
      
      public function reset() : void
      {
         this.value = this.nStartValue;
      }
      
      override public function toString() : String
      {
         return "[ProgressBar: Value = " + value + ",Visual value = " + this.nShownValue + ", Step size = " + this.nStepSize + "]";
      }
      
      protected function updateProgress() : void
      {
         if(this.sDir == sPROGRESSIVE)
         {
            if(this.nShownValue + stepSize >= value)
            {
               this.nShownValue = value;
            }
            else
            {
               this.nShownValue += stepSize;
            }
         }
         else if(this.sDir == sDEGRESSIVE)
         {
            if(this.nShownValue - stepSize <= value)
            {
               this.nShownValue = value;
            }
            else
            {
               this.nShownValue -= stepSize;
            }
         }
      }
      
      override protected function updateValue() : void
      {
         var _uMaxFrame:uint = 0;
         var _uFrame:uint = 0;
         if(animStateMachine.mcState.mcProgress != null)
         {
            _uMaxFrame = uint((animStateMachine.mcState.mcProgress as MovieClip).totalFrames);
            _uFrame = this.nShownValue / 100 * _uMaxFrame;
            animStateMachine.mcState.mcProgress.gotoAndStop(_uFrame);
         }
         if(animStateMachine.mcState.mcOutput != null)
         {
            if(animStateMachine.mcState.mcOutput.txtText != null)
            {
               if(bLocalizedValue)
               {
                  if(oLocalizedTextFieldValue != null)
                  {
                     oLocalizedTextFieldValue.destroy();
                  }
                  oValueLocalizationReplacements[sValueReplacementKey] = this.formatValue + this.sDisplaySign;
                  oLocalizedTextFieldValue = new LocalizedTextField(animStateMachine.mcState.mcOutput.txtText,sValueLocalizationStringID,oValueLocalizationReplacements);
               }
               else
               {
                  animStateMachine.mcState.mcOutput.txtText.text = this.formatValue + this.sDisplaySign;
               }
            }
         }
      }
      
      override protected function state_idle() : void
      {
         this.updateValue();
         if(this.sDir == sPROGRESSIVE)
         {
            if(this.nShownValue >= maxValue)
            {
               stopStateUpdate();
               dispatchEvent(new UIEvent(UIEvent.COMPLETE));
               return;
            }
         }
         else if(this.sDir == sDEGRESSIVE)
         {
            if(this.nShownValue <= minValue)
            {
               stopStateUpdate();
               dispatchEvent(new UIEvent(UIEvent.COMPLETE));
               return;
            }
         }
         this.updateProgress();
      }
      
      override public function get formatValue() : Number
      {
         var _nValue:Number = NaN;
         if(bAllowDecimal)
         {
            _nValue = SBKMath.roundDecPl(this.nShownValue,2);
         }
         else
         {
            _nValue = Math.floor(this.nShownValue);
         }
         return _nValue;
      }
      
      override public function set value(_n:Number) : void
      {
         if(_n < value)
         {
            this.sDir = sDEGRESSIVE;
         }
         else
         {
            this.sDir = sPROGRESSIVE;
         }
         super.value = _n;
      }
      
      public function get displayedValue() : Number
      {
         return this.nShownValue;
      }
   }
}

