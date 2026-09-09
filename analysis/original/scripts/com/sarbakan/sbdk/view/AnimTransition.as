package com.sarbakan.sbdk.view
{
   import com.sarbakan.sbdk.asset.AssetReference;
   import com.sarbakan.sbdk.asset.DisplayAsset;
   import com.sarbakan.sbdk.errors.AssetError;
   import com.sarbakan.sbdk.events.TransitionEvent;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   [Event(name="ERROR",type="com.sarbakan.sbdk.events.TransitionEvent")]
   [Event(name="RESUME",type="com.sarbakan.sbdk.events.TransitionEvent")]
   [Event(name="PAUSE",type="com.sarbakan.sbdk.events.TransitionEvent")]
   [Event(name="COMPLETE",type="com.sarbakan.sbdk.events.TransitionEvent")]
   [Event(name="STOP",type="com.sarbakan.sbdk.events.TransitionEvent")]
   [Event(name="START",type="com.sarbakan.sbdk.events.TransitionEvent")]
   public class AnimTransition extends AbstractTransition
   {
      
      private static const sENTER_FRAME:String = "ENTER_FRAME";
      
      private static const sASSET_EVENT:String = "ASSET_EVENT";
      
      private var oAssetRef:DisplayAsset;
      
      private var mcRef:MovieClip;
      
      private var oLocation:AssetReference;
      
      public function AnimTransition(_oLocation:AssetReference)
      {
         super();
         this.oLocation = _oLocation;
         init();
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.mcRef = null;
         if(this.oAssetRef != null)
         {
            this.oAssetRef.destroy();
         }
         this.oAssetRef = null;
      }
      
      public function display() : void
      {
         oAssetManager.requestAsset(this.oLocation,this.onAssetComplete,this.onAssetError);
      }
      
      override public function start(_mcRef:DisplayObject) : void
      {
         bIsPlaying = true;
         eventManager.addEventListener(sENTER_FRAME,this.oAssetRef.content,Event.ENTER_FRAME,this.onEnterFrame);
         dispatchEvent(new TransitionEvent(TransitionEvent.START,false,false,ID,this.mcRef));
      }
      
      override public function stop() : void
      {
         super.stop();
         this.end();
      }
      
      override public function pause() : void
      {
         super.pause();
         this.mcRef.stop();
      }
      
      override public function resume() : void
      {
         super.resume();
         this.mcRef.play();
      }
      
      private function end() : void
      {
         this.mcRef.stop();
         eventManager.cleanUp(sENTER_FRAME);
         bIsPlaying = false;
      }
      
      private function onEnterFrame(_oEvent:Event) : void
      {
         if(this.mcRef.currentFrame >= this.mcRef.totalFrames)
         {
            this.end();
            dispatchEvent(new TransitionEvent(TransitionEvent.COMPLETE,false,false,ID,mcContainer));
         }
      }
      
      private function onAssetComplete(_oAsset:DisplayAsset) : void
      {
         eventManager.cleanUp(sASSET_EVENT);
         this.oAssetRef = _oAsset;
         this.mcRef = MovieClip(this.oAssetRef.content);
         mcContainer.addChild(this.mcRef);
         this.start(this.oAssetRef.content);
      }
      
      private function onAssetError(_oError:AssetError) : void
      {
         dispatchEvent(new TransitionEvent(TransitionEvent.ERROR,false,false,_oError.ID,null,_oError.error));
      }
   }
}

