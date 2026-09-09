package gamePlayer.viewport
{
   import flash.events.Event;
   
   public class ViewportEvent extends Event
   {
      
      public static const EASING_COMPLETE:String = "easing_complete";
      
      public function ViewportEvent(_sType:String, _bBubbles:Boolean = false, _bCancelable:Boolean = false)
      {
         super(_sType,_bBubbles,_bCancelable);
      }
   }
}

