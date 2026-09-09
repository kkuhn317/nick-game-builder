package com.sarbakan.sbdk.preload
{
   import com.sarbakan.sbdk.events.PreloadEvent;
   
   public class ParallelLoader extends AbstractGroupLoader
   {
      
      private var nMaxParallelLoading:uint;
      
      private var aCurrentLoaders:Array;
      
      public function ParallelLoader(_nMaxParallelLoading:uint = 0)
      {
         super();
         this.nMaxParallelLoading = _nMaxParallelLoading;
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.aCurrentLoaders = null;
      }
      
      override public function start() : void
      {
         var _oCurrentLoader:IPreloadable = null;
         if(!isLoading && aLoadingList.length > 0)
         {
            super.start();
            while(aLoadingList.length > 0 && (this.nMaxParallelLoading == 0 || this.aCurrentLoaders.length < this.nMaxParallelLoading))
            {
               _oCurrentLoader = aLoadingList.shift() as IPreloadable;
               this.aCurrentLoaders.push(_oCurrentLoader);
               startLoader(_oCurrentLoader);
            }
         }
      }
      
      override public function stop() : void
      {
         if(isLoading)
         {
         }
         super.stop();
      }
      
      override protected function init() : void
      {
         super.init();
         this.aCurrentLoaders = new Array();
      }
      
      override protected function onLoadComplete(_oEvent:PreloadEvent) : void
      {
         super.onLoadComplete(_oEvent);
         this.aCurrentLoaders.splice(this.aCurrentLoaders.indexOf(_oEvent.target),1);
         IPreloadable(_oEvent.target).destroy();
         if(!bStopped)
         {
            if(this.aCurrentLoaders.length == 0)
            {
               bLoading = false;
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
      
      override protected function onLoadError(_oEvent:PreloadEvent) : void
      {
         super.onLoadError(_oEvent);
         this.aCurrentLoaders.splice(this.aCurrentLoaders.indexOf(_oEvent.target),1);
         IPreloadable(_oEvent.target).destroy();
         if(!bStopped)
         {
            if(this.aCurrentLoaders.length == 0)
            {
               bLoading = false;
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
}

