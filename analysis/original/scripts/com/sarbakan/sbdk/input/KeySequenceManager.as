package com.sarbakan.sbdk.input
{
   import com.sarbakan.sbdk.events.SequenceEvent;
   import com.sarbakan.sbdk.utils.EventManager;
   import com.sarbakan.sbdk.utils.ObjectList;
   import flash.display.Stage;
   import flash.events.EventDispatcher;
   
   [Event(name="SEQUENCE_UNIT",type="com.sarbakan.sbdk.events.SequenceEvent")]
   [Event(name="SEQUENCE_FAILED",type="com.sarbakan.sbdk.events.SequenceEvent")]
   [Event(name="SEQUENCE_COMPLETED",type="com.sarbakan.sbdk.events.SequenceEvent")]
   public class KeySequenceManager extends EventDispatcher
   {
      
      private var oEventManager:EventManager;
      
      private var oStage:Stage;
      
      private var lSequences:ObjectList;
      
      public function KeySequenceManager(_oStage:Stage)
      {
         super();
         this.oStage = _oStage;
         this.init();
      }
      
      public function addSequence(_sSequenceID:String, _oKeySequence:KeySequence) : void
      {
         this.lSequences.insert(_sSequenceID,_oKeySequence);
         this.oEventManager.addEventListener(_sSequenceID,_oKeySequence,SequenceEvent.SEQUENCE_COMPLETED,this.onSequence);
         this.oEventManager.addEventListener(_sSequenceID,_oKeySequence,SequenceEvent.SEQUENCE_FAILED,this.onSequence);
         this.oEventManager.addEventListener(_sSequenceID,_oKeySequence,SequenceEvent.SEQUENCE_UNIT,this.onSequence);
         _oKeySequence.start(_sSequenceID,this.oStage);
      }
      
      override public function toString() : String
      {
         var i:KeySequence = null;
         var _sString:String = "";
         for each(i in this.lSequences.object)
         {
            _sString += i.toString() + "\n";
         }
         return _sString;
      }
      
      public function removeSequence(_sSequenceID:String) : void
      {
         this.lSequences.remove(_sSequenceID);
         this.oEventManager.cleanUp(_sSequenceID);
      }
      
      public function destroy() : void
      {
         var _oSequence:KeySequence = null;
         for each(_oSequence in this.lSequences.object)
         {
            _oSequence.destroy();
         }
         this.oEventManager.destroy();
         this.oEventManager = null;
         this.oStage = null;
      }
      
      private function init() : void
      {
         this.lSequences = new ObjectList();
         this.oEventManager = new EventManager();
      }
      
      private function onSequence(_e:SequenceEvent) : void
      {
         dispatchEvent(_e);
      }
   }
}

