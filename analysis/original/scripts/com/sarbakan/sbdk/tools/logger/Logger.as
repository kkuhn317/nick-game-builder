package com.sarbakan.sbdk.tools.logger
{
   import com.sarbakan.sbdk.errors.ErrorMessages;
   import com.sarbakan.sbdk.events.LogEvent;
   import flash.events.EventDispatcher;
   
   [Event(name="LOG",type="com.sarbakan.sbdk.events.LogEvent")]
   public class Logger extends EventDispatcher
   {
      
      private static var oInstance:Logger;
      
      private static var bAllowConstruction:Boolean = false;
      
      public function Logger()
      {
         super();
         if(!bAllowConstruction)
         {
            throw new Error(ErrorMessages.sSINGLETON_ERROR);
         }
      }
      
      public static function get instance() : Logger
      {
         if(!oInstance)
         {
            bAllowConstruction = true;
            oInstance = new Logger();
            bAllowConstruction = false;
         }
         return oInstance;
      }
      
      public function destroy() : void
      {
         oInstance = null;
      }
      
      public function logSBDK(_sMessage:String, _sFunction:String = null, _sClass:String = null) : void
      {
         this.formatLogMessage(_sMessage,LogLevel.SBDK,_sFunction,_sClass);
      }
      
      public function logDebug(_sMessage:String, _sFunction:String = null, _sClass:String = null) : void
      {
         this.formatLogMessage(_sMessage,LogLevel.DEBUG,_sFunction,_sClass);
      }
      
      public function logInfo(_sMessage:String, _sFunction:String = null, _sClass:String = null) : void
      {
         this.formatLogMessage(_sMessage,LogLevel.INFO,_sFunction,_sClass);
      }
      
      public function logWarning(_sMessage:String, _sFunction:String = null, _sClass:String = null) : void
      {
         this.formatLogMessage(_sMessage,LogLevel.WARNING,_sFunction,_sClass);
      }
      
      public function logError(_sMessage:String, _sFunction:String = null, _sClass:String = null) : void
      {
         this.formatLogMessage(_sMessage,LogLevel.ERROR,_sFunction,_sClass);
      }
      
      public function logAssertError(_sMessage:String, _sFunction:String = null, _sClass:String = null) : void
      {
         this.formatLogMessage(_sMessage,LogLevel.ERROR,_sFunction,_sClass);
      }
      
      public function logFatal(_sMessage:String, _sFunction:String = null, _sClass:String = null) : void
      {
         this.formatLogMessage(_sMessage,LogLevel.FATAL,_sFunction,_sClass);
      }
      
      private function formatLogMessage(_sMessage:String, _oLogLevel:LogLevel, _sFunction:String, _sClass:String) : void
      {
         dispatchEvent(new LogEvent(LogEvent.LOG,false,false,_sClass,_sFunction,_sMessage,_oLogLevel));
      }
   }
}

