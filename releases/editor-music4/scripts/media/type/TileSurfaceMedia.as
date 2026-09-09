package media.type
{
   import com.sarbakan.sbdk.math.geom.AABB2;
   import com.sarbakan.sbdk.blitting.core.BitmapDataCollection;
   import flash.display.BitmapData;
   import flash.geom.Rectangle;
   
   public class TileSurfaceMedia extends AbstractTileMedia
   {
      
      public static const TYPE:String = "tileSurface";
      
      public static const FULL_LINKAGES:Array = ["mcPlatform_tile00","mcPlatform_tile01","mcPlatform_tile02","mcPlatform_tile03","mcPlatform_tile06","mcPlatform_tile07","mcPlatform_tile10","mcPlatform_tile11","mcPlatform_tile12"];
      
      public static const SLOPE_LINKAGES:Array = ["mcPlatform_tile04","mcPlatform_tile05","mcPlatform_tile08","mcPlatform_tile09","mcPlatform_tile13","mcPlatform_tile14"];
      
      private static const GAME_LINKAGES:Array = FULL_LINKAGES.concat(SLOPE_LINKAGES);
      
      private static const PREVIEW_LINKAGES:Array = ["mcPlatform_tile01","mcPlatform_tile04"];
      
      public function TileSurfaceMedia(_sAlias:String, _sMediaDirectory:String)
      {
         super(_sAlias,_sMediaDirectory);
         if(_sAlias == "__editor_floor")
         {
            for each(var symbol:String in FULL_LINKAGES.concat(SLOPE_LINKAGES)) lClass.insert(symbol,EditorTilePose);
            lClass.insert("mcPreview",EditorTilePose);
            // StillElement.fromClass requires a frame in the original bitmap cache.
            var pixels:BitmapData=new BitmapData(30,30,true,0);
            pixels.draw(new EditorTilePose());
            BitmapDataCollection.instance.insertData(TYPE,EditorTilePose,null,1,pixels,new Rectangle(0,0,30,30),new Rectangle(0,0,30,30),Math.sqrt(450),Math.PI/4,null,null,false);
            bGameLoaded = true;
         }
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


import flash.display.MovieClip;
class EditorTilePose extends MovieClip {
 public function EditorTilePose() { super(); graphics.beginFill(0x32556A); graphics.drawRect(0,0,30,30); graphics.endFill(); graphics.beginFill(0x60C8A0); graphics.drawRect(0,0,30,4); graphics.endFill(); }
}
