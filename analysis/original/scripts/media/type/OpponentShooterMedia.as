package media.type
{
   public class OpponentShooterMedia extends AbstractMedia
   {
      
      public static const TYPE:String = "opponentShooter";
      
      public static const LINKAGE_IDLE:String = "mcShooter_idle";
      
      public static const LINKAGE_START_SHOOT:String = "mcShooter_startShoot";
      
      public static const LINKAGE_END_SHOOT:String = "mcShooter_endShoot";
      
      public static const LINKAGE_HURT:String = "mcShooter_hurt";
      
      public static const LINKAGE_DIE:String = "mcShooter_die";
      
      public static const LINKAGE_PROJECTILE_MOVE:String = "mcProjectile_move";
      
      public static const LINKAGE_PROJECTILE_HIT:String = "mcProjectile_hit";
      
      private static const GAME_LINKAGES:Array = [LINKAGE_DIE,LINKAGE_END_SHOOT,LINKAGE_HURT,LINKAGE_IDLE,LINKAGE_START_SHOOT,LINKAGE_PROJECTILE_MOVE,LINKAGE_PROJECTILE_HIT];
      
      public function OpponentShooterMedia(_sAlias:String, _sMediaDirectory:String)
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
      
      override public function get flipable() : Boolean
      {
         return true;
      }
   }
}

