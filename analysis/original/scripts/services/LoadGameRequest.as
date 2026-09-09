package services
{
   import builderManager.TemplateData;
   import com.sarbakan.sbdk.blitting.core.BitmapDataCollection;
   import com.sarbakan.sbdk.utils.EventManager;
   import data.GameData;
   import data.GameDataManager;
   import data.events.GameDataEvent;
   import flash.events.EventDispatcher;
   import media.MediaList;
   import media.MediaManager;
   import media.events.MediaEvent;
   import media.type.BackgroundMedia;
   import media.type.PlayableCharacterMedia;
   import services.events.GameLoadEvent;
   
   public class LoadGameRequest extends EventDispatcher
   {
      
      private static const sEVENT_SERVICES_ID:String = "eventManager";
      
      private var oEventManager:EventManager;
      
      private var nSlotID:int;
      
      private var oGameData:GameData;
      
      private var oTemplateData:TemplateData;
      
      public function LoadGameRequest(_nSlotID:int)
      {
         super();
         this.nSlotID = _nSlotID;
         this.oEventManager = new EventManager();
         this.oEventManager.addEventListener(sEVENT_SERVICES_ID,GameDataManager.instance,GameDataEvent.COMPLETE,this.onGameLoaded);
         GameDataManager.instance.loadGameDataBySlotID(BuilderMain.instance.nPendingSlot);
      }
      
      public function destroy() : void
      {
         this.oGameData = null;
         this.oTemplateData = null;
         if(Boolean(this.oEventManager))
         {
            this.oEventManager.destroy();
         }
         this.oEventManager = null;
      }
      
      private function onGameLoaded(_e:GameDataEvent) : void
      {
         this.oEventManager.cleanUp(sEVENT_SERVICES_ID);
         this.oGameData = _e.gameData;
         if(Boolean(GameDataManager.instance.getGameData(this.oGameData.template)))
         {
            this.onTemplateDataLoaded(null);
         }
         else
         {
            this.oEventManager.addEventListener(sEVENT_SERVICES_ID,GameDataManager.instance,GameDataEvent.COMPLETE,this.onTemplateDataLoaded);
            GameDataManager.instance.loadGameData(this.oGameData.template);
         }
      }
      
      private function onTemplateDataLoaded(_e:GameDataEvent) : void
      {
         this.oTemplateData = new TemplateData(GameDataManager.instance.getGameData(this.oGameData.template),BuilderMain.instance.mediaList);
         var _oMediaList:MediaList = BuilderMain.instance.mediaList;
         MediaManager.instance.addMediaToLoad([_oMediaList.getMedia(this.oGameData.heroAlias)]);
         this.oEventManager.addEventListener(sEVENT_SERVICES_ID,MediaManager.instance,MediaEvent.MEDIA_ALL_LOAD_COMPLETE,this.onMediaLoaded);
         MediaManager.instance.startMediaLoading();
      }
      
      private function onMediaLoaded(_e:MediaEvent) : void
      {
         MediaManager.instance.stopMediaRendering();
         BitmapDataCollection.instance.disposeGroup(BackgroundMedia.TYPE);
         BitmapDataCollection.instance.disposeGroup(PlayableCharacterMedia.TYPE);
         var _oMediaList:MediaList = BuilderMain.instance.mediaList;
         var _aMedia:Array = [_oMediaList.getMedia(this.oGameData.heroAlias),_oMediaList.getMedia(this.oGameData.backgroundAlias)];
         MediaManager.instance.addMediaToRender(_aMedia);
         this.oEventManager.addEventListener(sEVENT_SERVICES_ID,MediaManager.instance,MediaEvent.MEDIA_ALL_RENDERED,this.onMediaRendered);
         MediaManager.instance.startMediaRendering();
      }
      
      private function onMediaRendered(_e:MediaEvent) : void
      {
         this.oEventManager.cleanUp(sEVENT_SERVICES_ID);
         dispatchEvent(new GameLoadEvent(GameLoadEvent.LOAD_COMPLETE,this.nSlotID));
      }
      
      public function get slotID() : int
      {
         return this.nSlotID;
      }
      
      public function get gameData() : GameData
      {
         return this.oGameData;
      }
      
      public function get templateData() : TemplateData
      {
         return this.oTemplateData;
      }
   }
}

