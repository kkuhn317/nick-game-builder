package ui.screens
{
   import com.sarbakan.sbdk.asset.AssetReference;
   import com.sarbakan.sbdk.view.AbstractView;
   
   public class AbstractBuilderStepScreen extends AbstractView
   {
      
      protected static const sEVENT_MANAGER_ID:String = "eventManager";
      
      public function AbstractBuilderStepScreen(_oAssetLocation:AssetReference)
      {
         super(_oAssetLocation);
      }
      
      override public function destroy() : void
      {
         eventManager.cleanUp(sEVENT_MANAGER_ID);
         super.destroy();
      }
   }
}

