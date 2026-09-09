package com.sarbakan.sbdk.utils
{
   import com.sarbakan.sbdk.math.random.Random;
   import flash.events.*;
   
   public class StringUtils
   {
      
      private static var nASCII_0:uint = 48;
      
      private static var nASCII_9:uint = 57;
      
      private static var nASCII_A:uint = 65;
      
      private static var nASCII_Z:uint = 90;
      
      private static var nASCII_a:uint = 97;
      
      private static var nASCII_z:uint = 122;
      
      private static var nASCII_HYPHEN:uint = 45;
      
      private static var nASCII_APOSTROFE:uint = 39;
      
      private static var nASCII_STRESSED:uint = 95;
      
      public function StringUtils()
      {
         super();
      }
      
      public static function lowerFirstChar(_sString:String) : String
      {
         var _sFirtChar:String = _sString.charAt(0);
         _sFirtChar = _sFirtChar.toLowerCase();
         var _endString:String = _sString.substr(1);
         return _sFirtChar + _endString;
      }
      
      public static function upperFirstChar(_sString:String) : String
      {
         var _sFirtChar:String = _sString.charAt(0);
         _sFirtChar = _sFirtChar.toUpperCase();
         var _endString:String = _sString.substr(1);
         return _sFirtChar + _endString;
      }
      
      public static function trim(_sString:String, _oStringDirection:StringDirection) : String
      {
         var i:uint = 0;
         if(_oStringDirection == StringDirection.LEFT || _oStringDirection == StringDirection.BOTH)
         {
            i = 0;
            while(_sString.charAt(i) == " ")
            {
               i++;
            }
            _sString = _sString.substr(i);
         }
         if(_oStringDirection == StringDirection.RIGHT || _oStringDirection == StringDirection.BOTH)
         {
            i = _sString.length - 1;
            while(_sString.charAt(i) == " ")
            {
               i--;
            }
            _sString = _sString.substr(0,i + 1);
         }
         return _sString;
      }
      
      public static function pad(_sString:String, _nPadLenght:int, _sPad:String, _oStringDirection:StringDirection) : String
      {
         _nPadLenght -= _sString.length;
         if(_nPadLenght > 0)
         {
            switch(_oStringDirection)
            {
               case StringDirection.LEFT:
                  return padLeft(_nPadLenght,_sPad) + _sString;
               case StringDirection.RIGHT:
                  return _sString + padRight(_nPadLenght,_sPad);
               case StringDirection.BOTH:
                  return padLeft(Math.ceil(_nPadLenght / 2),_sPad) + _sString + padRight(Math.floor(_nPadLenght / 2),_sPad);
            }
         }
         return _sString;
      }
      
      private static function padLeft(_nPadLenght:int, _sPad:String) : String
      {
         var _sChar:String = null;
         var _sLeftPadding:String = "";
         var j:uint = 0;
         for(var i:uint = 0; i < _nPadLenght; i++)
         {
            _sChar = _sPad.charAt(j);
            if(_sChar == "")
            {
               j = 0;
               _sChar = _sPad.charAt(j);
            }
            _sLeftPadding += _sChar;
            j++;
         }
         return _sLeftPadding;
      }
      
      private static function padRight(_nPadLenght:int, _sPad:String) : String
      {
         var _sChar:String = null;
         var _sRightPadding:String = "";
         var j:uint = 0;
         for(var i:uint = 0; i < _nPadLenght; i++)
         {
            _sChar = _sPad.charAt(j);
            if(_sChar == "")
            {
               j = 0;
               _sChar = _sPad.charAt(j);
            }
            _sRightPadding += _sChar;
            j++;
         }
         return _sRightPadding;
      }
      
      public static function repeat(_sString:String, _nMultiplier:uint) : String
      {
         var _sRepeat:String = _sString;
         for(var i:uint = 1; i < _nMultiplier; i++)
         {
            _sString += _sRepeat;
         }
         return _sString;
      }
      
      public static function shuffle(_sString:String) : String
      {
         var i:int = 0;
         var _nRandom:uint = 0;
         var _sShuffle:String = "";
         var _length:uint = uint(_sString.length);
         var _aShuffle:Array = new Array();
         for(i = 0; i < _length; i++)
         {
            _aShuffle.push(_sString.charAt(i));
         }
         for(i = 0; i < _length; i++)
         {
            _nRandom = uint(Random.getInt(0,_aShuffle.length - 1));
            _sShuffle += _aShuffle[_nRandom];
            _aShuffle.splice(_nRandom,1);
         }
         return _sShuffle;
      }
      
      public static function wordCount(_sString:String) : uint
      {
         var _bSpace:Boolean = false;
         var _sChar:String = null;
         var _nCharCode:uint = 0;
         var _nCount:uint = 0;
         _nCharCode = _sString.charCodeAt(0);
         if(!validWordChar(_nCharCode))
         {
            _bSpace = true;
         }
         else
         {
            _bSpace = false;
            _nCount++;
         }
         var _nlength:uint = uint(_sString.length);
         for(var i:uint = 1; i < _nlength; i++)
         {
            _sChar = _sString.charAt(i);
            _nCharCode = _sString.charCodeAt(i);
            if(_bSpace)
            {
               if(validWordChar(_nCharCode))
               {
                  _bSpace = false;
                  _nCount++;
               }
            }
            else if(!validWordChar(_nCharCode))
            {
               _bSpace = true;
            }
         }
         return _nCount;
      }
      
      public static function reverse(_sString:String) : String
      {
         var _sReverse:String = "";
         for(var i:int = _sString.length; i >= 0; i--)
         {
            _sReverse += _sString.charAt(i);
         }
         return _sReverse;
      }
      
      public static function reverseWords(_sString:String) : String
      {
         var _sChar:String = null;
         var _nCharCode:uint = 0;
         var _bSpace:Boolean = false;
         var i:uint = 0;
         var _aWords:Array = new Array();
         var _nCount:int = -1;
         _sChar = _sString.charAt(0);
         _nCharCode = _sString.charCodeAt(i);
         if(!validWordChar(_nCharCode))
         {
            _bSpace = true;
         }
         else
         {
            _bSpace = false;
            _nCount++;
            _aWords[_nCount] = "";
            _aWords[_nCount] += _sChar;
         }
         var _nlength:uint = uint(_sString.length);
         for(i = 1; i < _nlength; i++)
         {
            _sChar = _sString.charAt(i);
            _nCharCode = _sString.charCodeAt(i);
            if(_bSpace)
            {
               if(validWordChar(_nCharCode))
               {
                  _bSpace = false;
                  _nCount++;
                  _aWords[_nCount] = "";
                  _aWords[_nCount] += _sChar;
               }
            }
            else if(!validWordChar(_nCharCode))
            {
               _bSpace = true;
            }
            else
            {
               _aWords[_nCount] += _sChar;
            }
         }
         var _sReverse:String = "";
         for(var j:int = _aWords.length - 1; j > 0; j--)
         {
            _sReverse += _aWords[j] + " ";
         }
         return _sReverse + _aWords[j];
      }
      
      public static function wrap(_sString:String, _nLength:uint, _sSeparator:String) : String
      {
         var _nEnd:uint = 0;
         var _nStringLength:Number = _sString.length;
         var _nCount:uint = _nLength;
         var _nLastCount:uint = 1;
         var _nStart:uint = 0;
         var _sWrap:String = "";
         while(_nCount < _nStringLength)
         {
            while(_sString.charAt(_nCount) != " ")
            {
               if(_nCount <= _nLastCount)
               {
                  _nCount += _nLength;
                  while(_sString.charAt(_nCount) != " " && _nCount < _nStringLength)
                  {
                     _nCount++;
                  }
                  break;
               }
               _nCount--;
            }
            _nEnd = _nCount;
            _sWrap += _sString.slice(_nStart,_nEnd) + _sSeparator;
            _nStart = _nEnd + 1;
            _nLastCount = _nCount + 1;
            _nCount += _nLength;
         }
         return _sWrap + _sString.slice(_nStart,_nStringLength);
      }
      
      public static function removeExtraWhiteSpaces(_sString:String) : String
      {
         var _sChar:String = null;
         var _sWhiteSpace:String = "";
         var _oneSpace:Boolean = false;
         var _nLength:uint = uint(_sString.length);
         for(var i:uint = 0; i < _nLength; i++)
         {
            _sChar = _sString.charAt(i);
            if(!_oneSpace)
            {
               _sWhiteSpace += _sChar;
               if(_sChar == " ")
               {
                  _oneSpace = true;
               }
            }
            else if(_sChar != " ")
            {
               _sWhiteSpace += _sChar;
               _oneSpace = false;
            }
         }
         return _sWhiteSpace;
      }
      
      public static function remove(_sString:String, _sRemove:String) : String
      {
         var _sChar:String = null;
         var _sSubChar:String = null;
         var j:uint = 0;
         var _sFinal:String = "";
         var _sFirstSubChar:String = _sRemove.charAt(0);
         var _nSubLength:uint = uint(_sRemove.length);
         var _nLength:uint = uint(_sString.length);
         for(var i:uint = 0; i < _nLength; i++)
         {
            _sChar = _sString.charAt(i);
            if(_sFirstSubChar == _sChar)
            {
               for(j = 1; j < _nSubLength; j++)
               {
                  _sSubChar = _sRemove.charAt(j);
                  if(_sSubChar != _sString.charAt(i + j))
                  {
                     break;
                  }
               }
            }
            if(j != _nSubLength)
            {
               _sFinal += _sChar;
            }
            else
            {
               i += j - 1;
               j = 0;
            }
         }
         return _sFinal;
      }
      
      public static function replace(_sString:String, _sPattern:String, _sReplacement:String) : String
      {
         return _sString.split(_sPattern).join(_sReplacement);
      }
      
      public static function stripHTML(_sString:String, _sSeparator:String) : String
      {
         var _sChar:String = null;
         var _bTag:Boolean = false;
         var _bWord:Boolean = false;
         var _sFinal:String = "";
         var _bOne:Boolean = true;
         var _nLength:uint = uint(_sString.length);
         for(var i:uint = 0; i < _nLength; i++)
         {
            _sChar = _sString.charAt(i);
            if(_bTag)
            {
               if(_sChar == ">")
               {
                  _bTag = false;
               }
            }
            else if(_sChar == "<")
            {
               _bTag = true;
               _bWord = false;
            }
            else
            {
               if(!_bWord)
               {
                  _bWord = true;
                  if(!_bOne)
                  {
                     _sFinal += _sSeparator;
                  }
                  _bOne = false;
               }
               _sFinal += _sChar;
            }
         }
         return _sFinal;
      }
      
      public static function escape(_sString:String) : String
      {
         var _sChar:String = null;
         var _sFinal:String = "";
         var _nLength:uint = uint(_sString.length);
         for(var i:uint = 0; i < _nLength; i++)
         {
            _sChar = _sString.charAt(i);
            if(_sChar == "\'" || _sChar == "\"" || _sChar == "\\")
            {
               _sFinal += "\\";
            }
            _sFinal += _sChar;
         }
         return _sFinal;
      }
      
      public static function beginWith(_sString:String, _sBeginWith:String, _bCaseSensitive:Boolean = false) : Boolean
      {
         var _sChar:String = null;
         var _sTestChar:String = null;
         if(!_bCaseSensitive)
         {
            _sString = _sString.toUpperCase();
            _sBeginWith = _sBeginWith.toUpperCase();
         }
         var _nLength:uint = uint(_sBeginWith.length);
         for(var i:uint = 0; i < _nLength; i++)
         {
            _sChar = _sString.charAt(i);
            _sTestChar = _sBeginWith.charAt(i);
            if(_sChar != _sTestChar)
            {
               break;
            }
         }
         if(i == _nLength)
         {
            return true;
         }
         return false;
      }
      
      public static function endWith(_sString:String, _sEndWith:String, _bCaseSensitive:Boolean = false) : Boolean
      {
         var _sChar:String = null;
         var _sTestChar:String = null;
         if(!_bCaseSensitive)
         {
            _sString = _sString.toUpperCase();
            _sEndWith = _sEndWith.toUpperCase();
         }
         var _nLength:uint = uint(_sEndWith.length);
         var j:uint = _sString.length - _nLength;
         for(var i:uint = 0; i < _nLength; i++)
         {
            _sChar = _sString.charAt(j);
            _sTestChar = _sEndWith.charAt(i);
            if(_sChar != _sTestChar)
            {
               break;
            }
            j++;
         }
         if(i == _nLength)
         {
            return true;
         }
         return false;
      }
      
      public static function countOf(_sString:String, _sCountOf:String, _bCaseSensitive:Boolean = false) : uint
      {
         var _sChar:String = null;
         var _sSubChar:String = null;
         var j:uint = 0;
         if(!_bCaseSensitive)
         {
            _sString = _sString.toUpperCase();
            _sCountOf = _sCountOf.toUpperCase();
         }
         var _sFinal:String = "";
         var _sFirstSubChar:String = _sCountOf.charAt(0);
         var _nSubLength:uint = uint(_sCountOf.length);
         var _nCount:uint = 0;
         var _nLength:uint = uint(_sString.length);
         for(var i:uint = 0; i < _nLength; i++)
         {
            _sChar = _sString.charAt(i);
            if(_sFirstSubChar == _sChar)
            {
               for(j = 1; j < _nSubLength; j++)
               {
                  _sSubChar = _sCountOf.charAt(j);
                  if(_sSubChar != _sString.charAt(i + j))
                  {
                     break;
                  }
               }
            }
            if(j == _nSubLength)
            {
               _nCount++;
               i += j - 1;
               j = 0;
            }
         }
         return _nCount;
      }
      
      public static function contains(_sString:String, _sCountOf:String, _bCaseSensitive:Boolean = false) : Boolean
      {
         var _sChar:String = null;
         var _sSubChar:String = null;
         var j:uint = 0;
         if(!_bCaseSensitive)
         {
            _sString = _sString.toUpperCase();
            _sCountOf = _sCountOf.toUpperCase();
         }
         var _sFinal:String = "";
         var _sFirstSubChar:String = _sCountOf.charAt(0);
         var _nSubLength:uint = uint(_sCountOf.length);
         var _nCount:uint = 0;
         var _nLength:uint = uint(_sString.length);
         for(var i:uint = 0; i < _nLength; i++)
         {
            _sChar = _sString.charAt(i);
            if(_sFirstSubChar == _sChar)
            {
               for(j = 1; j < _nSubLength; j++)
               {
                  _sSubChar = _sCountOf.charAt(j);
                  if(_sSubChar != _sString.charAt(i + j))
                  {
                     break;
                  }
               }
            }
            if(j == _nSubLength)
            {
               return true;
            }
         }
         return false;
      }
      
      public static function truncate(_sString:String, _nLength:uint, _sSuffix:String, _oStringDirection:StringDirection) : String
      {
         var _nStringLength:uint = uint(_sString.length);
         if(_oStringDirection == StringDirection.BOTH)
         {
            _nLength = Math.floor(_nLength / 2);
            _nLength += Math.floor(_nStringLength / 2);
         }
         if(_oStringDirection == StringDirection.RIGHT || _oStringDirection == StringDirection.BOTH)
         {
            _sString = _sString.slice(0,_nLength);
            _sString += _sSuffix;
         }
         if(_oStringDirection == StringDirection.LEFT || _oStringDirection == StringDirection.BOTH)
         {
            _sString = _sString.slice(_nStringLength - _nLength);
            _sString = _sSuffix + _sString;
         }
         return _sString;
      }
      
      public static function getOrdinalSuffix(_nNumber:Number) : String
      {
         _nNumber = Math.abs(_nNumber);
         var _nTestNum:Number = _nNumber % 100;
         if(_nTestNum > 10 && _nTestNum < 14)
         {
            return "th";
         }
         switch(_nNumber % 10)
         {
            case 1:
               return "st";
            case 2:
               return "nd";
            case 3:
               return "rd";
            default:
               return "th";
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

