package com.sarbakan.sbdk.tools.logger
{
   import com.sarbakan.sbdk.utils.AbstractEnumeration;
   
   public class LogLevel extends AbstractEnumeration
   {
      
      public static const DEBUG:LogLevel = new LogLevel("DEBUG",oProtectionFlag);
      
      public static const INFO:LogLevel = new LogLevel("INFO",oProtectionFlag);
      
      public static const WARNING:LogLevel = new LogLevel("WARNING",oProtectionFlag);
      
      public static const ERROR:LogLevel = new LogLevel("ERROR",oProtectionFlag);
      
      public static const FATAL:LogLevel = new LogLevel("FATAL",oProtectionFlag);
      
      public static const SBDK:LogLevel = new LogLevel("SBDK",oProtectionFlag);
      
      public function LogLevel(_sName:String, _oProtectionFlag:Object)
      {
         super(_sName,_oProtectionFlag);
      }
   }
}

