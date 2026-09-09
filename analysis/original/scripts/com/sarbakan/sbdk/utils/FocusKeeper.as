package com.sarbakan.sbdk.utils
{
   import com.sarbakan.sbdk.errors.ErrorMessages;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.text.TextField;
   
   public class FocusKeeper
   {
      
      private static var oInstance:FocusKeeper;
      
      private static const sEVENT_MANAGER_ID:String = "focusKeeper";
      
      private static var bAllowConstruction:Boolean = false;
      
      private var oStage:Stage;
      
      private var oEventManager:EventManager;
      
      private var txtCatcher:TextField;
      
      public function FocusKeeper(_oStage:Stage)
      {
         super();
         if(!bAllowConstruction)
         {
            throw new Error(ErrorMessages.sSINGLETON_STAGE);
         }
         this.oStage = _oStage;
         this.init();
      }
      
      public static function instance(_oStage:Stage) : FocusKeeper
      {
         if(oInstance == null)
         {
            bAllowConstruction = true;
            oInstance = new FocusKeeper(_oStage);
            bAllowConstruction = false;
         }
         return oInstance;
      }
      
      public function destroy() : void
      {
         if(this.oEventManager != null)
         {
            oInstance = null;
            this.oEventManager.destroy();
            this.oEventManager = null;
         }
      }
      
      public function enable() : void
      {
         this.txtCatcher = new TextField();
         this.txtCatcher.width = 0;
         this.txtCatcher.height = 0;
         this.txtCatcher.y = -1000;
         this.oStage.addChild(this.txtCatcher);
         this.oStage.focus = this.txtCatcher;
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oStage,FocusEvent.FOCUS_IN,this.onFocusIn);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oStage,FocusEvent.FOCUS_OUT,this.onFocusOut);
      }
      
      public function disable() : void
      {
         this.oStage.removeChild(this.txtCatcher);
         this.txtCatcher = null;
         this.oEventManager.cleanUp(sEVENT_MANAGER_ID);
         this.oStage.focus = null;
      }
      
      private function init() : void
      {
         this.oEventManager = new EventManager();
      }
      
      private function onFocusIn(_e:Event) : void
      {
         if(!(_e.target is TextField))
         {
            this.oStage.focus = this.txtCatcher;
         }
      }
      
      private function onFocusOut(_e:Event) : void
      {
         this.oStage.focus = this.txtCatcher;
      }
      
      public function get enabled() : Boolean
      {
         return this.txtCatcher != null;
      }
   }
}

