package media
{
   import com.sarbakan.sbdk.utils.ExternalConfig;
   import com.sarbakan.sbdk.utils.ObjectList;
   import media.type.AbstractMedia;
   import media.type.BackgroundMedia;
   import media.type.BonusCoinMedia;
   import media.type.BonusExtraLifeMedia;
   import media.type.BonusInvincibilityMedia;
   import media.type.GoalMedia;
   import media.type.MusicMedia;
   import media.type.OpponentJumperMedia;
   import media.type.OpponentShooterMedia;
   import media.type.OpponentWalkerMedia;
   import media.type.PlatformObjectMedia;
   import media.type.PlayableCharacterMedia;
   import media.type.PropsMedia;
   import media.type.SfxMedia;
   import media.type.TileFatalMedia;
   import media.type.TilePlatformMedia;
   import media.type.TileSlipperyMedia;
   import media.type.TileSurfaceMedia;
   
   public class MediaList
   {
      
      private var sBuilderAlias:String;
      
      private var sPropertyAlias:String;
      
      private var lMedias:ObjectList;
      
      public function MediaList(_sBuilderAlias:String, _sPropertyAlias:String, _sXML:String)
      {
         super();
         this.sBuilderAlias = _sBuilderAlias;
         this.sPropertyAlias = _sPropertyAlias;
         this.lMedias = new ObjectList();
         this.parseMedias(new XML(_sXML));
      }
      
      public function destroy() : void
      {
         var _oMedia:AbstractMedia = null;
         if(Boolean(this.lMedias))
         {
            for each(_oMedia in this.lMedias.object)
            {
               _oMedia.destroy();
            }
            this.lMedias.destroy();
         }
         this.lMedias = null;
      }
      
      public function getMedia(_sAlias:String) : AbstractMedia
      {
         return this.lMedias.find(_sAlias);
      }
      
      public function getMediaFromType(_aTypes:Array) : Array
      {
         var _oMedia:AbstractMedia = null;
         var _aReturn:Array = new Array();
         for each(_oMedia in this.lMedias.object)
         {
            if(_aTypes.indexOf(_oMedia.type) != -1)
            {
               _aReturn.push(_oMedia);
            }
         }
         _aReturn.sortOn("type");
         return _aReturn;
      }
      
      public function listMediasFromAlias(_aAlias:Array) : Array
      {
         var _sAlias:String = null;
         var _oMedia:AbstractMedia = null;
         var _aReturn:Array = new Array();
         for each(_sAlias in _aAlias)
         {
            _oMedia = this.getMedia(_sAlias);
            if(Boolean(_oMedia))
            {
               _aReturn.push(_oMedia);
            }
         }
         return _aReturn;
      }
      
      public function hasMedia(_oTest:AbstractMedia) : Boolean
      {
         var _oMedia:AbstractMedia = this.lMedias.find(_oTest.alias);
         return Boolean(_oMedia != null && _oMedia == _oTest);
      }
      
      public function removeMedia(_oMedia:AbstractMedia) : void
      {
         if(this.lMedias.find(_oMedia.alias) == _oMedia)
         {
            this.lMedias.remove(_oMedia.alias);
         }
      }
      
      private function parseMedias(_oXML:XML) : void
      {
         var _oCategory:XML = null;
         var _sCatName:String = null;
         var _lMedias:XMLList = null;
         var _oMedia:XML = null;
         var _lCategories:XMLList = _oXML..element;
         for each(_oCategory in _lCategories)
         {
            _sCatName = _oCategory.@name;
            _lMedias = _oCategory..media;
            for each(_oMedia in _lMedias)
            {
               this.addMedia(_sCatName,_oMedia);
            }
         }
      }
      
      private function addMedia(_sCatName:String, _oConfig:XML) : void
      {
         var _cMediaClass:Class = null;
         var _sMediaDirectory:String = null;
         var _oMedia:AbstractMedia = null;
         switch(_sCatName)
         {
            case BackgroundMedia.TYPE:
               _cMediaClass = BackgroundMedia;
               break;
            case BonusCoinMedia.TYPE:
               _cMediaClass = BonusCoinMedia;
               break;
            case BonusExtraLifeMedia.TYPE:
               _cMediaClass = BonusExtraLifeMedia;
               break;
            case BonusInvincibilityMedia.TYPE:
               _cMediaClass = BonusInvincibilityMedia;
               break;
            case GoalMedia.TYPE:
               _cMediaClass = GoalMedia;
               break;
            case MusicMedia.TYPE:
               _cMediaClass = MusicMedia;
               break;
            case OpponentJumperMedia.TYPE:
               _cMediaClass = OpponentJumperMedia;
               break;
            case OpponentShooterMedia.TYPE:
               _cMediaClass = OpponentShooterMedia;
               break;
            case OpponentWalkerMedia.TYPE:
               _cMediaClass = OpponentWalkerMedia;
               break;
            case PlatformObjectMedia.TYPE:
               _cMediaClass = PlatformObjectMedia;
               break;
            case PlayableCharacterMedia.TYPE:
               _cMediaClass = PlayableCharacterMedia;
               break;
            case PropsMedia.TYPE:
               _cMediaClass = PropsMedia;
               break;
            case SfxMedia.TYPE:
               _cMediaClass = SfxMedia;
               break;
            case TileFatalMedia.TYPE:
               _cMediaClass = TileFatalMedia;
               break;
            case TilePlatformMedia.TYPE:
               _cMediaClass = TilePlatformMedia;
               break;
            case TileSlipperyMedia.TYPE:
               _cMediaClass = TileSlipperyMedia;
               break;
            case TileSurfaceMedia.TYPE:
               _cMediaClass = TileSurfaceMedia;
               break;
            case "checkpoint":
            case "musicPreview":
            case "titleCharacter":
            case "titleBackground":
         }
         if(Boolean(_cMediaClass))
         {
            _sMediaDirectory = ExternalConfig.instance.getProperty(CommonConfig.sCONFIG_MEDIA_PATH) + "/" + this.sBuilderAlias + "/" + this.sPropertyAlias + "/" + _sCatName;
            _oMedia = new _cMediaClass(_oConfig.@alias,_sMediaDirectory) as AbstractMedia;
            this.lMedias.insert(_oConfig.@alias,_oMedia);
         }
      }
      
      public function get medias() : Array
      {
         var _oMedia:AbstractMedia = null;
         var _aReturn:Array = new Array();
         for each(_oMedia in this.lMedias.object)
         {
            _aReturn.push(_oMedia);
         }
         return _aReturn;
      }
   }
}

