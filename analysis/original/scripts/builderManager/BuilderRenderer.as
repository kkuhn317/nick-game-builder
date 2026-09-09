package builderManager
{
   import builderManager.elements.BuilderElement;
   import com.sarbakan.sbdk.core.UpdateManager;
   import com.sarbakan.sbdk.data.spatialIndexing.ISpatialIndexElement;
   import com.sarbakan.sbdk.events.UpdateEvent;
   import com.sarbakan.sbdk.math.geom.AABB2;
   import com.sarbakan.sbdk.utils.EventManager;
   import com.sarbakan.sbdk.utils.ObjectList;
   import data.GameData;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.display.PixelSnapping;
   import flash.events.Event;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.ColorTransform;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import gamePlayer.BackgroundManager;
   import media.MediaList;
   import media.type.BackgroundMedia;
   import media.type.BonusCoinMedia;
   import media.type.GoalMedia;
   import media.type.OpponentJumperMedia;
   import media.type.OpponentShooterMedia;
   import media.type.OpponentWalkerMedia;
   import media.type.PlayableCharacterMedia;
   import services.ServiceManager;
   import utils.ColorMatrix;
   
   public class BuilderRenderer
   {
      
      public static const nMIN_ZOOM:Number = Math.round(CommonConfig.nCELL_SIZE * 0.15) / CommonConfig.nCELL_SIZE;
      
      public static const nMAX_ZOOM:Number = Math.round(CommonConfig.nCELL_SIZE * 0.8) / CommonConfig.nCELL_SIZE;
      
      private static const sEVENT_MANAGER_ID:String = "eventManager";
      
      private static const nBUILDER_SIZE:Number = 7500;
      
      private static const oBUILDER_BOUNDS:Rectangle = new Rectangle(-nBUILDER_SIZE,-nBUILDER_SIZE,2 * nBUILDER_SIZE,2 * nBUILDER_SIZE);
      
      private static const nBKG_COLOR:uint = 0;
      
      public var mcContainer:MovieClip;
      
      private var oEventManager:EventManager;
      
      private var oBitmap:Bitmap;
      
      private var oBackbuffer:BitmapData;
      
      private var oBackground:BackgroundManager;
      
      private var oViewRect:Rectangle;
      
      private var lScaledMedia:ObjectList;
      
      private var nCurrentZoom:Number;
      
      private var bInvalidate:Boolean;
      
      private var oGameData:GameData;
      
      private var oMediaList:MediaList;
      
      private var oData:BuilderData;
      
      private var oDraggedElement:BuilderElement;
      
      public function BuilderRenderer(_mcContainer:MovieClip, _oData:BuilderData)
      {
         super();
         this.oEventManager = new EventManager();
         this.mcContainer = _mcContainer;
         this.builderData = _oData;
         this.oBackbuffer = new BitmapData(this.mcContainer.mcRenderArea.width,this.mcContainer.mcRenderArea.height,true,nBKG_COLOR);
         this.oBitmap = new Bitmap(this.oBackbuffer,PixelSnapping.ALWAYS,true);
         this.mcContainer.addChildAt(this.oBitmap,this.mcContainer.getChildIndex(this.mcContainer.mcRenderArea) + 1);
         this.nCurrentZoom = nMAX_ZOOM;
         this.updateCenterPos(0,0);
         this.updateBackground();
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,UpdateManager.instance,UpdateEvent.UPDATE,this.onUpdate);
         this.invalidate();
      }
      
      public function destroy() : void
      {
         this.oBitmap = null;
         if(Boolean(this.oBackbuffer))
         {
            this.oBackbuffer.dispose();
         }
         this.oBackbuffer = null;
         if(Boolean(this.oBackground))
         {
            this.oBackground.destroy();
         }
         this.oBackground = null;
         if(Boolean(this.oEventManager))
         {
            this.oEventManager.destroy();
         }
         this.oEventManager = null;
         this.clearScaledMedia();
         this.oGameData = null;
         this.oMediaList = null;
         this.oData = null;
         this.oDraggedElement = null;
      }
      
      public function updateCenterPos(_nCenterX:Number, _nCenterY:Number) : void
      {
         if(this.oViewRect == null)
         {
            this.oViewRect = new Rectangle();
         }
         this.oViewRect.width = this.oBackbuffer.width / this.nCurrentZoom;
         this.oViewRect.height = this.oBackbuffer.height / this.nCurrentZoom;
         this.oViewRect.x = _nCenterX - this.oViewRect.width / 2;
         this.oViewRect.y = _nCenterY - this.oViewRect.height / 2;
         if(this.oViewRect.x < oBUILDER_BOUNDS.x)
         {
            this.oViewRect.x = oBUILDER_BOUNDS.x;
         }
         if(this.oViewRect.y < oBUILDER_BOUNDS.y)
         {
            this.oViewRect.y = oBUILDER_BOUNDS.y;
         }
         if(this.oViewRect.right > oBUILDER_BOUNDS.right)
         {
            this.oViewRect.x = oBUILDER_BOUNDS.right - this.oViewRect.width;
         }
         if(this.oViewRect.bottom > oBUILDER_BOUNDS.bottom)
         {
            this.oViewRect.y = oBUILDER_BOUNDS.bottom - this.oViewRect.height;
         }
         this.invalidate();
      }
      
      public function centerOnElement(_oElement:BuilderElement) : void
      {
         var _oElementCenter:Point = new Point();
         _oElementCenter.x = _oElement.bounds.nXMin + (_oElement.bounds.nXMax - _oElement.bounds.nXMin) / 2;
         _oElementCenter.y = _oElement.bounds.nYMin + (_oElement.bounds.nYMax - _oElement.bounds.nYMin) / 2;
         this.updateCenterPos(_oElementCenter.x,_oElementCenter.y);
      }
      
      public function updateBackground() : void
      {
         var _oMedia:BackgroundMedia = null;
         if(Boolean(this.oBackground))
         {
            this.oBackground.destroy();
         }
         if(this.oGameData.backgroundAlias != null)
         {
            _oMedia = this.oMediaList.getMedia(this.oGameData.backgroundAlias) as BackgroundMedia;
            this.oBackground = new BackgroundManager();
            this.oBackground.init(this.oBackbuffer.width,this.oBackbuffer.height,_oMedia,new Point());
            this.oBackground.zoom = this.nCurrentZoom;
         }
         this.invalidate();
      }
      
      public function invalidate() : void
      {
         this.bInvalidate = true;
      }
      
      public function takeSnapshot(_oNewBounds:AABB2) : void
      {
         var _oBD:BitmapData = null;
         var _aIgnoreType:Array = null;
         if(Boolean(ServiceManager.instance.fakedServicePath))
         {
            _oBD = new BitmapData(this.oBackbuffer.width,this.oBackbuffer.height,true,0);
         }
         else
         {
            _oBD = new BitmapData(BuilderConfig.oPREVIEW_SIZE.x,BuilderConfig.oPREVIEW_SIZE.y,false);
         }
         _oBD.lock();
         var _nZoomBack:Number = this.nCurrentZoom;
         this.zoom = nMIN_ZOOM;
         var _oViewRectBackup:Rectangle = this.oViewRect;
         this.updateCenterPos(_oNewBounds.nXMin + (_oNewBounds.nXMax - _oNewBounds.nXMin) / 2,_oNewBounds.nYMin + (_oNewBounds.nYMax - _oNewBounds.nYMin) / 2);
         if(ServiceManager.instance.fakedServicePath == null && Boolean(this.oBackground))
         {
            this.oBackground.updatePos(this.oViewRect.x,this.oViewRect.y);
            _oBD.copyPixels(this.oBackground.bitmap.bitmapData,_oBD.rect,_oBD.rect.topLeft);
            this.oBackground.updatePos(_oViewRectBackup.x,_oViewRectBackup.y);
         }
         else
         {
            _aIgnoreType = [PlayableCharacterMedia.TYPE,GoalMedia.TYPE,BonusCoinMedia.TYPE,OpponentJumperMedia.TYPE,OpponentShooterMedia.TYPE,OpponentWalkerMedia.TYPE];
         }
         this.renderElements(_oBD,_aIgnoreType);
         this.oViewRect = _oViewRectBackup;
         this.zoom = _nZoomBack;
         this.bInvalidate = true;
         _oBD.unlock();
         BuilderMain.instance.oBuilderSnapshot = _oBD;
      }
      
      private function renderElements(_oRenderer:BitmapData, _aIgnoreType:Array = null) : void
      {
         var _oIndex:ISpatialIndexElement = null;
         var _oElement:BuilderElement = null;
         var _oRenderPos:Point = null;
         var _oBD:BitmapData = null;
         var _oDragBD:BitmapData = null;
         var _aElements:Array = this.oData.queryRectangle(this.oViewRect);
         for each(_oIndex in _aElements)
         {
            if(Boolean(_oIndex) && Boolean(_oIndex.data))
            {
               _oElement = _oIndex.data;
               if(_aIgnoreType == null || _aIgnoreType.indexOf(_oElement.mediaType) == -1)
               {
                  _oRenderPos = new Point(_oElement.bounds.nXMin - this.oViewRect.x,_oElement.bounds.nYMin - this.oViewRect.y);
                  _oBD = _oElement.getBitmapData();
                  if(this.nCurrentZoom != 1)
                  {
                     _oRenderPos.x *= this.nCurrentZoom;
                     _oRenderPos.y *= this.nCurrentZoom;
                     _oBD = this.getScaledBD(_oElement);
                  }
                  if(_oElement == this.oDraggedElement)
                  {
                     _oDragBD = new BitmapData(_oBD.width,_oBD.height,true,0);
                     _oDragBD.draw(_oBD,null,new ColorTransform(1,1,1,0.5));
                     _oBD = _oDragBD;
                  }
                  _oRenderer.copyPixels(_oBD,_oBD.rect,_oRenderPos,null,null,true);
                  if(Boolean(_oDragBD))
                  {
                     _oDragBD.dispose();
                     _oDragBD = null;
                  }
               }
            }
         }
      }
      
      private function getScaledBD(_oElement:BuilderElement) : BitmapData
      {
         if(this.lScaledMedia == null)
         {
            this.lScaledMedia = new ObjectList();
         }
         var _oBD:BitmapData = this.lScaledMedia.find(_oElement.previewAlias + _oElement.flip);
         if(_oBD == null)
         {
            _oBD = _oElement.getBitmapData(this.nCurrentZoom);
            this.lScaledMedia.insert(_oElement.previewAlias + _oElement.flip,_oBD);
         }
         return _oBD;
      }
      
      private function clearScaledMedia() : void
      {
         var _oBD:BitmapData = null;
         if(Boolean(this.lScaledMedia))
         {
            for each(_oBD in this.lScaledMedia.object)
            {
               _oBD.dispose();
            }
            this.lScaledMedia.destroy();
         }
         this.lScaledMedia = null;
      }
      
      private function onDataChange(_e:Event) : void
      {
         this.invalidate();
      }
      
      private function onUpdate(_e:Event) : void
      {
         var _oColorMatrix:ColorMatrix = null;
         if(this.bInvalidate)
         {
            this.oBackbuffer.lock();
            if(Boolean(this.oBackground))
            {
               this.oBackground.updatePos(this.oViewRect.x,this.oViewRect.y);
               if(StepManager.instance.currentStep.id == StepManager.sSTEP_LAYOUT)
               {
                  _oColorMatrix = new ColorMatrix();
                  _oColorMatrix.adjustSaturation(-100);
                  this.oBackbuffer.applyFilter(this.oBackground.bitmap.bitmapData,this.oBackbuffer.rect,this.oBackbuffer.rect.topLeft,new ColorMatrixFilter(_oColorMatrix));
               }
               else
               {
                  this.oBackbuffer.copyPixels(this.oBackground.bitmap.bitmapData,this.oBackbuffer.rect,this.oBackbuffer.rect.topLeft);
               }
            }
            else
            {
               this.oBackbuffer.fillRect(this.oBackbuffer.rect,nBKG_COLOR);
            }
            this.renderElements(this.oBackbuffer);
            this.oBackbuffer.unlock();
            this.bInvalidate = false;
         }
      }
      
      public function set zoom(_nValue:Number) : void
      {
         _nValue = Math.min(Math.max(_nValue,nMIN_ZOOM),nMAX_ZOOM);
         _nValue = Math.round(CommonConfig.nCELL_SIZE * _nValue) / CommonConfig.nCELL_SIZE;
         if(_nValue != this.nCurrentZoom)
         {
            this.nCurrentZoom = _nValue;
            if(Boolean(this.oBackground))
            {
               this.oBackground.zoom = this.nCurrentZoom;
            }
            this.updateCenterPos(this.oViewRect.x + this.oViewRect.width / 2,this.oViewRect.y + this.oViewRect.height / 2);
            this.clearScaledMedia();
            if(this.nCurrentZoom != 1)
            {
               this.lScaledMedia = new ObjectList();
            }
            this.invalidate();
         }
      }
      
      public function get zoom() : Number
      {
         return this.nCurrentZoom;
      }
      
      public function get centerPos() : Point
      {
         return new Point(this.oViewRect.x + this.oViewRect.width / 2,this.oViewRect.y + this.oViewRect.height / 2);
      }
      
      public function get background() : BackgroundManager
      {
         return this.oBackground;
      }
      
      public function get bitmap() : Bitmap
      {
         return this.oBitmap;
      }
      
      public function get container() : MovieClip
      {
         return this.mcContainer;
      }
      
      public function set draggedElement(_oValue:BuilderElement) : void
      {
         if(this.oDraggedElement != _oValue)
         {
            this.oDraggedElement = _oValue;
            if(this.oDraggedElement != null)
            {
               this.invalidate();
            }
         }
      }
      
      public function set builderData(_oValue:BuilderData) : void
      {
         if(Boolean(this.oData))
         {
            this.oEventManager.removeEventListener(sEVENT_MANAGER_ID,this.oData,Event.CHANGE,this.onDataChange);
         }
         this.oGameData = BuilderMain.instance.gameData;
         this.oMediaList = BuilderMain.instance.mediaList;
         this.oData = _oValue;
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oData,Event.CHANGE,this.onDataChange);
         this.invalidate();
      }
   }
}

