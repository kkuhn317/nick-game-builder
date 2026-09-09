package media.events
{
   import flash.events.Event;
   
   public class MediaEvent extends Event
   {
      
      public static const LIST_LOAD_COMPLETE:String = "list_loadComplete";
      
      public static const LIST_LOAD_ERROR:String = "list_loadError";
      
      public static const MEDIA_ALL_LOAD_COMPLETE:String = "media_loadAllComplete";
      
      public static const MEDIA_LOAD_ERROR:String = "media_loadError";
      
      public static const MEDIA_ALL_RENDERED:String = "media_allRendered";
      
      public static const MEDIA_RENDER_ERROR:String = "media_renderError";
      
      private var sError:String;
      
      public function MediaEvent(_sType:String, _sError:String = null, _bBubbles:Boolean = false, _bCancelable:Boolean = false)
      {
         super(_sType,_bBubbles,_bCancelable);
         this.sError = _sError;
      }
      
      public function get errorMessage() : String
      {
         return this.sError;
      }
   }
}

