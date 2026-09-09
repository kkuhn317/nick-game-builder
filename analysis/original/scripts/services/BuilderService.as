package services
{
   import com.adobe.images.JPGEncoder;
   import com.adobe.images.PNGEncoder;
   import com.sarbakan.sbdk.math.random.Random;
   import com.sarbakan.sbdk.utils.ExternalConfig;
   import flash.display.BitmapData;
   import flash.net.URLRequest;
   import flash.net.URLRequestHeader;
   import flash.utils.ByteArray;
   import services.events.ServiceRequestEvent;
   import utils.Base64;
   
   public class BuilderService extends AbstractService
   {
      
      public static const sID:String = "builderService";
      
      public function BuilderService()
      {
         super();
      }
      
      override public function destroy() : void
      {
         super.destroy();
      }
      
      public function getSavedGames() : ServiceRequest
      {
         var _oURL:URLRequest = null;
         if(Boolean(ServiceManager.instance.fakedServicePath))
         {
            _oURL = new URLRequest(ServiceManager.instance.serviceDomain + "/" + ServiceManager.instance.fakedServicePath + "/savedData/getSavedGames.php");
         }
         else
         {
            _oURL = ProxyManager.instance.getServiceUrl("getSavedGames");
         }
         _oURL.requestHeaders.push(new URLRequestHeader("pragma","no-cache"));
         return new ServiceRequest(_oURL,{"cacheBuster":Random.getInt()});
      }
      
      public function setGameData(_sGameData:String, _sTitle:String, _sBuilderType:String, _sProperty:String, _sBuilderPath:String, _nGameID:int = -1) : ServiceRequest
      {
         var _oURL:URLRequest = null;
         if(Boolean(ServiceManager.instance.fakedServicePath))
         {
            _oURL = new URLRequest(ServiceManager.instance.serviceDomain + "/" + ServiceManager.instance.fakedServicePath + "/savedData/setGameData.php");
         }
         else
         {
            _oURL = ProxyManager.instance.getServiceUrl("setGameData");
         }
         _oURL.url += "?title=" + _sTitle;
         _oURL.url += "&builderType=" + _sBuilderType;
         _oURL.url += "&builderPath=" + _sBuilderPath;
         _oURL.url += "&alias=" + _sProperty;
         if(_nGameID != -1)
         {
            _oURL.url += "&slot=" + _nGameID;
         }
         _oURL.url += "&_rawPost=true";
         var _oHeader:URLRequestHeader = new URLRequestHeader("Content-type","text/html");
         _oURL.requestHeaders.push(_oHeader);
         var _oGameData:ByteArray = new ByteArray();
         _oGameData.writeUTFBytes(_sGameData);
         _oGameData.compress();
         _sGameData = Base64.encodeByteArray(_oGameData);
         var _oCompressedData:ByteArray = new ByteArray();
         _oCompressedData.writeUTFBytes(_sGameData);
         _oURL.data = _oCompressedData;
         var _oRequest:ServiceRequest = new ServiceRequest(_oURL);
         oEventManager.addEventListener(sEVENT_MANAGER_ID,_oRequest,ServiceRequestEvent.RESPONSE,this.onSave);
         return _oRequest;
      }
      
      public function publishGame(_nGameID:int, _sBuilderType:String, _sCategory:String, _sBuilderPath:String, _sGameData:String, _sTitle:String, _oBitmapData:BitmapData) : ServiceRequest
      {
         var _oImage:ByteArray = null;
         var _oURL:URLRequest = null;
         var _oGameData:ByteArray = new ByteArray();
         _oGameData.writeUTFBytes(_sGameData);
         _oGameData.compress();
         _sGameData = Base64.encodeByteArray(_oGameData);
         if(Boolean(ServiceManager.instance.fakedServicePath))
         {
            _oImage = PNGEncoder.encode(_oBitmapData);
         }
         else
         {
            _oImage = new JPGEncoder(BuilderConfig.nDEFAULT_JPG_QUALITY).encode(_oBitmapData);
         }
         _oImage.position = 0;
         var _sImage:String = Base64.encodeByteArray(_oImage);
         var _oXML:XML = <answers collectionID={ExternalConfig.instance.getProperty("collectionID")}>
								
								<answer tag="slot">
									{_nGameID}
								</answer>
				
								<answer tag="builderType">
									{_sBuilderType}
								</answer>
				
								<answer tag="category">
									{_sCategory}
								</answer>
									
								<answer tag="builderPath">
									{_sBuilderPath}
								</answer>
								
								<answer tag="gamedata">
									{_sGameData}
								</answer>
									
								<answer tag="title">
									{_sTitle}
								</answer>
				
								<answer tag="imagedata">
									{_sImage}
								</answer>
								
							</answers>;
         if(Boolean(ServiceManager.instance.fakedServicePath))
         {
            _oURL = new URLRequest(ServiceManager.instance.serviceDomain + "/" + ServiceManager.instance.fakedServicePath + "/publish/publish.php");
         }
         else
         {
            _oURL = ProxyManager.instance.getServiceUrl("publishGame");
         }
         var _oParams:Object = {"xml":_oXML.toString()};
         var _oRequest:ServiceRequest = new ServiceRequest(_oURL,_oParams);
         oEventManager.addEventListener(sEVENT_MANAGER_ID,_oRequest,ServiceRequestEvent.RESPONSE,this.onPublish);
         return _oRequest;
      }
      
      public function checkWordFilter(_sString:String) : ServiceRequest
      {
         return new WordFilterRequest(_sString);
      }
      
      private function onSave(_e:ServiceRequestEvent) : void
      {
         oEventManager.removeEventListener(sEVENT_MANAGER_ID,_e.target as ServiceRequest,ServiceRequestEvent.RESPONSE,this.onSave);
         ProxyManager.instance.onGameSaved();
      }
      
      private function onPublish(_e:ServiceRequestEvent) : void
      {
         oEventManager.removeEventListener(sEVENT_MANAGER_ID,_e.target as ServiceRequest,ServiceRequestEvent.RESPONSE,this.onPublish);
         ProxyManager.instance.onGamePublished();
      }
      
      override internal function get serviceID() : String
      {
         return sID;
      }
   }
}

