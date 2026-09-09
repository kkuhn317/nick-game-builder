package com.sarbakan.sbdk.events
{
   import flash.events.Event;
   
   public class LocalizationEvent extends Event
   {
      
      public static const LOCALE_CHANGED:String = "sbdk_locale_changed";
      
      public static const STRING_FILE_LOADED:String = "sbdk_string_file_loaded";
      
      public static const EXTERNAL_FONTS_LOADED:String = "sbdk_external_fonts_loaded";
      
      public static const STRINGS_READY:String = "sbdk_strings_ready";
      
      private var sFile:String;
      
      public function LocalizationEvent(_sType:String, _sFile:String = null)
      {
         super(_sType,false,false);
         this.sFile = _sFile;
      }
      
      override public function clone() : Event
      {
         return new LocalizationEvent(type,this.sFile);
      }
      
      override public function toString() : String
      {
         return formatToString("LocalizationEvent","type","bubbles","cancelable","file");
      }
      
      public function get file() : String
      {
         return this.sFile;
      }
   }
}

