package com.sarbakan.sbdk.sound.vomanager
{
   public class DefaultPhonemeConverter extends AbstractPhonemeConverter
   {
      
      private static const sPHONEME_1:String = "P_1";
      
      private static const sPHONEME_2:String = "P_2";
      
      private static const sPHONEME_3:String = "P_3";
      
      private static const sPHONEME_4:String = "P_4";
      
      private static const sPHONEME_5:String = "P_5";
      
      private static const sPHONEME_6:String = "P_6";
      
      private static const sPHONEME_7:String = "P_7";
      
      private static const sPHONEME_8:String = "P_8";
      
      private static const sPHONEME_9:String = "P_9";
      
      public function DefaultPhonemeConverter()
      {
         super();
      }
      
      override protected function init() : void
      {
         setPhoneme("AA",sPHONEME_1);
         setPhoneme("AH",sPHONEME_1);
         setPhoneme("h",sPHONEME_1);
         setPhoneme("A0",sPHONEME_2);
         setPhoneme("AW",sPHONEME_2);
         setPhoneme("OW",sPHONEME_2);
         setPhoneme("OY",sPHONEME_2);
         setPhoneme("UH",sPHONEME_2);
         setPhoneme("UW",sPHONEME_2);
         setPhoneme("EH",sPHONEME_3);
         setPhoneme("AE",sPHONEME_3);
         setPhoneme("IH",sPHONEME_3);
         setPhoneme("AY",sPHONEME_3);
         setPhoneme("y",sPHONEME_4);
         setPhoneme("IY",sPHONEME_4);
         setPhoneme("EY",sPHONEME_4);
         setPhoneme("r",sPHONEME_5);
         setPhoneme("ER",sPHONEME_5);
         setPhoneme("l",sPHONEME_6);
         setPhoneme("w",sPHONEME_7);
         setPhoneme("CH",sPHONEME_7);
         setPhoneme("j",sPHONEME_7);
         setPhoneme("SH",sPHONEME_7);
         setPhoneme("ZH",sPHONEME_7);
         setPhoneme("n",sPHONEME_8);
         setPhoneme("NG",sPHONEME_8);
         setPhoneme("DH",sPHONEME_8);
         setPhoneme("d",sPHONEME_8);
         setPhoneme("g",sPHONEME_8);
         setPhoneme("t",sPHONEME_8);
         setPhoneme("z",sPHONEME_8);
         setPhoneme("s",sPHONEME_8);
         setPhoneme("x",sPHONEME_9);
         setPhoneme("f",sPHONEME_9);
         setPhoneme("v",sPHONEME_9);
         setPhoneme("m",sPHONEME_9);
         setPhoneme("b",sPHONEME_9);
         setPhoneme("p",sPHONEME_9);
      }
   }
}

