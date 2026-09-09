package com.sarbakan.sbdk.asset
{
   import flash.media.Sound;
   
   public class SoundAsset extends AbstractAsset
   {
      
      private var sndRef:Sound;
      
      public function SoundAsset(_sID:String, _sndRef:Sound)
      {
         super(_sID);
         this.sndRef = _sndRef;
      }
      
      override public function destroy() : void
      {
         super.destroy();
      }
      
      public function get content() : Sound
      {
         return this.sndRef;
      }
   }
}

