package ui.selectionPopup
{
   import builderManager.BuilderData;
   import builderManager.BuilderManager;
   import builderManager.BuilderRenderer;
   import builderManager.TemplateData;
   import com.sarbakan.sbdk.events.PreloadEvent;
   import com.sarbakan.sbdk.math.geom.AABB2;
   import com.sarbakan.sbdk.preload.DisplayLoader;
   import com.sarbakan.sbdk.preload.ParallelLoader;
   import com.sarbakan.sbdk.utils.ExternalConfig;
   import com.sarbakan.sbdk.view.ViewManager;
   import data.GameData;
   import data.GameDataManager;
   import data.events.GameDataEvent;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.PixelSnapping;
   import flash.events.Event;
   import flash.filters.ColorMatrixFilter;
   import media.MediaManager;
   import services.GameDataService;
   import services.ServiceManager;
   import services.ServiceRequest;
   import services.events.ServiceRequestEvent;
   import ui.events.PopupEvent;
   import ui.popups.ConfirmPopup;
   import utils.ColorMatrix;
   
   public class LayoutSelectionPopup extends AbstractSelectionPopup
   {
      
      private var aLayouts:Array;
      
      private var oTemplateLoader:ParallelLoader;
      
      private var oBlankBD:BitmapData;
      
      public function LayoutSelectionPopup()
      {
         super();
      }
      
      override public function destroy() : void
      {
         var _oLayout:LayoutStruct = null;
         super.destroy();
         for each(_oLayout in this.aLayouts)
         {
            _oLayout.destroy();
         }
         this.aLayouts = null;
         if(Boolean(this.oTemplateLoader))
         {
            this.oTemplateLoader.destroy();
         }
         this.oTemplateLoader = null;
      }
      
      override public function onBeforeShow() : void
      {
         var _oNewBounds:AABB2 = null;
         super.onBeforeShow();
         BuilderManager.instance.renderer.zoom = BuilderRenderer.nMIN_ZOOM;
         if(Boolean(BuilderManager.instance.builderData))
         {
            _oNewBounds = BuilderManager.instance.builderData.bounds;
            BuilderManager.instance.renderer.updateCenterPos(_oNewBounds.nXMin + (_oNewBounds.nXMax - _oNewBounds.nXMin) / 2,_oNewBounds.nYMin + (_oNewBounds.nYMax - _oNewBounds.nYMin) / 2);
         }
      }
      
      override public function onShow() : void
      {
         super.onShow();
         if(Boolean(this.aLayouts))
         {
            this.populateWheel();
         }
         else
         {
            StepManager.instance.showLoading();
            this.loadTemplateList();
         }
      }
      
      override public function onHide() : void
      {
         super.onHide();
         this.unGreyBackground();
      }
      
      override protected function initBtnNext() : void
      {
         super.initBtnNext();
         if(StepManager.instance.isStepEnabled(StepManager.sSTEP_HERO) || oSelector.selectedValue != null)
         {
            StepManager.instance.header.btnNext.enabled = true;
         }
      }
      
      private function populateWheel() : void
      {
         var _oLayout:LayoutStruct = null;
         var _oBD:BitmapData = null;
         for(var i:uint = 0; i < this.aLayouts.length; i++)
         {
            _oLayout = this.aLayouts[i];
            _oBD = _oLayout.oBD;
            if(i == 0)
            {
               _oBD = this.blankTemplateBD;
            }
            oSelector.addItem(null,_oLayout.sAlias,new Bitmap(_oBD,PixelSnapping.ALWAYS,true));
         }
         StepManager.instance.hideLoading();
      }
      
      private function loadTemplateList() : void
      {
         var _oService:GameDataService = ServiceManager.instance.getService(GameDataService.sID) as GameDataService;
         var _oRequest:ServiceRequest = _oService.getTemplateList(BuilderMain.instance.gameData.builderAlias,BuilderMain.instance.gameData.propertyAlias);
         eventManager.addEventListener(sEVENT_RENDER_ID,_oRequest,ServiceRequestEvent.RESPONSE,this.onTemplateListLoaded);
      }
      
      private function loadGameData() : void
      {
         if(Boolean(GameDataManager.instance.getGameData(oSelector.selectedValue)))
         {
            this.onGameDataLoaded(null);
         }
         else
         {
            eventManager.addEventListener(sEVENT_RENDER_ID,GameDataManager.instance,GameDataEvent.COMPLETE,this.onGameDataLoaded);
            StepManager.instance.showLoading();
            GameDataManager.instance.loadGameData(oSelector.selectedValue);
         }
      }
      
      private function select() : void
      {
         super.onSelect(null);
      }
      
      private function greyOutBackground() : void
      {
         var _oColorMatrix:ColorMatrix = null;
         if(Boolean(BuilderManager.instance) && Boolean(BuilderManager.instance.renderer.background))
         {
            if(StepManager.instance.currentStep.id == StepManager.sSTEP_LAYOUT)
            {
               _oColorMatrix = new ColorMatrix();
               _oColorMatrix.adjustSaturation(-100);
               BuilderManager.instance.renderer.background.bitmap.filters = [new ColorMatrixFilter(_oColorMatrix)];
            }
         }
      }
      
      private function unGreyBackground() : void
      {
         if(Boolean(BuilderManager.instance) && Boolean(BuilderManager.instance.renderer.background))
         {
            BuilderManager.instance.renderer.background.bitmap.filters = [];
         }
      }
      
      override protected function onSelect(_e:Event) : void
      {
         var _oPopup:ConfirmPopup = null;
         if(StepManager.instance.isStepEnabled(StepManager.sSTEP_MUSIC) && BuilderManager.instance.isTemplate == false)
         {
            _oPopup = ViewManager.instance.getView(BuilderMain.sPOPUP_CONFIRM) as ConfirmPopup;
            eventManager.addEventListener(sEVENT_RENDER_ID,_oPopup,PopupEvent.CONFIRM,this.onSelectConfirm);
            eventManager.addEventListener(sEVENT_RENDER_ID,_oPopup,PopupEvent.CANCEL,this.onSelectCancel);
            BuilderMain.instance.showConfirmPopup("id_ui_step_layout_confirmTitle","id_ui_step_layout_confirmText","id_ui_step_layout_btnConfirm","id_ui_step_layout_btnCancel");
         }
         else
         {
            this.loadGameData();
         }
      }
      
      private function onSelectConfirm(_e:PopupEvent) : void
      {
         eventManager.removeEventListener(sEVENT_RENDER_ID,_e.target as ConfirmPopup,PopupEvent.CONFIRM,this.onSelectConfirm);
         eventManager.removeEventListener(sEVENT_RENDER_ID,_e.target as ConfirmPopup,PopupEvent.CANCEL,this.onSelectCancel);
         StepManager.instance.enableStep(StepManager.sSTEP_PUBLISH,false);
         BuilderMain.instance.hidePopup(BuilderMain.sPOPUP_CONFIRM);
         this.loadGameData();
      }
      
      private function onSelectCancel(_e:PopupEvent) : void
      {
         eventManager.removeEventListener(sEVENT_RENDER_ID,_e.target as ConfirmPopup,PopupEvent.CONFIRM,this.onSelectConfirm);
         eventManager.removeEventListener(sEVENT_RENDER_ID,_e.target as ConfirmPopup,PopupEvent.CANCEL,this.onSelectCancel);
         oSelector.selectNone();
         BuilderMain.instance.hidePopup(BuilderMain.sPOPUP_CONFIRM);
      }
      
      private function onTemplateListLoaded(_e:ServiceRequestEvent) : void
      {
         var _oTemplate:XML = null;
         var _oLoader:DisplayLoader = null;
         this.aLayouts = new Array();
         this.oTemplateLoader = new ParallelLoader();
         var _oXML:XML = new XML(_e.data);
         var _oTemplates:XMLList = _oXML..template;
         var _sImageFolder:String = MediaManager.instance.mediaServer + "/";
         _sImageFolder += ExternalConfig.instance.getProperty(CommonConfig.sCONFIG_MEDIA_PATH) + "/";
         _sImageFolder += BuilderMain.instance.gameData.builderAlias + "/";
         _sImageFolder += BuilderMain.instance.gameData.propertyAlias + "/";
         _sImageFolder += "templates/";
         for each(_oTemplate in _oTemplates)
         {
            _oLoader = new DisplayLoader(_sImageFolder + _oTemplate.@alias + ".png");
            eventManager.addEventListener(sEVENT_RENDER_ID,_oLoader,PreloadEvent.COMPLETE,this.onTemplatePreviewLoaded,false,0,true,_oTemplate.@alias);
            this.oTemplateLoader.addLoader(_oLoader);
         }
         eventManager.addEventListener(sEVENT_RENDER_ID,this.oTemplateLoader,PreloadEvent.GROUP_COMPLETE,this.onAllTemplatePreviewLoaded);
         this.oTemplateLoader.start();
      }
      
      private function onTemplatePreviewLoaded(_e:PreloadEvent, _sAlias:String) : void
      {
         var _oBitmap:Bitmap = _e.content;
         this.aLayouts.push(new LayoutStruct(_sAlias,_oBitmap.bitmapData));
      }
      
      private function onAllTemplatePreviewLoaded(_e:PreloadEvent) : void
      {
         this.aLayouts.sortOn("sAlias");
         if(Boolean(this.oTemplateLoader))
         {
            this.oTemplateLoader.destroy();
         }
         this.oTemplateLoader = null;
         this.populateWheel();
      }
      
      private function onGameDataLoaded(_e:GameDataEvent) : void
      {
         eventManager.cleanUp(sEVENT_RENDER_ID);
         var _oGameData:GameData = GameDataManager.instance.getGameData(oSelector.selectedValue);
         BuilderMain.instance.templateData = new TemplateData(_oGameData,BuilderMain.instance.mediaList);
         BuilderManager.instance.builderData = new BuilderData(_oGameData,true);
         BuilderMain.instance.gameData.template = oSelector.selectedValue;
         StepManager.instance.hideLoading();
         this.select();
      }
      
      override protected function get itemHeightRatio() : Number
      {
         return 231 / 350;
      }
      
      private function get blankTemplateBD() : BitmapData
      {
         if(this.oBlankBD == null)
         {
            this.oBlankBD = new BitmapData(BuilderConfig.oPREVIEW_SIZE.x,BuilderConfig.oPREVIEW_SIZE.y,true,0);
         }
         return this.oBlankBD;
      }
   }
}

import flash.display.BitmapData;

class LayoutStruct
{
   
   public var sAlias:String;
   
   public var oBD:BitmapData;
   
   public function LayoutStruct(_sAlias:String, _oBD:BitmapData)
   {
      super();
      this.sAlias = _sAlias;
      this.oBD = _oBD;
   }
   
   public function destroy() : void
   {
      if(Boolean(this.oBD))
      {
         this.oBD.dispose();
      }
      this.oBD = null;
   }
}
