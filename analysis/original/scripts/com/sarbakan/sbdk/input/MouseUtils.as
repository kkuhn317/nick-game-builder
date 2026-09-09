package com.sarbakan.sbdk.input
{
   import com.sarbakan.sbdk.errors.ErrorMessages;
   import com.sarbakan.sbdk.utils.EventManager;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Stage;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   
   public class MouseUtils
   {
      
      private static var oInstance:MouseUtils;
      
      private static const sEVENT_MANAGER_ID_MOUSEDOWN:String = "mouseDown";
      
      private static const sEVENT_MANAGER_ID_MOUSEOUTSIDE:String = "mouseOutside";
      
      private static var bAllowConstruction:Boolean = false;
      
      private var oStage:Stage;
      
      private var oEventManager:EventManager;
      
      private var lMouseUpOutside:Dictionary;
      
      private var bMouseDown:Boolean;
      
      public function MouseUtils(_oStage:Stage)
      {
         super();
         if(!bAllowConstruction)
         {
            throw new Error(ErrorMessages.sSINGLETON_STAGE);
         }
         this.oStage = _oStage;
         this.init();
      }
      
      public static function instance(_oStage:Stage) : MouseUtils
      {
         if(oInstance == null)
         {
            bAllowConstruction = true;
            oInstance = new MouseUtils(_oStage);
            bAllowConstruction = false;
         }
         return oInstance;
      }
      
      public function isMouseDown(_mcRef:DisplayObjectContainer = null) : Boolean
      {
         var _bMouseDown:Boolean = false;
         if(_mcRef != null && this.bMouseDown == true)
         {
            _bMouseDown = this.isMouseOver(_mcRef);
         }
         else
         {
            _bMouseDown = this.bMouseDown;
         }
         return _bMouseDown;
      }
      
      public function isMouseUp() : Boolean
      {
         return this.bMouseDown == false;
      }
      
      public function isMouseOver(_mcRef:DisplayObjectContainer) : Boolean
      {
         return _mcRef.hitTestPoint(_mcRef.stage.mouseX,_mcRef.stage.mouseY);
      }
      
      public function enableMouseUpOutside(_mcRef:DisplayObject) : void
      {
         this.lMouseUpOutside[_mcRef] = true;
         _mcRef.addEventListener(MouseEvent.MOUSE_DOWN,this.onOutsideMouseDown,false,0,true);
      }
      
      public function disableMouseUpOutside(_mcRef:DisplayObject) : void
      {
         _mcRef.removeEventListener(MouseEvent.MOUSE_DOWN,this.onOutsideMouseDown,false);
         this.oEventManager.cleanUp(sEVENT_MANAGER_ID_MOUSEOUTSIDE);
         delete this.lMouseUpOutside[_mcRef];
      }
      
      public function destroy() : void
      {
         var _oKey:Object = null;
         var _mc:DisplayObject = null;
         for(_oKey in this.lMouseUpOutside)
         {
            _mc = _oKey as DisplayObject;
            this.disableMouseUpOutside(_mc);
         }
         this.lMouseUpOutside = null;
         if(this.oEventManager != null)
         {
            this.oEventManager.destroy();
            this.oEventManager = null;
         }
         oInstance = null;
         this.oStage = null;
      }
      
      private function init() : void
      {
         this.lMouseUpOutside = new Dictionary(true);
         this.bMouseDown = false;
         if(this.oStage != null)
         {
            this.oEventManager = new EventManager();
            this.oEventManager.addEventListener(sEVENT_MANAGER_ID_MOUSEDOWN,this.oStage,MouseEvent.MOUSE_DOWN,this.onStatusMouseDown);
            this.oEventManager.addEventListener(sEVENT_MANAGER_ID_MOUSEDOWN,this.oStage,MouseEvent.MOUSE_UP,this.onStatusMouseUp);
         }
      }
      
      private function onStatusMouseDown(_e:MouseEvent) : void
      {
         this.bMouseDown = true;
      }
      
      private function onStatusMouseUp(_e:MouseEvent) : void
      {
         this.bMouseDown = false;
      }
      
      private function onOutsideMouseDown(_e:MouseEvent) : void
      {
         var _mcTarget:DisplayObject = _e.target as DisplayObject;
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID_MOUSEOUTSIDE,_mcTarget,MouseEvent.MOUSE_UP,this.onOutsideMouseUp);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID_MOUSEOUTSIDE,this.oStage,MouseEvent.MOUSE_UP,this.onOutsideMouseUpOutside,false,0,true,_mcTarget);
      }
      
      private function onOutsideMouseUp(_e:MouseEvent) : void
      {
         var _mcTarget:DisplayObject = _e.target as DisplayObject;
         if(this.oEventManager != null)
         {
            this.oEventManager.cleanUp(sEVENT_MANAGER_ID_MOUSEOUTSIDE);
         }
      }
      
      private function onOutsideMouseUpOutside(_e:MouseEvent, _oTarget:*) : void
      {
         var _mcTarget:DisplayObject = _oTarget as DisplayObject;
         this.oEventManager.cleanUp(sEVENT_MANAGER_ID_MOUSEOUTSIDE);
         _mcTarget.dispatchEvent(_e);
      }
   }
}

