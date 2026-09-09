package com.sarbakan.sbdk.sound.vomanager
{
   import com.sarbakan.sbdk.utils.ObjectList;
   
   public class AbstractPhonemeConverter
   {
      
      protected var lPhonemeList:ObjectList;
      
      public function AbstractPhonemeConverter()
      {
         super();
         this.initialize();
      }
      
      public function destroy() : void
      {
         this.lPhonemeList.clear();
         this.lPhonemeList.destroy();
         this.lPhonemeList = null;
      }
      
      public function setPhoneme(_sPhoneme:String, _sTargetLabel:String) : void
      {
         this.lPhonemeList.insert(_sPhoneme,_sTargetLabel);
      }
      
      public function phonemeTolabel(_sPhoneme:String) : String
      {
         return this.lPhonemeList.find(_sPhoneme);
      }
      
      protected function init() : void
      {
      }
      
      private function initialize() : void
      {
         this.lPhonemeList = new ObjectList();
         this.init();
      }
   }
}

