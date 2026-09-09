package com.sarbakan.sbdk.ui
{
   import com.sarbakan.sbdk.events.UIEvent;
   import flash.display.MovieClip;
   
   public class Radio extends AbstractToggleControl
   {
      
      private var oRadioGroup:RadioGroup;
      
      public function Radio(_mcRef:MovieClip, _oValue:Object = null, _bButtonMode:Boolean = true)
      {
         super(_mcRef,_oValue,_bButtonMode);
         disableAutomaticSounds();
      }
      
      internal function setGroup(_oGrp:RadioGroup) : void
      {
         this.oRadioGroup = _oGrp;
      }
      
      override protected function onRelease(_e:UIEvent) : void
      {
         if(!checked)
         {
            super.onRelease(_e);
         }
      }
      
      public function get group() : RadioGroup
      {
         return this.oRadioGroup;
      }
   }
}

