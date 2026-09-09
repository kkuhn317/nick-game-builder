package gamePlayer.elements
{
   import media.type.AbstractMedia;
   
   public class AbstractGameElement
   {
      
      protected var oMedia:AbstractMedia;
      
      public function AbstractGameElement(_oMedia:AbstractMedia)
      {
         super();
         this.oMedia = _oMedia;
      }
      
      public function destroy() : void
      {
         this.oMedia = null;
      }
      
      public function get type() : String
      {
         return this.oMedia.type;
      }
   }
}

