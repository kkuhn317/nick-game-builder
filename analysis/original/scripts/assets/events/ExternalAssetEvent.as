package assets.events
{
   import flash.events.Event;
   
   public class ExternalAssetEvent extends Event
   {
      
      public static const COMPLETE:String = "sbdk_complete";
      
      public static const PROGRESS:String = "sbdk_progress";
      
      private var sCategory:String;
      
      private var nPercentage:uint;
      
      public function ExternalAssetEvent(_sType:String, _sCategory:String = null, _nPercentage:uint = 0)
      {
         super(_sType,false,false);
         this.sCategory = _sCategory;
         this.nPercentage = _nPercentage;
      }
      
      override public function clone() : Event
      {
         return new ExternalAssetEvent(type,this.sCategory,this.nPercentage);
      }
      
      override public function toString() : String
      {
         return formatToString("ExternalMediaEvent","type","bubbles","cancelable","group");
      }
      
      public function get category() : String
      {
         return this.sCategory;
      }
      
      public function get percentage() : uint
      {
         return this.nPercentage;
      }
   }
}

