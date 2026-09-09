package media.type
{
   public class PlayableCharacterMedia extends AbstractMedia
   {
      
      public static const TYPE:String = "playableCharacter";
      
      public static const LINKAGE_IDLE:String = "mcCharacter_idle";
      
      public static const LINKAGE_START_RUN:String = "mcCharacter_startRun";
      
      public static const LINKAGE_RUN:String = "mcCharacter_run";
      
      public static const LINKAGE_RUN_ICE:String = "mcCharacter_runOnIce";
      
      public static const LINKAGE_JUMP_UP:String = "mcCharacter_jumpUp";
      
      public static const LINKAGE_JUMP_TOP:String = "mcCharacter_jumpTop";
      
      public static const LINKAGE_JUMP_DOWN:String = "mcCharacter_jumpDown";
      
      public static const LINKAGE_JUMP_END:String = "mcCharacter_jumpEnd";
      
      public static const LINKAGE_JUMP_STOMP:String = "mcCharacter_jumpStomp";
      
      public static const LINKAGE_JUMP_AIR:String = "mcCharacter_jumpInAir";
      
      public static const LINKAGE_CROUCH:String = "mcCharacter_crouch";
      
      public static const LINKAGE_SLIDE:String = "mcCharacter_slide";
      
      public static const LINKAGE_CLING:String = "mcCharacter_cling";
      
      public static const LINKAGE_HURT:String = "mcCharacter_hurt";
      
      public static const LINKAGE_INVINCIBILITY_OVERLAY:String = "mcCharacter_invincible";
      
      public static const LINKAGE_START_DIE:String = "mcCharacter_startDie";
      
      public static const LINKAGE_DIE:String = "mcCharacter_die";
      
      public static const LINKAGE_RESPAWN:String = "mcCharacter_respawn";
      
      public static const LINKAGE_TITLE_CHARACTER:String = "mcTitleCharacter";
      
      public static const LINKAGE_SELECTION_WHEEL:String = "mcSelectionWheelIcon";
      
      private static const GAME_LINKAGES:Array = [LINKAGE_CLING,LINKAGE_CROUCH,LINKAGE_DIE,LINKAGE_HURT,LINKAGE_IDLE,LINKAGE_INVINCIBILITY_OVERLAY,LINKAGE_JUMP_AIR,LINKAGE_JUMP_DOWN,LINKAGE_JUMP_END,LINKAGE_JUMP_STOMP,LINKAGE_JUMP_TOP,LINKAGE_JUMP_UP,LINKAGE_RESPAWN,LINKAGE_RUN,LINKAGE_RUN_ICE,LINKAGE_SLIDE,LINKAGE_START_DIE,LINKAGE_START_RUN,LINKAGE_TITLE_CHARACTER];
      
      private static const PREVIEW_LINKAGES:Array = [sDEFAULT_PREVIEW,LINKAGE_SELECTION_WHEEL];
      
      public function PlayableCharacterMedia(_sAlias:String, _sMediaDirectory:String)
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
      
      override public function get previewLinkages() : Array
      {
         return PREVIEW_LINKAGES;
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

