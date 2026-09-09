package com.sarbakan.sbdk.asset
{
   import com.sarbakan.sbdk.utils.EventManager;
   import flash.display.DisplayObject;
   
   public class DisplayAsset extends AbstractAsset
   {
      
      private var mcRef:DisplayObject;
      
      private var oEventManager:EventManager;
      
      public function DisplayAsset(_sID:String, _mcRef:DisplayObject)
      {
         this.mcRef = _mcRef;
         super(_sID);
      }
      
      override public function destroy() : void
      {
         this.mcRef = null;
         this.oEventManager.clearAll();
         this.oEventManager.destroy();
         this.oEventManager = null;
      }
      
      override protected function init() : void
      {
         this.oEventManager = new EventManager();
      }
      
      public function get content() : DisplayObject
      {
         return this.mcRef;
      }
   }
}

