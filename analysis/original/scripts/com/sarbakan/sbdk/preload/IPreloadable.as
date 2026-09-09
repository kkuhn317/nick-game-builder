package com.sarbakan.sbdk.preload
{
   import flash.events.IEventDispatcher;
   
   public interface IPreloadable extends IEventDispatcher
   {
      
      function destroy() : void;
      
      function start() : void;
      
      function stop() : void;
      
      function get fileName() : String;
      
      function get ID() : String;
      
      function set ID(param1:String) : void;
      
      function get priority() : int;
      
      function set priority(param1:int) : void;
      
      function get isLoading() : Boolean;
      
      function get isGroup() : Boolean;
   }
}

