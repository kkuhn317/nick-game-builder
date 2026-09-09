package com.sarbakan.sbdk.preload
{
   import com.sarbakan.sbdk.events.PreloadEvent;
   
   public class SequencialLoader extends AbstractGroupLoader
   {
      
      private var oCurrentLoader:IPreloadable;
      
      public function SequencialLoader()
      {
         super();
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.oCurrentLoader = null;
      }
      
      override public function start() : void
      {
         if(!isLoading && aLoadingList.length > 0)
         {
            super.start();
            this.oCurrentLoader = aLoadingList.shift();
            startLoader(this.oCurrentLoader);
         }
      }
      
      override public function stop() : void
      {
         if(isLoading)
         {
            if(Boolean(this.oCurrentLoader))
            {
               oEventManager.cleanUp(this.oCurrentLoader.fileName);
               this.oCurrentLoader.stop();
            }
            this.oCurrentLoader = null;
         }
         super.stop();
      }
      
      override protected function init() : void
      {
         super.init();
      }
      
      override protected function onLoadComplete(_oEvent:PreloadEvent) : void
      {
         super.onLoadComplete(_oEvent);
         IPreloadable(_oEvent.target).destroy();
         this.oCurrentLoader = null;
         bLoading = false;
         if(!bStopped)
         {
            if(aLoadingList.length > 0)
            {
               this.start();
               ++nTotalNbrLoaded;
            }
            else
            {
               onGroupComplete();
            }
         }
      }
      
      override protected function onLoadError(_oEvent:PreloadEvent) : void
      {
         super.onLoadError(_oEvent);
         IPreloadable(_oEvent.target).destroy();
         this.oCurrentLoader = null;
         bLoading = false;
         if(!bStopped)
         {
            if(aLoadingList.length > 0)
            {
               this.start();
               ++nTotalNbrLoaded;
            }
            else
            {
               onGroupComplete();
            }
         }
      }
   }
}

