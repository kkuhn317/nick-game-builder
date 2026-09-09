package gamePlayer.elements
{
   import flash.geom.Point;
   import gamePlayer.physic.TileManager;
   import media.type.AbstractMedia;
   import utils.enum.SurfaceType;
   
   public class TilePlatform extends AbstractTileElement
   {
      
      public function TilePlatform(_oMedia:AbstractMedia, _oPos:Point, _sLinkage:String)
      {
         super(_oMedia,_oPos,_sLinkage);
      }
      
      override public function destroy() : void
      {
         super.destroy();
      }
      
      override protected function getTileType(_sLinkage:String) : uint
      {
         return TileManager.EDGES_PLATFORM;
      }
      
      override public function get floorType() : SurfaceType
      {
         return SurfaceType.PLATFORM;
      }
   }
}

