package tutorial
{
   import com.sarbakan.sbdk.asset.AssetReference;
   import com.sarbakan.sbdk.localization.LocalizationManager;
   import com.sarbakan.sbdk.state.AnimStateMachine;
   import com.sarbakan.sbdk.view.AbstractView;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   
   public class TutorialOverlay extends AbstractView
   {
      
      protected static const sEVENT_MANAGER_ID:String = "eventManager";
      
      private var oStateMachine:AnimStateMachine;
      
      public function TutorialOverlay()
      {
         super(AssetReference.fromLibraryClass(mcTutorial));
      }
      
      override public function destroy() : void
      {
         super.destroy();
      }
      
      override public function onBeforeShow() : void
      {
         super.onBeforeShow();
         this.oStateMachine = new AnimStateMachine(mcContent);
         this.oStateMachine.addState(StepManager.sSTEP_BACKGROUND,null,this.state_background_init);
         this.oStateMachine.addState(StepManager.sSTEP_LAYOUT,null,this.state_layout_init);
         this.oStateMachine.addState(StepManager.sSTEP_HERO,null,this.state_hero_init);
         this.oStateMachine.addState(StepManager.sSTEP_MUSIC,null,this.state_music_init);
         this.oStateMachine.addState(StepManager.sSTEP_GOAL,null,this.state_goal_init);
         this.oStateMachine.addState(StepManager.sSTEP_BUILDER,null,this.state_builder_init);
         this.oStateMachine.addState(StepManager.sSTEP_TEST);
         this.oStateMachine.addState(StepManager.sSTEP_PUBLISH,null,this.state_publish_init);
         this.oStateMachine.setState(StepManager.instance.currentStep.id);
         var _oStage:Stage = BuilderMain.instance.stage;
         eventManager.addEventListener(sEVENT_MANAGER_ID,_oStage,MouseEvent.MOUSE_DOWN,this.onFocusOut);
         eventManager.addEventListener(sEVENT_MANAGER_ID,_oStage,KeyboardEvent.KEY_DOWN,this.onFocusOut);
      }
      
      override public function onHide() : void
      {
         eventManager.cleanUp(sEVENT_MANAGER_ID);
      }
      
      private function state_background_init() : void
      {
         LocalizationManager.instance.setTextField(this.oStateMachine.mcState.txtTitle,"id_tutorialBuilder_backgroundTitle");
         LocalizationManager.instance.setTextField(this.oStateMachine.mcState.txtText,"id_tutorialBuilder_backgroundText");
         LocalizationManager.instance.setTextField(this.oStateMachine.mcState.txtNext,"id_tutorialBuilder_NextStep");
      }
      
      private function state_layout_init() : void
      {
         LocalizationManager.instance.setTextField(this.oStateMachine.mcState.txtTitle,"id_tutorialBuilder_layoutTitle");
         LocalizationManager.instance.setTextField(this.oStateMachine.mcState.txtText,"id_tutorialBuilder_layoutText");
         LocalizationManager.instance.setTextField(this.oStateMachine.mcState.txtNext,"id_tutorialBuilder_NextStep");
      }
      
      private function state_hero_init() : void
      {
         LocalizationManager.instance.setTextField(this.oStateMachine.mcState.txtTitle,"id_tutorialBuilder_heroTitle");
         LocalizationManager.instance.setTextField(this.oStateMachine.mcState.txtText,"id_tutorialBuilder_heroText");
         LocalizationManager.instance.setTextField(this.oStateMachine.mcState.txtNext,"id_tutorialBuilder_NextStep");
      }
      
      private function state_music_init() : void
      {
         LocalizationManager.instance.setTextField(this.oStateMachine.mcState.txtTitle,"id_tutorialBuilder_musicTitle");
         LocalizationManager.instance.setTextField(this.oStateMachine.mcState.txtText,"id_tutorialBuilder_musicText");
         LocalizationManager.instance.setTextField(this.oStateMachine.mcState.txtNext,"id_tutorialBuilder_NextStep");
      }
      
      private function state_goal_init() : void
      {
         LocalizationManager.instance.setTextField(this.oStateMachine.mcState.txtTitle,"id_tutorialBuilder_goalTitle");
         LocalizationManager.instance.setTextField(this.oStateMachine.mcState.txtText,"id_tutorialBuilder_goalText");
         LocalizationManager.instance.setTextField(this.oStateMachine.mcState.txtNext,"id_tutorialBuilder_NextStep");
      }
      
      private function state_builder_init() : void
      {
         LocalizationManager.instance.setTextField(this.oStateMachine.mcState.txtTitle,"id_tutorialBuilder_builderTitle");
         LocalizationManager.instance.setTextField(this.oStateMachine.mcState.txtText,"id_tutorialBuilder_builderText");
         LocalizationManager.instance.setTextField(this.oStateMachine.mcState.txtTip,"id_tutorialBuilder_builderNextTip");
         LocalizationManager.instance.setTextField(this.oStateMachine.mcState.txtNext,"id_tutorialBuilder_builderNextStep");
      }
      
      private function state_publish_init() : void
      {
         LocalizationManager.instance.setTextField(this.oStateMachine.mcState.txtTitle,"id_tutorialBuilder_publishTitle");
         LocalizationManager.instance.setTextField(this.oStateMachine.mcState.txtText,"id_tutorialBuilder_publishText");
         LocalizationManager.instance.setTextField(this.oStateMachine.mcState.txtNext,"id_tutorialBuilder_publishNextStep");
      }
      
      private function onFocusOut(_e:Event) : void
      {
         StepManager.instance.hideTutorial();
      }
   }
}

