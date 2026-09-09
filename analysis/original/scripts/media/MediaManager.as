package media
{
   import com.sarbakan.sbdk.blitting.core.BitmapDataCollection;
   import com.sarbakan.sbdk.blitting.core.VectorToBitmapConverter;
   import com.sarbakan.sbdk.errors.ErrorMessages;
   import com.sarbakan.sbdk.events.BitmappedEvent;
   import com.sarbakan.sbdk.events.PreloadEvent;
   import com.sarbakan.sbdk.preload.SequencialLoader;
   import com.sarbakan.sbdk.tools.logger.Logger;
   import com.sarbakan.sbdk.utils.EventManager;
   import com.sarbakan.sbdk.utils.ExternalConfig;
   import com.sarbakan.sbdk.utils.ObjectList;
   import com.sarbakan.sbdk.view.ViewManager;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import media.events.MediaEvent;
   import media.type.AbstractMedia;
   import media.type.MusicMedia;
   import media.type.PropsMedia;
   import media.type.SfxMedia;
   import services.MediaService;
   import services.ServiceManager;
   import services.ServiceRequest;
   import services.events.ServiceRequestEvent;
   
   public class MediaManager extends EventDispatcher
   {
      
      private static var oInstance:MediaManager;
      
      private static const sEVENT_MANAGER_ID:String = "eventManager";
      
      private static var bAllowConstruction:Boolean = false;
      
      private var sMediaDomain:String;
      
      private var oEventManager:EventManager;
      
      private var lMediaList:ObjectList;
      
      private var oMediaLoader:SequencialLoader;
      
      private var oMediaRenderer:VectorToBitmapConverter;
      
      public function MediaManager()
      {
         super();
         if(!bAllowConstruction)
         {
            throw new Error(ErrorMessages.sSINGLETON_ERROR);
         }
         this.init();
      }
      
      public static function get instance() : MediaManager
      {
         if(!oInstance)
         {
            bAllowConstruction = true;
            oInstance = new MediaManager();
            bAllowConstruction = false;
         }
         return oInstance;
      }
      
      public function destroy() : void
      {
         var _oMediaList:MediaList = null;
         if(Boolean(this.lMediaList))
         {
            for each(_oMediaList in this.lMediaList.object)
            {
               _oMediaList.destroy();
            }
            this.lMediaList.destroy();
         }
         this.lMediaList = null;
         if(Boolean(this.oMediaLoader))
         {
            this.oMediaLoader.destroy();
         }
         this.oMediaLoader = null;
         if(Boolean(this.oMediaRenderer))
         {
            this.oMediaRenderer.destroy();
         }
         this.oMediaRenderer = null;
         if(Boolean(this.oEventManager))
         {
            this.oEventManager.destroy();
         }
         this.oEventManager = null;
         oInstance = null;
      }
      
      public function loadMediaList(_sBuilderAlias:String, _sPropertyAlias:String) : void
      {
         var _oService:MediaService = ServiceManager.instance.getService(MediaService.sID) as MediaService;
         var _oRequest:ServiceRequest = _oService.getMedias(_sBuilderAlias,_sPropertyAlias);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,_oRequest,ServiceRequestEvent.RESPONSE,this.onMediaListLoadComplete,false,0,true,_sBuilderAlias,_sPropertyAlias);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,_oRequest,IOErrorEvent.IO_ERROR,this.onMediaListLoadError);
      }
      
      public function getMediaList(_sBuilderAlias:String, _sPropertyAlias:String) : MediaList
      {
         return this.lMediaList.find(_sBuilderAlias + "_" + _sPropertyAlias);
      }
      
      public function addMediaToLoad(_aMedias:Array, _bLoadPreview:Boolean = false) : void
      {
         var _oMedia:AbstractMedia = null;
         if(this.oMediaLoader == null)
         {
            this.oMediaLoader = new SequencialLoader();
         }
         for each(_oMedia in _aMedias)
         {
            if(_bLoadPreview && _oMedia.previewLoader != null)
            {
               if(_oMedia.previewLoaded == false)
               {
                  this.oMediaLoader.addLoader(_oMedia.previewLoader);
                  this.oEventManager.addEventListener(sEVENT_MANAGER_ID,_oMedia.previewLoader,PreloadEvent.ERROR,this.onMediaLoadError,false,0,true,_oMedia);
               }
            }
            else if(_oMedia.gameLoaded == false)
            {
               this.oMediaLoader.addLoader(_oMedia.gameLoader);
               this.oEventManager.addEventListener(sEVENT_MANAGER_ID,_oMedia.gameLoader,PreloadEvent.ERROR,this.onMediaLoadError,false,0,true,_oMedia);
            }
         }
      }
      
      public function startMediaLoading() : void
      {
         if(this.oMediaLoader.isGroupEmpty)
         {
            this.onAllMediaLoaded(null);
         }
         else
         {
            this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oMediaLoader,PreloadEvent.PROGRESS,this.onMediaLoadProgress);
            this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oMediaLoader,PreloadEvent.GROUP_COMPLETE,this.onAllMediaLoaded);
            this.oMediaLoader.start();
         }
      }
      
      public function addMediaToRender(_aMedias:Array, _bRenderPreview:Boolean = false) : void
      {
         var _oMedia:AbstractMedia = null;
         var _aMediaClass:Array = null;
         if(this.oMediaRenderer == null)
         {
            this.oMediaRenderer = VectorToBitmapConverter.instance(ViewManager.instance.stage);
         }
         for each(_oMedia in _aMedias)
         {
            if(_bRenderPreview == false || _oMedia.previewLoaded == false)
            {
               if(_oMedia.gameLoaded)
               {
                  _aMediaClass = this.getMediaUnrenderedElements(_oMedia);
                  if(_aMediaClass.length > 0)
                  {
                     this.oMediaRenderer.addMovieClipClass(_aMediaClass,null,null,_oMedia.checkForCollider,_oMedia.flipable,_oMedia.type);
                  }
               }
            }
         }
      }
      
      public function startMediaRendering() : void
      {
         if(this.oMediaRenderer.isEmpty)
         {
            this.onAllMediaRendered(null);
         }
         else
         {
            this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oMediaRenderer,BitmappedEvent.ALL_COMPLETE,this.onAllMediaRendered);
            this.oMediaRenderer.start();
         }
      }
      
      public function stopMediaRendering() : void
      {
         if(Boolean(this.oMediaRenderer))
         {
            this.oEventManager.removeEventListener(sEVENT_MANAGER_ID,this.oMediaRenderer,BitmappedEvent.ALL_COMPLETE,this.onAllMediaRendered);
            this.oEventManager.removeEventListener(sEVENT_MANAGER_ID,this.oMediaRenderer,BitmappedEvent.ERROR,this.onMediaRenderError);
            this.oMediaRenderer.stop();
            trace("Stop : " + this.oMediaRenderer.isEmpty);
         }
         this.oMediaRenderer = null;
      }
      
      private function init() : void
      {
         this.oEventManager = new EventManager();
         this.lMediaList = new ObjectList();
         this.sMediaDomain = ExternalConfig.instance.getProperty(CommonConfig.sCONFIG_DOMAIN_MEDIA);
      }
      
      private function getMediaUnrenderedElements(_oMedia:AbstractMedia) : Array
      {
         var _aMediaClass:Array = _oMedia.getClassList();
         for(var i:uint = 0; i < _aMediaClass.length; i++)
         {
            if(BitmapDataCollection.instance.containsCollection(_aMediaClass[i]))
            {
               _aMediaClass.splice(i,1);
               i--;
            }
         }
         return _aMediaClass;
      }
      
      private function onMediaListLoadComplete(_e:ServiceRequestEvent, _sBuilderAlias:String, _sPropertyAlias:String) : void
      {
         this.oEventManager.cleanUp(sEVENT_MANAGER_ID);
         var _oMediaList:MediaList = new MediaList(_sBuilderAlias,_sPropertyAlias,_e.data);
         this.lMediaList.insert(_sBuilderAlias + "_" + _sPropertyAlias,_oMediaList);
         dispatchEvent(new MediaEvent(MediaEvent.LIST_LOAD_COMPLETE));
      }
      
      private function onMediaListLoadError(_e:IOErrorEvent) : void
      {
         this.oEventManager.cleanUp(sEVENT_MANAGER_ID);
         dispatchEvent(new MediaEvent(MediaEvent.LIST_LOAD_ERROR,_e.type + "," + _e.text));
      }
      
      private function onMediaLoadProgress(_e:PreloadEvent) : void
      {
         dispatchEvent(_e);
      }
      
      private function onAllMediaLoaded(_e:PreloadEvent) : void
      {
         this.oEventManager.cleanUp(sEVENT_MANAGER_ID);
         this.oMediaLoader.destroy();
         this.oMediaLoader = null;
         dispatchEvent(new MediaEvent(MediaEvent.MEDIA_ALL_LOAD_COMPLETE));
      }
      
      private function onMediaLoadError(_e:PreloadEvent, _oMedia:AbstractMedia) : void
      {
         var _oMediaList:MediaList = null;
         if(_oMedia.type == MusicMedia.TYPE || _oMedia.type == SfxMedia.TYPE || _oMedia.type == PropsMedia.TYPE)
         {
            for each(_oMediaList in this.lMediaList.object)
            {
               if(_oMediaList.hasMedia(_oMedia))
               {
                  Logger.instance.logError(_e.error,"onMediaLoadError","MediaManager");
                  _oMediaList.removeMedia(_oMedia);
                  break;
               }
            }
         }
         else
         {
            dispatchEvent(new MediaEvent(MediaEvent.MEDIA_LOAD_ERROR,_e.error));
         }
      }
      
      private function onAllMediaRendered(_e:BitmappedEvent) : void
      {
         this.oEventManager.cleanUp(sEVENT_MANAGER_ID);
         if(Boolean(this.oMediaRenderer))
         {
            this.oMediaRenderer.destroy();
         }
         this.oMediaRenderer = null;
         dispatchEvent(new MediaEvent(MediaEvent.MEDIA_ALL_RENDERED));
      }
      
      private function onMediaRenderError(_e:BitmappedEvent) : void
      {
         dispatchEvent(new MediaEvent(MediaEvent.MEDIA_RENDER_ERROR,_e.error));
      }
      
      public function get mediaServer() : String
      {
         return this.sMediaDomain;
      }
      
      public function get renderer() : VectorToBitmapConverter
      {
         return this.oMediaRenderer;
      }
      
      public function get hasMediaToLoad() : Boolean
      {
         return Boolean(this.oMediaLoader.isGroupEmpty == false);
      }
      
      public function get hasMediaToRender() : Boolean
      {
         return Boolean(this.oMediaRenderer.isEmpty == false);
      }
   }
}

