package media.type
{
   public class PlatformObjectMedia extends AbstractMedia
   {
      
      public static const TYPE:String = "platformObject";
      
      public static const LINKAGE_PROPS:String = "mcProps";
      
      private static const GAME_LINKAGES:Array = [LINKAGE_PROPS];
      
      private static const PREVIEW_LINKAGES:Array = [LINKAGE_PROPS];
      
      public function PlatformObjectMedia(_sAlias:String, _sMediaDirectory:String)
      {
         super(_sAlias,_sMediaDirectory);
      }
      
      override public function destroy() : void
      {
         super.destroy();
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
         return PREVIEW_LINKAGES;
      }
      
      override public function get previewSuffixe() : String
      {
         return null;
      }
   }
}

