package ui.events
{
   import flash.events.Event;
   
   public class PopupEvent extends Event
   {
      
      public static const REQUEST_SHOW:String = "game_popup_requestshow";
      
      public static const REQUEST_HIDE:String = "game_popup_requesthide";
      
      public static const CONFIRM:String = "confirm";
      
      public static const CANCEL:String = "cancel";
      
      public var sPopupViewID:String;
      
      public function PopupEvent(_sType:String, _sPopupViewID:String, _bBubbles:Boolean = false, _bCancelable:Boolean = false)
      {
         super(_sType,_bBubbles,_bCancelable);
         this.sPopupViewID = _sPopupViewID;
      }
   }
}

