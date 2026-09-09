package gamePlayer.elements
{
   import com.sarbakan.sbdk.blitting.core.StillElement;
   import flash.geom.Point;
   import gamePlayer.physic.TileManager;
   import media.type.AbstractMedia;
   import media.type.PlatformObjectMedia;
   
   public class PlatformObject extends AbstractGameElement
   {
      
      private var oStillElement:StillElement;
      
      public function PlatformObject(_oMedia:AbstractMedia, _oPos:Point)
      {
         super(_oMedia);
         this.oStillElement = StillElement.fromClass(_oMedia.getClass(PlatformObjectMedia.LINKAGE_PROPS),null,_oPos.x,_oPos.y);
         TileManager.instance.addPlatformObject(_oPos,this.oStillElement.width);
      }
      
      override public function destroy() : void
      {
         super.destroy();
      }
      
      public function get stillElement() : StillElement
      {
         return this.oStillElement;
      }
   }
}

