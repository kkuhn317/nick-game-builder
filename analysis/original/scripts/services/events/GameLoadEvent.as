package services.events
{
   import flash.events.Event;
   
   public class GameLoadEvent extends Event
   {
      
      public static const REQUEST_LOAD:String = "gameRequestLoad";
      
      public static const LOAD_COMPLETE:String = "gameLoadComplete";
      
      public static const LOAD_ERROR:String = "gameLoadError";
      
      private var nSlotID:int;
      
      public function GameLoadEvent(type:String, _nSlotID:int, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super(type,bubbles,cancelable);
         this.nSlotID = _nSlotID;
      }
      
      public function get slotID() : int
      {
         return this.nSlotID;
      }
   }
}

