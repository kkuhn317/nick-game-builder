package media.type
{
   public class BonusInvincibilityMedia extends AbstractMedia
   {
      
      public static const TYPE:String = "bonusInvincibility";
      
      public static const LINKAGE_IDLE:String = "mcBonus_idle";
      
      public static const LINKAGE_COLLECTED:String = "mcBonus_collected";
      
      private static const GAME_LINKAGES:Array = [LINKAGE_IDLE,LINKAGE_COLLECTED];
      
      public function BonusInvincibilityMedia(_sAlias:String, _sMediaDirectory:String)
      {
         super(_sAlias,_sMediaDirectory);
      }
      
      override public function destroy() : void
      {
         super.destroy();
      }
      
      override public function get type() : String
      {
         return TYPE;
      }
      
      override public function get gameLinkages() : Array
      {
         return GAME_LINKAGES;
      }
      
      override public function get checkForCollider() : Boolean
      {
         return true;
      }
   }
}

