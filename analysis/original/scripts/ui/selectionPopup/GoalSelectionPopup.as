package ui.selectionPopup
{
   import builderManager.BuilderManager;
   import builderManager.BuilderRenderer;
   import builderManager.ToolManager;
   import com.sarbakan.sbdk.localization.LocalizationManager;
   import com.sarbakan.sbdk.math.geom.AABB2;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class GoalSelectionPopup extends AbstractSelectionPopup
   {
      
      public function GoalSelectionPopup()
      {
         super();
      }
      
      override public function destroy() : void
      {
         super.destroy();
      }
      
      override public function onBeforeShow() : void
      {
         var _oNewBounds:AABB2 = null;
         super.onBeforeShow();
         BuilderManager.instance.renderer.zoom = BuilderRenderer.nMIN_ZOOM;
         if(Boolean(BuilderManager.instance.builderData))
         {
            _oNewBounds = BuilderManager.instance.builderData.bounds;
            BuilderManager.instance.renderer.updateCenterPos(_oNewBounds.nXMin + (_oNewBounds.nXMax - _oNewBounds.nXMin) / 2,_oNewBounds.nYMin + (_oNewBounds.nYMax - _oNewBounds.nYMin) / 2);
         }
      }
      
      override protected function initSelector() : void
      {
         super.initSelector();
         oSelector.addItem(null,CommonConfig.sGOAL_TYPE_DOOR,this.createIcon(mcDoorGoalIcon,"id_ui_goal_door"),"id_tooltip_goal_door");
         oSelector.addItem(null,CommonConfig.sGOAL_TYPE_COIN,this.createIcon(mcCoinGoalIcon,"id_ui_goal_coin"),"id_tooltip_goal_coins");
         oSelector.addItem(null,CommonConfig.sGOAL_TYPE_OPPONENT,this.createIcon(mcOpponentGoalIcon,"id_ui_goal_opponent"),"id_tooltip_goal_opponents");
         if(Boolean(BuilderMain.instance.gameData.goal))
         {
            oSelector.selectedValue = BuilderMain.instance.gameData.goal;
         }
      }
      
      override protected function destroySelector() : void
      {
         ToolManager.instance.selectedItem = null;
         super.destroySelector();
      }
      
      private function createIcon(_cClass:Class, _sLocale:String) : MovieClip
      {
         var _mcContent:MovieClip = new mcGoalSelectionButton();
         var _mcIconContainer:MovieClip = _mcContent.mcIcon;
         var _mcIcon:MovieClip = new _cClass();
         var _nScale:Number = Math.min(1,_mcIconContainer.width / _mcIcon.width,_mcIconContainer.height / _mcIcon.height);
         _mcIcon.scaleX = _nScale;
         _mcIcon.scaleY = _nScale;
         _mcIconContainer.addChild(_mcIcon);
         LocalizationManager.instance.setTextField(_mcContent.txtObjective,_sLocale);
         return _mcContent;
      }
      
      override protected function onSelect(_e:Event) : void
      {
         eventManager.cleanUp(sEVENT_RENDER_ID);
         trace("is template : " + BuilderManager.instance.isTemplate);
         var _sNewValue:String = oSelector.selectedValue;
         if(_sNewValue != BuilderMain.instance.gameData.goal)
         {
            StepManager.instance.enableStep(StepManager.sSTEP_PUBLISH,false);
         }
         if(oSelector.selectedValue != _sNewValue)
         {
            oSelector.selectedValue = _sNewValue;
         }
         BuilderMain.instance.gameData.goal = _sNewValue;
         BuilderManager.instance.updateGoal();
         BuilderManager.instance.changeGoalDisplayType();
         super.onSelect(_e);
      }
      
      override protected function get itemHeightRatio() : Number
      {
         return 0.5;
      }
   }
}

