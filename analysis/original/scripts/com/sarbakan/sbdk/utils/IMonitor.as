package com.sarbakan.sbdk.utils
{
   public interface IMonitor
   {
      
      function start() : void;
      
      function stop() : void;
      
      function destroy() : void;
      
      function get value() : int;
      
      function get average() : Number;
      
      function get min() : int;
      
      function set min(param1:int) : void;
      
      function get max() : int;
      
      function set max(param1:int) : void;
      
      function get running() : Boolean;
   }
}

