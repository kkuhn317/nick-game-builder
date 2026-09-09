package data
{
   import com.sarbakan.sbdk.errors.ErrorMessages;
   import com.sarbakan.sbdk.math.random.Random;
   import com.sarbakan.sbdk.utils.EventManager;
   import com.sarbakan.sbdk.utils.ObjectList;
   import data.events.GameDataEvent;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.net.URLRequest;
   import flash.net.URLRequestHeader;
   import services.GameDataService;
   import services.ServiceManager;
   import services.ServiceRequest;
   import services.events.ServiceRequestEvent;
   
   public class GameDataManager extends EventDispatcher
   {
      
      private static var oInstance:GameDataManager;
      
      private static const sEVENT_MANAGER_ID:String = "eventManager";
      
      private static var bAllowConstruction:Boolean = false;
      
      private var oEventManager:EventManager;
      
      private var lGameData:ObjectList;
      
      public function GameDataManager()
      {
         super();
         if(!bAllowConstruction)
         {
            throw new Error(ErrorMessages.sSINGLETON_ERROR);
         }
         this.init();
      }
      
      public static function get instance() : GameDataManager
      {
         if(!oInstance)
         {
            bAllowConstruction = true;
            oInstance = new GameDataManager();
            bAllowConstruction = false;
         }
         return oInstance;
      }
      
      public function destroy() : void
      {
         var _oGameData:GameData = null;
         if(Boolean(this.lGameData))
         {
            for each(_oGameData in this.lGameData.object)
            {
               _oGameData.destroy();
            }
            this.lGameData.destroy();
         }
         this.lGameData = null;
         if(Boolean(this.oEventManager))
         {
            this.oEventManager.destroy();
         }
         this.oEventManager = null;
         oInstance = null;
      }
      
      public function getGameData(_sAlias:String) : GameData
      {
         return this.lGameData.find(_sAlias);
      }
      
      public function loadGameData(_sAlias:String) : void
      {
         var _oService:GameDataService = ServiceManager.instance.getService(GameDataService.sID) as GameDataService;
         var _oRequest:ServiceRequest = _oService.getGameData(_sAlias);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,_oRequest,ServiceRequestEvent.RESPONSE,this.onGameDataLoadComplete,false,0,true,_sAlias);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,_oRequest,IOErrorEvent.IO_ERROR,this.onGameDataLoadError);
      }
      
      public function loadGameDataBySlotID(_nSlotID:uint) : void
      {
         var _oService:GameDataService = ServiceManager.instance.getService(GameDataService.sID) as GameDataService;
         var _oRequest:ServiceRequest = _oService.getGameDataBySlotID(_nSlotID);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,_oRequest,ServiceRequestEvent.RESPONSE,this.onGameDataBySlotComplete);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,_oRequest,IOErrorEvent.IO_ERROR,this.onGameDataLoadError);
      }
      
      private function init() : void
      {
         this.oEventManager = new EventManager();
         this.lGameData = new ObjectList();
      }
      
      private function onGameDataBySlotComplete(_e:ServiceRequestEvent) : void
      {
         var _oUrl:URLRequest = null;
         var _oRequest:ServiceRequest = null;
         var _oResponse:XML = new XML(_e.data);
         if(_oResponse.data.@file != "")
         {
            _oUrl = new URLRequest(_oResponse.data.@file);
            _oUrl.requestHeaders.push(new URLRequestHeader("pragma","no-cache"));
            _oRequest = new ServiceRequest(_oUrl,{"cacheBuster":Random.getInt()});
            this.oEventManager.addEventListener(sEVENT_MANAGER_ID,_oRequest,ServiceRequestEvent.RESPONSE,this.onGameDataLoadComplete);
         }
         else
         {
            this.onGameDataLoadComplete(_e);
         }
      }
      
      private function onGameDataLoadComplete(_e:ServiceRequestEvent, _sGameAlias:String = null) : void
      {
         var _sData:String = null;
         var _oResponse:XML = null;
         if(_e.data.indexOf("<response>") == -1)
         {
            _sData = _e.data;
         }
         else
         {
            _oResponse = new XML(_e.data);
            _sData = _oResponse.data;
         }
         var _oGameData:GameData = new GameData(_sData);
         if(_sGameAlias != null)
         {
            this.lGameData.insert(_sGameAlias,_oGameData);
         }
         dispatchEvent(new GameDataEvent(GameDataEvent.COMPLETE,_oGameData));
      }
      
      private function onGameDataLoadError(_e:IOErrorEvent) : void
      {
         dispatchEvent(new GameDataEvent(GameDataEvent.ERROR,null,_e.text));
      }
   }
}

