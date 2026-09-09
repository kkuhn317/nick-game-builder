package gamePlayer
{
   import com.sarbakan.sbdk.errors.ErrorMessages;
   import gamePlayer.ui.GamePlayerHUD;
   
   public class GameSession
   {
      
      private static var oInstance:GameSession;
      
      private static var bAllowConstruction:Boolean = false;
      
      private var uLives:uint;
      
      private var uCoinsCollected:uint;
      
      private var uCoinsLeft:uint;
      
      private var uCurrentScore:uint;
      
      private var uOpponentLeft:uint;
      
      private var uGoalLeft:uint;
      
      private var oHud:GamePlayerHUD;
      
      public function GameSession()
      {
         super();
         if(!bAllowConstruction)
         {
            throw new Error(ErrorMessages.sSINGLETON_ERROR);
         }
      }
      
      public static function get instance() : GameSession
      {
         if(oInstance == null)
         {
            bAllowConstruction = true;
            oInstance = new GameSession();
            bAllowConstruction = false;
         }
         return oInstance;
      }
      
      public function destroy() : void
      {
         oInstance = null;
         this.oHud = null;
      }
      
      public function reset() : void
      {
         this.uLives = GamePlayerConfig.uLIFES_START;
         this.uCoinsCollected = 0;
         this.uCoinsLeft = 0;
         this.uCurrentScore = 0;
         this.uOpponentLeft = 0;
         this.uGoalLeft = 0;
      }
      
      public function set hud(value:GamePlayerHUD) : void
      {
         this.oHud = value;
      }
      
      public function get lives() : uint
      {
         return this.uLives;
      }
      
      public function set lives(value:uint) : void
      {
         this.uLives = value;
         this.oHud.updateLife();
      }
      
      public function get score() : uint
      {
         return this.uCurrentScore;
      }
      
      public function set score(value:uint) : void
      {
         this.uCurrentScore = value;
         this.oHud.updateScore();
      }
      
      public function get goalLeft() : uint
      {
         return this.uGoalLeft;
      }
      
      public function set goalLeft(value:uint) : void
      {
         this.uGoalLeft = value;
         this.oHud.updateGoalsLeft();
      }
      
      public function get opponentLeft() : uint
      {
         return this.uOpponentLeft;
      }
      
      public function set opponentLeft(value:uint) : void
      {
         this.uOpponentLeft = value;
         this.oHud.updateOpponentsLeft();
      }
      
      public function get coinsLeft() : uint
      {
         return this.uCoinsLeft;
      }
      
      public function set coinsLeft(value:uint) : void
      {
         this.uCoinsLeft = value;
         this.oHud.updateCoinsLeft();
      }
      
      public function get coinsCollected() : uint
      {
         return this.uCoinsCollected;
      }
      
      public function set coinsCollected(value:uint) : void
      {
         this.uCoinsCollected = value;
         if(this.uCoinsCollected >= GamePlayerConfig.uCOINS_FOR_LIFE)
         {
            this.uCoinsCollected -= GamePlayerConfig.uCOINS_FOR_LIFE;
            this.lives += 1;
         }
         this.oHud.updateCoinsCollected();
      }
   }
}

