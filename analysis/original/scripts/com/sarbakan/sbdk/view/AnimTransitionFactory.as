package com.sarbakan.sbdk.view
{
   import com.sarbakan.sbdk.asset.AssetReference;
   import com.sarbakan.sbdk.events.TransitionEvent;
   import com.sarbakan.sbdk.utils.EventManager;
   
   internal class AnimTransitionFactory extends AbstractTransitionFactory
   {
      
      private static const sTRANSITION_EVENT:String = "TRANSITION_EVENT";
      
      private var oLocation:AssetReference;
      
      private var oEventManager:EventManager;
      
      public function AnimTransitionFactory(_sId:String, _oLocation:AssetReference)
      {
         super(_sId);
         this.oLocation = _oLocation;
         this.init();
      }
      
      override protected function init() : void
      {
         this.oEventManager = new EventManager();
      }
      
      override public function destroy() : void
      {
         this.oEventManager.clearAll();
         this.oEventManager.destroy();
         this.oEventManager = null;
      }
      
      override public function request() : AbstractTransition
      {
         var _oTransition:AbstractTransition = new AnimTransition(this.oLocation);
         _oTransition.ID = ID;
         this.oEventManager.addEventListener(sTRANSITION_EVENT + ID,_oTransition,TransitionEvent.COMPLETE,this.onTransitionEvent);
         this.oEventManager.addEventListener(sTRANSITION_EVENT + ID,_oTransition,TransitionEvent.ERROR,this.onTransitionEvent);
         this.oEventManager.addEventListener(sTRANSITION_EVENT + ID,_oTransition,TransitionEvent.PAUSE,this.onTransitionEvent);
         this.oEventManager.addEventListener(sTRANSITION_EVENT + ID,_oTransition,TransitionEvent.RESUME,this.onTransitionEvent);
         this.oEventManager.addEventListener(sTRANSITION_EVENT + ID,_oTransition,TransitionEvent.START,this.onTransitionEvent);
         this.oEventManager.addEventListener(sTRANSITION_EVENT + ID,_oTransition,TransitionEvent.STOP,this.onTransitionEvent);
         return _oTransition;
      }
      
      private function onTransitionEvent(_oEvent:TransitionEvent) : void
      {
         dispatchEvent(_oEvent);
         switch(_oEvent.type)
         {
            case TransitionEvent.COMPLETE:
            case TransitionEvent.ERROR:
            case TransitionEvent.STOP:
               this.oEventManager.cleanUp(sTRANSITION_EVENT + _oEvent.transitionID);
         }
      }
   }
}

