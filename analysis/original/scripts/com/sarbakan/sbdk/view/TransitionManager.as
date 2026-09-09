package com.sarbakan.sbdk.view
{
   import com.sarbakan.sbdk.asset.AssetReference;
   import com.sarbakan.sbdk.events.TransitionEvent;
   import com.sarbakan.sbdk.utils.EventManager;
   import com.sarbakan.sbdk.utils.ObjectList;
   import flash.events.EventDispatcher;
   
   [Event(name="ERROR",type="com.sarbakan.sbdk.events.TransitionEvent")]
   [Event(name="RESUME",type="com.sarbakan.sbdk.events.TransitionEvent")]
   [Event(name="PAUSE",type="com.sarbakan.sbdk.events.TransitionEvent")]
   [Event(name="COMPLETE",type="com.sarbakan.sbdk.events.TransitionEvent")]
   [Event(name="STOP",type="com.sarbakan.sbdk.events.TransitionEvent")]
   [Event(name="START",type="com.sarbakan.sbdk.events.TransitionEvent")]
   internal class TransitionManager extends EventDispatcher
   {
      
      private static const sTRANSITION_EVENT:String = "TRANSITION_EVENT";
      
      private var lTransitionList:ObjectList;
      
      private var oEventManager:EventManager;
      
      public function TransitionManager()
      {
         super();
         this.init();
      }
      
      public function destroy() : void
      {
         this.lTransitionList.clear();
         this.lTransitionList = null;
         this.oEventManager.clearAll();
         this.oEventManager = null;
      }
      
      public function addAnimTransition(_sTransitionID:String, _oAnimAsset:AssetReference) : void
      {
         var _oTransition:AnimTransitionFactory = null;
         if(this.lTransitionList.find(_sTransitionID) == null)
         {
            _oTransition = new AnimTransitionFactory(_sTransitionID,_oAnimAsset);
            this.lTransitionList.insert(_sTransitionID,_oTransition);
         }
      }
      
      public function addEffectTransition(_sTransitionID:String, _oEffectTransition:AbstractEffectTransition) : void
      {
         if(this.lTransitionList.find(_sTransitionID) == null)
         {
            this.lTransitionList.insert(_sTransitionID,new EffectTransitionFactory(_sTransitionID,_oEffectTransition));
         }
      }
      
      public function removeTransition(_sTransitionID:String) : void
      {
         if(this.lTransitionList.find(_sTransitionID) != null)
         {
            this.lTransitionList.remove(_sTransitionID);
         }
      }
      
      public function getTransition(_sTransitionID:String) : AbstractTransition
      {
         var _oTransitionFactory:AbstractTransitionFactory = this.lTransitionList.find(_sTransitionID);
         if(_oTransitionFactory != null)
         {
            this.oEventManager.addEventListener(sTRANSITION_EVENT + _sTransitionID,_oTransitionFactory,TransitionEvent.COMPLETE,this.onTransitionEvent);
            this.oEventManager.addEventListener(sTRANSITION_EVENT + _sTransitionID,_oTransitionFactory,TransitionEvent.ERROR,this.onTransitionEvent);
            this.oEventManager.addEventListener(sTRANSITION_EVENT + _sTransitionID,_oTransitionFactory,TransitionEvent.PAUSE,this.onTransitionEvent);
            this.oEventManager.addEventListener(sTRANSITION_EVENT + _sTransitionID,_oTransitionFactory,TransitionEvent.RESUME,this.onTransitionEvent);
            this.oEventManager.addEventListener(sTRANSITION_EVENT + _sTransitionID,_oTransitionFactory,TransitionEvent.START,this.onTransitionEvent);
            this.oEventManager.addEventListener(sTRANSITION_EVENT + _sTransitionID,_oTransitionFactory,TransitionEvent.STOP,this.onTransitionEvent);
            return _oTransitionFactory.request();
         }
         return null;
      }
      
      private function init() : void
      {
         this.lTransitionList = new ObjectList();
         this.oEventManager = new EventManager();
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

