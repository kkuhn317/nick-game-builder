package media.type
{
   public class GoalMedia extends AbstractMedia
   {
      
      public static const TYPE:String = "goal";
      
      public static const LINKAGE_IDLE:String = "mcGoal_idle";
      
      public static const LINKAGE_COLLECT:String = "mcGoal_collect";
      
      public static const LINKAGE_COLLECTED:String = "mcGoal_collected";
      
      private static const GAME_LINKAGES:Array = [LINKAGE_IDLE,LINKAGE_COLLECT,LINKAGE_COLLECTED];
      
      public function GoalMedia(_sAlias:String, _sMediaDirectory:String)
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

