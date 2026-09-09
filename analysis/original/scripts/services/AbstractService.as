package services
{
   import com.sarbakan.sbdk.utils.EventManager;
   
   public class AbstractService
   {
      
      protected static const sEVENT_MANAGER_ID:String = "eventManager";
      
      protected var oEventManager:EventManager;
      
      public function AbstractService()
      {
         super();
         this.init();
      }
      
      public function destroy() : void
      {
         if(Boolean(this.oEventManager))
         {
            this.oEventManager.destroy();
         }
         this.oEventManager = null;
      }
      
      private function init() : void
      {
         this.oEventManager = new EventManager();
      }
      
      internal function get serviceID() : String
      {
         return null;
      }
   }
}

