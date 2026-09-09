package media.type
{
   import com.sarbakan.sbdk.events.PreloadEvent;
   import com.sarbakan.sbdk.math.geom.AABB2;
   import com.sarbakan.sbdk.preload.DisplayLoader;
   import com.sarbakan.sbdk.utils.EventManager;
   import com.sarbakan.sbdk.utils.ObjectList;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.system.ApplicationDomain;
   import media.MediaManager;
   
   public class AbstractMedia
   {
      
      private static const sEVENT_MANAGER_ID:String = "eventManager";
      
      public static const sDEFAULT_PREVIEW:String = "mcPreview";
      
      public static const sMARQUEE_PREVIEW_ZONE:String = "_zone";
      
      protected var oEventManager:EventManager;
      
      protected var bGameLoaded:Boolean;
      
      protected var bPreviewLoaded:Boolean;
      
      protected var lClass:ObjectList;
      
      protected var oDrawBounds:AABB2;
      
      private var sAlias:String;
      
      private var oGameLoader:DisplayLoader;
      
      private var oPreviewLoader:DisplayLoader;
      
      private var lPreviewBD:ObjectList;
      
      public function AbstractMedia(_sAlias:String, _sMediaDirectory:String)
      {
         super();
         this.oEventManager = new EventManager();
         this.sAlias = _sAlias;
         this.lClass = new ObjectList();
         this.oGameLoader = new DisplayLoader(MediaManager.instance.mediaServer + "/" + _sMediaDirectory + "/" + _sAlias + this.gameSuffixe,new ApplicationDomain());
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oGameLoader,PreloadEvent.COMPLETE,this.onGameLoaded);
         this.lPreviewBD = new ObjectList();
         this.oPreviewLoader = this.oGameLoader;
         if(this.previewSuffixe != null && this.previewSuffixe != this.gameSuffixe)
         {
            this.oPreviewLoader = new DisplayLoader(MediaManager.instance.mediaServer + "/" + _sMediaDirectory + "/" + _sAlias + this.previewSuffixe,new ApplicationDomain());
            this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oPreviewLoader,PreloadEvent.COMPLETE,this.onPreviewLoaded);
         }
      }
      
      public function destroy() : void
      {
         var _oPreview:BitmapData = null;
         if(Boolean(this.lPreviewBD))
         {
            for each(_oPreview in this.lPreviewBD.object)
            {
               _oPreview.dispose();
            }
            this.lPreviewBD.destroy();
         }
         this.lPreviewBD = null;
         if(Boolean(this.oGameLoader))
         {
            this.oGameLoader.destroy();
         }
         this.oGameLoader = null;
         if(Boolean(this.oPreviewLoader))
         {
            this.oPreviewLoader.destroy();
         }
         this.oPreviewLoader = null;
         if(Boolean(this.lClass))
         {
            this.lClass.destroy();
         }
         this.lClass = null;
         this.oDrawBounds = null;
         this.oEventManager.destroy();
         this.oEventManager = null;
      }
      
      public function getClass(_sClassName:String) : Class
      {
         return this.lClass.find(_sClassName);
      }
      
      public function getClassList() : Array
      {
         var _sLinkage:String = null;
         var _aClass:Array = new Array();
         for each(_sLinkage in this.gameLinkages)
         {
            _aClass.push(this.getClass(_sLinkage));
         }
         return _aClass;
      }
      
      public function getPreview(_sPreviewLinkage:String = null, _nScale:Number = 1, _bFlip:Boolean = false) : BitmapData
      {
         var _oReturn:BitmapData = null;
         if(_sPreviewLinkage == null)
         {
            _sPreviewLinkage = this.previewLinkages[0];
         }
         if(_nScale == 1)
         {
            _oReturn = this.lPreviewBD.find(_sPreviewLinkage + _bFlip);
            if(_oReturn == null)
            {
               _oReturn = this.createPreview(_sPreviewLinkage,_nScale,_bFlip);
               this.lPreviewBD.insert(_sPreviewLinkage + _bFlip,_oReturn);
            }
         }
         else
         {
            _oReturn = this.createPreview(_sPreviewLinkage,_nScale,_bFlip);
         }
         return _oReturn;
      }
      
      protected function createPreview(_sPreviewLinkage:String, _nScale:Number = 1, _bFlip:Boolean = false) : BitmapData
      {
         var _oRect:Rectangle = null;
         var _cClass:Class = this.getClass(_sPreviewLinkage);
         var _mcPreview:MovieClip = new _cClass();
         var _mcMarquee:MovieClip = _mcPreview.getChildByName(sMARQUEE_PREVIEW_ZONE) as MovieClip;
         if(_mcMarquee != null)
         {
            _mcMarquee.visible = false;
            _oRect = _mcMarquee.getBounds(_mcPreview);
         }
         else
         {
            _oRect = _mcPreview.getBounds(_mcPreview);
         }
         var _oReturn:BitmapData = new BitmapData(_nScale * _oRect.width,_nScale * _oRect.height,true,0);
         if(_bFlip)
         {
            _oReturn.draw(_mcPreview,new Matrix(-_nScale,0,0,_nScale,_nScale * _oRect.width + _nScale * _oRect.left,-_nScale * _oRect.top));
         }
         else
         {
            _oReturn.draw(_mcPreview,new Matrix(_nScale,0,0,_nScale,-_nScale * _oRect.left,-_nScale * _oRect.top));
         }
         return _oReturn;
      }
      
      protected function onGameLoaded(_e:PreloadEvent) : void
      {
         var _sLinkage:String = null;
         this.bGameLoaded = true;
         var _oDomain:ApplicationDomain = _e.content.loaderInfo.applicationDomain;
         for each(_sLinkage in this.gameLinkages)
         {
            this.lClass.insert(_sLinkage,_oDomain.getDefinition(_sLinkage));
         }
      }
      
      protected function onPreviewLoaded(_e:PreloadEvent) : void
      {
         var _sLinkage:String = null;
         this.bPreviewLoaded = true;
         var _oDomain:ApplicationDomain = _e.content.loaderInfo.applicationDomain;
         for each(_sLinkage in this.previewLinkages)
         {
            this.lClass.insert(_sLinkage,_oDomain.getDefinition(_sLinkage));
         }
      }
      
      public function get alias() : String
      {
         return this.sAlias;
      }
      
      public function get type() : String
      {
         return "";
      }
      
      public function get gameLoader() : DisplayLoader
      {
         return this.oGameLoader;
      }
      
      public function get previewLoader() : DisplayLoader
      {
         return this.oPreviewLoader;
      }
      
      public function get gameLoaded() : Boolean
      {
         return this.bGameLoaded;
      }
      
      public function get previewLoaded() : Boolean
      {
         return this.bPreviewLoaded;
      }
      
      public function get gameLinkages() : Array
      {
         return null;
      }
      
      public function get previewLinkages() : Array
      {
         return [sDEFAULT_PREVIEW];
      }
      
      public function get gameSuffixe() : String
      {
         return ".swf";
      }
      
      public function get previewSuffixe() : String
      {
         return "_preview.swf";
      }
      
      public function get checkForCollider() : Boolean
      {
         return false;
      }
      
      public function get flipable() : Boolean
      {
         return false;
      }
      
      public function get drawBounds() : AABB2
      {
         var _oPreview:BitmapData = null;
         if(this.oDrawBounds == null)
         {
            _oPreview = this.getPreview();
            this.oDrawBounds = new AABB2(0,_oPreview.width,0,_oPreview.height);
         }
         return this.oDrawBounds;
      }
   }
}

