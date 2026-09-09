package com.sarbakan.sbdk.events
{
   import com.sarbakan.sbdk.tools.logger.LogLevel;
   import flash.events.Event;
   
   public class LogEvent extends Event
   {
      
      public static const LOG:String = "sbdk_log";
      
      public static const CONNECTED:String = "sbdk_connected";
      
      public static const ERROR:String = "sbdk_error";
      
      private var sScope:String;
      
      private var sFunctionDef:String;
      
      private var sMsg:String;
      
      private var oLevel:LogLevel;
      
      private var sError:String;
      
      public function LogEvent(_sType:String, _bBubbles:Boolean, _bCancelable:Boolean, _sScope:String, _sFunctionDef:String, _sMsg:String, _oLevel:LogLevel, _sError:String = null)
      {
         super(_sType,_bBubbles,_bCancelable);
         this.sScope = _sScope;
         this.sFunctionDef = _sFunctionDef;
         this.sMsg = _sMsg;
         this.oLevel = _oLevel;
         this.sError = _sError;
      }
      
      override public function clone() : Event
      {
         return new LogEvent(type,bubbles,cancelable,this.scope,this.functionDef,this.msg,this.level,this.error);
      }
      
      override public function toString() : String
      {
         return formatToString("StateEvent","type","bubbles","cancelable","scope","functionDef","msg","level","error");
      }
      
      public function get scope() : String
      {
         return this.sScope;
      }
      
      public function get functionDef() : String
      {
         return this.sFunctionDef;
      }
      
      public function get msg() : String
      {
         return this.sMsg;
      }
      
      public function get level() : LogLevel
      {
         return this.oLevel;
      }
      
      public function get error() : String
      {
         return this.sError;
      }
   }
}

