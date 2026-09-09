package com.sarbakan.sbdk.asset
{
   import flash.events.EventDispatcher;
   
   public class AbstractAsset extends EventDispatcher
   {
      
      private var sID:String;
      
      public function AbstractAsset(_sID:String)
      {
         super();
         this.sID = _sID;
         this.init();
      }
      
      public function destroy() : void
      {
      }
      
      override public function toString() : String
      {
         return "[AbstractAsset: " + this.sID + "]";
      }
      
      protected function init() : void
      {
      }
      
      public function get ID() : String
      {
         return this.sID;
      }
   }
}

