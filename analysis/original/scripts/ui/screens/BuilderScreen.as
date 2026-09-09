package ui.screens
{
   import builderManager.BuilderManager;
   import builderManager.ToolManager;
   import com.sarbakan.sbdk.asset.AssetReference;
   import com.sarbakan.sbdk.view.ViewManager;
   import mx.effects.easing.Sine;
   import ui.popups.ConfirmPopup;
   
   public class BuilderScreen extends AbstractBuilderStepScreen
   {
      
      private static const nANIM_DURATION:uint = 500;
      
      private static const fEASING_FUNCTION:Function = Sine.easeIn;
      
      private var oBuilder:BuilderManager;
      
      public function BuilderScreen()
      {
         super(AssetReference.fromLibraryClass(mcBuilderScreen));
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.destroyTools();
         if(Boolean(this.oBuilder))
         {
            this.oBuilder.destroy();
         }
         this.oBuilder = null;
      }
      
      override public function onBeforeShow() : void
      {
         super.onBeforeShow();
         StepManager.instance.showHeader();
         this.oBuilder = new BuilderManager(mcContent.mcBuilderZone);
         this.initTools();
      }
      
      override public function onHide() : void
      {
         super.onHide();
         eventManager.cleanUp(sEVENT_MANAGER_ID);
         var _oConfirmPopup:ConfirmPopup = ViewManager.instance.getView(BuilderMain.sPOPUP_CONFIRM) as ConfirmPopup;
         if(_oConfirmPopup.isDisplayed)
         {
            _oConfirmPopup.skipInOutStates = true;
            BuilderMain.instance.hidePopup(BuilderMain.sPOPUP_CONFIRM);
         }
         this.destroyTools();
         if(Boolean(this.oBuilder))
         {
            this.oBuilder.copyToGameData();
            this.oBuilder.destroy();
         }
         this.oBuilder = null;
      }
      
      private function initTools() : void
      {
         ToolManager.instance.init();
      }
      
      private function destroyTools() : void
      {
         ToolManager.instance.destroy();
      }
   }
}

