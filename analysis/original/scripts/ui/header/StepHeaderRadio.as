package ui.header
{
   import com.sarbakan.sbdk.asset.AssetReference;
   import com.sarbakan.sbdk.events.UIEvent;
   import com.sarbakan.sbdk.sound.SoundManager;
   import com.sarbakan.sbdk.ui.Radio;
   import flash.display.MovieClip;
   
   public class StepHeaderRadio extends Radio
   {
      
      private var nStepID:uint;
      
      public function StepHeaderRadio(_mcRef:MovieClip, _oValue:Object)
      {
         super(_mcRef,_oValue);
         this.highlight = false;
      }
      
      override public function destroy() : void
      {
         super.destroy();
      }
      
      override protected function createButton() : void
      {
         oCurrentStateButton = new StepHeaderRadioButton(oAnimStateMachine.mcState);
         StepHeaderRadioButton(oCurrentStateButton).stepID = this.nStepID;
         oCurrentStateButton.setSoundClick(AssetReference.fromLibraryClass(SoundConfig.cSFX_MOUSE_CLICK),SoundConfig.sSOUND_CATEGORY_SOUNDS,0);
         oCurrentStateButton.setSoundRoll(AssetReference.fromLibraryClass(SoundConfig.cSFX_MOUSE_ROLL),SoundConfig.sSOUND_CATEGORY_SOUNDS,0);
      }
      
      override protected function onRollOver(_e:UIEvent) : void
      {
         super.onRollOver(_e);
         SoundManager.instance.play(SoundConfig.sSOUND_CATEGORY_SOUNDS,AssetReference.fromLibraryClass(SoundConfig.cSFX_MOUSE_ROLL),1);
      }
      
      override protected function onRelease(_e:UIEvent) : void
      {
         super.onRelease(_e);
         SoundManager.instance.play(SoundConfig.sSOUND_CATEGORY_SOUNDS,AssetReference.fromLibraryClass(SoundConfig.cSFX_MOUSE_CLICK),1);
      }
      
      public function set stepID(_nValue:uint) : void
      {
         this.nStepID = _nValue;
         if(Boolean(oCurrentStateButton))
         {
            StepHeaderRadioButton(oCurrentStateButton).stepID = _nValue;
         }
      }
      
      public function set highlight(_bValue:Boolean) : void
      {
         if(Boolean(mcContainer.mcHighlight))
         {
            mcContainer.mcHighlight.visible = _bValue;
         }
      }
   }
}

