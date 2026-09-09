package com.sarbakan.sbdk.localization
{
   import com.sarbakan.sbdk.utils.StringUtils;
   
   public class LocalizedString
   {
      
      private var sString:String;
      
      private var sFontName:String;
      
      private var nFontSize:uint;
      
      private var nCharSpace:uint;
      
      private var nLineSpace:uint;
      
      public function LocalizedString(_sString:String, _sFontName:String = null, _nFontSize:uint = 0, _nCharSpace:uint = 0, _nLineSpace:uint = 0)
      {
         super();
         this.sString = _sString;
         this.sFontName = _sFontName;
         this.nFontSize = _nFontSize;
         this.nCharSpace = _nCharSpace;
         this.nLineSpace = _nLineSpace;
      }
      
      public function toString() : String
      {
         return this.sString;
      }
      
      public function getReplacedString(_oReplacements:Object) : LocalizedString
      {
         var _sKeyword:String = null;
         var _sString:String = this.sString;
         for(_sKeyword in _oReplacements)
         {
            _sString = StringUtils.replace(_sString,_sKeyword,_oReplacements[_sKeyword]);
         }
         return new LocalizedString(_sString,this.sFontName,this.nFontSize,this.nCharSpace,this.nLineSpace);
      }
      
      public function get string() : String
      {
         return this.sString;
      }
      
      public function get fontName() : String
      {
         return this.sFontName;
      }
      
      public function get fontSize() : uint
      {
         return this.nFontSize;
      }
      
      public function get charSpace() : uint
      {
         return this.nCharSpace;
      }
      
      public function get lineSpace() : uint
      {
         return this.nLineSpace;
      }
   }
}

