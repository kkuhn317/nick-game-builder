package com.sarbakan.sbdk.ui
{
   import com.sarbakan.sbdk.localization.LocalizationManager;
   import com.sarbakan.sbdk.state.AnimStateMachine;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   
   public class ToolTip extends EventDispatcher
   {
      
      private static const sSTATE_IN:String = "in";
      
      private static const sSTATE_IDLE:String = "idle";
      
      private static const sSTATE_OUT:String = "out";
      
      private var oAnimStateMachine:AnimStateMachine;
      
      private var mcRef:MovieClip;
      
      private var sContent:String;
      
      private var sLocalizationStringID:String;
      
      private var oLocalizationReplacements:Object;
      
      private var nMaxWidth:Number;
      
      public function ToolTip(_mcRef:MovieClip, _mcContainer:DisplayObjectContainer, _sContent:String, _nX:Number, _nY:Number, _nMaxWidth:Number = 0, _sLocalizationStringID:String = null, _oLocalizationReplacements:Object = null)
      {
         super();
         this.sContent = _sContent;
         this.sLocalizationStringID = _sLocalizationStringID;
         this.oLocalizationReplacements = _oLocalizationReplacements;
         this.mcRef = _mcRef;
         _mcContainer.addChild(this.mcRef);
         this.mcRef.x = _nX;
         this.mcRef.y = _nY;
         if(_nMaxWidth == 0)
         {
            this.nMaxWidth = _mcContainer.stage.stageWidth;
         }
         else
         {
            this.nMaxWidth = _nMaxWidth;
         }
         this.init();
      }
      
      public function destroy() : void
      {
         if(Boolean(this.mcRef) && Boolean(this.mcRef.parent))
         {
            this.mcRef.parent.removeChild(this.mcRef);
         }
         this.mcRef = null;
         if(Boolean(this.oAnimStateMachine))
         {
            this.oAnimStateMachine.destroy();
         }
         this.oAnimStateMachine = null;
      }
      
      public function hide() : void
      {
         if(Boolean(this.oAnimStateMachine))
         {
            this.oAnimStateMachine.setState(sSTATE_OUT);
         }
      }
      
      override public function toString() : String
      {
         return "[ToolTip: Content = " + this.sContent + "]";
      }
      
      private function init() : void
      {
         this.oAnimStateMachine = new AnimStateMachine(this.mcRef,false,false);
         this.oAnimStateMachine.addState(sSTATE_IN,this.state_in,this.stateLoad);
         this.oAnimStateMachine.addState(sSTATE_IDLE,null,this.stateLoad);
         this.oAnimStateMachine.addState(sSTATE_OUT,this.state_out,this.stateLoad);
         this.oAnimStateMachine.setState(sSTATE_IN);
      }
      
      private function render(_bRepositionContent:Boolean = false) : void
      {
         var _oBounds:Rectangle = null;
         var _nDelta:Number = NaN;
         var _nVerticalDelta:Number = NaN;
         this.mcRef.visible = false;
         var _oTextField:TextField = this.oAnimStateMachine.mcState.mcContent.mcText.txtText as TextField;
         var _oFrame:MovieClip = this.oAnimStateMachine.mcState.mcContent.mcFrame as MovieClip;
         var _nMarginWidth:Number = _oFrame.width - _oTextField.width;
         var _nMarginHeight:Number = _oFrame.height - _oTextField.height;
         _oTextField.multiline = false;
         _oTextField.wordWrap = false;
         _oTextField.autoSize = TextFieldAutoSize.LEFT;
         if(this.sLocalizationStringID == null)
         {
            _oTextField.text = this.sContent;
         }
         else
         {
            LocalizationManager.instance.setTextField(_oTextField,this.sLocalizationStringID,this.oLocalizationReplacements);
         }
         if(_oTextField.width > this.nMaxWidth)
         {
            _oTextField.width = this.nMaxWidth;
            _oTextField.multiline = true;
            _oTextField.wordWrap = true;
         }
         _oFrame.width = _oTextField.textWidth + _nMarginWidth * 2;
         _oFrame.height = _oTextField.textHeight + _nMarginHeight;
         if(_bRepositionContent)
         {
            _oBounds = this.mcRef.getBounds(this.mcRef.stage);
            if(_oBounds.right > this.mcRef.stage.stageWidth)
            {
               _nDelta = _oBounds.right - this.mcRef.stage.stageWidth;
               this.mcRef.x -= _nDelta;
            }
            if(_oBounds.bottom > this.mcRef.stage.stageHeight)
            {
               _nDelta = _oBounds.bottom - this.mcRef.stage.stageHeight;
               this.mcRef.y -= _nDelta;
            }
            _oBounds = this.mcRef.getBounds(this.mcRef.stage);
            if(_oBounds.contains(this.mcRef.parent.mouseX,this.mcRef.parent.mouseY))
            {
               _nVerticalDelta = _oBounds.bottom - this.mcRef.parent.mouseY;
               this.mcRef.y -= _nVerticalDelta + ToolTipManager.nDEFAULT_OFFSET_Y;
            }
         }
         this.mcRef.visible = true;
      }
      
      protected function stateLoad() : void
      {
         this.render(this.oAnimStateMachine.state == sSTATE_IN);
      }
      
      protected function state_in() : void
      {
         if(this.oAnimStateMachine.isLastFrame)
         {
            this.oAnimStateMachine.setState(sSTATE_IDLE);
         }
      }
      
      protected function state_out() : void
      {
         if(this.oAnimStateMachine.isLastFrame)
         {
            this.destroy();
            dispatchEvent(new Event(Event.COMPLETE));
         }
      }
   }
}

