package ui.screens
{
   import com.sarbakan.sbdk.localization.LocalizationManager;
   import data.GameData;
   import flash.display.MovieClip;
   import media.MediaList;
   import media.type.BackgroundMedia;
   import media.type.PlayableCharacterMedia;
   
   public class TheaterScreenLayout
   {
      
      public var mcContent:MovieClip;
      
      public function TheaterScreenLayout(_oGameData:GameData, _oMediaList:MediaList)
      {
         super();
         this.mcContent = new mcGenericScreenLayout();
         this.displayBkg(_oMediaList.getMedia(_oGameData.backgroundAlias) as BackgroundMedia);
         this.displayPlayer(_oMediaList.getMedia(_oGameData.heroAlias) as PlayableCharacterMedia);
         this.displayShowLogo();
      }
      
      public function destroy() : void
      {
         this.mcContent = null;
      }
      
      public function setTitleLocale(_sLocale:String, _oReplacement:Object = null) : void
      {
         LocalizationManager.instance.setTextField(this.mcContent.mcTitle.txtText,_sLocale,_oReplacement);
      }
      
      private function displayBkg(_oMedia:BackgroundMedia) : void
      {
         var _cBkgClass:Class = _oMedia.getClass(BackgroundMedia.LINKAGE_TITLE_BACKGROUND);
         var _mcBkg:MovieClip = new _cBkgClass();
         this.mcContent.addChildAt(_mcBkg,0);
      }
      
      private function displayPlayer(_oMedia:PlayableCharacterMedia) : void
      {
         var _mcPlaceholder:MovieClip = this.mcContent.mcHero;
         var _cPlayerClass:Class = _oMedia.getClass(PlayableCharacterMedia.LINKAGE_TITLE_CHARACTER);
         var _mcPlayer:MovieClip = new _cPlayerClass();
         _mcPlayer.x = _mcPlaceholder.x;
         _mcPlayer.y = _mcPlaceholder.y;
         this.mcContent.addChildAt(_mcPlayer,this.mcContent.getChildIndex(_mcPlaceholder));
         this.mcContent.removeChild(_mcPlaceholder);
      }
      
      private function displayShowLogo() : void
      {
         this.mcContent.addChild(new mcShowLogo());
      }
   }
}

