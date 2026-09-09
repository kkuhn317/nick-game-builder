package services
{
   import com.sarbakan.sbdk.errors.ErrorMessages;
   import com.sarbakan.sbdk.utils.EventManager;
   import com.sarbakan.sbdk.utils.ExternalConfig;
   import com.sarbakan.sbdk.utils.FrameTimer;
   import flash.display.Loader;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.TimerEvent;
   import flash.external.ExternalInterface;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import services.events.GameLoadEvent;
   import services.events.LoginEvent;
   
   public class ProxyManager extends EventDispatcher
   {
      
      private static var oInstance:ProxyManager;
      
      private static const sEVENT_MANAGER_ID:String = "eventManager";
      
      public static const PROXY_LOADED:String = "PROXY_READY";
      
      public static const PROXY_ERROR:String = "PROXY_ERROR";
      
      private static var bAllowConstruction:Boolean = false;
      
      private var oEventManager:EventManager;
      
      private var oLoader:Loader;
      
      private var oFakeLoginTimer:FrameTimer;
      
      private var oProxy:*;
      
      public function ProxyManager()
      {
         super();
         if(!bAllowConstruction)
         {
            throw new Error(ErrorMessages.sSINGLETON_ERROR);
         }
         this.init();
      }
      
      public static function get instance() : ProxyManager
      {
         if(!oInstance)
         {
            bAllowConstruction = true;
            oInstance = new ProxyManager();
            bAllowConstruction = false;
         }
         return oInstance;
      }
      
      public function destroy() : void
      {
         this.oLoader = null;
         this.oProxy = null;
         if(Boolean(this.oFakeLoginTimer))
         {
            this.oFakeLoginTimer.destroy();
         }
         this.oFakeLoginTimer = null;
         if(Boolean(this.oEventManager))
         {
            this.oEventManager.destroy();
         }
         this.oEventManager = null;
         oInstance = null;
      }
      
      public function load() : void
      {
         this.oLoader = new Loader();
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oLoader.contentLoaderInfo,Event.COMPLETE,this.onLoadComplete);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oLoader.contentLoaderInfo,IOErrorEvent.IO_ERROR,this.onLoadError);
         var _sProxyFile:String = ExternalConfig.instance.getProperty(CommonConfig.sCONFIG_PROXY_PATH_MODULE);
         var _oUrl:URLRequest = new URLRequest(_sProxyFile);
         var _oContext:LoaderContext = new LoaderContext(false,new ApplicationDomain(ApplicationDomain.currentDomain));
         this.oLoader.load(_oUrl,_oContext);
      }
      
      public function checkLogin() : void
      {
         if(Boolean(ServiceManager.instance.fakedServicePath))
         {
            this.oFakeLoginTimer = new FrameTimer(60,1,false);
            this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oFakeLoginTimer,TimerEvent.TIMER,this.onFakeLoginTimer);
            this.oFakeLoginTimer.start();
         }
         else
         {
            this.oProxy.execute("doCheckLoginSwf");
         }
      }
      
      internal function getServiceUrl(_sService:String) : URLRequest
      {
         return new URLRequest(ServiceManager.instance.serviceDomain + this.oProxy.getProperty(_sService));
      }
      
      public function sendTrackingCall(_sCallback:String, _sArgs:String = null) : void
      {
         var _sFunctionName:String = ExternalConfig.instance.getProperty("tracking_functionName");
         var _sJavascriptArgs:String = ExternalConfig.instance.getProperty(_sCallback);
         if(_sArgs != null)
         {
            _sJavascriptArgs += _sArgs;
         }
         if(ExternalInterface.available)
         {
            ExternalInterface.call(_sFunctionName,_sJavascriptArgs);
         }
      }
      
      public function sendPlayReportingCall(_sBuilderType:String, _sPropertyAlias:String, _sGameAlias:String) : void
      {
         var _sFunctionName:String = ExternalConfig.instance.getProperty("playCountTrackingFunction");
         var _sJavascriptArgs:String = ExternalConfig.instance.getProperty("playCountTrackingPrefix") + "-" + _sBuilderType + "-" + _sPropertyAlias + "-" + _sBuilderType;
         if(ExternalInterface.available)
         {
            ExternalInterface.call(_sFunctionName,_sJavascriptArgs);
         }
      }
      
      private function init() : void
      {
         this.oEventManager = new EventManager();
      }
      
      private function onLoadComplete(_e:Event) : void
      {
         this.oEventManager.cleanUp(sEVENT_MANAGER_ID);
         this.oProxy = _e.target.content.proxy;
         this.oProxy.responder = this;
         this.oProxy.addEventListener(PROXY_LOADED,this.onProxyReady);
         this.oProxy.addEventListener(PROXY_ERROR,this.onProxyError);
         var _sPropFile:String = ExternalConfig.instance.getProperty(CommonConfig.sCONFIG_PROXY_PATH_PROPS);
         this.oProxy.load(_sPropFile);
      }
      
      private function onLoadError(_e:IOErrorEvent) : void
      {
         this.oEventManager.cleanUp(sEVENT_MANAGER_ID);
         dispatchEvent(_e);
      }
      
      private function onProxyReady(_e:Event) : void
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.addCallback("onLoadGame",this.onLoadGame);
            ExternalInterface.addCallback("onLoginCancel",this.onLoginCancel);
         }
         dispatchEvent(new Event(PROXY_LOADED));
      }
      
      private function onProxyError(_e:ErrorEvent) : void
      {
      }
      
      private function onFakeLoginTimer(_e:Event) : void
      {
         this.oEventManager.removeEventListener(sEVENT_MANAGER_ID,this.oFakeLoginTimer,_e.type,this.onFakeLoginTimer);
         this.oFakeLoginTimer.destroy();
         this.oFakeLoginTimer = null;
         this.doLoginResponse([{"screenName":"username"}]);
      }
      
      public function doResponseEmpty(... args) : void
      {
      }
      
      public function doLoginResponse(... args) : void
      {
         var _oUser:Object = args[0][0];
         var _sUserName:String = _oUser.screenName;
         dispatchEvent(new LoginEvent(LoginEvent.LOGIN_SUCCEED,_sUserName));
      }
      
      public function onLoadGame(_nSlotID:Number) : void
      {
         dispatchEvent(new GameLoadEvent(GameLoadEvent.REQUEST_LOAD,_nSlotID));
      }
      
      public function onLoginCancel() : void
      {
         dispatchEvent(new LoginEvent(LoginEvent.LOGIN_CANCEL));
      }
      
      public function onGameCreated() : void
      {
         if(ExternalInterface.available)
         {
            this.oProxy.execute("onGameCreated");
         }
      }
      
      public function onGameTested() : void
      {
         if(ExternalInterface.available)
         {
            this.oProxy.execute("onGameTested");
         }
      }
      
      public function onGameSaved() : void
      {
         this.sendTrackingCall("tracking_callID_save");
         if(ExternalInterface.available)
         {
            this.oProxy.execute("onGameSaved");
         }
      }
      
      public function onGamePublished() : void
      {
         this.sendTrackingCall("tracking_callID_publish");
         if(ExternalInterface.available)
         {
            this.oProxy.execute("onGamePublished");
         }
      }
   }
}

