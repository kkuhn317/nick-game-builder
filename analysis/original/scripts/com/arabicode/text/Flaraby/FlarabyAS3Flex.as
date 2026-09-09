package com.arabicode.text.Flaraby
{
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   
   [Event(name="convert",type="com.arabicode.text.Flaraby.ConvertEvent")]
   [Event(name="urduremove",type="com.arabicode.text.Flaraby.UrduRemEvent")]
   [Event(name="urduadd",type="com.arabicode.text.Flaraby.UrduAddEvent")]
   [Event(name="persianremove",type="com.arabicode.text.Flaraby.PersianRemEvent")]
   [Event(name="persianadd",type="com.arabicode.text.Flaraby.PersianAddEvent")]
   [Event(name="extrawidth",type="com.arabicode.text.Flaraby.ExtraWidthEvent")]
   [Event(name="direction",type="com.arabicode.text.Flaraby.DirEvent")]
   public class FlarabyAS3Flex extends TextField
   {
      
      private var tashkeel:Array;
      
      private var urduOrd:Array;
      
      private var tashkeelNoEmbed:Array;
      
      private var ar:Array;
      
      private var revEnclosures:Array;
      
      private var spaceWidth:Number;
      
      private var sep:Array;
      
      private var _xcharwidth:Number;
      
      private var urduOn:Boolean;
      
      private var flarabyInitialized:Boolean;
      
      private var tashkeelEmbedOrd:Array;
      
      private var farsiOn:Boolean;
      
      private var digitsPunc:Array;
      
      private var _html:Boolean;
      
      private var tashkeelNoEmbedOrd:Array;
      
      private var tFLimit:Number;
      
      private var tashkeelEmbed:Array;
      
      private var tFType:String;
      
      private var originalSep:Array;
      
      private var specialPunc:Array;
      
      private var tashkeelNoEmbedOn:Boolean;
      
      private var arOrd:Array;
      
      private var linesArr:Array;
      
      private var newlineChar:String;
      
      private var tashkeelEmbedOn:Boolean;
      
      private var originaldir:String;
      
      private var enclosures:Array;
      
      private const RLM:String = "";
      
      private var farsiSep:Array;
      
      private const LRM:String = "";
      
      private var urduSep:Array;
      
      private var tFormat:TextFormat;
      
      private var originalArOrd:Array;
      
      private var farsi:Array;
      
      private var _dir:String;
      
      private var originalAr:Array;
      
      private var supportedTags:Array;
      
      private var urdu:Array;
      
      private var farsiOrd:Array;
      
      public function FlarabyAS3Flex()
      {
         super();
         if(flarabyInitialized == false)
         {
            ar = [String.fromCharCode(1575),String.fromCharCode(1571),String.fromCharCode(1573),String.fromCharCode(1570),String.fromCharCode(1576),String.fromCharCode(1578),String.fromCharCode(1577),String.fromCharCode(1579),String.fromCharCode(1580),String.fromCharCode(1581),String.fromCharCode(1582),String.fromCharCode(1583),String.fromCharCode(1584),String.fromCharCode(1585),String.fromCharCode(1586),String.fromCharCode(1587),String.fromCharCode(1588),String.fromCharCode(1589),String.fromCharCode(1590),String.fromCharCode(1591),String.fromCharCode(1592),String.fromCharCode(1593),String.fromCharCode(1594),String.fromCharCode(1601),String.fromCharCode(1602),String.fromCharCode(1603),String.fromCharCode(1604),String.fromCharCode(1605),String.fromCharCode(1606),String.fromCharCode(1607),String.fromCharCode(1608),String.fromCharCode(1572),String.fromCharCode(1610),String.fromCharCode(1609),String.fromCharCode(1574),String.fromCharCode(1569),String.fromCharCode(65275),String.fromCharCode(65273),String
            .fromCharCode(65271),String.fromCharCode(65269),String.fromCharCode(1600),String.fromCharCode(1649)];
            arOrd = [[65165,65166,65165,65166],[65155,65156,65155,65156],[65159,65160,65159,65160],[65153,65154,65153,65154],[65167,65168,65169,65170],[65173,65174,65175,65176],[65171,65172,65171,65172],[65177,65178,65179,65180],[65181,65182,65183,65184],[65185,65186,65187,65188],[65189,65190,65191,65192],[65193,65194,65193,65194],[65195,65196,65195,65196],[65197,65198,65197,65198],[65199,65200,65199,65200],[65201,65202,65203,65204],[65205,65206,65207,65208],[65209,65210,65211,65212],[65213,65214,65215,65216],[65217,65218,65219,65220],[65221,65222,65223,65224],[65225,65226,65227,65228],[65229,65230,65231,65232],[65233,65234,65235,65236],[65237,65238,65239,65240],[65241,65242,65243,65244],[65245,65246,65247,65248],[65249,65250,65251,65252],[65253,65254,65255,65256],[65257,65258,65259,65260],[65261,65262,65261,65262],[65157,65158,65157,65158],[65265,65266,65267,65268],[65263,65264,65263,65264],[65161,65162,65163,65164],[65152,65152,65152,65152],[65275,65276,65275,65276],[65273,65274,65273,65274],[65271
            ,65272,65271,65272],[65269,65270,65269,65270],[1600,1600,1600,1600],[64336,64337,64336,64337]];
            sep = [String.fromCharCode(1575),String.fromCharCode(1571),String.fromCharCode(1573),String.fromCharCode(1570),String.fromCharCode(1585),String.fromCharCode(1586),String.fromCharCode(1608),String.fromCharCode(1572),String.fromCharCode(1583),String.fromCharCode(1584),String.fromCharCode(1569),String.fromCharCode(65275),String.fromCharCode(65273),String.fromCharCode(65271),String.fromCharCode(65269),String.fromCharCode(1649)];
            tashkeelNoEmbed = [String.fromCharCode(1611),String.fromCharCode(1612),String.fromCharCode(1613),String.fromCharCode(1614),String.fromCharCode(1615),String.fromCharCode(1616),String.fromCharCode(1617),String.fromCharCode(1618),String.fromCharCode(1648)];
            tashkeelNoEmbedOrd = [[1611,1611,1611,1611],[1612,1612,1612,1612],[1613,1613,1613,1613],[1614,1614,1614,1614],[1615,1615,1615,1615],[1616,1616,1616,1616],[1617,1617,1617,1617],[1618,1618,1618,1618],[1648,1648,1648,1648]];
            tashkeelEmbed = [String.fromCharCode(1611),String.fromCharCode(1612),String.fromCharCode(1613),String.fromCharCode(1614),String.fromCharCode(1615),String.fromCharCode(1616),String.fromCharCode(1617),String.fromCharCode(1618),String.fromCharCode(1648),String.fromCharCode(59434),String.fromCharCode(59435),String.fromCharCode(59437),String.fromCharCode(59432),String.fromCharCode(59433),String.fromCharCode(59436)];
            tashkeelEmbedOrd = [[1611,1611,1611,1611],[1612,1612,1612,1612],[1613,1613,1613,1613],[65142,65142,65142,65143],[65144,65144,65144,65145],[65146,65146,65146,65147],[65148,65148,65148,65149],[65150,65150,65150,65151],[1648,1648,1648,1648],[59434,59434,59434,59434],[59435,59435,59435,59435],[59437,59437,59437,59437],[59432,59432,59432,64754],[59433,59433,59433,64755],[59436,59436,59436,64756]];
            farsiOn = false;
            urduOn = false;
            digitsPunc = [",","."];
            enclosures = ["(",")","[","]","{","}","«","»"];
            revEnclosures = [")","(","]","[","}","{","»","«"];
            specialPunc = ["!"];
            this.autoSize = TextFieldAutoSize.RIGHT;
            _dir = _dir == null ? "RTL" : _dir;
            flarabyInitialized = true;
         }
      }
      
      private function getPrevLetterType(p:int, str:String) : String
      {
         var tagOpen:Boolean = false;
         var j:int = 0;
         var c:String = null;
         if(p == 0)
         {
            return "no";
         }
         tagOpen = false;
         for(j = p - 1; j >= 0; j--)
         {
            c = str.charAt(j);
            if(_html)
            {
               if(c == ">")
               {
                  tagOpen = true;
                  continue;
               }
               if(c == "<")
               {
                  tagOpen = false;
                  continue;
               }
            }
            if(!tagOpen)
            {
               if(isLatin(c) || c == LRM)
               {
                  return "en";
               }
               if(isArabic(c) || c == RLM)
               {
                  return "ar";
               }
            }
         }
         return "no";
      }
      
      public function isTag(str:String) : Boolean
      {
         if(str.charAt(0) == "<" && str.charAt(str.length - 1) == ">")
         {
            return true;
         }
         return false;
      }
      
      public function replaceNewLines(str:String) : String
      {
         var tmp:Array = null;
         var tmpReplaceChar:String = null;
         tmpReplaceChar = _html || !this.multiline ? " " : "\n";
         tmp = str.split("\r\n");
         str = tmp.join(tmpReplaceChar);
         tmp = str.split("\r");
         str = tmp.join(tmpReplaceChar);
         if(_html)
         {
            tmpReplaceChar = !this.multiline ? " " : "<br />";
            tmp = str.split("<br>");
            str = tmp.join(tmpReplaceChar);
         }
         return str;
      }
      
      public function isDigit(char:String) : Boolean
      {
         var cod:uint = 0;
         if(!isNaN(parseInt(char)))
         {
            return true;
         }
         if(farsiOn || urduOn)
         {
            cod = char.charCodeAt(0);
            if(cod >= 1776 && cod <= 1785)
            {
               return true;
            }
         }
         return false;
      }
      
      public function convertArabicChar(p:int, str:String) : String
      {
         var char:String = null;
         var prv:String = null;
         var nxt:String = null;
         var uchar:String = null;
         var pos:Object = null;
         var hamza:String = null;
         char = str.charAt(p);
         prv = getPrevLetter(p - 1,str);
         nxt = getNextLetter(p + 1,str);
         if(!isArabic(prv) && isArabic(nxt))
         {
            pos = ar.indexOf(char);
            if(isArabic(nxt))
            {
               uchar = String.fromCharCode(arOrd[pos][2]);
            }
            else
            {
               uchar = String.fromCharCode(arOrd[pos][0]);
            }
         }
         else if(!isArabic(nxt) && isArabic(prv))
         {
            if(in_Array(prv,sep))
            {
               pos = ar.indexOf(char);
               uchar = String.fromCharCode(arOrd[pos][0]);
            }
            else
            {
               pos = ar.indexOf(char);
               uchar = String.fromCharCode(arOrd[pos][1]);
            }
         }
         else
         {
            hamza = String.fromCharCode(1569);
            if(nxt == hamza)
            {
               if(in_Array(prv,sep))
               {
                  pos = ar.indexOf(char);
                  uchar = String.fromCharCode(arOrd[pos][0]);
               }
               else
               {
                  pos = ar.indexOf(char);
                  uchar = String.fromCharCode(arOrd[pos][1]);
               }
            }
            else if(!isArabic(nxt) && !isArabic(prv))
            {
               pos = ar.indexOf(char);
               uchar = String.fromCharCode(arOrd[pos][0]);
            }
            else if(isArabic(prv) && in_Array(prv,sep))
            {
               pos = ar.indexOf(char);
               uchar = String.fromCharCode(arOrd[pos][2]);
            }
            else
            {
               pos = ar.indexOf(char);
               uchar = String.fromCharCode(arOrd[pos][3]);
            }
         }
         return uchar;
      }
      
      private function getPrevLetter(p:int, str:String) : String
      {
         var tagOpen:Boolean = false;
         var j:int = 0;
         var c:String = null;
         tagOpen = false;
         for(j = p; j >= 0; j--)
         {
            c = str.charAt(j);
            if(_html)
            {
               if(c == ">")
               {
                  tagOpen = true;
                  continue;
               }
               if(c == "<")
               {
                  tagOpen = false;
                  continue;
               }
            }
            if(!tagOpen && !in_Array(c,tashkeel))
            {
               return c;
            }
         }
         return "";
      }
      
      private function refreshComponent(lm:Number, tfrmt:TextFormat) : void
      {
         var siz:Number = NaN;
         tFType = _html ? "htmlText" : "text";
         newlineChar = _html ? "<br />" : "\n";
         supportedTags = _html ? ["<f","<a","<u"] : [];
         linesArr = [];
         tFormat = tfrmt;
         tFormat.align = null;
         if(this.multiline)
         {
            siz = Number(tFormat.size);
            extraCharWidth = isNaN(_xcharwidth) ? (siz < 27 ? 0.1 : (siz < 43 ? 0.4 : (siz < 49 ? 0.8 : 1.2))) : _xcharwidth;
            spaceWidth = getStringWidth(" ");
            tFLimit = lm;
         }
      }
      
      public function isArabic(char:String) : Boolean
      {
         var cod:uint = 0;
         cod = char.charCodeAt(0);
         if(!isNaN(cod))
         {
            if(cod >= 1569 && cod <= 1594 || cod >= 1600 && cod <= 1618 || cod == 1648 || cod == 1649 || cod == 65269 || cod == 65271 || cod == 65273 || cod == 65275)
            {
               return true;
            }
            if(this.embedFonts)
            {
               if(cod >= 59432 && cod <= 59437)
               {
                  return true;
               }
            }
            if(farsiOn)
            {
               if(cod == 1662 || cod == 1670 || cod == 1688 || cod == 1700 || cod == 1705 || cod == 1711 || cod == 1740)
               {
                  return true;
               }
            }
            if(urduOn)
            {
               if(cod == 1657 || cod == 1672 || cod == 1681 || cod == 1722 || cod == 1726 || cod == 1729 || cod == 1746 || cod == 1747)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      private function getTag(p:int, str:String) : String
      {
         var tag:String = null;
         var j:int = 0;
         var cr:String = null;
         tag = "";
         for(j = p; j < str.length; j++)
         {
            cr = str.charAt(j);
            tag += cr;
            if(cr == ">")
            {
               break;
            }
         }
         return tag;
      }
      
      public function get dir() : String
      {
         return _dir;
      }
      
      private function removeTashkeelEmbed() : void
      {
         var cod:uint = 0;
         while(ar.lengh > 0)
         {
            cod = uint(ar[ar.lengh - 1].charCodeAt(0));
            if(!(cod >= 1611 && cod <= 1618 || cod == 1648 || cod >= 59432 && cod <= 59437))
            {
               break;
            }
            ar.pop();
            arOrd.pop();
         }
         tashkeelEmbedOn = false;
      }
      
      public function addUrduSupport() : void
      {
         if(farsiOn)
         {
            removePersianSupport();
         }
         originalAr = ar;
         originalArOrd = arOrd;
         originalSep = sep;
         addPersianSupport();
         urdu = [String.fromCharCode(1657),String.fromCharCode(1672),String.fromCharCode(1681),String.fromCharCode(1722),String.fromCharCode(1726),String.fromCharCode(1729),String.fromCharCode(1746),String.fromCharCode(1747)];
         urduOrd = [[64358,64359,64360,64361],[64392,64393,64392,64393],[64396,64397,64396,64397],[64414,64415,64414,64415],[64426,64427,64428,64429],[64422,64423,64424,64425],[64430,64431,64430,64431],[64432,64433,64432,64433]];
         urduSep = [String.fromCharCode(1672),String.fromCharCode(1681),String.fromCharCode(1722),String.fromCharCode(1746),String.fromCharCode(1747)];
         ar = ar.concat(urdu);
         arOrd = arOrd.concat(urduOrd);
         sep = sep.concat(urduSep);
         urduOn = true;
         dispatchEvent(new UrduAddEvent("urduOn"));
      }
      
      public function removeTags(str:String) : String
      {
         var tagOpen:Boolean = false;
         var s:String = null;
         var d:int = 0;
         if(!isTag(str))
         {
            return str;
         }
         tagOpen = false;
         s = "";
         for(d = 0; d < str.length; d++)
         {
            if(str.charAt(d) == "<")
            {
               tagOpen = true;
            }
            else if(str.charAt(d) == ">")
            {
               tagOpen = false;
            }
            else if(!tagOpen)
            {
               s += str.charAt(d);
            }
         }
         return s;
      }
      
      public function removeTashkeel(str:String) : String
      {
         var tmpStr:String = null;
         var i:int = 0;
         var char:String = null;
         if(!tashkeelNoEmbedOn && !tashkeelEmbedOn)
         {
            checkTashkeel();
         }
         tmpStr = "";
         for(i = 0; i < str.length; i++)
         {
            char = str.charAt(i);
            if(!in_Array(char,tashkeel))
            {
               tmpStr += char;
            }
         }
         return tmpStr;
      }
      
      private function in_Array(item:Object, arr:Array) : Boolean
      {
         return arr.indexOf(item) < 0 ? false : true;
      }
      
      public function isPunc(char:String) : Boolean
      {
         if(isArabic(char) || isLatin(char) || isDigit(char))
         {
            return false;
         }
         return true;
      }
      
      private function getNextLetterType(p:int, str:String, checkDigit:Boolean) : String
      {
         var tagOpen:Boolean = false;
         var j:int = 0;
         var c:String = null;
         if(p == str.length - 1)
         {
            return "no";
         }
         tagOpen = false;
         for(j = p + 1; j < str.length; j++)
         {
            c = str.charAt(j);
            if(_html)
            {
               if(c == "<")
               {
                  tagOpen = true;
                  continue;
               }
               if(c == ">")
               {
                  tagOpen = false;
                  continue;
               }
            }
            if(!tagOpen)
            {
               if(isLatin(c) || c == LRM)
               {
                  return "en";
               }
               if(isArabic(c) || c == RLM)
               {
                  return "ar";
               }
               if(checkDigit)
               {
                  if(isDigit(c))
                  {
                     return "dg";
                  }
               }
            }
         }
         return "no";
      }
      
      public function removeUrduSupport() : void
      {
         ar = originalAr;
         arOrd = originalArOrd;
         sep = originalSep;
         urduOn = false;
         dispatchEvent(new UrduRemEvent("urduOff"));
      }
      
      private function getNextLetter(p:int, str:String) : String
      {
         var tagOpen:Boolean = false;
         var j:int = 0;
         var c:String = null;
         tagOpen = false;
         for(j = p; j < str.length; j++)
         {
            c = str.charAt(j);
            if(_html)
            {
               if(c == "<")
               {
                  tagOpen = true;
                  continue;
               }
               if(c == ">")
               {
                  tagOpen = false;
                  continue;
               }
            }
            if(!tagOpen && !in_Array(c,tashkeel))
            {
               return c;
            }
         }
         return "";
      }
      
      private function removeTashkeelNoEmbed() : void
      {
         var cod:uint = 0;
         while(ar.lengh > 0)
         {
            cod = uint(ar[ar.lengh - 1].charCodeAt(0));
            if(!(cod >= 1611 && cod <= 1618 || cod == 1648))
            {
               break;
            }
            ar.pop();
            arOrd.pop();
         }
         tashkeelNoEmbedOn = false;
      }
      
      public function getStringWidth(char:String) : Number
      {
         var tFW:Number = NaN;
         this[tFType] = char;
         this.setTextFormat(tFormat);
         return this.textWidth + _xcharwidth;
      }
      
      public function addPersianSupport() : Boolean
      {
         if(urduOn)
         {
            return false;
         }
         originalAr = ar;
         originalArOrd = arOrd;
         originalSep = sep;
         farsi = [String.fromCharCode(1662),String.fromCharCode(1670),String.fromCharCode(1688),String.fromCharCode(1700),String.fromCharCode(1705),String.fromCharCode(1711),String.fromCharCode(1740)];
         farsiOrd = [[64342,64343,64344,64345],[64378,64379,64380,64381],[64394,64395,64394,64395],[64362,64363,64364,64365],[64398,64399,64400,64401],[64402,64403,64404,64405],[65265,65266,65267,65268]];
         farsiSep = [String.fromCharCode(1688)];
         ar = ar.concat(farsi);
         arOrd = arOrd.concat(farsiOrd);
         sep = sep.concat(farsiSep);
         farsiOn = true;
         dispatchEvent(new PersianAddEvent("persianOn"));
         return true;
      }
      
      public function set dir(value:String) : void
      {
         _dir = value;
         dispatchEvent(new DirEvent("dirChange"));
      }
      
      private function convertBetweenLines(str:String) : String
      {
         var splited:Array = null;
         var converted:String = null;
         var joined:Array = null;
         var d:int = 0;
         joined = [];
         splited = str.split(newlineChar);
         for(d = 0; d < splited.length; d++)
         {
            converted = processArabicString(splited[d]);
            joined.push(converted);
         }
         return joined.join(newlineChar);
      }
      
      private function checkTashkeel() : void
      {
         if(this.embedFonts)
         {
            if(tashkeelNoEmbedOn)
            {
               removeTashkeelNoEmbed();
            }
            if(!tashkeelEmbedOn)
            {
               addTashkeelEmbed();
            }
         }
         else
         {
            if(tashkeelEmbedOn)
            {
               removeTashkeelEmbed();
            }
            if(!tashkeelNoEmbedOn)
            {
               addTashkeelNoEmbed();
            }
         }
      }
      
      public function convertArabicString(inputStr:String, lm:Number, tfrmt:TextFormat) : String
      {
         var outputStr:String = null;
         refreshComponent(lm,tfrmt);
         inputStr = addLafthEljalalah(inputStr);
         inputStr = replaceDoubleChars(inputStr);
         inputStr = replaceNewLines(inputStr);
         checkTashkeel();
         if(this.multiline)
         {
            outputStr = convertBetweenLines(inputStr);
         }
         else
         {
            outputStr = processArabicString(inputStr);
         }
         this[tFType] = "";
         dispatchEvent(new ConvertEvent("convert"));
         return outputStr;
      }
      
      private function addTashkeelNoEmbed() : void
      {
         ar = ar.concat(tashkeelNoEmbed);
         arOrd = arOrd.concat(tashkeelNoEmbedOrd);
         tashkeel = tashkeelNoEmbed;
         tashkeelNoEmbedOn = true;
      }
      
      public function getLines() : Array
      {
         return linesArr;
      }
      
      private function replaceDoubleChars(str:String) : String
      {
         var tmp:Array = null;
         tmp = str.split(String.fromCharCode(1604,1575));
         str = tmp.join(String.fromCharCode(65275));
         tmp = str.split(String.fromCharCode(1604,1573));
         str = tmp.join(String.fromCharCode(65273));
         tmp = str.split(String.fromCharCode(1604,1571));
         str = tmp.join(String.fromCharCode(65271));
         tmp = str.split(String.fromCharCode(1604,1570));
         str = tmp.join(String.fromCharCode(65269));
         if(this.embedFonts)
         {
            tmp = str.split(String.fromCharCode(1617,1611));
            str = tmp.join(String.fromCharCode(59434));
            tmp = str.split(String.fromCharCode(1617,1612));
            str = tmp.join(String.fromCharCode(59435));
            tmp = str.split(String.fromCharCode(1617,1613));
            str = tmp.join(String.fromCharCode(59437));
            tmp = str.split(String.fromCharCode(1617,1614));
            str = tmp.join(String.fromCharCode(59432));
            tmp = str.split(String.fromCharCode(1617,1615));
            str = tmp.join(String.fromCharCode(59433));
            tmp = str.split(String.fromCharCode(1617,1616));
            str = tmp.join(String.fromCharCode(59436));
         }
         return str;
      }
      
      private function addLafthEljalalah(str:String) : String
      {
         var tmp:Array = null;
         if(str.indexOf(String.fromCharCode(1604,1604,1607)) != -1 || str.indexOf(String.fromCharCode(1604,1604,1617,1614,1607)) != -1)
         {
            tmp = str.split(String.fromCharCode(32,1575,1604,1604,1607,32));
            str = tmp.join(String.fromCharCode(32,65165,65010,32));
            tmp = str.split(String.fromCharCode(32,1575,1604,1604,1617,1614,1607,32));
            str = tmp.join(String.fromCharCode(32,65165,65010,32));
            tmp = str.split(String.fromCharCode(32,1604,1604,1607,32));
            str = tmp.join(String.fromCharCode(32,65010,32));
            tmp = str.split(String.fromCharCode(32,1604,1604,1617,1614,1607,32));
            str = tmp.join(String.fromCharCode(32,65010,32));
            tmp = str.split(String.fromCharCode(32,1576,1575,1604,1604,1607,32));
            str = tmp.join(String.fromCharCode(32,65169,65166,65010,32));
            tmp = str.split(String.fromCharCode(32,1576,1575,1604,1604,1607,32));
            str = tmp.join(String.fromCharCode(32,65169,59430,65166,65010,32));
            tmp = str.split(String.fromCharCode(32,1578,1575,1604,1604,1607,32));
            str = tmp.join(String.fromCharCode(32,65175,65166,65010,32));
            tmp = str.split(String.fromCharCode(32,1578,1575,1604,1604,1607,32));
            str = tmp.join(String.fromCharCode(32,65175,59424,65166,65010,32));
            tmp = str.split(String.fromCharCode(32,1601,1575,1604,1604,1607,32));
            str = tmp.join(String.fromCharCode(32,65235,65166,65010,32));
            tmp = str.split(String.fromCharCode(32,1601,1575,1604,1604,1607,32));
            str = tmp.join(String.fromCharCode(32,65235,59424,65166,65010,32));
         }
         return str;
      }
      
      public function set html(value:Boolean) : void
      {
         _html = value;
      }
      
      private function addTashkeelEmbed() : void
      {
         ar = ar.concat(tashkeelEmbed);
         arOrd = arOrd.concat(tashkeelEmbedOrd);
         tashkeel = tashkeelEmbed;
         tashkeelEmbedOn = true;
      }
      
      public function removePersianSupport() : Boolean
      {
         if(urduOn)
         {
            return false;
         }
         ar = originalAr;
         arOrd = originalArOrd;
         sep = originalSep;
         farsiOn = false;
         dispatchEvent(new PersianRemEvent("persianOff"));
         return true;
      }
      
      public function get html() : Boolean
      {
         return _html;
      }
      
      public function set extraCharWidth(value:Number) : void
      {
         _xcharwidth = value;
         dispatchEvent(new ExtraWidthEvent("extraWidthChange"));
      }
      
      private function getTagsList(tarr:Array, typ:String) : String
      {
         var tags:String = null;
         var j:int = 0;
         tags = "";
         for(j = 0; j < tarr.length; j++)
         {
            if(typ == "op")
            {
               tags += tarr[j][typ];
            }
            else
            {
               tags = tarr[j][typ] + tags;
            }
         }
         return tags;
      }
      
      public function getCharArrWidth(arr:Array) : Number
      {
         var w:Number = NaN;
         var d:int = 0;
         w = 0;
         for(d = 0; d < arr.length; d++)
         {
            w += getStringWidth(arr[d]);
         }
         return w;
      }
      
      public function get extraCharWidth() : Number
      {
         return _xcharwidth;
      }
      
      private function processArabicString(str:String) : String
      {
         var char:String = null;
         var line:Array = null;
         var tmpLines:Array = null;
         var prvArr:Array = null;
         var nxtArr:Array = null;
         var arSpaceIndex:int = 0;
         var enSpaceIndex:int = 0;
         var tmpDigit:Object = null;
         var lineWidth:Number = NaN;
         var arabicSentence:Array = null;
         var englishSentence:Array = null;
         var arSentence:Boolean = false;
         var enSentence:Boolean = false;
         var openedTags:Array = null;
         var tagIndex:int = 0;
         var i:int = 0;
         var tag:String = null;
         var closeTag:String = null;
         var p:Number = NaN;
         var dg:String = null;
         var digitNextChar:String = null;
         var j:int = 0;
         var d:String = null;
         var pos:int = 0;
         var prv:String = null;
         var nxt:String = null;
         var nxt2:String = null;
         line = [];
         tmpLines = [];
         prvArr = [];
         nxtArr = [];
         arSpaceIndex = 0;
         enSpaceIndex = 0;
         tmpDigit = -1;
         lineWidth = 0;
         arabicSentence = [];
         englishSentence = [];
         arSentence = false;
         enSentence = false;
         openedTags = [];
         tagIndex = -1;
         for(i = 0; i < str.length; i++)
         {
            char = str.charAt(i);
            if(char == String.fromCharCode(1563) || char == String.fromCharCode(1567))
            {
               if(this.multiline)
               {
                  if(lineWidth > tFLimit)
                  {
                     if(arSentence)
                     {
                        prvArr = arSpaceIndex != -1 ? arabicSentence.slice(arabicSentence.length - arSpaceIndex,arabicSentence.length) : [];
                        nxtArr = arSpaceIndex != -1 ? arabicSentence.slice(0,arabicSentence.length - arSpaceIndex - 1) : arabicSentence;
                        if(_dir == "RTL")
                        {
                           line = prvArr.concat(line);
                        }
                        else
                        {
                           line = line.concat(prvArr);
                        }
                     }
                     else if(enSentence)
                     {
                        prvArr = enSpaceIndex != -1 ? englishSentence.slice(0,enSpaceIndex) : [];
                        nxtArr = enSpaceIndex != -1 ? englishSentence.slice(enSpaceIndex,englishSentence.length) : englishSentence;
                        if(_dir == "RTL")
                        {
                           line = prvArr.concat(line);
                        }
                        else
                        {
                           line = line.concat(prvArr);
                        }
                     }
                     tmpLines.push(line.join(""));
                     linesArr.push(line.join(""));
                     arabicSentence = arSentence ? nxtArr : [];
                     englishSentence = enSentence ? nxtArr : [];
                     line = [];
                     lineWidth = getCharArrWidth(nxtArr) + getStringWidth(char);
                  }
                  else
                  {
                     lineWidth += getStringWidth(char);
                  }
               }
               if(_html)
               {
                  char = openedTags[tagIndex] != null ? getTagsList(openedTags,"op") + char + getTagsList(openedTags,"cl") : char;
               }
               if(arSentence)
               {
                  arabicSentence.unshift(char);
               }
               else if(enSentence)
               {
                  englishSentence.push(char);
               }
            }
            else
            {
               if(_html)
               {
                  if(char == "<")
                  {
                     tag = getTag(i,str);
                     i += tag.length - 1;
                     if(tag.charAt(1) == "/")
                     {
                        openedTags.pop();
                        tagIndex--;
                     }
                     else
                     {
                        closeTag = getCloseTag(tag);
                        openedTags.push({
                           "op":tag,
                           "cl":closeTag
                        });
                        tagIndex++;
                     }
                     continue;
                  }
               }
               if(isArabic(char))
               {
                  if(tmpDigit != -1)
                  {
                     arabicSentence = [tmpDigit];
                     tmpDigit = -1;
                  }
                  char = convertArabicChar(i,str);
                  if(enSentence)
                  {
                     if(_dir == "RTL")
                     {
                        line = englishSentence.concat(line);
                     }
                     else
                     {
                        line = line.concat(englishSentence);
                     }
                  }
                  if(this.multiline)
                  {
                     if(lineWidth > tFLimit)
                     {
                        if(enSentence)
                        {
                           prvArr = enSpaceIndex != -1 ? englishSentence.slice(0,enSpaceIndex) : [];
                           nxtArr = enSpaceIndex != -1 ? englishSentence.slice(enSpaceIndex,englishSentence.length) : englishSentence;
                        }
                        else if(arSentence)
                        {
                           prvArr = arSpaceIndex != -1 ? arabicSentence.slice(arabicSentence.length - arSpaceIndex,arabicSentence.length) : [];
                           nxtArr = arSpaceIndex != -1 ? arabicSentence.slice(0,arabicSentence.length - arSpaceIndex - 1) : arabicSentence;
                           if(_dir == "RTL")
                           {
                              line = prvArr.concat(line);
                           }
                           else
                           {
                              line = line.concat(prvArr);
                           }
                        }
                        tmpLines.push(line.join(""));
                        linesArr.push(line.join(""));
                        arabicSentence = arSentence ? nxtArr : [];
                        line = [];
                        lineWidth = getCharArrWidth(nxtArr) + getStringWidth(char);
                     }
                     else
                     {
                        lineWidth += getStringWidth(char);
                     }
                  }
                  englishSentence = [];
                  enSentence = false;
                  arSentence = true;
                  if(_html)
                  {
                     char = openedTags[tagIndex] != null ? getTagsList(openedTags,"op") + char + getTagsList(openedTags,"cl") : char;
                  }
                  arabicSentence.unshift(char);
               }
               else if(isLatin(char))
               {
                  if(tmpDigit != -1)
                  {
                     englishSentence = [tmpDigit];
                     tmpDigit = -1;
                  }
                  if(arSentence)
                  {
                     if(_dir == "RTL")
                     {
                        line = arabicSentence.concat(line);
                     }
                     else
                     {
                        line = line.concat(arabicSentence);
                     }
                  }
                  if(this.multiline)
                  {
                     if(lineWidth > tFLimit)
                     {
                        if(arSentence)
                        {
                           prvArr = arSpaceIndex != -1 ? arabicSentence.slice(arabicSentence.length - arSpaceIndex,arabicSentence.length) : [];
                           nxtArr = arSpaceIndex != -1 ? arabicSentence.slice(0,arabicSentence.length - arSpaceIndex - 1) : arabicSentence;
                        }
                        else if(enSentence)
                        {
                           prvArr = enSpaceIndex != -1 ? englishSentence.slice(0,enSpaceIndex) : [];
                           nxtArr = enSpaceIndex != -1 ? englishSentence.slice(enSpaceIndex,englishSentence.length) : englishSentence;
                           if(_dir == "RTL")
                           {
                              line = prvArr.concat(line);
                           }
                           else
                           {
                              line = line.concat(prvArr);
                           }
                        }
                        tmpLines.push(line.join(""));
                        linesArr.push(line.join(""));
                        englishSentence = enSentence ? nxtArr : [];
                        line = [];
                        lineWidth = getCharArrWidth(nxtArr) + getStringWidth(char);
                     }
                     else
                     {
                        lineWidth += getStringWidth(char);
                     }
                  }
                  arabicSentence = [];
                  arSentence = false;
                  enSentence = true;
                  if(_html)
                  {
                     char = openedTags[tagIndex] != null ? getTagsList(openedTags,"op") + char + getTagsList(openedTags,"cl") : char;
                  }
                  englishSentence.push(char);
               }
               else if(isDigit(char))
               {
                  p = i;
                  dg = "";
                  for(j = p; j < str.length; j++)
                  {
                     d = str.charAt(j);
                     if(!(isDigit(d) || in_Array(d,digitsPunc) && isDigit(str.charAt(j + 1))))
                     {
                        if(isArabic(d))
                        {
                           digitNextChar = "a";
                        }
                        else if(isLatin(d))
                        {
                           digitNextChar = "l";
                        }
                        else
                        {
                           digitNextChar = "p";
                        }
                        i--;
                        break;
                     }
                     dg += d;
                     i++;
                  }
                  if(this.multiline)
                  {
                     if(lineWidth > tFLimit)
                     {
                        if(arSentence)
                        {
                           prvArr = arSpaceIndex != -1 ? arabicSentence.slice(arabicSentence.length - arSpaceIndex,arabicSentence.length) : [];
                           nxtArr = arSpaceIndex != -1 ? arabicSentence.slice(0,arabicSentence.length - arSpaceIndex - 1) : arabicSentence;
                           if(_dir == "RTL")
                           {
                              line = prvArr.concat(line);
                           }
                           else
                           {
                              line = line.concat(prvArr);
                           }
                        }
                        else if(enSentence)
                        {
                           prvArr = enSpaceIndex != -1 ? englishSentence.slice(0,enSpaceIndex) : [];
                           nxtArr = enSpaceIndex != -1 ? englishSentence.slice(enSpaceIndex,englishSentence.length) : englishSentence;
                           if(_dir == "RTL")
                           {
                              line = prvArr.concat(line);
                           }
                           else
                           {
                              line = line.concat(prvArr);
                           }
                        }
                        tmpLines.push(line.join(""));
                        linesArr.push(line.join(""));
                        arabicSentence = arSentence ? nxtArr : [];
                        englishSentence = enSentence ? nxtArr : [];
                        line = [];
                        lineWidth = getCharArrWidth(nxtArr) + getStringWidth(dg);
                     }
                     else
                     {
                        lineWidth += getStringWidth(dg);
                     }
                  }
                  if(_html)
                  {
                     dg = openedTags[tagIndex] != null ? getTagsList(openedTags,"op") + dg + getTagsList(openedTags,"cl") : dg;
                  }
                  if(arSentence)
                  {
                     if(_dir == "RTL")
                     {
                        if(digitNextChar == "l")
                        {
                           tmpDigit = dg;
                        }
                        else
                        {
                           arabicSentence.unshift(dg);
                        }
                     }
                     else
                     {
                        arabicSentence.unshift(dg);
                     }
                  }
                  else if(enSentence)
                  {
                     if(_dir == "RTL")
                     {
                        englishSentence.push(dg);
                     }
                     else if(digitNextChar == "a")
                     {
                        tmpDigit = dg;
                     }
                     else
                     {
                        englishSentence.push(dg);
                     }
                  }
                  else
                  {
                     tmpDigit = dg;
                  }
               }
               else
               {
                  if(this.multiline)
                  {
                     if(lineWidth > tFLimit)
                     {
                        if(arSentence)
                        {
                           prvArr = arSpaceIndex != -1 ? arabicSentence.slice(arabicSentence.length - arSpaceIndex,arabicSentence.length) : [];
                           nxtArr = arSpaceIndex != -1 ? arabicSentence.slice(0,arabicSentence.length - arSpaceIndex - 1) : arabicSentence;
                           if(_dir == "RTL")
                           {
                              line = prvArr.concat(line);
                           }
                           else
                           {
                              line = line.concat(prvArr);
                           }
                        }
                        else if(enSentence)
                        {
                           prvArr = enSpaceIndex != -1 ? englishSentence.slice(0,enSpaceIndex) : [];
                           nxtArr = enSpaceIndex != -1 ? englishSentence.slice(enSpaceIndex,englishSentence.length) : englishSentence;
                           if(_dir == "RTL")
                           {
                              line = prvArr.concat(line);
                           }
                           else
                           {
                              line = line.concat(prvArr);
                           }
                        }
                        tmpLines.push(line.join(""));
                        linesArr.push(line.join(""));
                        arabicSentence = arSentence ? nxtArr : [];
                        englishSentence = enSentence ? nxtArr : [];
                        line = [];
                        lineWidth = getCharArrWidth(nxtArr) + (char == " " ? spaceWidth : getStringWidth(char));
                     }
                     else
                     {
                        lineWidth += char == " " ? spaceWidth : getStringWidth(char);
                     }
                     if(char == " ")
                     {
                        if(arSentence)
                        {
                           arSpaceIndex = int(arabicSentence.length);
                           enSpaceIndex = -1;
                        }
                        else if(enSentence)
                        {
                           enSpaceIndex = int(englishSentence.length);
                           arSpaceIndex = -1;
                        }
                     }
                  }
                  pos = enclosures.indexOf(char);
                  prv = getPrevLetterType(i,str);
                  nxt = getNextLetterType(i,str,true);
                  nxt2 = getNextLetterType(i,str,false);
                  if(_dir == "LTR" && in_Array(char,specialPunc))
                  {
                     if(prv == "ar")
                     {
                        char += RLM;
                     }
                  }
                  if(prv == "no")
                  {
                     if(tmpDigit != -1)
                     {
                        if(_dir == "RTL")
                        {
                           line.unshift(tmpDigit);
                        }
                        else
                        {
                           line.push(tmpDigit);
                        }
                        tmpDigit = -1;
                     }
                  }
                  if(nxt == "dg")
                  {
                     nxt = prv;
                  }
                  if(pos !== -1)
                  {
                     if(prv == "ar" && nxt == "ar")
                     {
                        char = revEnclosures[pos];
                     }
                     else if(prv == "no" || nxt2 == "no")
                     {
                        if(_dir == "RTL")
                        {
                           char = revEnclosures[pos];
                        }
                     }
                     else if(pos % 2 == 0)
                     {
                        if(_dir == "RTL")
                        {
                           if(prv == "ar" && nxt != "ar" || prv != "ar" && nxt == "ar")
                           {
                              char = revEnclosures[pos];
                           }
                        }
                     }
                     else if(_dir == "RTL")
                     {
                        if(prv == "en" && nxt2 != "en" || prv == "ar" && nxt2 != "ar")
                        {
                           char = revEnclosures[pos];
                        }
                     }
                  }
                  if(prv == nxt)
                  {
                     if(_html)
                     {
                        char = openedTags[tagIndex] != null && char == " " ? (prv == "ar" ? RLM : LRM) + char + (nxt == "ar" ? RLM : LRM) : char;
                        char = openedTags[tagIndex] != null ? getTagsList(openedTags,"op") + char + getTagsList(openedTags,"cl") : char;
                     }
                     if(arSentence)
                     {
                        arabicSentence.unshift(char);
                     }
                     else if(enSentence)
                     {
                        englishSentence.push(char);
                     }
                     else if(_dir == "RTL")
                     {
                        line.unshift(char);
                     }
                     else
                     {
                        line.push(char);
                     }
                  }
                  else
                  {
                     if(arSentence || !enSentence)
                     {
                        if(_dir == "RTL")
                        {
                           line = arabicSentence.concat(line);
                        }
                        else
                        {
                           line = line.concat(arabicSentence);
                        }
                        arabicSentence = [];
                     }
                     else if(enSentence)
                     {
                        if(_dir == "RTL")
                        {
                           line = englishSentence.concat(line);
                        }
                        else
                        {
                           line = line.concat(englishSentence);
                        }
                        englishSentence = [];
                     }
                     if(_html)
                     {
                        char = openedTags[tagIndex] != null && char == " " ? (prv == "ar" ? RLM : LRM) + char + (nxt == "ar" ? RLM : LRM) : char;
                        char = openedTags[tagIndex] != null ? getTagsList(openedTags,"op") + char + getTagsList(openedTags,"cl") : char;
                     }
                     if(_dir == "RTL")
                     {
                        line.unshift(char);
                     }
                     else
                     {
                        line.push(char);
                     }
                  }
               }
            }
         }
         if(arabicSentence.length > 0)
         {
            if(_dir == "RTL")
            {
               line = arabicSentence.concat(line);
            }
            else
            {
               line = line.concat(arabicSentence);
            }
         }
         else if(englishSentence.length > 0)
         {
            if(_dir == "RTL")
            {
               line = englishSentence.concat(line);
            }
            else
            {
               line = line.concat(englishSentence);
            }
         }
         else if(tmpDigit != -1)
         {
            if(_dir == "RTL")
            {
               line.unshift(tmpDigit);
            }
            else
            {
               line.push(tmpDigit);
            }
            tmpDigit = -1;
         }
         tmpLines.push(line.join(""));
         linesArr.push(line.join(""));
         if(tmpLines.length > 1)
         {
            return tmpLines.join(newlineChar);
         }
         return tmpLines[0];
      }
      
      private function getCloseTag(openTag:String) : String
      {
         var tgSplit:Array = null;
         var closeTag:String = null;
         tgSplit = openTag.split(" ");
         if(tgSplit.length > 1)
         {
            closeTag = "</" + tgSplit[0].substr(1) + ">";
         }
         else
         {
            closeTag = "</" + tgSplit[0].substr(1);
         }
         return closeTag;
      }
      
      public function isLatin(char:String) : Boolean
      {
         var cod:uint = 0;
         cod = char.charCodeAt(0);
         if(cod >= 65 && cod <= 90 || cod >= 97 && cod <= 122 || cod >= 192 && cod <= 246 || cod >= 248 && cod <= 255)
         {
            return true;
         }
         return false;
      }
   }
}

