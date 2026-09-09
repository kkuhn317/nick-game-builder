package gamePlayer.events
{
   import flash.events.Event;
   
   public class GamePlayerEvent extends Event
   {
      
      public static const REQUEST_GOAL_DISPLAY:String = "gamePlayer_requestGoalDisplay";
      
      public static const REQUEST_MENU:String = "gamePlayer_requestMenu";
      
      public static const REQUEST_GAME_RESTART:String = "gamePlayer_requestGameRestart";
      
      public static const REQUEST_GAME_HELP:String = "gamePlayer_requestGameHelp";
      
      public static const REQUEST_GAME_QUIT:String = "gamePlayer_requestQuit";
      
      public static const CANCEL_GAME_QUIT:String = "gamePlayer_cancelQuit";
      
      public static const GAME_WIN:String = "gamePlayer_win";
      
      public static const GAME_LOSE:String = "gamePlayer_lose";
      
      public static const COLLECT_GOAL:String = "gamePlayer_collectGoal";
      
      public static const COLLECT_COIN:String = "gamePlayer_collectCoin";
      
      public static const KILL_OPPONENT:String = "gamePlayer_killOpponent";
      
      public function GamePlayerEvent(_sType:String, _bBubbles:Boolean = false, _bCancelable:Boolean = false)
      {
         super(_sType,_bBubbles,_bCancelable);
      }
   }
}

