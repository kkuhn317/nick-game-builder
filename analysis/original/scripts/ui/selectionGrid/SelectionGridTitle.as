package ui.selectionGrid
{
   import com.sarbakan.sbdk.localization.LocalizationManager;
   import flash.display.MovieClip;
   
   public class SelectionGridTitle
   {
      
      private var mcContainer:MovieClip;
      
      public function SelectionGridTitle(_sLocale:String)
      {
         super();
         this.mcContainer = new mcSelectionGridTitle();
         if(Boolean(_sLocale))
         {
            LocalizationManager.instance.setTextField(this.mcContainer.mcTitle.txtText,_sLocale);
         }
         else
         {
            this.mcContainer.mcTitle.txtText.text = "";
         }
      }
      
      public function setBkgHeight(_nHeight:Number) : void
      {
         this.mcContainer.mcBkg.height = _nHeight - this.mcContainer.mcBkg.y;
      }
      
      public function get mc() : MovieClip
      {
         return this.mcContainer;
      }
      
      public function get height() : Number
      {
         return -this.mcContainer.mcTitle.y;
      }
   }
}

