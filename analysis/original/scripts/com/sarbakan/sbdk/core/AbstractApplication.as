package com.sarbakan.sbdk.core
{
   import com.sarbakan.sbdk.asset.AssetManager;
   import com.sarbakan.sbdk.errors.ErrorMessages;
   import com.sarbakan.sbdk.input.MouseUtils;
   import com.sarbakan.sbdk.localization.LocalizationManager;
   import com.sarbakan.sbdk.preload.PreloadManager;
   import com.sarbakan.sbdk.sound.SoundManager;
   import com.sarbakan.sbdk.sound.vomanager.VoiceOverManager;
   import com.sarbakan.sbdk.state.StateMachine;
   import com.sarbakan.sbdk.state.StateMachineType;
   import com.sarbakan.sbdk.tools.logger.Logger;
   import com.sarbakan.sbdk.ui.AbstractControl;
   import com.sarbakan.sbdk.utils.AbsPathUtil;
   import com.sarbakan.sbdk.utils.EventManager;
   import com.sarbakan.sbdk.utils.ExternalConfig;
   import com.sarbakan.sbdk.utils.ExternalFontManager;
   import com.sarbakan.sbdk.utils.FPSMonitor;
   import com.sarbakan.sbdk.utils.FocusKeeper;
   import com.sarbakan.sbdk.utils.GraphicDebugTextManager;
   import com.sarbakan.sbdk.utils.MemoryMonitor;
   import com.sarbakan.sbdk.utils.StringUtils;
   import com.sarbakan.sbdk.view.ViewManager;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.system.Capabilities;
   import flash.ui.ContextMenu;
   import flash.ui.ContextMenuItem;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public class AbstractApplication extends Sprite
   {
      
      private static const sAPP_INIT_EVENT:String = "app_init";
      
      private static const sAPP_DEST_EVENT:String = "app_dest";
      
      private var oEventManager:EventManager;
      
      private var oPublicEventManager:EventManager;
      
      private var oStateMachine:StateMachine;
      
      private var oUpdateManager:UpdateManager;
      
      private var sVersionInfo:String;
      
      private var bDisplayContextMenu:Boolean;
      
      private var oInfoContextMenuItem:ContextMenuItem;
      
      public function AbstractApplication(_bSkipAddedToStage:Boolean = false)
      {
         super();
         if(Class(getDefinitionByName(getQualifiedClassName(this))) == AbstractApplication)
         {
            throw new IllegalOperationError(ErrorMessages.sABSTRACT_CLASS_ERROR);
         }
         this.oEventManager = new EventManager();
         if(!_bSkipAddedToStage)
         {
            this.oEventManager.addEventListener(sAPP_INIT_EVENT,this,Event.ADDED_TO_STAGE,this.onAddedToStage);
            this.oEventManager.addEventListener(sAPP_DEST_EVENT,this,Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
         }
         this.displayContextMenuInfo = true;
      }
      
      public function destroy() : void
      {
         if(this.oPublicEventManager != null)
         {
            this.oPublicEventManager.clearAll();
            this.oPublicEventManager.destroy();
            this.oPublicEventManager = null;
         }
         this.oEventManager.destroy();
         this.oStateMachine.destroy();
         this.oStateMachine = null;
         this.oEventManager = null;
         this.destroySingletons();
         this.oUpdateManager.destroy();
         this.oUpdateManager = null;
         AbstractControl.destroy();
      }
      
      protected function init() : void
      {
      }
      
      protected function initStateMachine() : void
      {
         this.oStateMachine = new StateMachine(StateMachineType.FRAME_BASED);
      }
      
      protected function initUpdateManager() : void
      {
         this.oUpdateManager = UpdateManager.instance;
         this.oUpdateManager.stage = this.stage;
         this.oUpdateManager.setUpdateCallback(this.stage,Event.ENTER_FRAME);
      }
      
      protected function initPreloadManager() : void
      {
         PreloadManager.instance.appAbsPath = AbsPathUtil.getPath(loaderInfo.url);
      }
      
      private function destroySingletons() : void
      {
         VoiceOverManager.instance.destroy();
         SoundManager.instance.destroy();
         LocalizationManager.instance.destroy();
         ExternalFontManager.instance.destroy();
         AssetManager.instance.destroy();
         PreloadManager.instance.destroy();
         ViewManager.instance.destroy();
         MouseUtils.instance(null).destroy();
         FPSMonitor.instance(null).destroy();
         FocusKeeper.instance(null).destroy();
         MemoryMonitor.instance.destroy();
         GraphicDebugTextManager.instance.destroy();
         ExternalConfig.instance.destroy();
      }
      
      private function validateExternalFontManager() : void
      {
         var _mcParent:DisplayObject = null;
         var _oClass:Class = null;
         var _oLocalManager:LocalizationManager = null;
         try
         {
            _mcParent = DisplayObject(this.parent);
            if(_mcParent.loaderInfo != null)
            {
               _oClass = _mcParent.loaderInfo.applicationDomain.getDefinition("com.sarbakan.sbdk.localization::LocalizationManager") as Class;
               _oLocalManager = LocalizationManager.instance;
               if(_oClass != null && _oLocalManager != null)
               {
                  if(_oLocalManager.externalFontManager != _oClass.instance.externalFontManager)
                  {
                     _oLocalManager.externalFontManager.destroy();
                     _oLocalManager.externalFontManager = _oClass.instance.externalFontManager;
                  }
               }
            }
         }
         catch(e:Error)
         {
            Logger.instance.logWarning("Local ExternalFontManager","validateExternalFontManager","AbstractApplication");
         }
      }
      
      private function setContextMenu() : void
      {
         var _oContextMenu:ContextMenu = null;
         this.destroyContextMenu();
         if(contextMenu != null)
         {
            _oContextMenu = contextMenu;
         }
         else
         {
            _oContextMenu = new ContextMenu();
         }
         var _sContextMenuString:String = "";
         if(this.sVersionInfo != null)
         {
            _sContextMenuString = this.sVersionInfo + " ";
         }
         var _sFlashVersion:String = Capabilities.version;
         _sFlashVersion = _sFlashVersion.split(" ").pop();
         _sFlashVersion = StringUtils.replace(_sFlashVersion,",",".");
         var _bOnlyShowFlashPlayer:Boolean = _sContextMenuString == "";
         if(!_bOnlyShowFlashPlayer)
         {
            _sContextMenuString += "(";
         }
         _sContextMenuString += "Flash " + _sFlashVersion;
         if(Capabilities.isDebugger)
         {
            _sContextMenuString += " debug";
         }
         if(!_bOnlyShowFlashPlayer)
         {
            _sContextMenuString += ")";
         }
         this.oInfoContextMenuItem = new ContextMenuItem(_sContextMenuString,false,false);
         _oContextMenu.customItems.push(this.oInfoContextMenuItem);
         contextMenu = _oContextMenu;
      }
      
      private function destroyContextMenu() : void
      {
         var _oContextMenu:ContextMenu = null;
         var _iIndexPreviousVersion:int = 0;
         if(contextMenu != null)
         {
            _oContextMenu = contextMenu;
            if(this.oInfoContextMenuItem != null)
            {
               _iIndexPreviousVersion = _oContextMenu.customItems.indexOf(_oContextMenu);
               _oContextMenu.customItems.splice(_iIndexPreviousVersion,1);
            }
            contextMenu = _oContextMenu;
         }
      }
      
      protected function onAddedToStage(_oEvent:Event = null) : void
      {
         this.initStateMachine();
         this.initUpdateManager();
         this.stage.stageFocusRect = false;
         this.initPreloadManager();
         this.validateExternalFontManager();
         this.init();
         this.oEventManager.cleanUp(sAPP_INIT_EVENT);
      }
      
      protected function onRemovedFromStage(_oEvent:Event) : void
      {
         this.oEventManager.cleanUp(sAPP_DEST_EVENT);
         this.destroy();
      }
      
      protected function get versionInfo() : String
      {
         return this.sVersionInfo;
      }
      
      protected function set versionInfo(_sVersion:String) : void
      {
         this.sVersionInfo = _sVersion;
         if(this.bDisplayContextMenu)
         {
            this.setContextMenu();
         }
      }
      
      public function get stateMachine() : StateMachine
      {
         return this.oStateMachine;
      }
      
      public function get updateManager() : UpdateManager
      {
         return this.oUpdateManager;
      }
      
      public function get eventManager() : EventManager
      {
         if(this.oPublicEventManager == null)
         {
            this.oPublicEventManager = new EventManager();
         }
         return this.oPublicEventManager;
      }
      
      public function get displayContextMenuInfo() : Boolean
      {
         return this.bDisplayContextMenu;
      }
      
      public function set displayContextMenuInfo(_bEnabled:Boolean) : void
      {
         this.bDisplayContextMenu = _bEnabled;
         if(this.bDisplayContextMenu)
         {
            this.setContextMenu();
         }
         else
         {
            this.destroyContextMenu();
         }
      }
   }
}

