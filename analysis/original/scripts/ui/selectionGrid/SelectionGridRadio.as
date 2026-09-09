package ui.selectionGrid
{
   import com.sarbakan.sbdk.asset.AssetReference;
   import com.sarbakan.sbdk.events.UIEvent;
   import com.sarbakan.sbdk.sound.SoundManager;
   import com.sarbakan.sbdk.ui.Radio;
   import flash.display.DisplayObject;
   import flash.geom.Point;
   import ui.controls.ImageButton;
   
   public class SelectionGridRadio extends Radio
   {
      
      private static const sEVENT_MANAGER_SELECT:String = "eventManagerSelect";
      
      private static const nMARGIN:Number = 20;
      
      private var oImage:DisplayObject;
      
      private var nCurrentRatio:Number = 1;
      
      private var nOverRatio:Number = 1;
      
      private var oHitZoneSize:Point;
      
      public function SelectionGridRadio(_oImage:DisplayObject, _oValue:*)
      {
         this.oImage = _oImage;
         super(new mcSelectionGridRadio(),_oValue);
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.oHitZoneSize = null;
         this.oImage = null;
      }
      
      public function updatePos(_nX:Number, _nY:Number, _nCellSize:Number, _nItemHeightRatio:Number, _nOverRatio:Number) : void
      {
         this.nCurrentRatio = Math.min(1,_nCellSize / (this.oImage.width + nMARGIN),_nCellSize * _nItemHeightRatio / (this.oImage.height + nMARGIN));
         this.nOverRatio = _nOverRatio;
         this.oHitZoneSize = new Point(_nCellSize,_nCellSize * _nItemHeightRatio);
         if(Boolean(oCurrentStateButton))
         {
            ImageButton(oCurrentStateButton).imageRatio = this.nCurrentRatio;
            ImageButton(oCurrentStateButton).overRatio = this.nOverRatio;
            ImageButton(oCurrentStateButton).setScale(this.oHitZoneSize.x,this.oHitZoneSize.y);
         }
         mcContainer.x = _nX;
         mcContainer.y = _nY;
      }
      
      override protected function createButton() : void
      {
         oCurrentStateButton = new ImageButton(oAnimStateMachine.mcState,this.oImage);
         oCurrentStateButton.setSoundClick(AssetReference.fromLibraryClass(BuilderSoundConfig.cSND_SELECTOR_CLICK),SoundConfig.sSOUND_CATEGORY_SOUNDS,0);
         oCurrentStateButton.setSoundRoll(AssetReference.fromLibraryClass(BuilderSoundConfig.cSND_SELECTOR_OVER),SoundConfig.sSOUND_CATEGORY_SOUNDS,0);
         if(Boolean(this.oHitZoneSize))
         {
            ImageButton(oCurrentStateButton).setScale(this.oHitZoneSize.x,this.oHitZoneSize.y);
            ImageButton(oCurrentStateButton).imageRatio = this.nCurrentRatio;
            ImageButton(oCurrentStateButton).overRatio = this.nOverRatio;
         }
      }
      
      override protected function onRollOver(_e:UIEvent) : void
      {
         super.onRollOver(_e);
         SoundManager.instance.play(SoundConfig.sSOUND_CATEGORY_SOUNDS,AssetReference.fromLibraryClass(BuilderSoundConfig.cSND_SELECTOR_OVER),1);
      }
      
      override protected function onRelease(_e:UIEvent) : void
      {
         SoundManager.instance.play(SoundConfig.sSOUND_CATEGORY_SOUNDS,AssetReference.fromLibraryClass(BuilderSoundConfig.cSND_SELECTOR_CLICK),1);
         if(!checked)
         {
            super.onRelease(_e);
         }
         else
         {
            dispatchEvent(_e);
            dispatchEvent(new UIEvent(UIEvent.CHANGE));
         }
      }
   }
}

