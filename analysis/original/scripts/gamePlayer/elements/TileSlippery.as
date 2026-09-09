package gamePlayer.elements
{
   import flash.geom.Point;
   import media.type.AbstractMedia;
   import utils.enum.SurfaceType;
   
   public class TileSlippery extends TileSurface
   {
      
      public function TileSlippery(_oMedia:AbstractMedia, _oPos:Point, _sLinkage:String)
      {
         super(_oMedia,_oPos,_sLinkage);
      }
      
      override public function destroy() : void
      {
         super.destroy();
      }
      
      override public function get floorType() : SurfaceType
      {
         return SurfaceType.SLIPPERY;
      }
      
      override public function get slopeType() : SurfaceType
      {
         return SurfaceType.SLIPPERY_SLOPE;
      }
   }
}

