package media.type
{
   import com.sarbakan.sbdk.events.PreloadEvent;
   
   public class BackgroundMedia extends AbstractMedia
   {
      
      public static const TYPE:String = "background";
      
      public static const LINKAGE_STILL:String = "mcBkg_still";
      
      public static const LINKAGE_BOTTOM_FIRST:String = "mcBkgFirst_bottom";
      
      public static const LINKAGE_BOTTOM_SECOND:String = "mcBkgSecond_bottom";
      
      public static const LINKAGE_MIDDLE_FIRST:String = "mcBkgFirst_middle";
      
      public static const LINKAGE_MIDDLE_SECOND:String = "mcBkgSecond_middle";
      
      public static const LINKAGE_TOP_FIRST:String = "mcBkgFirst_top";
      
      public static const LINKAGE_TOP_SECOND:String = "mcBkgSecond_top";
      
      public static const LINKAGE_TITLE_BACKGROUND:String = "mcTitleBackground";
      
      private static const GAME_LINKAGES:Array = [LINKAGE_STILL,LINKAGE_BOTTOM_FIRST,LINKAGE_BOTTOM_SECOND,LINKAGE_MIDDLE_FIRST,LINKAGE_MIDDLE_SECOND,LINKAGE_TOP_FIRST,LINKAGE_TOP_SECOND];
      
      private static const PREVIEW_LINKAGE:Array = [sDEFAULT_PREVIEW,LINKAGE_TITLE_BACKGROUND];
      
      public function BackgroundMedia(_sAlias:String, _sMediaDirectory:String)
      {
         super(_sAlias,_sMediaDirectory);
      }
      
      override public function destroy() : void
      {
         super.destroy();
      }
      
      override protected function onGameLoaded(_e:PreloadEvent) : void
      {
         super.onGameLoaded(_e);
         onPreviewLoaded(_e);
      }
      
      override public function get type() : String
      {
         return TYPE;
      }
      
      override public function get gameLinkages() : Array
      {
         return GAME_LINKAGES;
      }
      
      override public function get previewLinkages() : Array
      {
         return PREVIEW_LINKAGE;
      }
      
      override public function get previewSuffixe() : String
      {
         return null;
      }
      
      override public function get checkForCollider() : Boolean
      {
         return true;
      }
   }
}

