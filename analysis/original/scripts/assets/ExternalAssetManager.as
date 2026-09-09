package assets
{
   import assets.events.ExternalAssetEvent;
   import com.sarbakan.sbdk.errors.ErrorMessages;
   import com.sarbakan.sbdk.events.PreloadEvent;
   import com.sarbakan.sbdk.preload.DisplayLoader;
   import com.sarbakan.sbdk.preload.PreloadManager;
   import com.sarbakan.sbdk.tools.logger.Logger;
   import com.sarbakan.sbdk.utils.EventManager;
   import flash.events.EventDispatcher;
   
   public class ExternalAssetManager extends EventDispatcher
   {
      
      private static var oInstance:ExternalAssetManager;
      
      public static const sDEFAULT_FILE_DIRECTORY:String = "media";
      
      private static const sEVENT_ID:String = "eventID";
      
      private static const sCATEGORY_PREFIX:String = "externalAsset_";
      
      private static var bAllowConstruction:Boolean = false;
      
      private var oEventManager:EventManager;
      
      private var sFileDirectory:String;
      
      private var bLoading:Boolean;
      
      private var aCategoriesList:Array;
      
      private var oPreloadManager:PreloadManager;
      
      private var oCurrentCategory:AssetCategory;
      
      public function ExternalAssetManager()
      {
         super();
         if(!bAllowConstruction)
         {
            throw new Error(ErrorMessages.sSINGLETON_ERROR);
         }
         this.init();
      }
      
      public static function get instance() : ExternalAssetManager
      {
         if(!oInstance)
         {
            bAllowConstruction = true;
            oInstance = new ExternalAssetManager();
            bAllowConstruction = false;
         }
         return oInstance;
      }
      
      public function destroy() : void
      {
         var _oCategory:AssetCategory = null;
         for each(_oCategory in this.aCategoriesList)
         {
            _oCategory.destroy();
         }
         this.aCategoriesList = null;
         this.oCurrentCategory = null;
         this.oPreloadManager = null;
         this.oEventManager.destroy();
         this.oEventManager = null;
         oInstance = null;
      }
      
      public function addCategory(_sCategory:String, _nPriority:int = -1) : void
      {
         if(_nPriority == -1)
         {
            _nPriority = int(this.aCategoriesList.length);
         }
         this.aCategoriesList.push(new AssetCategory(_sCategory,_nPriority));
         this.sortPriority();
      }
      
      public function addFile(_sCategory:String, _sFile:String) : void
      {
         var _oCategory:AssetCategory = this.getCategoryByID(_sCategory);
         _oCategory.oGroupLoader.addLoader(new DisplayLoader(this.sFileDirectory + "/" + _sFile));
         _oCategory.bLoaded = false;
      }
      
      public function isCategoriesReady(... _aCategories) : Boolean
      {
         var _sCategory:String = null;
         var _bReady:Boolean = true;
         for each(_sCategory in _aCategories)
         {
            if(this.getCategoryByID(_sCategory).bLoaded == false)
            {
               _bReady = false;
               break;
            }
         }
         return _bReady;
      }
      
      public function start() : void
      {
         var i:uint = 0;
         var _oCategory:AssetCategory = null;
         if(!this.bLoading)
         {
            for(i = 0; i < this.aCategoriesList.length; i++)
            {
               _oCategory = this.aCategoriesList[i] as AssetCategory;
               if(_oCategory.bLoaded == false)
               {
                  this.oCurrentCategory = _oCategory;
                  break;
               }
            }
            if(this.oCurrentCategory != null)
            {
               this.bLoading = true;
               this.oPreloadManager.addLoader(sCATEGORY_PREFIX + this.oCurrentCategory.sCategoryID,this.oCurrentCategory.oGroupLoader);
               this.oEventManager.addEventListener(sEVENT_ID,this.oPreloadManager,PreloadEvent.GROUP_COMPLETE,this.onLoadComplete);
               this.oEventManager.addEventListener(sEVENT_ID,this.oPreloadManager,PreloadEvent.PROGRESS,this.onLoadProgress);
               this.oEventManager.addEventListener(sEVENT_ID,this.oCurrentCategory.oGroupLoader,PreloadEvent.ERROR,this.onLoadError,false,0,true,"Cannot load external asset : ",sEVENT_ID);
               this.oPreloadManager.start();
            }
         }
      }
      
      private function init() : void
      {
         this.oEventManager = new EventManager();
         this.oPreloadManager = PreloadManager.instance;
         this.aCategoriesList = new Array();
         this.sFileDirectory = sDEFAULT_FILE_DIRECTORY;
      }
      
      private function getCategoryByID(_sCategory:String) : AssetCategory
      {
         var _oReturn:AssetCategory = null;
         var _oCategory:AssetCategory = null;
         for each(_oCategory in this.aCategoriesList)
         {
            if(_oCategory.sCategoryID == _sCategory)
            {
               _oReturn = _oCategory;
               break;
            }
         }
         return _oReturn;
      }
      
      private function sortPriority() : void
      {
         if(this.aCategoriesList.length > 0)
         {
            this.aCategoriesList.sortOn("priority");
         }
      }
      
      private function onLoadComplete(_e:PreloadEvent) : void
      {
         this.oEventManager.cleanUp(sEVENT_ID);
         this.oCurrentCategory.bLoaded = true;
         dispatchEvent(new ExternalAssetEvent(ExternalAssetEvent.COMPLETE,this.oCurrentCategory.sCategoryID,100));
         this.oCurrentCategory = null;
         this.bLoading = false;
         this.start();
      }
      
      private function onLoadProgress(_e:PreloadEvent) : void
      {
         dispatchEvent(new ExternalAssetEvent(ExternalAssetEvent.PROGRESS,this.oCurrentCategory.sCategoryID,_e.totalPercentage));
      }
      
      private function onLoadError(_oEvent:PreloadEvent, _sErrorMessage:String, _sEventManagerID:String) : void
      {
         Logger.instance.logError(_sErrorMessage + "(" + _oEvent.error + ")","onLoadError","ExternalAssetManager");
         this.oEventManager.cleanUp(_sEventManagerID);
      }
      
      public function set fileDirectory(_sDirectory:String) : void
      {
         this.sFileDirectory = _sDirectory;
      }
   }
}

import com.sarbakan.sbdk.preload.SequencialLoader;

class AssetCategory
{
   
   public var sCategoryID:String;
   
   public var bLoaded:Boolean;
   
   public var oGroupLoader:SequencialLoader;
   
   private var nPriority:uint;
   
   public function AssetCategory(_sCategoryID:String, _nPriority:uint)
   {
      super();
      this.sCategoryID = _sCategoryID;
      this.nPriority = _nPriority;
      this.bLoaded = false;
      this.oGroupLoader = new SequencialLoader();
   }
   
   public function destroy() : void
   {
      if(Boolean(this.oGroupLoader))
      {
         this.oGroupLoader.destroy();
      }
      this.oGroupLoader = null;
   }
   
   public function get priority() : uint
   {
      return this.nPriority;
   }
}
