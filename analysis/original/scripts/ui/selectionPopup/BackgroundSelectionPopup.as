package ui.selectionPopup
{
   import builderManager.BuilderManager;
   import builderManager.BuilderRenderer;
   import com.sarbakan.sbdk.blitting.core.BitmapDataCollection;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Rectangle;
   import media.MediaManager;
   import media.events.MediaEvent;
   import media.type.AbstractMedia;
   import media.type.BackgroundMedia;
   
   public class BackgroundSelectionPopup extends AbstractSelectionPopup
   {
      
      private static const oPREVIEW_SCROLL_RECT:Rectangle = new Rectangle(0,0,225,150);
      
      public function BackgroundSelectionPopup()
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
      }
      
      override protected function initSelector() : void
      {
         var _oMedia:BackgroundMedia = null;
         super.initSelector();
         var _aMedias:Array = BuilderMain.instance.mediaList.getMediaFromType([BackgroundMedia.TYPE]);
         _aMedias.sortOn("alias");
         for each(_oMedia in _aMedias)
         {
            oSelector.addItem(null,_oMedia.alias,this.getPreview(_oMedia));
         }
         oSelector.selectedValue = BuilderMain.instance.gameData.backgroundAlias;
      }
      
      private function getPreview(_oMedia:AbstractMedia) : MovieClip
      {
         var _cClass:Class = _oMedia.getClass(AbstractMedia.sDEFAULT_PREVIEW);
         var _mcPreview:MovieClip = new _cClass();
         _mcPreview.scrollRect = oPREVIEW_SCROLL_RECT;
         return _mcPreview;
      }
      
      override protected function onSelect(_e:Event) : void
      {
         eventManager.cleanUp(sEVENT_RENDER_ID);
         if(BuilderMain.instance.gameData.backgroundAlias == null || BuilderMain.instance.gameData.backgroundAlias != oSelector.selectedValue)
         {
            StepManager.instance.showLoading();
            BitmapDataCollection.instance.disposeGroup(BackgroundMedia.TYPE);
            MediaManager.instance.addMediaToRender([BuilderMain.instance.mediaList.getMedia(oSelector.selectedValue)]);
            eventManager.addEventListener(sEVENT_RENDER_ID,MediaManager.instance,MediaEvent.MEDIA_ALL_RENDERED,this.onBackgroundRendered);
            MediaManager.instance.startMediaRendering();
         }
         else
         {
            super.onSelect(_e);
         }
      }
      
      private function onBackgroundRendered(_e:Event) : void
      {
         eventManager.cleanUp(sEVENT_RENDER_ID);
         BuilderManager.instance.renderer.updateCenterPos(0,0);
         BuilderMain.instance.gameData.backgroundAlias = oSelector.selectedValue;
         BuilderManager.instance.updateBackground();
         StepManager.instance.hideLoading();
         super.onSelect(null);
      }
      
      override protected function get itemHeightRatio() : Number
      {
         return 150 / 225;
      }
   }
}

