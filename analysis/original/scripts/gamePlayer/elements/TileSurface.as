package gamePlayer.elements
{
   import flash.geom.Point;
   import gamePlayer.physic.TileManager;
   import media.type.AbstractMedia;
   
   public class TileSurface extends AbstractTileElement
   {
      
      public function TileSurface(_oMedia:AbstractMedia, _oPos:Point, _sLinkage:String)
      {
         super(_oMedia,_oPos,_sLinkage);
      }
      
      override public function destroy() : void
      {
         super.destroy();
      }
      
      override protected function getTileType(_sLinkage:String) : uint
      {
         var _nType:uint = 0;
         switch(_sLinkage)
         {
            case "mcPlatform_tile00":
            case "mcPlatform_tile01":
            case "mcPlatform_tile02":
            case "mcPlatform_tile03":
            case "mcPlatform_tile06":
            case "mcPlatform_tile07":
            case "mcPlatform_tile10":
            case "mcPlatform_tile11":
            case "mcPlatform_tile12":
               _nType = TileManager.EDGES_FULL;
               break;
            case "mcPlatform_tile04":
               _nType = TileManager.EDGES_TOP_ASCENDING;
               break;
            case "mcPlatform_tile05":
               _nType = TileManager.EDGES_TOP_DESCENDING;
               break;
            case "mcPlatform_tile08":
            case "mcPlatform_tile13":
               _nType = TileManager.EDGES_BOTTOM_DESCENDING;
               break;
            case "mcPlatform_tile09":
            case "mcPlatform_tile14":
               _nType = TileManager.EDGES_BOTTOM_ASCENDING;
         }
         return _nType;
      }
   }
}

