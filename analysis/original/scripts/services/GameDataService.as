package services
{
   import flash.net.URLRequest;
   import flash.net.URLRequestHeader;
   
   public class GameDataService extends AbstractService
   {
      
      public static const sID:String = "gameDataService";
      
      public function GameDataService()
      {
         super();
      }
      
      override public function destroy() : void
      {
         super.destroy();
      }
      
      public function getTemplateList(_sBuilderAlias:String, _sPropertyAlias:String) : ServiceRequest
      {
         var _oURL:URLRequest = null;
         var _oParams:Object = null;
         if(Boolean(ServiceManager.instance.fakedServicePath))
         {
            _oURL = new URLRequest(ServiceManager.instance.serviceDomain + "/" + ServiceManager.instance.fakedServicePath + "/templateList/" + _sBuilderAlias + "_" + _sPropertyAlias + ".xml");
         }
         else
         {
            _oURL = ProxyManager.instance.getServiceUrl("getTemplates");
            _oParams = {
               "builderType":_sBuilderAlias,
               "property":_sPropertyAlias
            };
         }
         return new ServiceRequest(_oURL,_oParams);
      }
      
      public function getGameData(_sAlias:String) : ServiceRequest
      {
         var _oURL:URLRequest = null;
         var _oParams:Object = null;
         if(Boolean(ServiceManager.instance.fakedServicePath))
         {
            _oURL = new URLRequest(ServiceManager.instance.serviceDomain + "/" + ServiceManager.instance.fakedServicePath + "/template/" + _sAlias + ".xml");
         }
         else
         {
            _oURL = ProxyManager.instance.getServiceUrl("getGameData");
            _oParams = {"alias":_sAlias};
         }
         return new ServiceRequest(_oURL,_oParams);
      }
      
      public function getGameDataBySlotID(_nSlotID:uint) : ServiceRequest
      {
         var _oURL:URLRequest = null;
         var _oParams:Object = {"slot":_nSlotID};
         if(Boolean(ServiceManager.instance.fakedServicePath))
         {
            _oURL = new URLRequest(ServiceManager.instance.serviceDomain + "/" + ServiceManager.instance.fakedServicePath + "/savedData/getGameData.php");
         }
         else
         {
            _oURL = ProxyManager.instance.getServiceUrl("getGameData");
         }
         _oURL.requestHeaders.push(new URLRequestHeader("pragma","no-cache"));
         return new ServiceRequest(_oURL,_oParams);
      }
      
      override internal function get serviceID() : String
      {
         return sID;
      }
   }
}

