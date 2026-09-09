package ui.header
{
   import com.sarbakan.sbdk.localization.LocalizationManager;
   import com.sarbakan.sbdk.ui.Button;
   import flash.display.MovieClip;
   
   public class StepHeaderRadioButton extends Button
   {
      
      private var nStepID:uint;
      
      public function StepHeaderRadioButton(_mcRef:MovieClip)
      {
         super(_mcRef);
      }
      
      override public function destroy() : void
      {
         super.destroy();
      }
      
      override protected function state_up_load() : void
      {
         super.state_up_load();
         this.displayStepID();
      }
      
      override protected function state_over_load() : void
      {
         super.state_over_load();
         this.displayStepID();
      }
      
      override protected function state_down_load() : void
      {
         super.state_down_load();
         this.displayStepID();
      }
      
      override protected function state_disabled_load() : void
      {
         super.state_disabled_load();
         this.displayStepID();
      }
      
      private function displayStepID() : void
      {
         if(Boolean(oAnimStateMachine.mcState) && Boolean(oAnimStateMachine.mcState.mcStepID))
         {
            LocalizationManager.instance.setTextField(oAnimStateMachine.mcState.mcStepID.txtText,"id_ui_global_stepID",{"$value$":this.nStepID});
         }
      }
      
      public function set stepID(_nValue:uint) : void
      {
         this.nStepID = _nValue;
         this.displayStepID();
      }
   }
}

