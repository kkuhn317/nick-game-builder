package com.sarbakan.sbdk.ui
{
   import com.sarbakan.sbdk.asset.AssetManager;
   import com.sarbakan.sbdk.asset.AssetReference;
   import com.sarbakan.sbdk.asset.DisplayAsset;
   import com.sarbakan.sbdk.errors.ErrorMessages;
   import com.sarbakan.sbdk.utils.EventManager;
   import flash.display.DisplayObjectContainer;
   import flash.display.InteractiveObject;
   import flash.display.MovieClip;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.IEventDispatcher;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   
   public class ToolTipManager
   {
      
      private static var oInstance:ToolTipManager;
      
      private static const sEVENT_MANAGER_ID:String = "toolTipManager";
      
      public static const nDEFAULT_DELAY:uint = 500;
      
      public static const nDEFAULT_MAX_WIDTH:uint = 0;
      
      public static const nDEFAULT_OFFSET_X:Number = 10;
      
      public static const nDEFAULT_OFFSET_Y:Number = 25;
      
      private static var bAllowConstruction:Boolean = false;
      
      private var oStage:Stage;
      
      private var oEventManager:EventManager;
      
      private var oToolTipAsset:AssetReference;
      
      private var cToolTipClass:Class;
      
      private var nDelay:uint;
      
      private var nMaxWidth:Number;
      
      private var nOffsetX:Number;
      
      private var nOffsetY:Number;
      
      private var oTargetList:Dictionary;
      
      private var oDelays:Dictionary;
      
      private var oTargetListLocalized:Dictionary;
      
      private var aCurrentToolTip:Array;
      
      private var mcCurrentTarget:InteractiveObject;
      
      private var oDetectionTimer:Timer;
      
      public function ToolTipManager(_oStage:Stage)
      {
         super();
         if(!bAllowConstruction)
         {
            throw new Error(ErrorMessages.sSINGLETON_STAGE);
         }
         this.oStage = _oStage;
         this.init();
      }
      
      public static function instance(_oStage:Stage) : ToolTipManager
      {
         if(oInstance == null)
         {
            bAllowConstruction = true;
            oInstance = new ToolTipManager(_oStage);
            bAllowConstruction = false;
         }
         return oInstance;
      }
      
      public function destroy() : void
      {
         this.oEventManager.destroy();
         this.killCurrent();
         this.aCurrentToolTip = null;
         oInstance = null;
         this.oStage = null;
         this.oToolTipAsset = null;
         this.cToolTipClass = null;
         this.oTargetList = null;
         this.oDelays = null;
         this.oTargetListLocalized = null;
         this.oDetectionTimer = null;
         this.mcCurrentTarget = null;
      }
      
      public function hideCurrent() : void
      {
         var _oToolTip:ToolTip = null;
         if(this.aCurrentToolTip != null)
         {
            for each(_oToolTip in this.aCurrentToolTip)
            {
               _oToolTip.hide();
            }
         }
      }
      
      public function killCurrent() : void
      {
         var _oToolTip:ToolTip = null;
         if(this.aCurrentToolTip != null)
         {
            for each(_oToolTip in this.aCurrentToolTip)
            {
               _oToolTip.destroy();
            }
         }
      }
      
      public function setConfiguration(_oToolTipAsset:AssetReference, _cToolTipClass:Class = null) : void
      {
         this.oToolTipAsset = _oToolTipAsset;
         if(_cToolTipClass == null)
         {
            this.cToolTipClass = ToolTip;
         }
         else
         {
            this.cToolTipClass = _cToolTipClass;
         }
      }
      
      public function addTarget(_mcTarget:InteractiveObject, _sContent:String, _iDelay:int = -1) : void
      {
         this.oTargetList[_mcTarget] = _sContent;
         this.oDelays[_mcTarget] = _iDelay;
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,_mcTarget,MouseEvent.ROLL_OVER,this.onRollOverTarget);
      }
      
      public function addTargetLocalized(_mcTarget:InteractiveObject, _sStringID:String, _oReplacements:Object = null, _iDelay:int = -1) : void
      {
         this.oTargetListLocalized[_mcTarget] = new LocalizedContentStruct(_sStringID,_oReplacements);
         this.oDelays[_mcTarget] = _iDelay;
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,_mcTarget,MouseEvent.ROLL_OVER,this.onRollOverTarget);
      }
      
      public function removeTarget(_mcTarget:DisplayObjectContainer) : void
      {
         delete this.oTargetList[_mcTarget];
         delete this.oDelays[_mcTarget];
         this.oEventManager.removeEventListener(sEVENT_MANAGER_ID,_mcTarget,MouseEvent.ROLL_OVER,this.onRollOverTarget);
      }
      
      public function removeTargetLocalized(_mcTarget:DisplayObjectContainer) : void
      {
         delete this.oTargetListLocalized[_mcTarget];
         this.oEventManager.removeEventListener(sEVENT_MANAGER_ID,_mcTarget,MouseEvent.ROLL_OVER,this.onRollOverTarget);
      }
      
      private function init() : void
      {
         this.oEventManager = new EventManager();
         this.aCurrentToolTip = new Array();
         this.nDelay = nDEFAULT_DELAY;
         this.nMaxWidth = nDEFAULT_MAX_WIDTH;
         this.nOffsetX = nDEFAULT_OFFSET_X;
         this.nOffsetY = nDEFAULT_OFFSET_Y;
         this.oTargetList = new Dictionary(true);
         this.oDelays = new Dictionary(true);
         this.oTargetListLocalized = new Dictionary(true);
         this.oDetectionTimer = new Timer(this.nDelay,1);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oDetectionTimer,TimerEvent.TIMER_COMPLETE,this.onDetectionTimer);
      }
      
      private function onRollOverTarget(_e:MouseEvent) : void
      {
         if(this.oDelays[_e.target] == -1)
         {
            this.oDetectionTimer.delay = this.nDelay;
         }
         else
         {
            this.oDetectionTimer.delay = this.oDelays[_e.target];
         }
         this.oDetectionTimer.start();
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,_e.target as IEventDispatcher,MouseEvent.ROLL_OUT,this.onRollOutTarget);
         this.mcCurrentTarget = _e.target as InteractiveObject;
      }
      
      private function onRollOutTarget(_e:MouseEvent) : void
      {
         this.oDetectionTimer.stop();
         this.oEventManager.removeEventListener(sEVENT_MANAGER_ID,_e.target as IEventDispatcher,MouseEvent.ROLL_OUT,this.onRollOutTarget);
         this.mcCurrentTarget = null;
         this.hideCurrent();
      }
      
      private function onDetectionTimer(_e:TimerEvent) : void
      {
         this.oEventManager.removeEventListener(sEVENT_MANAGER_ID,_e.target as IEventDispatcher,MouseEvent.ROLL_OUT,this.onRollOutTarget);
         this.hideCurrent();
         if(this.oToolTipAsset != null)
         {
            AssetManager.instance.requestAsset(this.oToolTipAsset,this.onToolTipAsset);
         }
      }
      
      private function onToolTipAsset(_oAsset:DisplayAsset) : void
      {
         var _oTooltip:ToolTip = null;
         var _oContent:LocalizedContentStruct = null;
         if(Boolean(this.oTargetListLocalized[this.mcCurrentTarget]))
         {
            _oContent = this.oTargetListLocalized[this.mcCurrentTarget] as LocalizedContentStruct;
            _oTooltip = new this.cToolTipClass(_oAsset.content as MovieClip,this.oStage,null,this.oStage.mouseX + this.nOffsetX,this.oStage.mouseY + this.nOffsetY,this.nMaxWidth,_oContent.sStringID,_oContent.oReplacements) as ToolTip;
         }
         else
         {
            _oTooltip = new this.cToolTipClass(_oAsset.content as MovieClip,this.oStage,this.oTargetList[this.mcCurrentTarget],this.oStage.mouseX + this.nOffsetX,this.oStage.mouseY + this.nOffsetY,this.nMaxWidth) as ToolTip;
         }
         if(Boolean(_oTooltip))
         {
            this.aCurrentToolTip.push(_oTooltip);
            this.oEventManager.addEventListener(sEVENT_MANAGER_ID,_oTooltip,Event.COMPLETE,this.onTooltipComplete);
         }
      }
      
      private function onTooltipComplete(_e:Event) : void
      {
         var _nIndex:int = this.aCurrentToolTip.indexOf(_e.target);
         if(_nIndex != -1)
         {
            this.aCurrentToolTip.splice(_nIndex,1);
         }
      }
      
      public function get delay() : Number
      {
         return this.nDelay;
      }
      
      public function set delay(_nDelay:Number) : void
      {
         this.nDelay = _nDelay;
      }
      
      public function get maxWidth() : Number
      {
         return this.nMaxWidth;
      }
      
      public function set maxWidth(_nMaxWidth:Number) : void
      {
         this.nMaxWidth = _nMaxWidth;
      }
      
      public function get offsetX() : Number
      {
         return this.nOffsetX;
      }
      
      public function set offsetX(_nOffset:Number) : void
      {
         this.nOffsetX = _nOffset;
      }
      
      public function get offsetY() : Number
      {
         return this.nOffsetY;
      }
      
      public function set offsetY(_nOffset:Number) : void
      {
         this.nOffsetY = _nOffset;
      }
   }
}

class LocalizedContentStruct
{
   
   public var sStringID:String;
   
   public var oReplacements:Object;
   
   public function LocalizedContentStruct(_sStringID:String, _oReplacements:Object)
   {
      super();
      this.sStringID = _sStringID;
      this.oReplacements = _oReplacements;
   }
}
