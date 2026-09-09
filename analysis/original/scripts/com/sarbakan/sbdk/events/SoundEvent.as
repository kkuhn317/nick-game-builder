package com.sarbakan.sbdk.events
{
   import com.sarbakan.sbdk.sound.SoundUnit;
   import flash.events.Event;
   
   public class SoundEvent extends Event
   {
      
      public static const READY:String = "sbdk_ready";
      
      public static const COMPLETED:String = "sbdk_completed";
      
      public static const DESTROYED:String = "sbdk_destroyed";
      
      public static const FADE_VOLUME_COMPLETED:String = "sbdk_fade_volume_completed";
      
      public static const FADE_PAN_COMPLETED:String = "sbdk_fade_pan_completed";
      
      public static const ALL_SOUND_CHANNELS_USED:String = "sbdk-all_sound_channels_used";
      
      private var oSoundUnit:SoundUnit;
      
      public function SoundEvent(_sType:String, _bBubbles:Boolean, _bCancelable:Boolean, _oSoundUnit:SoundUnit)
      {
         super(_sType,_bBubbles,_bCancelable);
         this.oSoundUnit = _oSoundUnit;
      }
      
      override public function clone() : Event
      {
         return new SoundEvent(type,bubbles,cancelable,this.oSoundUnit);
      }
      
      override public function toString() : String
      {
         return formatToString("SoundEvent","type","bubbles","cancelable","soundUnit");
      }
      
      public function get soundUnit() : SoundUnit
      {
         return this.oSoundUnit;
      }
   }
}

