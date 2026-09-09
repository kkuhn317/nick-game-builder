package ui.selectionPopup
{
   import com.sarbakan.sbdk.localization.LocalizationManager;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.filters.ColorMatrixFilter;
   import media.type.MusicMedia;
   import sound.SfxManager;
   import utils.ColorMatrix;
   
   public class MusicSelectionPopup extends AbstractSelectionPopup
   {
      
      public function MusicSelectionPopup()
      {
         super();
      }
      
      override public function destroy() : void
      {
         super.destroy();
      }
      
      override public function onHide() : void
      {
         var _oMedia:MusicMedia = null;
         if(Boolean(BuilderMain.instance.gameData.musicAlias))
         {
            _oMedia = BuilderMain.instance.mediaList.getMedia(BuilderMain.instance.gameData.musicAlias) as MusicMedia;
            SfxManager.instance.playMusic(_oMedia);
         }
         super.onHide();
      }
      
      override protected function initSelector() : void
      {
         super.initSelector();
         var _aMusics:Array = BuilderMain.instance.mediaList.getMediaFromType([MusicMedia.TYPE]);
         _aMusics.sortOn("alias");
         for(var i:uint = 0; i < _aMusics.length; i++)
         {
            oSelector.addItem(null,MusicMedia(_aMusics[i]).alias,this.getMusicButton(i,_aMusics.length));
         }
         oSelector.selectedValue = BuilderMain.instance.gameData.musicAlias;
      }
      
      private function getMusicButton(_nIndex:uint, _nTotal:uint) : MovieClip
      {
         var _nHue:Number = _nIndex / _nTotal * 360 - 180;
         var _oMatrix:ColorMatrix = new ColorMatrix();
         _oMatrix.adjustColor(BuilderConfig.nMUSIC_BRIGHTNESS,BuilderConfig.nMUSIC_CONTRAST,BuilderConfig.nMUSIC_SATURATION,_nHue);
         var _mcButton:MovieClip = new mcMusicButton();
         _mcButton.filters = [new ColorMatrixFilter(_oMatrix)];
         LocalizationManager.instance.setTextField(_mcButton.txtId,"id_ui_step_music_id",{"$value$":_nIndex + 1});
         return _mcButton;
      }
      
      override protected function onSelect(_e:Event) : void
      {
         var _oMedia:MusicMedia = BuilderMain.instance.mediaList.getMedia(oSelector.selectedValue) as MusicMedia;
         if(Boolean(_oMedia))
         {
            SfxManager.instance.playMusic(_oMedia,true);
         }
         BuilderMain.instance.gameData.musicAlias = oSelector.selectedValue;
         super.onSelect(_e);
      }
   }
}

