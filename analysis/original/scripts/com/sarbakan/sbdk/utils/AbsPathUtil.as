package com.sarbakan.sbdk.utils
{
   public class AbsPathUtil
   {
      
      public function AbsPathUtil()
      {
         super();
      }
      
      public static function getPath(_sURL:String) : String
      {
         var _nLastChar:int = 0;
         if(_sURL.lastIndexOf(".") != -1)
         {
            _sURL = _sURL.substr(0,_sURL.lastIndexOf("."));
         }
         if(_sURL.lastIndexOf("/") == -1)
         {
            _nLastChar = _sURL.lastIndexOf("\\");
         }
         else
         {
            _nLastChar = _sURL.lastIndexOf("/");
            if(_nLastChar <= 10)
            {
               _nLastChar = _sURL.lastIndexOf("\\");
            }
         }
         return _sURL.substring(0,_nLastChar + 1);
      }
      
      public static function parseAbsoluteURL(_sUrl:String) : String
      {
         var _nPosDot:int = 0;
         var _nPosParent:int = 0;
         while(true)
         {
            _nPosDot = _sUrl.indexOf("../");
            if(_nPosDot == -1)
            {
               break;
            }
            _nPosParent = _sUrl.lastIndexOf("/",_nPosDot - 2);
            _sUrl = _sUrl.substr(0,_nPosParent + 1) + _sUrl.substr(_nPosDot + 3);
         }
         return _sUrl;
      }
   }
}

