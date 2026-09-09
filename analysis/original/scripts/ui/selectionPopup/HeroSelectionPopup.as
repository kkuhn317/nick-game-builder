package ui.selectionPopup
{
   import builderManager.BuilderManager;
   import builderManager.BuilderRenderer;
   import builderManager.ToolManager;
   import com.sarbakan.sbdk.blitting.core.BitmapDataCollection;
   import flash.display.MovieClip;
   import flash.events.Event;
   import media.MediaManager;
   import media.events.MediaEvent;
   import media.type.PlayableCharacterMedia;
   import services.ProxyManager;
   
   public class HeroSelectionPopup extends AbstractSelectionPopup
   {
      
      public function HeroSelectionPopup()
      {
         super();
      }
      
      override public function destroy() : void
      {
         super.destroy();
      }
      
      override public function onBeforeShow() : void
      {
         super.onBeforeShow();
         BuilderManager.instance.renderer.zoom = BuilderRenderer.nMAX_ZOOM;
         BuilderManager.instance.targetHero();
      }
      
      override protected function initSelector() : void
      {
         var _oMedia:PlayableCharacterMedia = null;
         super.initSelector();
         var _aMedias:Array = BuilderMain.instance.mediaList.getMediaFromType([PlayableCharacterMedia.TYPE]);
         _aMedias.sortOn("alias");
         for each(_oMedia in _aMedias)
         {
            oSelector.addItem(null,_oMedia.alias,this.getButton(_oMedia));
         }
         if(Boolean(BuilderMain.instance.gameData.heroAlias))
         {
            oSelector.selectedValue = BuilderMain.instance.gameData.heroAlias;
         }
      }
      
      override protected function destroySelector() : void
      {
         ToolManager.instance.selectedItem = null;
         super.destroySelector();
      }
      
      private function getButton(_oMedia:PlayableCharacterMedia) : MovieClip
      {
         var _cClass:Class = _oMedia.getClass(PlayableCharacterMedia.LINKAGE_SELECTION_WHEEL);
         return new _cClass();
      }
      
      override protected function onSelect(_e:Event) : void
      {
         eventManager.cleanUp(sEVENT_RENDER_ID);
         ToolManager.instance.selectedItem = null;
         var _sHeroAlias:String = oSelector.selectedValue;
         if(_sHeroAlias != BuilderMain.instance.gameData.heroAlias)
         {
            StepManager.instance.enableStep(StepManager.sSTEP_PUBLISH,false);
         }
         if(BuilderMain.instance.gameData.heroAlias == null || BuilderMain.instance.gameData.heroAlias != _sHeroAlias)
         {
            StepManager.instance.showLoading();
            MediaManager.instance.addMediaToLoad([BuilderMain.instance.mediaList.getMedia(_sHeroAlias)]);
            eventManager.addEventListener(sEVENT_RENDER_ID,MediaManager.instance,MediaEvent.MEDIA_ALL_LOAD_COMPLETE,this.onHeroLoaded);
            MediaManager.instance.startMediaLoading();
         }
         else
         {
            super.onSelect(_e);
         }
      }
      
      private function onHeroLoaded(_e:Event) : void
      {
         eventManager.cleanUp(sEVENT_RENDER_ID);
         MediaManager.instance.stopMediaRendering();
         BitmapDataCollection.instance.disposeGroup(PlayableCharacterMedia.TYPE);
         BuilderMain.instance.gameData.heroAlias = oSelector.selectedValue;
         BuilderManager.instance.updateHero();
         ProxyManager.instance.sendTrackingCall("tracking_callID_playerChange",oSelector.selectedValue);
         StepManager.instance.hideLoading();
         super.onSelect(null);
         MediaManager.instance.addMediaToRender([BuilderMain.instance.mediaList.getMedia(oSelector.selectedValue)]);
         MediaManager.instance.startMediaRendering();
      }
   }
}

