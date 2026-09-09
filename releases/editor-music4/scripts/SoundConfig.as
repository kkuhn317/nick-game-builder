package
{
   import flash.utils.getDefinitionByName;

   public class SoundConfig
   {
      public static const sSOUND_CATEGORY_MUSIC:String = "sndCatMusic";
      public static const sSOUND_CATEGORY_SOUNDS:String = "sndCatSounds";
      public static const nMUSIC_SWITCH_FADE_DURATION:Number = 500;
      public static const nDEFAULT_VOLUME_MUSIC:Number = 0.7;
      public static const nDEFAULT_VOLUME_SOUNDS:Number = 1;

      // Resolve UI assets only if a caller actually requests them. Music and
      // teardown must not initialize missing mouse/popup sound classes.
      // Missing assets still fail explicitly when requested; no dummy sounds.
      public static function get cSFX_MOUSE_ROLL() : Class { return getDefinitionByName("sndMouseRoll") as Class; }
      public static function get cSFX_MOUSE_CLICK() : Class { return getDefinitionByName("sndMouseClick") as Class; }
      public static function get cSFX_POPUP_IN() : Class { return getDefinitionByName("sndPopupIn") as Class; }
      public static function get cSFX_POPUP_OUT() : Class { return getDefinitionByName("sndPopupOut") as Class; }

      public static const sSFX_TRANSITION_IN:String = "sndTransitionIn";
      public static const sSFX_TRANSITION_OUT:String = "sndTransitionOut";
      public function SoundConfig() { super(); }
   }
}
