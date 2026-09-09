package sound
{
   import com.sarbakan.sbdk.asset.AssetReference;
   import com.sarbakan.sbdk.errors.ErrorMessages;
   import com.sarbakan.sbdk.events.PreloadEvent;
   import com.sarbakan.sbdk.events.SoundEvent;
   import com.sarbakan.sbdk.preload.FileLoader;
   import com.sarbakan.sbdk.sound.SoundManager;
   import com.sarbakan.sbdk.sound.SoundUnit;
   import com.sarbakan.sbdk.utils.EventManager;
   import com.sarbakan.sbdk.utils.ObjectList;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.system.ApplicationDomain;
   import media.type.MusicMedia;
   
   public class SfxManager extends EventDispatcher
   {
      
      private static var oInstance:SfxManager;
      
      private static const sEVENT_MANAGER_ID:String = "eventManager";
      
      private static var bAllowConstruction:Boolean = false;
      
      private var oEventManager:EventManager;
      
      private var oSoundListLoader:FileLoader;
      
      private var lSfxStruct:ObjectList;
      
      private var oCurrentMusic:SoundUnit;
      
      private var sCurrentMusicAlias:String;
      
      private var lFadingMusic:ObjectList;
      
      private var oApplicationDomain:ApplicationDomain;
      
      public function SfxManager()
      {
         super();
         if(!bAllowConstruction)
         {
            throw new Error(ErrorMessages.sSINGLETON_ERROR);
         }
         this.init();
      }
      
      public static function get instance() : SfxManager
      {
         if(oInstance == null)
         {
            bAllowConstruction = true;
            oInstance = new SfxManager();
            bAllowConstruction = false;
         }
         return oInstance;
      }
      
      public function destroy() : void
      {
         var _oSfx:SoundStruct = null;
         if(Boolean(this.oSoundListLoader))
         {
            this.oSoundListLoader.destroy();
         }
         this.oSoundListLoader = null;
         if(Boolean(this.lSfxStruct))
         {
            for each(_oSfx in this.lSfxStruct.object)
            {
               _oSfx.destroy();
            }
            this.lSfxStruct.destroy();
         }
         this.lSfxStruct = null;
         if(Boolean(this.lFadingMusic))
         {
            this.lFadingMusic.destroy();
         }
         this.lFadingMusic = null;
         this.oApplicationDomain = null;
         oInstance = null;
      }
      
      public function loadSoundConfig(_sFilename:String) : void
      {
         this.oSoundListLoader = new FileLoader(_sFilename);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oSoundListLoader,PreloadEvent.COMPLETE,this.onSoundConfigLoaded);
         this.oSoundListLoader.start();
      }
      
      public function playMusic(_oMedia:MusicMedia, _bPreview:Boolean = false) : void
      {
         var _oAsset:AssetReference = null;
         var _bChange:Boolean = true;
         if(Boolean(_oMedia))
         {
            if(this.sCurrentMusicAlias == _oMedia.alias)
            {
               _bChange = false;
            }
            else if(_bPreview && this.sCurrentMusicAlias == _oMedia.alias + "_preview")
            {
               _bChange = false;
            }
            if(_bPreview)
            {
               if(_oMedia.gameLoaded)
               {
                  _bPreview = false;
               }
            }
            else if(_oMedia.gameLoaded == false)
            {
               if(_oMedia.gameLoader.isLoading == false)
               {
                  this.oEventManager.addEventListener(sEVENT_MANAGER_ID,_oMedia.gameLoader,PreloadEvent.COMPLETE,this.onGameMusicLoaded,false,0,true,_oMedia);
                  this.oEventManager.addEventListener(sEVENT_MANAGER_ID,_oMedia.gameLoader,PreloadEvent.ERROR,this.onLoadError);
                  _oMedia.gameLoader.start();
               }
               _bPreview = true;
            }
            if(_bChange)
            {
               if(this.oCurrentMusic != null)
               {
                  this.lFadingMusic.insert(this.sCurrentMusicAlias,this.oCurrentMusic);
                  this.oEventManager.addEventListener(this.sCurrentMusicAlias,this.oCurrentMusic,SoundEvent.FADE_VOLUME_COMPLETED,this.onFadeOutComplete);
                  this.oCurrentMusic.fadeVolume(0,SoundConfig.nMUSIC_SWITCH_FADE_DURATION,true);
               }
               this.sCurrentMusicAlias = _oMedia.alias;
               if(_bPreview)
               {
                  this.sCurrentMusicAlias += "_preview";
               }
               if(Boolean(this.lFadingMusic.find(this.sCurrentMusicAlias)))
               {
                  this.oEventManager.cleanUp(this.sCurrentMusicAlias);
                  this.oCurrentMusic = this.lFadingMusic.find(this.sCurrentMusicAlias);
                  this.lFadingMusic.remove(this.sCurrentMusicAlias);
                  this.oCurrentMusic.fadeVolume(SoundConfig.nDEFAULT_VOLUME_MUSIC,SoundConfig.nMUSIC_SWITCH_FADE_DURATION);
               }
               else
               {
                  if(_bPreview)
                  {
                     _oAsset = AssetReference.fromLibraryClass(_oMedia.getClass(MusicMedia.PREVIEW_LINKAGE));
                  }
                  else
                  {
                     _oAsset = AssetReference.fromLibraryClass(_oMedia.getClass(MusicMedia.GAME_LINKAGE));
                  }
                  this.oCurrentMusic = SoundManager.instance.play(SoundConfig.sSOUND_CATEGORY_MUSIC,_oAsset,0,0,false,false);
                  this.oCurrentMusic.fadeVolume(SoundConfig.nDEFAULT_VOLUME_MUSIC,SoundConfig.nMUSIC_SWITCH_FADE_DURATION);
               }
            }
         }
      }
      
      public function getCurrentSound(_sID:String) : SoundUnit
      {
         var _oReturn:SoundUnit = null;
         var _oSfx:SoundStruct = this.lSfxStruct.find(_sID);
         if(Boolean(_oSfx))
         {
            _oReturn = _oSfx.oSound;
         }
         return _oReturn;
      }
      
      public function playSFX(_sID:String) : void
      {
         var _oAsset:AssetReference = null;
         var _oSfx:SoundStruct = this.lSfxStruct.find(_sID);
         if(Boolean(_oSfx))
         {
            if(Boolean(_oSfx.oSound))
            {
               _oSfx.oSound.position = 0;
               _oSfx.oSound.start();
            }
            else if(Boolean(this.oApplicationDomain))
            {
               _oAsset = AssetReference.fromLibraryClass(this.oApplicationDomain.getDefinition(_oSfx.classname) as Class);
               _oSfx.oSound = SoundManager.instance.play(SoundConfig.sSOUND_CATEGORY_SOUNDS,_oAsset,_oSfx.nVolume,_oSfx.nLoop,false,true);
            }
         }
      }
      
      public function stopSFX(_sID:String) : void
      {
         var _oSfx:SoundStruct = this.lSfxStruct.find(_sID);
         if(Boolean(_oSfx))
         {
            if(Boolean(_oSfx.oSound))
            {
               _oSfx.oSound.stop();
               _oSfx.oSound = null;
            }
         }
      }
      
      public function stopAllSFX() : void
      {
         var _oSFX:SoundStruct = null;
         for each(_oSFX in this.lSfxStruct.object)
         {
            if(Boolean(_oSFX.oSound))
            {
               _oSFX.oSound.destroy();
            }
            _oSFX.oSound = null;
         }
      }
      
      private function init() : void
      {
         this.oEventManager = new EventManager();
         this.lSfxStruct = new ObjectList();
         this.lFadingMusic = new ObjectList();
      }
      
      private function onSoundConfigLoaded(_e:PreloadEvent) : void
      {
         var _oSound:XML = null;
         this.oEventManager.removeEventListener(sEVENT_MANAGER_ID,_e.target as IEventDispatcher,_e.type,this.onSoundConfigLoaded);
         var _oXML:XML = new XML(_e.content);
         var _oSounds:XMLList = _oXML..sound;
         for each(_oSound in _oSounds)
         {
            this.lSfxStruct.insert(_oSound.@id,new SoundStruct(_oSound.@classname,_oSound.@volume,_oSound.@loop));
         }
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      private function onFadeOutComplete(_e:SoundEvent) : void
      {
         var _sID:String = this.lFadingMusic.findKey(_e.target);
         if(Boolean(_sID))
         {
            this.oEventManager.cleanUp(_sID);
            this.lFadingMusic.remove(_sID);
         }
         SoundUnit(_e.target).destroy();
      }
      
      private function onGameMusicLoaded(_e:PreloadEvent, _oMedia:MusicMedia) : void
      {
         this.oEventManager.removeEventListener(sEVENT_MANAGER_ID,_e.target as IEventDispatcher,_e.type,this.onGameMusicLoaded);
         if(this.sCurrentMusicAlias == _oMedia.alias + "_preview")
         {
            this.playMusic(_oMedia);
         }
      }
      
      private function onLoadError(_e:PreloadEvent) : void
      {
         dispatchEvent(_e);
      }
      
      public function set soundDomain(_oValue:ApplicationDomain) : void
      {
         this.oApplicationDomain = _oValue;
      }
   }
}

import com.sarbakan.sbdk.math.random.Random;
import com.sarbakan.sbdk.sound.SoundUnit;

class SoundStruct
{
   
   public var oSound:SoundUnit;
   
   public var nVolume:Number;
   
   public var nLoop:int;
   
   private var aClassNames:Array;
   
   public function SoundStruct(_sClass:String, _nVolume:Number, _nLoop:int)
   {
      super();
      this.aClassNames = _sClass.split(",");
      this.nVolume = _nVolume;
      this.nLoop = _nLoop;
   }
   
   public function destroy() : void
   {
      if(Boolean(this.oSound))
      {
         this.oSound.destroy();
      }
      this.oSound = null;
   }
   
   public function get classname() : String
   {
      return Random.getArrayElement(this.aClassNames) as String;
   }
}
