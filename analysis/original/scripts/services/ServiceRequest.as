package services
{
   import com.sarbakan.sbdk.utils.FrameTimer;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.TimerEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   import services.events.ServiceRequestEvent;
   
   public class ServiceRequest extends EventDispatcher
   {
      
      protected var oLoader:URLLoader;
      
      private var oResponseTimer:FrameTimer;
      
      public function ServiceRequest(_oUrl:URLRequest, _oParams:Object = null)
      {
         super();
         ServiceManager.instance.addPendingRequest(this);
         this.oLoader = new URLLoader();
         this.oLoader.addEventListener(Event.COMPLETE,this.onLoadComplete);
         this.oLoader.addEventListener(IOErrorEvent.IO_ERROR,this.onLoadError);
         _oUrl.method = URLRequestMethod.POST;
         if(Boolean(_oParams))
         {
            _oUrl.data = this.parseVariables(_oParams);
         }
         this.oLoader.load(_oUrl);
      }
      
      public function destroy() : void
      {
         if(Boolean(this.oLoader))
         {
            this.oLoader.removeEventListener(Event.COMPLETE,this.onLoadComplete);
            this.oLoader.removeEventListener(IOErrorEvent.IO_ERROR,this.onLoadError);
         }
         this.oLoader = null;
         if(Boolean(this.oResponseTimer))
         {
            this.oResponseTimer.removeEventListener(TimerEvent.TIMER,this.onResponseReady);
            this.oResponseTimer.destroy();
         }
         this.oResponseTimer = null;
         ServiceManager.instance.removePendingRequest(this);
      }
      
      private function parseVariables(_oParams:Object) : URLVariables
      {
         var _oVars:URLVariables = null;
         var i:String = null;
         if(Boolean(_oParams))
         {
            _oVars = new URLVariables();
            for(i in _oParams)
            {
               _oVars[i] = _oParams[i];
            }
         }
         return _oVars;
      }
      
      protected function onLoadComplete(_e:Event) : void
      {
         this.oResponseTimer = new FrameTimer(1,0,false);
         this.oResponseTimer.addEventListener(TimerEvent.TIMER,this.onResponseReady);
         this.oResponseTimer.start();
      }
      
      protected function onLoadError(_e:IOErrorEvent) : void
      {
         dispatchEvent(_e);
         this.destroy();
      }
      
      protected function onResponseReady(_e:TimerEvent) : void
      {
         dispatchEvent(new ServiceRequestEvent(ServiceRequestEvent.RESPONSE,this.oLoader.data));
         this.destroy();
      }
   }
}

