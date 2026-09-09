package ui.selectionPopup
{
   import com.sarbakan.sbdk.asset.AssetReference;
   import com.sarbakan.sbdk.events.UIEvent;
   import com.sarbakan.sbdk.ui.Button;
   import com.sarbakan.sbdk.view.AbstractView;
   import flash.events.Event;
   import ui.selectionGrid.SelectionGrid;
   
   public class AbstractSelectionPopup extends AbstractView
   {
      
      private static const sEVENT_MANAGER_ID:String = "eventManager";
      
      protected static const sEVENT_RENDER_ID:String = "eventRender";
      
      protected var oSelector:SelectionGrid;
      
      public function AbstractSelectionPopup()
      {
         super();
         assetLocation = AssetReference.fromLibraryClass(mcSelectionGridPopup);
         bUseMouseBlocker = false;
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.destroySelector();
      }
      
      override public function onBeforeShow() : void
      {
         this.initSelector();
         this.initBtnNext();
      }
      
      override public function onHide() : void
      {
         super.onHide();
         eventManager.cleanUp(sEVENT_MANAGER_ID);
         this.destroySelector();
      }
      
      protected function initBtnNext() : void
      {
         var _oBtnNext:Button = StepManager.instance.header.btnNext;
         _oBtnNext.mcContainer.visible = true;
         _oBtnNext.setLocalizedLabel("id_ui_global_btnNext");
         _oBtnNext.enabled = Boolean(this.oSelector.selectedValue != null);
         eventManager.addEventListener(sEVENT_MANAGER_ID,_oBtnNext,UIEvent.RELEASE,this.onBtnNext);
      }
      
      protected function initSelector() : void
      {
         this.oSelector = new SelectionGrid(mcContent.mcSelector,this.itemHeightRatio,this.overRatio,this.heightModifier);
         eventManager.addEventListener(sEVENT_MANAGER_ID,this.oSelector,UIEvent.CHANGE,this.onSelect);
      }
      
      protected function destroySelector() : void
      {
         if(Boolean(this.oSelector))
         {
            this.oSelector.destroy();
         }
         this.oSelector = null;
      }
      
      protected function onSelect(_e:Event) : void
      {
         dispatchEvent(new Event(Event.SELECT));
         StepManager.instance.header.btnNext.enabled = true;
      }
      
      protected function onBtnNext(_e:UIEvent) : void
      {
         StepManager.instance.next();
      }
      
      protected function get itemHeightRatio() : Number
      {
         return 1;
      }
      
      protected function get overRatio() : Number
      {
         return 1.1;
      }
      
      protected function get heightModifier() : Number
      {
         var _oBtnNext:Button = StepManager.instance.header.btnNext;
         var _nReturn:Number = 0;
         if(Boolean(_oBtnNext))
         {
            _nReturn = _oBtnNext.mcContainer.height;
         }
         return _nReturn;
      }
   }
}

