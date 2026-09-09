package com.sarbakan.sbdk.view
{
   import com.sarbakan.sbdk.errors.ErrorMessages;
   import com.sarbakan.sbdk.events.TransitionEvent;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   [Event(name="ERROR",type="com.sarbakan.sbdk.events.TransitionEvent")]
   [Event(name="RESUME",type="com.sarbakan.sbdk.events.TransitionEvent")]
   [Event(name="PAUSE",type="com.sarbakan.sbdk.events.TransitionEvent")]
   [Event(name="COMPLETE",type="com.sarbakan.sbdk.events.TransitionEvent")]
   [Event(name="STOP",type="com.sarbakan.sbdk.events.TransitionEvent")]
   [Event(name="START",type="com.sarbakan.sbdk.events.TransitionEvent")]
   public class AbstractEffectTransition extends AbstractTransition
   {
      
      private static const sRENDER_EVENT:String = "RENDER_EVENT";
      
      protected var oInput:BitmapData;
      
      protected var oOutput:BitmapData;
      
      protected var oCanvas:Bitmap;
      
      private var nWidth:uint;
      
      private var nHeight:uint;
      
      public function AbstractEffectTransition()
      {
         super();
         if(Class(getDefinitionByName(getQualifiedClassName(this))) == AbstractEffectTransition)
         {
            throw new IllegalOperationError(ErrorMessages.sABSTRACT_CLASS_ERROR);
         }
         this.nWidth = 0;
         this.nHeight = 0;
      }
      
      protected function onStart(_mcView:DisplayObject) : void
      {
      }
      
      protected function onRender() : void
      {
      }
      
      protected function indicateDone() : void
      {
         dispatchEvent(new TransitionEvent(TransitionEvent.COMPLETE,false,false,ID,mcContainer));
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.oCanvas = null;
         this.oOutput.dispose();
         this.oInput.dispose();
         this.oInput = null;
         this.oOutput = null;
      }
      
      public function copy() : AbstractEffectTransition
      {
         return null;
      }
      
      override public function start(_mcRef:DisplayObject) : void
      {
         super.start(_mcRef);
         this.nWidth = _mcRef.width;
         this.nHeight = _mcRef.height;
         this.oInput = new BitmapData(this.nWidth,this.nHeight,true,0);
         if(this.oOutput == null)
         {
            this.oOutput = new BitmapData(this.nWidth,this.nHeight,true,0);
         }
         this.oInput.draw(_mcRef);
         this.oCanvas = new Bitmap(this.oOutput);
         mcContainer.addChild(this.oCanvas);
         eventManager.addEventListener(sRENDER_EVENT,mcContainer,Event.ENTER_FRAME,this.onEnterFrame);
         this.onStart(_mcRef);
      }
      
      override public function stop() : void
      {
         super.stop();
         eventManager.cleanUp(sRENDER_EVENT);
      }
      
      override public function pause() : void
      {
         super.pause();
         eventManager.cleanUp(sRENDER_EVENT);
      }
      
      override public function resume() : void
      {
         super.resume();
         eventManager.addEventListener(sRENDER_EVENT,mcContainer,Event.ENTER_FRAME,this.onEnterFrame);
      }
      
      private function onEnterFrame(_oEvent:Event) : void
      {
         this.onRender();
      }
      
      public function get width() : uint
      {
         return this.nWidth;
      }
      
      public function get height() : uint
      {
         return this.nHeight;
      }
      
      override public function set originViewAssetRef(_mcViewRef:DisplayObject) : void
      {
         if(_mcViewRef != null)
         {
            if(this.oOutput == null)
            {
               this.oOutput = new BitmapData(_mcViewRef.width,_mcViewRef.height,true,0);
            }
            this.oOutput.draw(_mcViewRef);
         }
      }
   }
}

