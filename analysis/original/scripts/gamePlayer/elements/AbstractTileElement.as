package gamePlayer.elements
{
   import com.sarbakan.sbdk.blitting.core.StillElement;
   import flash.geom.Point;
   import gamePlayer.physic.TileManager;
   import media.type.AbstractMedia;
   import utils.enum.SurfaceType;
   
   public class AbstractTileElement extends AbstractGameElement
   {
      
      private var oStillElement:StillElement;
      
      public function AbstractTileElement(_oMedia:AbstractMedia, _oPos:Point, _sLinkage:String)
      {
         super(_oMedia);
         TileManager.instance.addTile(this,_oPos,this.getTileType(_sLinkage));
         this.oStillElement = StillElement.fromClass(_oMedia.getClass(_sLinkage),null,_oPos.x,_oPos.y);
      }
      
      override public function destroy() : void
      {
         super.destroy();
      }
      
      protected function getTileType(_sLinkage:String) : uint
      {
         return 0;
      }
      
      public function get wallType() : SurfaceType
      {
         return SurfaceType.WALL;
      }
      
      public function get slopeType() : SurfaceType
      {
         return SurfaceType.GROUND_SLOPE;
      }
      
      public function get floorType() : SurfaceType
      {
         return SurfaceType.GROUND;
      }
      
      public function get ceillingType() : SurfaceType
      {
         return SurfaceType.CEILING;
      }
      
      public function get stillElement() : StillElement
      {
         return this.oStillElement;
      }
   }
}

