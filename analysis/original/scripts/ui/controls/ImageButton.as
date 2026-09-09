package ui.controls
{
   import com.sarbakan.sbdk.ui.Button;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.geom.Rectangle;
   
   public class ImageButton extends Button
   {
      
      private var oImage:DisplayObject;
      
      private var nImageRatio:Number = 1;
      
      private var nOverRatio:Number = 1;
      
      private var nWidth:Number;
      
      private var nHeight:Number;
      
      public function ImageButton(_mcRef:MovieClip, _oImage:DisplayObject)
      {
         this.oImage = _oImage;
         super(_mcRef);
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.oImage = null;
      }
      
      public function setScale(_nWidth:Number, _nHeight:Number) : void
      {
         if(Boolean(mcContainer.mcHitArea))
         {
            mcContainer.mcHitArea.width = _nWidth;
            mcContainer.mcHitArea.height = _nHeight;
         }
         this.nWidth = _nWidth;
         this.nHeight = _nHeight;
         this.updateBkgScale();
      }
      
      private function addImage() : void
      {
         if(Boolean(oAnimStateMachine) && Boolean(oAnimStateMachine.mcState) && Boolean(oAnimStateMachine.mcState.mcImage))
         {
            oAnimStateMachine.mcState.mcImage.addChild(this.oImage);
         }
      }
      
      private function centerImage() : void
      {
         var _nRatio:Number = this.nImageRatio;
         if(oAnimStateMachine.isState(sSTATE_OVER))
         {
            _nRatio = this.nImageRatio * this.nOverRatio;
         }
         this.oImage.scaleX = _nRatio;
         this.oImage.scaleY = _nRatio;
         var _oBounds:Rectangle = this.oImage.getBounds(this.oImage);
         this.oImage.x = -this.oImage.width / 2 - _oBounds.x * _nRatio;
         this.oImage.y = -this.oImage.height / 2 - _oBounds.y * _nRatio;
      }
      
      private function updateBkgScale() : void
      {
         var _nRatio:Number = NaN;
         if(!isNaN(this.nWidth) && !isNaN(this.nHeight))
         {
            if(Boolean(oAnimStateMachine.mcState) && Boolean(oAnimStateMachine.mcState.mcBkg))
            {
               _nRatio = 1;
               if(oAnimStateMachine.isState(sSTATE_OVER))
               {
                  _nRatio = this.nOverRatio;
               }
               oAnimStateMachine.mcState.mcBkg.width = this.nWidth * _nRatio;
               oAnimStateMachine.mcState.mcBkg.height = this.nHeight * _nRatio;
            }
         }
      }
      
      override protected function state_up_load() : void
      {
         super.state_up_load();
         this.updateBkgScale();
         this.addImage();
      }
      
      override protected function state_over_load() : void
      {
         super.state_over_load();
         this.updateBkgScale();
         this.addImage();
      }
      
      override protected function state_down_load() : void
      {
         super.state_down_load();
         this.updateBkgScale();
         this.addImage();
      }
      
      override protected function state_disabled_load() : void
      {
         super.state_disabled_load();
         this.updateBkgScale();
         this.addImage();
      }
      
      override protected function onRender() : void
      {
         super.onRender();
         this.centerImage();
      }
      
      public function set imageRatio(_nValue:Number) : void
      {
         this.nImageRatio = _nValue;
         this.centerImage();
      }
      
      public function set overRatio(_nValue:Number) : void
      {
         this.nOverRatio = _nValue;
         this.centerImage();
      }
   }
}

