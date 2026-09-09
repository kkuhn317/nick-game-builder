package data
{
   import flash.geom.Rectangle;
   import flash.utils.ByteArray;
   import utils.Base64;
   
   public class GameData
   {
      
      private var oBounds:Rectangle;
      
      private var sBuilderType:String;
      
      private var sProperty:String;
      
      private var sBackground:String;
      
      private var sHero:String;
      
      private var sGoal:String;
      
      private var sSFX:String;
      
      private var sTitle:String;
      
      private var sMusic:String;
      
      private var sTemplate:String;
      
      private var aElements:Array;
      
      private var aUsedMediaAlias:Array;
      
      public function GameData(_sGameData:String = null)
      {
         super();
         this.aElements = new Array();
         if(Boolean(_sGameData))
         {
            this.xmlIn(this.decode(_sGameData));
         }
      }
      
      public function destroy() : void
      {
         this.clearElements();
         this.aUsedMediaAlias = null;
      }
      
      public function xmlIn(_sGameData:String) : void
      {
         var _oElement:XML = null;
         var _oXML:XML = new XML(_sGameData);
         var _sVersion:String = _oXML.header.version;
         this.sBuilderType = _oXML.header.builderType.@alias;
         this.sProperty = _oXML.header.ip.@alias;
         this.sBackground = _oXML.header.background.@alias;
         this.sMusic = _oXML.header.music.@alias;
         this.sSFX = _oXML.header.sfx.@alias;
         this.sTitle = _oXML.header.title.text;
         this.sTemplate = _oXML.header.template.@alias;
         if(_oXML.header.goal.@type != "")
         {
            this.sGoal = _oXML.header.goal.@type;
         }
         if(_sVersion == "6")
         {
            this.sHero = _oXML.header.hero.@alias;
         }
         this.oBounds = new Rectangle();
         this.oBounds.left = int(_oXML.header.bounds.@left);
         this.oBounds.right = int(_oXML.header.bounds.@right);
         this.oBounds.top = int(_oXML.header.bounds.@top);
         this.oBounds.bottom = int(_oXML.header.bounds.@bottom);
         var _oElements:XMLList = _oXML..elements[0].children();
         for each(_oElement in _oElements)
         {
            this.aElements.push(GameDataElement.fromXML(_oElement));
            if(_sVersion == "5" && _oElement.name() == "playableCharacter")
            {
               this.sHero = _oElement.@alias;
            }
         }
         this.listUsedMedia();
      }
      
      public function xmlOut() : String
      {
         var _oGameElement:GameDataElement = null;
         var _oBounds:Rectangle = this.bounds;
         var _oXML:XML = <game>
								<header>
									<version>6</version>
									<builderType alias={this.sBuilderType}/>
									<background alias={this.sBackground}/>
									<ip alias={this.sProperty}/>
									<music alias={this.sMusic}/>
									<sfx alias={this.sSFX}/>
									<bounds left={_oBounds.left} top={_oBounds.top} right={_oBounds.right} bottom={_oBounds.bottom}/>
									<goal type={this.sGoal}/>
									<hero alias={this.sHero}/>
									<template alias={this.sTemplate}/>
									<title color="0x00ffdd55">
										<text>{this.sTitle}</text>
									</title>
								</header>
								<elements/>
							</game>;
         var _oElementsNode:XML = _oXML..elements[0];
         for each(_oGameElement in this.aElements)
         {
            _oElementsNode.appendChild(_oGameElement.xmlOut());
         }
         return _oXML.toString();
      }
      
      private function decode(_sRawGameData:String) : String
      {
         var _sReturn:String = null;
         var _oGameDataBytes:ByteArray = null;
         if(_sRawGameData.indexOf("<") != -1)
         {
            _sReturn = _sRawGameData;
         }
         else
         {
            _oGameDataBytes = Base64.decodeToByteArray(_sRawGameData);
            _oGameDataBytes.uncompress();
            _sReturn = _oGameDataBytes.toString();
         }
         return _sReturn;
      }
      
      private function listUsedMedia() : void
      {
         var _oElem:GameDataElement = null;
         this.aUsedMediaAlias = new Array();
         for each(_oElem in this.aElements)
         {
            if(this.aUsedMediaAlias.indexOf(_oElem.alias) == -1)
            {
               this.aUsedMediaAlias.push(_oElem.alias);
            }
         }
         this.aUsedMediaAlias.push(this.sBackground);
         this.aUsedMediaAlias.push(this.sMusic);
         this.aUsedMediaAlias.push(this.sSFX);
      }
      
      private function clearElements() : void
      {
         if(Boolean(this.aElements))
         {
            while(this.aElements.length > 0)
            {
               GameDataElement(this.aElements.pop()).destroy();
            }
         }
         this.aElements = null;
      }
      
      public function get levelElements() : Array
      {
         return this.aElements;
      }
      
      public function set levelElements(_aValue:Array) : void
      {
         this.clearElements();
         this.aElements = _aValue;
         this.listUsedMedia();
      }
      
      public function get bounds() : Rectangle
      {
         return this.oBounds;
      }
      
      public function set bounds(_oValue:Rectangle) : void
      {
         this.oBounds = _oValue;
      }
      
      public function get usedMediaAlias() : Array
      {
         return this.aUsedMediaAlias;
      }
      
      public function get builderAlias() : String
      {
         return this.sBuilderType;
      }
      
      public function set builderAlias(value:String) : void
      {
         this.sBuilderType = value;
      }
      
      public function get multigoalEnabled() : Boolean
      {
         return Boolean(this.propertyAlias == "gs_luckycharm");
      }
      
      public function get propertyAlias() : String
      {
         return this.sProperty;
      }
      
      public function set propertyAlias(value:String) : void
      {
         this.sProperty = value;
      }
      
      public function get backgroundAlias() : String
      {
         return this.sBackground;
      }
      
      public function set backgroundAlias(value:String) : void
      {
         this.sBackground = value;
      }
      
      public function get heroAlias() : String
      {
         return this.sHero;
      }
      
      public function set heroAlias(value:String) : void
      {
         this.sHero = value;
      }
      
      public function get goal() : String
      {
         return this.sGoal;
      }
      
      public function set goal(value:String) : void
      {
         this.sGoal = value;
      }
      
      public function get musicAlias() : String
      {
         return this.sMusic;
      }
      
      public function set musicAlias(value:String) : void
      {
         this.sMusic = value;
      }
      
      public function get sfxAlias() : String
      {
         return this.sSFX;
      }
      
      public function set sfxAlias(value:String) : void
      {
         if(value != null && value != "null")
         {
            this.sSFX = value;
            if(this.aUsedMediaAlias != null && this.aUsedMediaAlias.indexOf(this.sSFX) == -1)
            {
               this.aUsedMediaAlias.push(this.sSFX);
            }
         }
      }
      
      public function get title() : String
      {
         return this.sTitle;
      }
      
      public function set title(value:String) : void
      {
         this.sTitle = value;
      }
      
      public function get template() : String
      {
         return this.sTemplate;
      }
      
      public function set template(value:String) : void
      {
         this.sTemplate = value;
      }
   }
}

