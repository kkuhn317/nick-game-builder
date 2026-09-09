package media.type
{
   public class OpponentWalkerMedia extends AbstractMedia
   {
      
      public static const TYPE:String = "opponentWalker";
      
      public static const LINKAGE_WALK:String = "mcWalker_walk";
      
      public static const LINKAGE_SLIDE:String = "mcWalker_slide";
      
      public static const LINKAGE_FALL:String = "mcWalker_fall";
      
      public static const LINKAGE_LAND:String = "mcWalker_land";
      
      public static const LINKAGE_HURT:String = "mcWalker_hurt";
      
      public static const LINKAGE_DIE:String = "mcWalker_die";
      
      private static const GAME_LINKAGES:Array = [LINKAGE_DIE,LINKAGE_FALL,LINKAGE_HURT,LINKAGE_LAND,LINKAGE_SLIDE,LINKAGE_WALK];
      
      public function OpponentWalkerMedia(_sAlias:String, _sMediaDirectory:String)
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

