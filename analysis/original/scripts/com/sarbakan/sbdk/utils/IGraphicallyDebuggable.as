package com.sarbakan.sbdk.utils
{
   import flash.display.DisplayObjectContainer;
   
   public interface IGraphicallyDebuggable
   {
      
      function enableGraphicDebug(param1:DisplayObjectContainer) : void;
      
      function disableGraphicDebug() : void;
   }
}

