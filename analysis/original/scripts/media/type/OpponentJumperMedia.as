package media.type
{
   public class OpponentJumperMedia extends AbstractMedia
   {
      
      public static const TYPE:String = "opponentJumper";
      
      public static const LINKAGE_JUMP_UP:String = "mcJumper_jumpUp";
      
      public static const LINKAGE_JUMP_TOP:String = "mcJumper_jumpTop";
      
      public static const LINKAGE_JUMP_END:String = "mcJumper_jumpEnd";
      
      public static const LINKAGE_JUMP_DOWN:String = "mcJumper_jumpDown";
      
      public static const LINKAGE_HURT:String = "mcJumper_hurt";
      
      public static const LINKAGE_DIE:String = "mcJumper_die";
      
      private static const GAME_LINKAGES:Array = [LINKAGE_DIE,LINKAGE_HURT,LINKAGE_JUMP_DOWN,LINKAGE_JUMP_END,LINKAGE_JUMP_TOP,LINKAGE_JUMP_UP];
      
      public function OpponentJumperMedia(_sAlias:String, _sMediaDirectory:String)
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

