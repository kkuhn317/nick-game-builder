package media.type
{
   import com.sarbakan.sbdk.events.PreloadEvent;
   import flash.system.ApplicationDomain;
   
   public class MusicMedia extends AbstractMedia
   {
      
      public static const TYPE:String = "music";
      
      public static const GAME_LINKAGE:String = "gameMusic";
      
      public static const PREVIEW_LINKAGE:String = "musicPreview";
      
      public function MusicMedia(_sAlias:String, _sMediaDirectory:String)
      {
         super(_sAlias,_sMediaDirectory);
      }
      
      override public function destroy() : void
      {
         super.destroy();
      }
      
      override protected function onGameLoaded(_e:PreloadEvent) : void
      {
         bGameLoaded = true;
         var _oDomain:ApplicationDomain = _e.content.loaderInfo.applicationDomain;
         lClass.insert(GAME_LINKAGE,_oDomain.getDefinition(GAME_LINKAGE));
      }
      
      override protected function onPreviewLoaded(_e:PreloadEvent) : void
      {
         bPreviewLoaded = true;
         var _oDomain:ApplicationDomain = _e.content.loaderInfo.applicationDomain;
         lClass.insert(PREVIEW_LINKAGE,_oDomain.getDefinition(PREVIEW_LINKAGE));
      }
      
      override public function get type() : String
      {
         return TYPE;
      }
      
      override public function get gameLinkages() : Array
      {
         return null;
      }
      
      override public function get previewLinkages() : Array
      {
         return null;
      }
   }
}

