package media.type
{
   import com.sarbakan.sbdk.math.geom.AABB2;
   
   public class TilePlatformMedia extends AbstractTileMedia
   {
      
      public static const TYPE:String = "tilePlatform";
      
      private static const GAME_LINKAGES:Array = ["mcPlatform_tile00","mcPlatform_tile01","mcPlatform_tile02","mcPlatform_tile03"];
      
      private static const PREVIEW_LINKAGES:Array = ["mcPlatform_tile03"];
      
      public function TilePlatformMedia(_sAlias:String, _sMediaDirectory:String)
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
      
      override public function get drawBounds() : AABB2
      {
         if(oDrawBounds == null)
         {
            oDrawBounds = new AABB2(0,CommonConfig.nCELL_SIZE,0,CommonConfig.nCELL_SIZE);
         }
         return oDrawBounds;
      }
   }
}

