package builderManager.elements
{
   import media.type.AbstractMedia;
   
   public class GoalElement extends BuilderElement
   {
      
      public function GoalElement(_nX:Number, _nY:Number, _oMedia:AbstractMedia, _bFlip:Boolean)
      {
         super(_nX,_nY,_oMedia,_bFlip);
      }
      
      override public function destroy() : void
      {
         super.destroy();
      }
      
      override public function get isUnique() : Boolean
      {
         return BuilderMain.instance.gameData.multigoalEnabled ? false : true;
      }
   }
}

