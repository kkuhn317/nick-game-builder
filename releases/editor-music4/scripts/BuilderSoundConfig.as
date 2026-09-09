package
{
   import flash.utils.getDefinitionByName;

   public class BuilderSoundConfig
   {
      public static const nVOLUME_DROP:Number = 0.6;
      public static const nVOLUME_GRAB:Number = 0.8;
      public static const nVOLUME_ERASE:Number = 0.9;

      // ToolManager's prototype sound handler is deliberately silent. Argument
      // evaluation happens first, so these lists must not load absent classes.
      public static function get aSND_ELEMENT_DROP() : Array
      {
         if(BuilderMain.instance.editorPrototype) return [];
         return [getDefinitionByName("sndElementDrop01"),getDefinitionByName("sndElementDrop02")];
      }
      public static function get aSND_ELEMENT_GRAB() : Array
      {
         if(BuilderMain.instance.editorPrototype) return [];
         return [getDefinitionByName("sndElementGrab01"),getDefinitionByName("sndElementGrab02")];
      }
      public static function get aSND_ELEMENT_ERASE() : Array
      {
         if(BuilderMain.instance.editorPrototype) return [];
         return [getDefinitionByName("sndElementErase01"),getDefinitionByName("sndElementErase02")];
      }
      // The original selector UI is not active; defer its assets until used.
      public static function get cSND_SELECTOR_CLICK() : Class { return getDefinitionByName("sndSelector_down") as Class; }
      public static function get cSND_SELECTOR_OVER() : Class { return getDefinitionByName("sndSelector_over") as Class; }
      public function BuilderSoundConfig() { super(); }
   }
}
