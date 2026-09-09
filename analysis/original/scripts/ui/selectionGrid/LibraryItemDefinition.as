package ui.selectionGrid
{
   import com.sarbakan.sbdk.math.geom.AABB2;
   import media.type.AbstractMedia;
   
   public class LibraryItemDefinition
   {
      
      private var sLinkage:String;
      
      private var oMedia:AbstractMedia;
      
      public function LibraryItemDefinition(_oMedia:AbstractMedia, _sLinkage:String = null)
      {
         super();
         this.oMedia = _oMedia;
         this.sLinkage = _sLinkage;
      }
      
      public function destroy() : void
      {
         this.oMedia = null;
      }
      
      public function get drawBounds() : AABB2
      {
         return this.oMedia.drawBounds;
      }
      
      public function get media() : AbstractMedia
      {
         return this.oMedia;
      }
      
      public function get linkage() : String
      {
         return this.sLinkage;
      }
   }
}

