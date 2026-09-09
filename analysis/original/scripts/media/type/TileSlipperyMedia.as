package media.type
{
   import com.sarbakan.sbdk.math.geom.AABB2;
   
   public class TileSlipperyMedia extends AbstractTileMedia
   {
      
      public static const TYPE:String = "tileSlippery";
      
      private static const GAME_LINKAGES:Array = ["mcPlatform_tile00","mcPlatform_tile01","mcPlatform_tile02","mcPlatform_tile03","mcPlatform_tile04","mcPlatform_tile05","mcPlatform_tile06","mcPlatform_tile07","mcPlatform_tile08","mcPlatform_tile09","mcPlatform_tile10","mcPlatform_tile11","mcPlatform_tile12","mcPlatform_tile13","mcPlatform_tile14"];
      
      private static const PREVIEW_LINKAGES:Array = ["mcPlatform_tile01","mcPlatform_tile04"];
      
      public function TileSlipperyMedia(_sAlias:String, _sMediaDirectory:String)
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

