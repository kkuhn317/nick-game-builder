package com.sarbakan.sbdk.sound
{
   import com.sarbakan.sbdk.asset.AssetManager;
   import com.sarbakan.sbdk.asset.AssetReference;
   import com.sarbakan.sbdk.asset.SoundAsset;
   import com.sarbakan.sbdk.core.UpdateManager;
   import com.sarbakan.sbdk.errors.AssetError;
   import com.sarbakan.sbdk.errors.ErrorMessages;
   import com.sarbakan.sbdk.events.SoundEvent;
   import com.sarbakan.sbdk.events.UpdateEvent;
   import com.sarbakan.sbdk.tools.logger.Logger;
   import com.sarbakan.sbdk.utils.CallBackArguments;
   import com.sarbakan.sbdk.utils.EventManager;
   import com.sarbakan.sbdk.utils.ObjectList;
   import flash.events.EventDispatcher;
   import flash.media.Sound;
   
   [Event(name="ALL_SOUND_CHANNELS_USED",type="com.sarbakan.sbdk.events.SoundEvent")]
   [Event(name="PAN_VOLUME_COMPLETED",type="com.sarbakan.sbdk.events.SoundEvent")]
   [Event(name="FADE_VOLUME_COMPLETED",type="com.sarbakan.sbdk.events.SoundEvent")]
   [Event(name="COMPLETED",type="com.sarbakan.sbdk.events.SoundEvent")]
   [Event(name="READY",type="com.sarbakan.sbdk.events.SoundEvent")]
   public class SoundManager extends EventDispatcher
   {
      
      private static var oInstance:SoundManager;
      
      private static const sEVENT_MANAGER_ID:String = "soundManager";
      
      private static var bAllowConstruction:Boolean = false;
      
      private var oAssetManager:AssetManager;
      
      private var oEventManager:EventManager;
      
      private var lCategory:ObjectList;
      
      private var lAutoBalanceAsset:ObjectList;
      
      private var bMuted:Boolean;
      
      private var bPaused:Boolean;
      
      private var oTargetActiveSound:SoundAsset;
      
      public function SoundManager()
      {
         super();
         if(!bAllowConstruction)
         {
            throw new Error(ErrorMessages.sSINGLETON);
         }
         this.init();
      }
      
      public static function get instance() : SoundManager
      {
         if(oInstance == null)
         {
            bAllowConstruction = true;
            oInstance = new SoundManager();
            bAllowConstruction = false;
         }
         return oInstance;
      }
      
      public function destroy() : void
      {
         this.stop();
         this.oEventManager.destroy();
         this.oEventManager = null;
         this.oAssetManager = null;
         oInstance = null;
         this.lCategory.clear();
         this.lCategory = null;
         this.lAutoBalanceAsset.clear();
         this.lAutoBalanceAsset = null;
      }
      
      public function addCategory(_sCategoryID:String, _nRelativeVolume:Number = 1) : void
      {
         var _oCategoryData:CategoryStruct = this.lCategory.find(_sCategoryID) as CategoryStruct;
         if(_oCategoryData == null)
         {
            this.lCategory.insert(_sCategoryID,new CategoryStruct());
         }
         if(_nRelativeVolume >= 0 && _nRelativeVolume <= 1)
         {
            this.setRelativeVolume(_sCategoryID,_nRelativeVolume);
         }
         else
         {
            Logger.instance.logWarning("Relative Volume = " + _nRelativeVolume + " not valid. It must be a value between 0 & 1.");
         }
      }
      
      public function removeCategory(_sCategoryID:String) : void
      {
         var _oCategoryData:CategoryStruct = this.getCategoryData(_sCategoryID);
         if(_oCategoryData != null)
         {
            this.stop(_sCategoryID);
            this.lCategory.remove(_sCategoryID);
         }
      }
      
      public function removeSound(_oSoundUnit:SoundUnit) : void
      {
         var _nTotalAssetPlaying:uint = 0;
         var _oBalancedAsset:Object = this.lAutoBalanceAsset.find(_oSoundUnit.assetID);
         if(_oBalancedAsset != null)
         {
            _nTotalAssetPlaying = _oBalancedAsset as uint;
            _nTotalAssetPlaying--;
            _nTotalAssetPlaying = Math.max(0,_nTotalAssetPlaying);
            this.lAutoBalanceAsset.modify(_oSoundUnit.assetID,_nTotalAssetPlaying);
         }
         this.oEventManager.removeEventListener(sEVENT_MANAGER_ID,_oSoundUnit,SoundEvent.COMPLETED,this.onSoundComplete);
         this.oEventManager.removeEventListener(sEVENT_MANAGER_ID,_oSoundUnit,SoundEvent.DESTROYED,this.onSoundDestroyed);
         this.oEventManager.removeEventListener(sEVENT_MANAGER_ID,_oSoundUnit,SoundEvent.FADE_VOLUME_COMPLETED,this.onFadeComplete);
         this.oEventManager.removeEventListener(sEVENT_MANAGER_ID,_oSoundUnit,SoundEvent.FADE_PAN_COMPLETED,this.onFadeComplete);
         var _oCategoryData:CategoryStruct = this.lCategory.find(_oSoundUnit.categoryID) as CategoryStruct;
         _oCategoryData.lCurrentSoundUnits[_oSoundUnit] = null;
         delete _oCategoryData.lCurrentSoundUnits[_oSoundUnit];
         _oSoundUnit.destroy();
      }
      
      public function categoryExist(_sCategoryID:String) : Boolean
      {
         var _oCategoryData:CategoryStruct = this.getCategoryData(_sCategoryID);
         if(_oCategoryData != null)
         {
            return true;
         }
         return false;
      }
      
      public function play(_sCategoryID:String, _oLocation:AssetReference, _nVolume:Number = 1, _nLoop:int = 1, _bKillAfter:Boolean = true, _bPauseable:Boolean = false) : SoundUnit
      {
         var _oCategoryData:CategoryStruct = this.getCategoryData(_sCategoryID);
         var _oSoundUnit:SoundUnit = new SoundUnit(_sCategoryID,_nVolume,_nLoop,_bPauseable);
         _oSoundUnit.setSoundPlaying(true);
         _oSoundUnit.killAfterPlayback = _bKillAfter;
         _oSoundUnit.categoryVolume = _oCategoryData.nVolumePercent;
         if(_oCategoryData.bMuted || this.bMuted)
         {
            _oSoundUnit.mute();
         }
         if(_oCategoryData.bPaused)
         {
            _oSoundUnit.pause();
         }
         _oCategoryData.lCurrentSoundUnits[_oSoundUnit] = _oSoundUnit;
         this.oAssetManager.requestAsset(_oLocation,CallBackArguments.create(this.soundLoadedCallBack,_oSoundUnit),CallBackArguments.create(this.soundLoadedErrorCallback,_oSoundUnit));
         return _oSoundUnit;
      }
      
      public function getActiveSound(_oLocation:AssetReference) : Array
      {
         var i:CategoryStruct = null;
         var j:SoundUnit = null;
         var _aSoundUnitList:Array = new Array();
         this.oAssetManager.requestAsset(_oLocation,this.AssetRetrievedCallback);
         if(this.oTargetActiveSound != null)
         {
            for each(i in this.lCategory.object)
            {
               for each(j in i.lCurrentSoundUnits)
               {
                  if(j.assetID == this.oTargetActiveSound.ID)
                  {
                     _aSoundUnitList.push(j);
                  }
               }
            }
         }
         this.oTargetActiveSound = null;
         return _aSoundUnitList;
      }
      
      public function isSoundActive(_oLocation:AssetReference) : Boolean
      {
         var i:CategoryStruct = null;
         var j:SoundUnit = null;
         var _bIsPlaying:Boolean = false;
         this.oAssetManager.requestAsset(_oLocation,this.AssetRetrievedCallback);
         if(this.oTargetActiveSound != null)
         {
            for each(i in this.lCategory.object)
            {
               for each(j in i.lCurrentSoundUnits)
               {
                  if(j.assetID == this.oTargetActiveSound.ID)
                  {
                     return true;
                  }
               }
            }
         }
         return _bIsPlaying;
      }
      
      public function stop(_sCategoryID:String = null) : void
      {
         var _fActionCallBack:Function = function(_oSoundUnit:SoundUnit):void
         {
            _oSoundUnit.stop();
         };
         this.applyAction(_fActionCallBack,_sCategoryID);
      }
      
      public function pause(_sCategoryID:String = null) : void
      {
         var _fActionCallBack:Function = function(_oSoundUnit:SoundUnit):void
         {
            _oSoundUnit.updateManagerPause();
         };
         if(_sCategoryID != null)
         {
            this.getCategoryData(_sCategoryID).bPaused = true;
         }
         else
         {
            this.bPaused = true;
         }
         this.applyAction(_fActionCallBack,_sCategoryID);
      }
      
      public function resume(_sCategoryID:String = null) : void
      {
         var _fActionCallBack:Function = function(_oSoundUnit:SoundUnit):void
         {
            _oSoundUnit.updateManagerResume();
         };
         if(_sCategoryID != null)
         {
            this.getCategoryData(_sCategoryID).bPaused = false;
         }
         else
         {
            this.bPaused = false;
         }
         this.applyAction(_fActionCallBack,_sCategoryID);
      }
      
      public function isPaused(_sCategoryID:String = null) : Boolean
      {
         if(_sCategoryID != null)
         {
            return this.getCategoryData(_sCategoryID).bPaused;
         }
         return this.bPaused;
      }
      
      public function mute(_sCategoryID:String = null) : void
      {
         var i:CategoryStruct = null;
         var _fActionCallBack:Function = function(_oSoundUnit:SoundUnit):void
         {
            _oSoundUnit.mute();
         };
         if(_sCategoryID != null)
         {
            this.getCategoryData(_sCategoryID).bMuted = true;
         }
         else
         {
            for each(i in this.lCategory.object)
            {
               i.bMuted = true;
            }
            this.bMuted = true;
         }
         this.applyAction(_fActionCallBack,_sCategoryID);
      }
      
      public function unmute(_sCategoryID:String = null) : void
      {
         var i:CategoryStruct = null;
         var _fActionCallBack:Function = function(_oSoundUnit:SoundUnit):void
         {
            _oSoundUnit.unmute();
         };
         if(_sCategoryID != null)
         {
            this.getCategoryData(_sCategoryID).bMuted = false;
         }
         else
         {
            for each(i in this.lCategory.object)
            {
               i.bMuted = false;
            }
            this.bMuted = false;
         }
         this.applyAction(_fActionCallBack,_sCategoryID);
      }
      
      public function isMuted(_sCategoryID:String = null) : Boolean
      {
         if(_sCategoryID != null)
         {
            return this.getCategoryData(_sCategoryID).bMuted;
         }
         return this.bMuted;
      }
      
      public function setRelativeVolume(_sCategoryID:String, _nVolume:Number) : void
      {
         var i:CategoryStruct = null;
         var k:SoundUnit = null;
         var _fActionCallBack:Function = null;
         var _oCategoryData:CategoryStruct = null;
         if(_sCategoryID == null)
         {
            for each(i in this.lCategory.object)
            {
               i.nVolumePercent = _nVolume;
               for each(k in i.lCurrentSoundUnits)
               {
                  k.categoryVolume = _nVolume;
               }
            }
         }
         else
         {
            _fActionCallBack = function(_oSoundUnit:SoundUnit):void
            {
               _oSoundUnit.categoryVolume = _nVolume;
            };
            _oCategoryData = this.lCategory.find(_sCategoryID) as CategoryStruct;
            if(_oCategoryData != null)
            {
               _oCategoryData.nVolumePercent = _nVolume;
            }
            this.applyAction(_fActionCallBack,_sCategoryID);
         }
      }
      
      public function getRelativeVolume(_sCategoryID:String = null) : Number
      {
         var i:CategoryStruct = null;
         var _oCategoryData:CategoryStruct = null;
         if(_sCategoryID == null)
         {
            var _loc4_:int = 0;
            var _loc5_:* = this.lCategory.object;
            for each(i in _loc5_)
            {
               return i.nVolumePercent;
            }
         }
         else
         {
            _oCategoryData = this.getCategoryData(_sCategoryID);
            if(_oCategoryData != null)
            {
               return _oCategoryData.nVolumePercent;
            }
         }
         return 0;
      }
      
      public function setPan(_sCategoryID:String, _nPan:Number) : void
      {
         var _fActionCallBack:Function = function(_oSoundUnit:SoundUnit):void
         {
            _oSoundUnit.pan = _nPan;
         };
         this.applyAction(_fActionCallBack,_sCategoryID);
      }
      
      public function fadeVolume(_sCategoryID:String, _nVolumeDest:Number, _nDuration:int = 3000, _bStopAtEnd:Boolean = false, _bKillAfter:Boolean = true) : void
      {
         var _fActionCallBack:Function = function(_oSoundUnit:SoundUnit):void
         {
            _oSoundUnit.killAfterPlayback = _bKillAfter;
            _oSoundUnit.fadeVolume(_nVolumeDest,_nDuration,_bStopAtEnd);
         };
         this.applyAction(_fActionCallBack,_sCategoryID);
      }
      
      public function fadePan(_sCategoryID:String, _nPanDest:Number, _nDuration:int = 3000, _bStopAtEnd:Boolean = false, _bKillAfter:Boolean = true) : void
      {
         var _fActionCallBack:Function = function(_oSoundUnit:SoundUnit):void
         {
            _oSoundUnit.killAfterPlayback = _bKillAfter;
            _oSoundUnit.fadePan(_nPanDest,_nDuration,_bStopAtEnd);
         };
         this.applyAction(_fActionCallBack,_sCategoryID);
      }
      
      public function enableVolumeAutoBalance(_oAssetReference:AssetReference) : void
      {
         var _oAssetID:* = null;
         switch(_oAssetReference.location)
         {
            case AssetReference.sASSET_MANAGER:
               _oAssetID = _oAssetReference.assetID;
               break;
            case AssetReference.sLIBRARY_CLASS:
               _oAssetID = _oAssetReference.classRef;
               break;
            case AssetReference.sLIBRARY_STRING:
               _oAssetID = _oAssetReference.linkID;
         }
         var _oAsset:Object = this.lAutoBalanceAsset.find(_oAssetID);
         if(_oAsset == null)
         {
            this.lAutoBalanceAsset.insert(_oAssetID,0);
         }
      }
      
      public function disableVolumeAutoBalance(_oAssetReference:AssetReference) : void
      {
         var _oAssetID:* = null;
         switch(_oAssetReference.location)
         {
            case AssetReference.sASSET_MANAGER:
               _oAssetID = _oAssetReference.assetID;
               break;
            case AssetReference.sLIBRARY_CLASS:
               _oAssetID = _oAssetReference.classRef;
               break;
            case AssetReference.sLIBRARY_STRING:
               _oAssetID = _oAssetReference.linkID;
         }
         var _oAsset:Object = this.lAutoBalanceAsset.find(_oAssetID);
         if(_oAsset != null)
         {
            this.lAutoBalanceAsset.remove(_oAssetID);
         }
      }
      
      override public function toString() : String
      {
         return "[SoundManager: Mute = " + this.bMuted + ", Pause = " + this.bPaused + "]";
      }
      
      private function init() : void
      {
         this.lCategory = new ObjectList();
         this.lAutoBalanceAsset = new ObjectList();
         this.oAssetManager = AssetManager.instance;
         this.oEventManager = new EventManager();
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,UpdateManager.instance,UpdateEvent.PAUSE,this.onPause);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,UpdateManager.instance,UpdateEvent.RESUME,this.onResume);
      }
      
      private function applyAction(_fActionCallBack:Function, _sCategoryID:String = null) : void
      {
         var _lCategoryToApply:ObjectList = null;
         var _oCategoryData:CategoryStruct = null;
         var _oSoundUnit:SoundUnit = null;
         if(Boolean(_sCategoryID))
         {
            _oCategoryData = this.getCategoryData(_sCategoryID);
            _lCategoryToApply = new ObjectList();
            _lCategoryToApply.insert(_sCategoryID,_oCategoryData);
         }
         else
         {
            _lCategoryToApply = this.lCategory;
         }
         var _oCategoryToApply:Object = _lCategoryToApply.object;
         for each(_oCategoryData in _oCategoryToApply)
         {
            for each(_oSoundUnit in _oCategoryData.lCurrentSoundUnits)
            {
               _fActionCallBack(_oSoundUnit);
            }
         }
      }
      
      private function soundLoadedCallBack(_oAsset:SoundAsset, _oSoundUnit:SoundUnit) : void
      {
         var _oBalancedAsset:Object = this.lAutoBalanceAsset.find(_oAsset.ID);
         var _nTotalAssetPlaying:uint = 0;
         if(_oBalancedAsset != null)
         {
            _nTotalAssetPlaying = _oBalancedAsset as uint;
            _nTotalAssetPlaying++;
            this.lAutoBalanceAsset.modify(_oAsset.ID,_nTotalAssetPlaying);
         }
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,_oSoundUnit,SoundEvent.COMPLETED,this.onSoundComplete);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,_oSoundUnit,SoundEvent.DESTROYED,this.onSoundDestroyed);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,_oSoundUnit,SoundEvent.FADE_VOLUME_COMPLETED,this.onFadeComplete);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,_oSoundUnit,SoundEvent.FADE_PAN_COMPLETED,this.onFadeComplete);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,_oSoundUnit,SoundEvent.READY,this.onSoundReady);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,_oSoundUnit,SoundEvent.ALL_SOUND_CHANNELS_USED,this.onAllChannelsUsed);
         _oSoundUnit.setSound(_oAsset.content as Sound,_oAsset.ID,_nTotalAssetPlaying);
      }
      
      private function soundLoadedErrorCallback(_oError:AssetError, _oSoundUnit:SoundUnit) : void
      {
         _oSoundUnit.setSoundPlaying(false);
      }
      
      private function getCategoryData(_sCategoryID:String) : CategoryStruct
      {
         return this.lCategory.find(_sCategoryID) as CategoryStruct;
      }
      
      private function AssetRetrievedCallback(_oAsset:SoundAsset) : void
      {
         this.oTargetActiveSound = _oAsset;
      }
      
      private function onSoundReady(_e:SoundEvent) : void
      {
         dispatchEvent(_e);
         this.oEventManager.removeEventListener(sEVENT_MANAGER_ID,_e.soundUnit,SoundEvent.READY,this.onSoundReady);
         this.oEventManager.removeEventListener(sEVENT_MANAGER_ID,_e.soundUnit,SoundEvent.ALL_SOUND_CHANNELS_USED,this.onAllChannelsUsed);
      }
      
      private function onAllChannelsUsed(_e:SoundEvent) : void
      {
         dispatchEvent(_e);
         this.oEventManager.removeEventListener(sEVENT_MANAGER_ID,_e.soundUnit,SoundEvent.READY,this.onSoundReady);
         this.oEventManager.removeEventListener(sEVENT_MANAGER_ID,_e.soundUnit,SoundEvent.ALL_SOUND_CHANNELS_USED,this.onAllChannelsUsed);
      }
      
      private function onSoundDestroyed(_e:SoundEvent) : void
      {
         this.removeSound(_e.soundUnit);
      }
      
      private function onSoundComplete(_e:SoundEvent) : void
      {
         dispatchEvent(_e);
         if(_e.soundUnit.killAfterPlayback)
         {
            this.removeSound(_e.soundUnit);
         }
      }
      
      private function onFadeComplete(_e:SoundEvent) : void
      {
         dispatchEvent(_e);
      }
      
      private function onPause(_e:UpdateEvent) : void
      {
         this.pause();
      }
      
      private function onResume(_e:UpdateEvent) : void
      {
         this.resume();
      }
   }
}

import flash.utils.Dictionary;

class CategoryStruct
{
   
   public var lCurrentSoundUnits:Dictionary;
   
   public var bMuted:Boolean;
   
   public var bPaused:Boolean;
   
   public var nVolumePercent:Number = 1;
   
   public function CategoryStruct()
   {
      super();
      this.lCurrentSoundUnits = new Dictionary(true);
      this.bMuted = false;
      this.bPaused = false;
   }
}
