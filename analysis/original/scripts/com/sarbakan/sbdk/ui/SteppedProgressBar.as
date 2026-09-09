package com.sarbakan.sbdk.ui
{
   import com.sarbakan.sbdk.math.SBKMath;
   import com.sarbakan.sbdk.utils.ObjectList;
   import flash.display.MovieClip;
   
   public class SteppedProgressBar extends ProgressBar
   {
      
      private var oSteps:ObjectList;
      
      public function SteppedProgressBar(_mcRef:MovieClip, _sDisplaySign:String = "", _bPausable:Boolean = true, _nMinValue:Number = 0, _nMaxValue:Number = 1, _nStepSize:Number = 1, _bAllowDecimal:Boolean = false)
      {
         super(_mcRef,_sDisplaySign,_bPausable,_nMinValue,_nMaxValue,_nMinValue,_nStepSize,_bAllowDecimal);
         this.oSteps = new ObjectList();
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.oSteps.destroy();
         this.oSteps = null;
      }
      
      override public function toString() : String
      {
         return "[SteppedProgressBar: Value = " + value + ",Visual value = " + nShownValue + ", Step size = " + nStepSize + "]";
      }
      
      public function addStep(_sStepID:String, _nMinValue:Number = 0, _nMaxValue:Number = 1, _nStepRatio:Number = 1) : void
      {
         this.oSteps.insert(_sStepID,new StepStruct(_nMinValue,_nMaxValue,_nStepRatio));
      }
      
      public function setStepValue(_sStepID:String, _nValue:Number) : void
      {
         var _oStruct:StepStruct = this.oSteps.find(_sStepID);
         if(_nValue < _oStruct.nMinValue)
         {
            _nValue = _oStruct.nMinValue;
         }
         else if(_nValue > _oStruct.nMaxValue)
         {
            _nValue = _oStruct.nMaxValue;
         }
         _oStruct.nValue = _nValue;
         this.updateGlobalValue();
      }
      
      private function updateGlobalValue() : void
      {
         var _oStruct:StepStruct = null;
         var _nValue:Number = minValue;
         var _nRatio:Number = 0;
         for each(_oStruct in this.oSteps.object)
         {
            _nValue += _oStruct.completionRatio * _oStruct.nStepRatio * (maxValue - minValue);
            _nRatio += _oStruct.nStepRatio;
         }
         super.value = SBKMath.roundDecPl(_nValue,2);
      }
      
      override public function set value(_n:Number) : void
      {
         throw new Error("Cannot edit global value of a SteppedProgressBar, use setStepValue");
      }
   }
}

class StepStruct
{
   
   public var nMinValue:Number;
   
   public var nMaxValue:Number;
   
   public var nStepRatio:Number;
   
   public var nValue:Number;
   
   public function StepStruct(_nMinValue:Number, _nMaxValue:Number, _nStepRatio:Number)
   {
      super();
      this.nMinValue = _nMinValue;
      this.nMaxValue = _nMaxValue;
      this.nStepRatio = _nStepRatio;
      this.nValue = _nMinValue;
   }
   
   public function get completionRatio() : Number
   {
      return (this.nValue - this.nMinValue) / (this.nMaxValue - this.nMinValue);
   }
}
