package media.type
{
   import com.sarbakan.sbdk.events.PreloadEvent;
   import sound.SfxManager;
   
   public class SfxMedia extends AbstractMedia
   {
      
      public static const TYPE:String = "sfx";
      
      public function SfxMedia(_sAlias:String, _sMediaDirectory:String)
      {
         super(_sAlias,_sMediaDirectory);
      }
      
      override public function destroy() : void
      {
         super.destroy();
      }
      
      override protected function onGameLoaded(_e:PreloadEvent) : void
      {
         super.onGameLoaded(_e);
         SfxManager.instance.soundDomain = _e.content.loaderInfo.applicationDomain;
      }
      
      override public function get type() : String
      {
         return TYPE;
      }
      
      override public function get previewSuffixe() : String
      {
         return null;
      }
   }
}

