package com.sarbakan.sbdk.view
{
   import flash.events.EventDispatcher;
   
   internal class AbstractTransitionFactory extends EventDispatcher
   {
      
      private var sId:String;
      
      public function AbstractTransitionFactory(_sId:String)
      {
         super();
         this.sId = _sId;
      }
      
      protected function init() : void
      {
      }
      
      public function destroy() : void
      {
      }
      
      public function request() : AbstractTransition
      {
         return null;
      }
      
      public function get ID() : String
      {
         return this.sId;
      }
   }
}

