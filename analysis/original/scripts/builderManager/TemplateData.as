package builderManager
{
   import data.GameData;
   import data.GameDataElement;
   import flash.geom.Point;
   import media.MediaList;
   import media.type.AbstractMedia;
   import media.type.BonusCoinMedia;
   import media.type.GoalMedia;
   import media.type.OpponentJumperMedia;
   import media.type.OpponentShooterMedia;
   import media.type.OpponentWalkerMedia;
   import media.type.PlayableCharacterMedia;
   
   public class TemplateData
   {
      
      private var oPlayerPos:Point;
      
      private var oGoalPos:Point;
      
      private var aCoins:Array;
      
      private var aOpponents:Array;
      
      public function TemplateData(_oGameData:GameData, _oMediaList:MediaList)
      {
         var _oElement:GameDataElement = null;
         var _oMedia:AbstractMedia = null;
         super();
         this.aCoins = new Array();
         this.aOpponents = new Array();
         for each(_oElement in _oGameData.levelElements)
         {
            _oMedia = _oMediaList.getMedia(_oElement.alias);
            if(Boolean(_oMedia))
            {
               if(_oMedia.type == PlayableCharacterMedia.TYPE)
               {
                  this.setPlayerPos(_oElement,_oMedia as PlayableCharacterMedia);
               }
               else if(_oMedia.type == GoalMedia.TYPE)
               {
                  this.setGoalPos(_oElement,_oMedia as GoalMedia);
               }
               else if(_oMedia.type == BonusCoinMedia.TYPE)
               {
                  this.aCoins.push(_oElement);
               }
               else if(_oMedia.type == OpponentJumperMedia.TYPE || _oMedia.type == OpponentShooterMedia.TYPE || _oMedia.type == OpponentWalkerMedia.TYPE)
               {
                  this.aOpponents.push(_oElement);
               }
            }
         }
      }
      
      public function getPlayerPos(_oMedia:PlayableCharacterMedia) : Point
      {
         var _oReturn:Point = this.oPlayerPos.clone();
         if(Boolean(_oMedia))
         {
            _oReturn.y -= _oMedia.drawBounds.nYMax;
         }
         return _oReturn;
      }
      
      public function getGoalPos(_oMedia:GoalMedia) : Point
      {
         var _oReturn:Point = this.oGoalPos.clone();
         if(Boolean(_oMedia))
         {
            _oReturn.y -= _oMedia.drawBounds.nYMax;
         }
         return _oReturn;
      }
      
      private function setPlayerPos(_oElement:GameDataElement, _oMedia:PlayableCharacterMedia) : void
      {
         this.oPlayerPos = new Point(_oElement.x,_oElement.y + _oMedia.drawBounds.nYMax);
      }
      
      private function setGoalPos(_oElement:GameDataElement, _oMedia:GoalMedia) : void
      {
         this.oGoalPos = new Point(_oElement.x,_oElement.y + _oMedia.drawBounds.nYMax);
      }
      
      public function get coins() : Array
      {
         return this.aCoins;
      }
      
      public function get opponents() : Array
      {
         return this.aOpponents;
      }
   }
}

