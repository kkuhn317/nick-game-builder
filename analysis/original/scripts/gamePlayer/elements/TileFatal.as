package gamePlayer.elements
{
   import flash.geom.Point;
   import gamePlayer.physic.TileManager;
   import media.type.AbstractMedia;
   import utils.enum.SurfaceType;
   
   public class TileFatal extends AbstractTileElement
   {
      
      public function TileFatal(_oMedia:AbstractMedia, _oPos:Point, _sLinkage:String)
      {
         super(_oMedia,_oPos,_sLinkage);
      }
      
      override public function destroy() : void
      {
         super.destroy();
      }
      
      override protected function getTileType(_sLinkage:String) : uint
      {
         return TileManager.EDGES_FULL;
      }
      
      override public function get wallType() : SurfaceType
      {
         return SurfaceType.FATAL_WALL;
      }
      
      override public function get floorType() : SurfaceType
      {
         return SurfaceType.FATAL_FLOOR;
      }
      
      override public function get slopeType() : SurfaceType
      {
         return SurfaceType.FATAL_FLOOR;
      }
      
      override public function get ceillingType() : SurfaceType
      {
         return SurfaceType.FATAL_CEILING;
      }
   }
}

