package
{
   public class BuilderSoundConfig
   {
      
      public static const nVOLUME_DROP:Number = 0.6;
      
      public static const aSND_ELEMENT_DROP:Array = [sndElementDrop01,sndElementDrop02];
      
      public static const nVOLUME_GRAB:Number = 0.8;
      
      public static const aSND_ELEMENT_GRAB:Array = [sndElementGrab01,sndElementGrab02];
      
      public static const nVOLUME_ERASE:Number = 0.9;
      
      public static const aSND_ELEMENT_ERASE:Array = [sndElementErase01,sndElementErase02];
      
      public static const cSND_SELECTOR_CLICK:Class = sndSelector_down;
      
      public static const cSND_SELECTOR_OVER:Class = sndSelector_over;
      
      public function BuilderSoundConfig()
      {
         super();
      }
   }
}

