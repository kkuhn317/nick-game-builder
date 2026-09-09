package ui.selectionPopup
{
   import builderManager.BuilderManager;
   import builderManager.BuilderRenderer;
   import builderManager.ToolManager;
   import com.sarbakan.sbdk.math.geom.AABB2;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.PixelSnapping;
   import media.type.AbstractMedia;
   import media.type.BonusCoinMedia;
   import media.type.BonusExtraLifeMedia;
   import media.type.BonusInvincibilityMedia;
   import media.type.GoalMedia;
   import media.type.OpponentJumperMedia;
   import media.type.OpponentShooterMedia;
   import media.type.OpponentWalkerMedia;
   import media.type.PlatformObjectMedia;
   import media.type.PropsMedia;
   import media.type.TileFatalMedia;
   import media.type.TilePlatformMedia;
   import media.type.TileSlipperyMedia;
   import media.type.TileSurfaceMedia;
   import ui.selectionGrid.LibraryItemDefinition;
   
   public class ToolsPopup extends AbstractSelectionPopup
   {
      
      private static var sEVENT_MANAGER_ID:String = "events";
      
      public function ToolsPopup()
      {
         super();
      }
      
      override public function destroy() : void
      {
         eventManager.cleanUp(sEVENT_MANAGER_ID);
         super.destroy();
      }
      
      override public function onBeforeShow() : void
      {
         var _oNewBounds:AABB2 = null;
         super.onBeforeShow();
         this.attachTools();
         BuilderManager.instance.renderer.zoom = BuilderRenderer.nMIN_ZOOM;
         if(Boolean(BuilderManager.instance.builderData))
         {
            _oNewBounds = BuilderManager.instance.builderData.bounds;
            BuilderManager.instance.renderer.updateCenterPos(_oNewBounds.nXMin + (_oNewBounds.nXMax - _oNewBounds.nXMin) / 2,_oNewBounds.nYMin + (_oNewBounds.nYMax - _oNewBounds.nYMin) / 2);
         }
      }
      
      override protected function initBtnNext() : void
      {
         StepManager.instance.header.btnNext.mcContainer.visible = false;
      }
      
      override protected function initSelector() : void
      {
         super.initSelector();
         ToolManager.instance.selector = oSelector;
         this.buildCategory("id_ui_category_enemy",[OpponentWalkerMedia.TYPE,OpponentJumperMedia.TYPE,OpponentShooterMedia.TYPE]);
         this.buildCategory("id_ui_category_tiles",[TileSurfaceMedia.TYPE,TileSlipperyMedia.TYPE,TileFatalMedia.TYPE,TilePlatformMedia.TYPE]);
         var _aTypes:Array = [BonusCoinMedia.TYPE,BonusExtraLifeMedia.TYPE,BonusInvincibilityMedia.TYPE];
         if(BuilderMain.instance.gameData.multigoalEnabled && BuilderMain.instance.gameData.goal == CommonConfig.sGOAL_TYPE_DOOR)
         {
            _aTypes.push(GoalMedia.TYPE);
         }
         this.buildCategory("id_ui_category_collectables",_aTypes);
         this.buildCategory("id_ui_category_props",[PlatformObjectMedia.TYPE,PropsMedia.TYPE]);
      }
      
      override protected function destroySelector() : void
      {
         super.destroySelector();
         ToolManager.instance.selector = null;
      }
      
      private function buildCategory(_sCat:String, _aElementTypes:Array) : void
      {
         var _oMedia:AbstractMedia = null;
         var _sLinkage:String = null;
         var _aMedias:Array = BuilderMain.instance.mediaList.getMediaFromType(_aElementTypes);
         _aMedias.sortOn("type");
         for each(_oMedia in _aMedias)
         {
            for each(_sLinkage in _oMedia.previewLinkages)
            {
               oSelector.addItem(_sCat,new LibraryItemDefinition(_oMedia,_sLinkage),this.getPreview(_oMedia,_sLinkage),"id_tooltip_gameObject_" + _oMedia.type);
            }
         }
      }
      
      private function getPreview(_oMedia:AbstractMedia, _sLinkage:String) : DisplayObject
      {
         var _cClass:Class = null;
         var _mcReturn:MovieClip = null;
         if(_oMedia.type == PropsMedia.TYPE)
         {
            return new Bitmap(_oMedia.getPreview(_sLinkage),PixelSnapping.ALWAYS,true);
         }
         _cClass = _oMedia.getClass(_sLinkage);
         _mcReturn = new _cClass();
         if(_mcReturn.getChildByName(AbstractMedia.sMARQUEE_PREVIEW_ZONE) != null)
         {
            _mcReturn.removeChild(_mcReturn.getChildByName(AbstractMedia.sMARQUEE_PREVIEW_ZONE));
         }
         return _mcReturn;
      }
      
      private function attachTools() : void
      {
         var _mcTool:MovieClip = ToolManager.instance.mcContainer;
         if(Boolean(_mcTool.parent))
         {
            _mcTool.parent.removeChild(_mcTool);
         }
         mcContent.addChild(_mcTool);
      }
      
      override protected function get overRatio() : Number
      {
         return 3;
      }
      
      override protected function get heightModifier() : Number
      {
         return 0;
      }
   }
}

