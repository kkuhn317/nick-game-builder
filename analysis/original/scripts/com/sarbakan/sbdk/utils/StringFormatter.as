package com.sarbakan.sbdk.utils
{
   import com.sarbakan.sbdk.math.SBKMath;
   import flash.events.*;
   
   public class StringFormatter
   {
      
      private static var nMAX_LETTERS:Number = 2;
      
      private static var nASCII_0:uint = 48;
      
      private static var nASCII_9:uint = 57;
      
      private static var nASCII_A:uint = 65;
      
      private static var nASCII_Z:uint = 90;
      
      private static var nASCII_a:uint = 97;
      
      private static var nASCII_z:uint = 122;
      
      private static var nASCII_HYPHEN:uint = 45;
      
      private static var nASCII_APOSTROFE:uint = 39;
      
      private static var nASCII_STRESSED:uint = 95;
      
      private static var nKILOBYTE:Number = 1024;
      
      private static var nMEGABYTE:Number = 1048576;
      
      private static var nGIGABYTE:Number = 1073741824;
      
      private static var nTERABYTE:Number = 1099511627776;
      
      public function StringFormatter()
      {
         super();
      }
      
      public static function formatTime(_nTime:uint, _sSeparator:String = ":") : String
      {
         var _nTotalSec:uint = _nTime / 1000;
         var _sMinute:String = String(Math.floor(_nTotalSec / 60));
         var _sSecond:String = String(Math.round(_nTotalSec - uint(_sMinute) * 60));
         if(uint(_sMinute) < 10)
         {
            _sMinute = "0" + _sMinute;
         }
         if(uint(_sSecond) < 10)
         {
            _sSecond = "0" + _sSecond;
         }
         return _sMinute + _sSeparator + _sSecond;
      }
      
      public static function formatNumber(_nNumber:Number, _sDecimalSeparator:String, _sThousandSeparator:String) : String
      {
         var _sChar:String = null;
         var _sFinal:String = "";
         var _bNegative:Boolean = _nNumber < 0;
         var _sNumber:String = String(Math.floor(Math.abs(_nNumber)));
         var _nLength:uint = uint(_sNumber.length);
         var _sDecimal:String = String(_nNumber).slice(_nLength + 1);
         var j:uint = 3 - _nLength % 3;
         if(j == 3)
         {
            j = 0;
         }
         for(var i:uint = 0; i < _nLength; i++)
         {
            _sChar = _sNumber.charAt(i);
            if(j == 3)
            {
               j = 0;
               _sFinal += _sThousandSeparator;
            }
            _sFinal += _sChar;
            j++;
         }
         if(_sDecimal.length > 0)
         {
            _sFinal += _sDecimalSeparator + _sDecimal;
         }
         if(_bNegative)
         {
            _sFinal = "-" + _sFinal;
         }
         return _sFinal;
      }
      
      public static function formatByte(_nNumber:Number, _nDecimalPrecision:uint = 0) : String
      {
         var _sReturnValue:String = "";
         if(_nNumber >= 0 && _nNumber < nKILOBYTE)
         {
            return String(SBKMath.roundDecPl(_nNumber,_nDecimalPrecision)) + " byte";
         }
         if(_nNumber >= nKILOBYTE && _nNumber < nMEGABYTE)
         {
            _nNumber /= nKILOBYTE;
            return String(SBKMath.roundDecPl(_nNumber,_nDecimalPrecision)) + " KB";
         }
         if(_nNumber >= nMEGABYTE && _nNumber < nGIGABYTE)
         {
            _nNumber /= nMEGABYTE;
            return String(SBKMath.roundDecPl(_nNumber,_nDecimalPrecision)) + " MB";
         }
         if(_nNumber >= nGIGABYTE && _nNumber < nTERABYTE)
         {
            _nNumber /= nGIGABYTE;
            return String(SBKMath.roundDecPl(_nNumber,_nDecimalPrecision)) + " GB";
         }
         if(_nNumber >= nTERABYTE)
         {
            _nNumber /= nTERABYTE;
            return String(SBKMath.roundDecPl(_nNumber,_nDecimalPrecision)) + " TB";
         }
         return null;
      }
      
      public static function formatDate(_oDate:Date, _sFormat:String) : String
      {
         var _sChar:String = null;
         var _nNextCharCode:uint = 0;
         var _nBegin:uint = 0;
         var _nEnd:uint = 0;
         var j:uint = 0;
         var _nCharCode:uint = 32;
         var _sFinal:String = "";
         var _bLetter:Boolean = false;
         var _nLength:uint = uint(_sFormat.length);
         for(var i:uint = 0; i < _nLength; i++)
         {
            _nCharCode = _sFormat.charCodeAt(i);
            if(validWordChar(_nCharCode))
            {
               _nBegin = i;
               _sChar = _sFormat.charAt(i);
               j = 0;
               while(j < nMAX_LETTERS && validateFormatChar(_sChar) != false)
               {
                  i++;
                  j++;
                  _sChar = _sFormat.charAt(i);
               }
               _nEnd = i;
               _nCharCode = _sFormat.charCodeAt(i);
               if(!validWordChar(_nCharCode))
               {
                  for(j = _nBegin; j < _nEnd; j++)
                  {
                     _sChar = _sFormat.charAt(j);
                     _sFinal += format(_oDate,_sChar);
                  }
               }
               else
               {
                  for(j = _nBegin; j < _nEnd; j++)
                  {
                     _sChar = _sFormat.charAt(j);
                     _sFinal += _sChar;
                  }
                  while(validWordChar(_nCharCode))
                  {
                     _sChar = _sFormat.charAt(i);
                     _sFinal += _sChar;
                     i++;
                     _nCharCode = _sFormat.charCodeAt(i);
                  }
               }
            }
            _sChar = _sFormat.charAt(i);
            _sFinal += _sChar;
         }
         return _sFinal;
      }
      
      private static function format(_oDate:Date, _sFormat:String) : String
      {
         var _nMonth:uint = 0;
         var _aMonth:Array = null;
         var _nDay:uint = 0;
         var _aDay:Array = null;
         var _nHours:uint = 0;
         var _sYear:String = null;
         var _nLength:uint = 0;
         var _nDate:uint = 0;
         var _nTotalDay:uint = 0;
         var _nMin:uint = 0;
         var _nSec:uint = 0;
         var _nYear:uint = 0;
         switch(_sFormat)
         {
            case "j":
               return String(_oDate.date);
            case "n":
               return String(_oDate.month + 1);
            case "m":
               _nMonth = _oDate.month + 1;
               if(_nMonth < 10)
               {
                  return String("0" + _nMonth);
               }
               return String(_nMonth);
               break;
            case "F":
               _nMonth = _oDate.month;
               _aMonth = new Array("January","February","March","April","May","June","July","August","September","October","November","December");
               return _aMonth[_nMonth];
            case "M":
               _nMonth = _oDate.month;
               _aMonth = new Array("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
               return _aMonth[_nMonth];
            case "y":
               _sYear = String(_oDate.getFullYear());
               _nLength = uint(_sYear.length);
               return _sYear.charAt(_nLength - 2) + _sYear.charAt(_nLength - 1);
            case "Y":
               return String(_oDate.fullYear);
            case "S":
               return StringUtils.getOrdinalSuffix(_oDate.date);
            case "d":
               _nDate = _oDate.date;
               if(_nDate < 10)
               {
                  return String("0" + _nDate);
               }
               return String(_nDate);
               break;
            case "l":
               _nDay = _oDate.day;
               _aDay = new Array("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday");
               return _aDay[_nDay];
            case "D":
               _nDay = _oDate.day;
               _aDay = new Array("Sun","Mon","Tue","Wed","Thu","Fri","Sat");
               return _aDay[_nDay];
            case "N":
               _nDay = _oDate.day;
               if(_nDay == 0)
               {
                  _nDay = 7;
               }
               return String(_nDay);
            case "w":
               return String(_oDate.day);
            case "t":
               _nMonth = _oDate.month;
               if(_nMonth == 1)
               {
                  _nYear = _oDate.fullYear;
                  if(_nYear % 4 == 0 && _nYear % 100 != 0 || _nYear % 400 == 0)
                  {
                     _nTotalDay = 29;
                  }
                  else
                  {
                     _nTotalDay = 28;
                  }
               }
               else
               {
                  _aMonth = new Array(31,28,31,30,31,30,31,31,30,31,30,31);
                  _nTotalDay = uint(_aMonth[_nMonth]);
               }
               return String(_nTotalDay);
            case "a":
               if(_oDate.hours >= 12)
               {
                  return "pm";
               }
               return "am";
               break;
            case "A":
               if(_oDate.hours >= 12)
               {
                  return "PM";
               }
               return "AM";
               break;
            case "g":
               _nHours = _oDate.hours;
               if(_nHours == 0)
               {
                  _nHours = 24;
               }
               if(_nHours > 12)
               {
                  _nHours -= 12;
               }
               return String(_nHours);
            case "G":
               return String(_oDate.hours);
            case "h":
               _nHours = _oDate.hours;
               if(_nHours == 0)
               {
                  _nHours = 24;
               }
               if(_nHours > 12)
               {
                  _nHours -= 12;
               }
               if(_nHours < 10)
               {
                  return "0" + String(_nHours);
               }
               return String(_nHours);
               break;
            case "H":
               _nHours = _oDate.hours;
               if(_nHours < 10)
               {
                  return "0" + String(_nHours);
               }
               return String(_nHours);
               break;
            case "i":
               _nMin = _oDate.minutes;
               if(_nMin < 10)
               {
                  return "0" + String(_nMin);
               }
               return String(_nMin);
               break;
            case "s":
               _nSec = _oDate.seconds;
               if(_nSec < 10)
               {
                  return "0" + String(_nSec);
               }
               return String(_nSec);
               break;
            case "u":
               return String(_oDate.milliseconds);
            default:
               return null;
         }
      }
      
      private static function validateFormatChar(_sChar:String) : Boolean
      {
         switch(_sChar)
         {
            case "j":
            case "n":
            case "m":
            case "F":
            case "M":
            case "y":
            case "Y":
            case "S":
            case "d":
            case "l":
            case "D":
            case "N":
            case "w":
            case "T":
            case "a":
            case "A":
            case "g":
            case "G":
            case "h":
            case "H":
            case "i":
            case "s":
            case "u":
            case "t":
               return true;
            default:
               return false;
         }
      }
      
      private static function validWordChar(_nCharCode:uint) : Boolean
      {
         if((_nCharCode < nASCII_0 || _nCharCode > nASCII_Z && _nCharCode < nASCII_a || _nCharCode > nASCII_9 && _nCharCode < nASCII_A) && _nCharCode != nASCII_APOSTROFE && _nCharCode != nASCII_HYPHEN && _nCharCode != nASCII_STRESSED)
         {
            return false;
         }
         return true;
      }
   }
}

