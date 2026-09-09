package com.sarbakan.sbdk.view
{
   import com.sarbakan.sbdk.events.TransitionEvent;
   import com.sarbakan.sbdk.utils.EventManager;
   
   internal class EffectTransitionFactory extends AbstractTransitionFactory
   {
      
      private static const sTRANSITION_EVENT:String = "TRANSITION_EVENT";
      
      private var oTransitionRef:AbstractEffectTransition;
      
      private var oEventManager:EventManager;
      
      public function EffectTransitionFactory(_sId:String, _oTransitionRef:AbstractEffectTransition)
      {
         super(_sId);
         this.oTransitionRef = _oTransitionRef;
         this.oTransitionRef.ID = _sId;
         this.init();
      }
      
      override protected function init() : void
      {
         this.oEventManager = new EventManager();
      }
      
      override public function destroy() : void
      {
         this.oTransitionRef.destroy();
         this.oTransitionRef = null;
         this.oEventManager.clearAll();
         this.oEventManager.destroy();
         this.oEventManager = null;
      }
      
      override public function request() : AbstractTransition
      {
         var _oTransition:AbstractTransition = this.oTransitionRef.copy();
         _oTransition.ID = this.oTransitionRef.ID;
         this.oEventManager.addEventListener(sTRANSITION_EVENT,_oTransition,TransitionEvent.COMPLETE,this.onTransitionEvent);
         this.oEventManager.addEventListener(sTRANSITION_EVENT,_oTransition,TransitionEvent.ERROR,this.onTransitionEvent);
         this.oEventManager.addEventListener(sTRANSITION_EVENT,_oTransition,TransitionEvent.PAUSE,this.onTransitionEvent);
         this.oEventManager.addEventListener(sTRANSITION_EVENT,_oTransition,TransitionEvent.RESUME,this.onTransitionEvent);
         this.oEventManager.addEventListener(sTRANSITION_EVENT,_oTransition,TransitionEvent.START,this.onTransitionEvent);
         this.oEventManager.addEventListener(sTRANSITION_EVENT,_oTransition,TransitionEvent.STOP,this.onTransitionEvent);
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
               this.oEventManager.cleanUp(sTRANSITION_EVENT);
         }
      }
   }
}

