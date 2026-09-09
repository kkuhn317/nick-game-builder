package services
{
   import flash.events.TimerEvent;
   import flash.net.URLRequest;
   import services.events.ServiceRequestEvent;
   
   public class WordFilterRequest extends ServiceRequest
   {
      
      public function WordFilterRequest(_sString:String)
      {
         var _oURL:URLRequest = null;
         if(Boolean(ServiceManager.instance.fakedServicePath))
         {
            _oURL = new URLRequest(ServiceManager.instance.serviceDomain + "/" + ServiceManager.instance.fakedServicePath + "/wordFilter/wordfilter.php");
         }
         else
         {
            _oURL = ProxyManager.instance.getServiceUrl("wordfilter");
         }
         var _oParams:Object = {"name":_sString};
         super(_oURL,_oParams);
      }
      
      override public function destroy() : void
      {
         super.destroy();
      }
      
      private function formatResponse(_sResponse:String) : Object
      {
         var _sParam:String = null;
         var _aParam:Array = null;
         var _aResponse:Array = String(_sResponse).split("&");
         var _oData:Object = {};
         for each(_sParam in _aResponse)
         {
            if(_sParam.indexOf("=") != -1)
            {
               _aParam = _sParam.split("=");
               _oData[_aParam[0] as String] = _aParam[1];
            }
         }
         return _oData;
      }
      
      override protected function onResponseReady(_e:TimerEvent) : void
      {
         dispatchEvent(new ServiceRequestEvent(ServiceRequestEvent.RESPONSE,this.formatResponse(oLoader.data)));
         this.destroy();
      }
   }
}

