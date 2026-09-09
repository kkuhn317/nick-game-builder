package services.events
{
   import flash.events.Event;
   
   public class ServiceRequestEvent extends Event
   {
      
      public static const RESPONSE:String = "service_response_RESPONSE";
      
      private var oData:*;
      
      public function ServiceRequestEvent(_sType:String, _oData:* = null, _bBubbles:Boolean = false, _bCancelable:Boolean = false)
      {
         super(_sType,_bBubbles,_bCancelable);
         this.oData = _oData;
      }
      
      public function get data() : *
      {
         return this.oData;
      }
   }
}

