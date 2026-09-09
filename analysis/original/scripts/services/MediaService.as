package services
{
   import flash.net.URLRequest;
   
   public class MediaService extends AbstractService
   {
      
      public static const sID:String = "mediaService";
      
      public function MediaService()
      {
         super();
      }
      
      override public function destroy() : void
      {
         super.destroy();
      }
      
      public function getMedias(_sBuilderAlias:String, _sProperty:String) : ServiceRequest
      {
         var _oURL:URLRequest = null;
         var _oParam:Object = null;
         if(Boolean(ServiceManager.instance.fakedServicePath))
         {
            _oURL = new URLRequest(ServiceManager.instance.serviceDomain + "/" + ServiceManager.instance.fakedServicePath + "/mediaList/" + _sBuilderAlias + "_" + _sProperty + ".xml");
         }
         else
         {
            _oURL = ProxyManager.instance.getServiceUrl("getMedias");
            _oParam = {
               "builderType":_sBuilderAlias,
               "property":_sProperty
            };
         }
         return new ServiceRequest(_oURL,_oParam);
      }
      
      override internal function get serviceID() : String
      {
         return sID;
      }
   }
}

