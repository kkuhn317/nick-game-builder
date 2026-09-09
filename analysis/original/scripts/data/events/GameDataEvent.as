package data.events
{
   import data.GameData;
   import flash.events.Event;
   
   public class GameDataEvent extends Event
   {
      
      public static const COMPLETE:String = "gamePlayer_requestMenu";
      
      public static const ERROR:String = "gamePlayer_requestGameHelp";
      
      private var oGameData:GameData;
      
      private var sError:String;
      
      public function GameDataEvent(_sType:String, _oGameData:GameData = null, _sError:String = null, _bBubbles:Boolean = false, _bCancelable:Boolean = false)
      {
         super(_sType,_bBubbles,_bCancelable);
         this.oGameData = _oGameData;
         this.sError = _sError;
      }
      
      public function get gameData() : GameData
      {
         return this.oGameData;
      }
      
      public function get errorMessage() : String
      {
         return this.sError;
      }
   }
}

