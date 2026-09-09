package services
{
   import com.sarbakan.sbdk.errors.ErrorMessages;
   import com.sarbakan.sbdk.utils.ExternalConfig;
   import com.sarbakan.sbdk.utils.ObjectList;
   
   public class ServiceManager
   {
      
      private static var oInstance:ServiceManager;
      
      private static var bAllowConstruction:Boolean = false;
      
      private var sServiceDomain:String;
      
      private var sFakedServicePath:String;
      
      private var lServicesList:ObjectList;
      
      private var aPendingRequests:Array;
      
      public function ServiceManager()
      {
         super();
         if(!bAllowConstruction)
         {
            throw new Error(ErrorMessages.sSINGLETON_ERROR);
         }
         this.init();
      }
      
      public static function get instance() : ServiceManager
      {
         if(!oInstance)
         {
            bAllowConstruction = true;
            oInstance = new ServiceManager();
            bAllowConstruction = false;
         }
         return oInstance;
      }
      
      public function destroy() : void
      {
         var _oService:AbstractService = null;
         if(Boolean(this.lServicesList))
         {
            for each(_oService in this.lServicesList.object)
            {
               _oService.destroy();
            }
            this.lServicesList.destroy();
         }
         this.lServicesList = null;
         this.aPendingRequests = null;
         oInstance = null;
      }
      
      public function addService(_oService:AbstractService) : void
      {
         this.lServicesList.insert(_oService.serviceID,_oService);
      }
      
      public function getService(_sID:String) : AbstractService
      {
         return this.lServicesList.find(_sID);
      }
      
      internal function addPendingRequest(_oRequest:ServiceRequest) : void
      {
         this.aPendingRequests.push(_oRequest);
      }
      
      internal function removePendingRequest(_oRequest:ServiceRequest) : void
      {
         this.aPendingRequests.splice(this.aPendingRequests.indexOf(_oRequest));
      }
      
      private function init() : void
      {
         this.sServiceDomain = ExternalConfig.instance.getProperty(CommonConfig.sCONFIG_DOMAIN_SERVICES);
         this.sFakedServicePath = ExternalConfig.instance.getProperty(CommonConfig.sCONFIG_FAKED_SERVICES_PATH);
         this.lServicesList = new ObjectList();
         this.aPendingRequests = new Array();
      }
      
      public function get serviceDomain() : String
      {
         return this.sServiceDomain;
      }
      
      public function get fakedServicePath() : String
      {
         return this.sFakedServicePath;
      }
   }
}

