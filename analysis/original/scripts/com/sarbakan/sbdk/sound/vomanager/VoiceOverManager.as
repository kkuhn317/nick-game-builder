package com.sarbakan.sbdk.sound.vomanager
{
   import com.sarbakan.sbdk.asset.AssetReference;
   import com.sarbakan.sbdk.core.UpdateManager;
   import com.sarbakan.sbdk.errors.ErrorMessages;
   import com.sarbakan.sbdk.events.SoundEvent;
   import com.sarbakan.sbdk.events.UpdateEvent;
   import com.sarbakan.sbdk.events.VOEvent;
   import com.sarbakan.sbdk.sound.SoundManager;
   import com.sarbakan.sbdk.sound.SoundUnit;
   import com.sarbakan.sbdk.utils.EventManager;
   import com.sarbakan.sbdk.utils.FrameTimer;
   import com.sarbakan.sbdk.utils.IGraphicallyDebuggable;
   import com.sarbakan.sbdk.utils.ObjectList;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.getQualifiedClassName;
   
   [Event(name="ERROR",type="com.sarbakan.sbdk.events.VOEvent")]
   [Event(name="START",type="com.sarbakan.sbdk.events.VOEvent")]
   [Event(name="COMPLETE",type="com.sarbakan.sbdk.events.VOEvent")]
   public class VoiceOverManager extends EventDispatcher implements IGraphicallyDebuggable
   {
      
      private static var oInstance:VoiceOverManager;
      
      private static var bAllowConstruction:Boolean = false;
      
      private const sVERSION:String = "1.1";
      
      private const sTIMER_EVENT:String = "TIMER_EVENT";
      
      private const sSOUND_EVENT:String = "SOUND_EVENT";
      
      private const sUPDATE_EVENT:String = "UPDATE_EVENT";
      
      private const sLIPSYNC_CLASS_NAME:String = "com.sarbakan.sbdk.sound.vomanager::LipsyncDataDummy";
      
      private const nDUMMY_SOUND_DURATION:int = 2000;
      
      private const sVO_SOUND:String = "VO_SOUND";
      
      public const sDEFAULT_TEXT_FONT:String = "Verdana";
      
      public const nDEFAULT_TEXT_COLOR:Number = 16777113;
      
      public const nDEFAULT_TEXT_COLOR_SHADOW:Number = 0;
      
      public const nDEFAULT_TEXT_SIZE:uint = 12;
      
      public const sDEFAULT_TEXT_ALIGN:String = "left";
      
      public const nDEFAULT_WIDTH_RATIO:Number = 1;
      
      public const nDEFAULT_HEIGHT_RATIO:Number = 0.25;
      
      public const nDEFAULT_X_POS:int = 0;
      
      public const nDEFAULT_Y_POS:int = 0;
      
      private var oDebugText:TextField;
      
      private var oDebugTextFormat:TextFormat;
      
      private var oDebugShadowText:TextField;
      
      private var oDebugShadowTextFormat:TextFormat;
      
      private var lCharList:ObjectList;
      
      private var lCurrentVOList:Array;
      
      private var lVOQueues:ObjectList;
      
      private var lCurrentVOQueue:Array;
      
      private var lSingleVOList:ObjectList;
      
      private var nCurrentQueueIndex:uint;
      
      private var oSoundManager:SoundManager;
      
      private var oVOListTimer:FrameTimer;
      
      private var oVOQueueTimer:FrameTimer;
      
      private var oUpdateManager:UpdateManager;
      
      private var oEventManager:EventManager;
      
      private var oPhonemeConverter:AbstractPhonemeConverter;
      
      private var bPausable:Boolean;
      
      private var bGraphicDebugEnabled:Boolean;
      
      private var sCurrentQueueID:String;
      
      private var sTextFont:String;
      
      private var nTextColor:Number;
      
      private var nTextColorShadow:Number;
      
      private var nTextSize:uint;
      
      private var sTextAlign:String;
      
      private var nTextWidthRatio:Number;
      
      private var nTextHeightRatio:Number;
      
      private var nTextXPosition:int;
      
      private var nTextYPosition:int;
      
      public function VoiceOverManager()
      {
         super();
         if(!bAllowConstruction)
         {
            throw new Error(ErrorMessages.sSINGLETON_STAGE);
         }
         this.init();
      }
      
      public static function get instance() : VoiceOverManager
      {
         if(oInstance == null)
         {
            bAllowConstruction = true;
            oInstance = new VoiceOverManager();
            bAllowConstruction = false;
         }
         return oInstance;
      }
      
      public function destroy() : void
      {
         this.oEventManager.clearAll();
         this.oEventManager.destroy();
         this.oEventManager = null;
         this.lCurrentVOList.splice(0,this.lCurrentVOList.length);
         this.lCurrentVOList = null;
         this.lVOQueues.clear();
         this.lVOQueues = null;
         this.lCharList.clear();
         this.lCharList = null;
         this.lSingleVOList.clear();
         this.lSingleVOList = null;
         this.lCurrentVOQueue.splice(0,this.lCurrentVOQueue.length);
         this.lCurrentVOQueue = null;
         this.oSoundManager = null;
         this.oVOListTimer.stop();
         this.oVOListTimer.destroy();
         this.oVOListTimer = null;
         this.oVOQueueTimer.stop();
         this.oVOQueueTimer.destroy();
         this.oVOQueueTimer = null;
         this.oUpdateManager = null;
         this.oPhonemeConverter.destroy();
         this.oPhonemeConverter = null;
         this.oDebugText = null;
         this.oDebugTextFormat = null;
         this.oDebugShadowText = null;
         this.oDebugShadowTextFormat = null;
         oInstance = null;
      }
      
      public function enableGraphicDebug(_mcTarget:DisplayObjectContainer) : void
      {
         if(!this.bGraphicDebugEnabled)
         {
            this.oDebugTextFormat = new TextFormat();
            this.oDebugShadowTextFormat = new TextFormat();
            this.oDebugText = new TextField();
            this.oDebugShadowText = new TextField();
            this.oDebugText.selectable = false;
            this.oDebugText.mouseEnabled = false;
            this.oDebugShadowText.selectable = false;
            this.oDebugShadowText.mouseEnabled = false;
            this.setTextFormats();
            this.oDebugText.width = _mcTarget.stage.width * this.nTextWidthRatio;
            this.oDebugText.height = _mcTarget.stage.height * this.nTextHeightRatio;
            this.oDebugShadowText.width = _mcTarget.stage.width * this.nTextWidthRatio;
            this.oDebugShadowText.height = _mcTarget.stage.height * this.nTextHeightRatio;
            this.oDebugText.x = this.nTextXPosition;
            this.oDebugText.y = this.nTextYPosition;
            this.oDebugShadowText.x = this.oDebugText.x + 1;
            this.oDebugShadowText.y = this.oDebugText.y + 1;
            _mcTarget.addChild(this.oDebugShadowText);
            _mcTarget.addChild(this.oDebugText);
            this.bGraphicDebugEnabled = true;
         }
      }
      
      public function disableGraphicDebug() : void
      {
         if(this.bGraphicDebugEnabled)
         {
            this.oDebugShadowText.parent.removeChild(this.oDebugShadowText);
            this.oDebugText.parent.removeChild(this.oDebugText);
            this.oDebugShadowText = null;
            this.oDebugText = null;
            this.oDebugTextFormat = null;
            this.oDebugShadowTextFormat = null;
            this.bGraphicDebugEnabled = false;
         }
      }
      
      public function setPhonemeConverter(_oPhonemeConverter:AbstractPhonemeConverter) : void
      {
         if(this.oPhonemeConverter != null)
         {
            this.oPhonemeConverter.destroy();
         }
         this.oPhonemeConverter = _oPhonemeConverter;
      }
      
      public function fadeVolume(_nVolumeDest:Number, _nDuration:int = 1000) : void
      {
         this.oSoundManager.fadeVolume(this.sVO_SOUND,_nVolumeDest,_nDuration);
      }
      
      public function muteVolume() : void
      {
         this.oSoundManager.mute(this.sVO_SOUND);
      }
      
      public function unmuteVolume() : void
      {
         this.oSoundManager.unmute(this.sVO_SOUND);
      }
      
      public function pause() : void
      {
         if(this.bPausable)
         {
            this.oUpdateManager.pause();
            this.oVOListTimer.stop();
         }
      }
      
      public function resume() : void
      {
         if(this.bPausable)
         {
            this.oUpdateManager.resume();
            this.oVOListTimer.start();
         }
      }
      
      public function stop() : void
      {
         var i:CharacterStruct = null;
         var j:Array = null;
         var _aVOList:Array = null;
         var k:int = 0;
         this.oVOListTimer.stop();
         this.oVOQueueTimer.stop();
         this.lCurrentVOList.splice(0,this.lCurrentVOList.length);
         this.lCurrentVOQueue.splice(0,this.lCurrentVOQueue.length);
         this.oSoundManager.stop(this.sVO_SOUND);
         this.sCurrentQueueID = "";
         this.clearDebugText();
         for each(i in this.lCharList.object)
         {
            if(i.mcMouthRef != null)
            {
               i.mcMouthRef.gotoAndStop(this.oPhonemeConverter.phonemeTolabel("x"));
            }
         }
         for each(j in this.lVOQueues.object)
         {
            _aVOList = j;
            for(k = 0; k < _aVOList.length; k++)
            {
               _aVOList[k].oSound = null;
            }
         }
      }
      
      public function clearAll() : void
      {
         var i:CharacterStruct = null;
         var _aTempArray:Array = null;
         var j:int = 0;
         var k:Array = null;
         for each(i in this.lCharList.object)
         {
            if(i.mcMouthRef != null)
            {
               i.mcMouthRef.gotoAndStop(this.oPhonemeConverter.phonemeTolabel("x"));
               i.mcMouthRef = null;
            }
         }
         this.lCharList.clear();
         this.lCurrentVOList.splice(0,this.lCurrentVOList.length);
         this.lSingleVOList.clear();
         for(j = 0; j < this.lCurrentVOQueue.length; j++)
         {
            _aTempArray = this.lCurrentVOQueue[j];
            _aTempArray.splice(0,_aTempArray.length);
         }
         this.lCurrentVOQueue.splice(0,this.lCurrentVOQueue.length);
         for each(k in this.lVOQueues.object)
         {
            _aTempArray = k;
            _aTempArray.splice(0,_aTempArray.length);
         }
         this.lVOQueues.clear();
         this.stop();
      }
      
      public function addCharacter(_sCharID:String) : void
      {
         var _oChar:CharacterStruct = null;
         if(this.lCharList.find(_sCharID) == null)
         {
            _oChar = new CharacterStruct();
            _oChar.sID = _sCharID;
            this.lCharList.insert(_sCharID,_oChar);
         }
      }
      
      public function setCharacterMouth(_sCharID:String, _mcMouthRef:MovieClip) : void
      {
         var _oChar:CharacterStruct = this.lCharList.find(_sCharID);
         if(_oChar != null)
         {
            _oChar.mcMouthRef = _mcMouthRef;
         }
      }
      
      public function removeCharacter(_sCharID:String) : void
      {
         if(this.lCharList.find(_sCharID) != null)
         {
            this.lCharList.remove(_sCharID);
         }
      }
      
      public function startVO(_sVO_ID:String, _aCharID:Array = null, _oVOData:AbstractLipsyncData = null, _oSoundRef:AssetReference = null, _nVolume:Number = 1, _sVOString:String = null) : void
      {
         var _oVOConfig:VoiceOverStruct = new VoiceOverStruct();
         _oVOConfig.sID = _sVO_ID;
         _oVOConfig.aCharID = _aCharID;
         _oVOConfig.oVOData = _oVOData;
         if(_oSoundRef != null)
         {
            _oVOConfig.oSound = this.oSoundManager.play(this.sVO_SOUND,_oSoundRef,_nVolume,1,this.bPausable);
            if(getQualifiedClassName(_oVOData) == this.sLIPSYNC_CLASS_NAME)
            {
               LipsyncDataDummy(_oVOData).duration = _oVOConfig.oSound.duration / 1000 + 1;
            }
         }
         else if(getQualifiedClassName(_oVOData) == this.sLIPSYNC_CLASS_NAME)
         {
            _oVOConfig.bIsDummy = true;
            _oVOConfig.oSoundDummy = new SoundDummy(this.nDUMMY_SOUND_DURATION);
            _oVOConfig.oSoundDummy.play();
            this.oEventManager.addEventListener(this.sSOUND_EVENT + _oVOConfig.oSoundDummy.ID,_oVOConfig.oSoundDummy,SoundDummyEvent.COMPLETED,this.onDummySoundComplete);
            LipsyncDataDummy(_oVOData).duration = _oVOConfig.oSoundDummy.duration / 1000 + 1;
         }
         else
         {
            _oVOConfig.bIsDummy = true;
            _oVOConfig.oSoundDummy = new SoundDummy(_oVOData.timingArray[_oVOData.timingArray.length - 1] + 1000);
            _oVOConfig.oSoundDummy.play();
            this.oEventManager.addEventListener(this.sSOUND_EVENT + _oVOConfig.oSoundDummy.ID,_oVOConfig.oSoundDummy,SoundDummyEvent.COMPLETED,this.onDummySoundComplete);
         }
         _oVOConfig.bPlaying = true;
         _oVOConfig.sVOString = _sVOString;
         if(this.bGraphicDebugEnabled)
         {
            if(_oVOConfig.sVOString != null)
            {
               this.setDebugText(_oVOConfig.sVOString);
            }
         }
         this.lCurrentVOList.push(_oVOConfig);
         if(!this.oVOListTimer.running)
         {
            this.oVOListTimer.start();
         }
         dispatchEvent(new VOEvent(VOEvent.START,false,false,_sVO_ID));
      }
      
      public function setSingleVOCharID(_sVO_ID:String, _aCharID:Array = null) : void
      {
         var i:CharacterStruct = null;
         var j:int = 0;
         var _oVOConfig:VoiceOverStruct = this.lSingleVOList.find(_sVO_ID);
         if(_oVOConfig != null)
         {
            for each(i in this.lCharList.object)
            {
               for(j = 0; j < _oVOConfig.aCharID.length; j++)
               {
                  if(i.sID == _oVOConfig.aCharID[j])
                  {
                     if(i.mcMouthRef != null)
                     {
                        i.mcMouthRef.gotoAndStop(this.oPhonemeConverter.phonemeTolabel("x"));
                     }
                  }
               }
            }
            _oVOConfig.aCharID = _aCharID;
         }
      }
      
      public function getSingleVOSound(_sVO_ID:String) : SoundUnit
      {
         var _oVOConfig:VoiceOverStruct = this.lSingleVOList.find(_sVO_ID);
         if(_oVOConfig != null)
         {
            if(_oVOConfig.bPlaying && _oVOConfig.oSound != null)
            {
               return _oVOConfig.oSound;
            }
         }
         return null;
      }
      
      public function addSingleVO(_sVO_ID:String, _aCharID:Array = null, _oVOData:AbstractLipsyncData = null, _oSoundRef:AssetReference = null, _nVolume:Number = 1, _sVOString:String = null) : void
      {
         var _oVOConfig:VoiceOverStruct = new VoiceOverStruct();
         if(this.lSingleVOList.find(_sVO_ID) == null)
         {
            _oVOConfig.sID = _sVO_ID;
            _oVOConfig.aCharID = _aCharID;
            _oVOConfig.oVOData = _oVOData;
            _oVOConfig.oSoundAssetRef = _oSoundRef;
            _oVOConfig.nVolume = _nVolume;
            _oVOConfig.sVOString = _sVOString;
            this.lSingleVOList.insert(_sVO_ID,_oVOConfig);
         }
      }
      
      public function removeSingleVO(_sVO_ID:String) : void
      {
         if(this.lSingleVOList.find(_sVO_ID) != null)
         {
            this.lSingleVOList.remove(_sVO_ID);
         }
      }
      
      public function startSingleVO(_sVO_ID:String) : void
      {
         var _oVOConfig:VoiceOverStruct = this.lSingleVOList.find(_sVO_ID);
         if(_oVOConfig != null)
         {
            if(_oVOConfig.bPlaying)
            {
               if(_oVOConfig.oSound != null)
               {
                  _oVOConfig.oSound.stop();
                  this.removeVOFromList(_oVOConfig.oSound.assetID);
               }
               else if(_oVOConfig.oSoundDummy != null)
               {
                  this.removeVOFromList(_oVOConfig.oSoundDummy.ID);
               }
            }
            this.lCurrentVOList.push(_oVOConfig);
            if(_oVOConfig.oSoundAssetRef != null)
            {
               _oVOConfig.oSound = this.oSoundManager.play(this.sVO_SOUND,_oVOConfig.oSoundAssetRef,_oVOConfig.nVolume,1,_oVOConfig.bPausable);
               if(getQualifiedClassName(_oVOConfig.oVOData) == this.sLIPSYNC_CLASS_NAME)
               {
                  LipsyncDataDummy(_oVOConfig.oVOData).duration = _oVOConfig.oSound.duration / 1000 + 1;
               }
            }
            else if(getQualifiedClassName(_oVOConfig.oVOData) == this.sLIPSYNC_CLASS_NAME)
            {
               _oVOConfig.bIsDummy = true;
               _oVOConfig.oSoundDummy = new SoundDummy(this.nDUMMY_SOUND_DURATION);
               _oVOConfig.oSoundDummy.play();
               this.oEventManager.addEventListener(this.sSOUND_EVENT + _oVOConfig.oSoundDummy.ID,_oVOConfig.oSoundDummy,SoundDummyEvent.COMPLETED,this.onDummySoundComplete);
               LipsyncDataDummy(_oVOConfig.oVOData).duration = _oVOConfig.oSoundDummy.duration / 1000 + 1;
            }
            else
            {
               _oVOConfig.bIsDummy = true;
               _oVOConfig.oSoundDummy = new SoundDummy(_oVOConfig.oVOData.timingArray[_oVOConfig.oVOData.timingArray.length - 1] + 1000);
               _oVOConfig.oSoundDummy.play();
               this.oEventManager.addEventListener(this.sSOUND_EVENT + _oVOConfig.oSoundDummy.ID,_oVOConfig.oSoundDummy,SoundDummyEvent.COMPLETED,this.onDummySoundComplete);
            }
            _oVOConfig.bPlaying = true;
            if(this.bGraphicDebugEnabled)
            {
               if(_oVOConfig.sVOString != null)
               {
                  this.setDebugText(_oVOConfig.sVOString);
               }
            }
            if(!this.oVOListTimer.running)
            {
               this.oVOListTimer.start();
            }
         }
      }
      
      public function addQueuedVO(_sQueue_ID:String, _sQueueUnitID:String, _aCharID:Array, _oVOData:AbstractLipsyncData, _oSoundRef:AssetReference, _nPriority:uint, _nVolume:Number = 1, _sVOString:String = null) : void
      {
         var _aVOQueue:Array = this.lVOQueues.find(_sQueue_ID);
         var _oVOConfig:VoiceOverStruct = new VoiceOverStruct();
         if(_aVOQueue == null)
         {
            _aVOQueue = new Array();
            this.lVOQueues.insert(_sQueue_ID,_aVOQueue);
         }
         _oVOConfig.sID = _sQueue_ID;
         _oVOConfig.sUnitID = _sQueueUnitID;
         _oVOConfig.aCharID = _aCharID;
         _oVOConfig.nVolume = _nVolume;
         _oVOConfig.bPausable = this.bPausable;
         _oVOConfig.nPriority = _nPriority;
         _oVOConfig.oVOData = _oVOData;
         _oVOConfig.oSoundAssetRef = _oSoundRef;
         _oVOConfig.sVOString = _sVOString;
         if(_oSoundRef == null)
         {
            _oVOConfig.bIsDummy = true;
         }
         _aVOQueue.push(_oVOConfig);
         _aVOQueue.sortOn("nPriority",Array.NUMERIC);
      }
      
      public function removeQueuedVO(_sVO_ID:String) : void
      {
         var i:int = 0;
         var _aVOQueue:Array = this.lVOQueues.find(_sVO_ID);
         if(_aVOQueue != null)
         {
            for(i = 0; i < _aVOQueue.length; i++)
            {
               _aVOQueue[i].destroy();
            }
            this.lVOQueues.remove(_sVO_ID);
         }
      }
      
      public function startVOQueue(_sVO_ID:String) : void
      {
         var _nListLength:int = 0;
         var _nIndex:int = 0;
         var _oVO:VoiceOverStruct = null;
         var _aTargetQueue:Array = this.lVOQueues.find(_sVO_ID);
         if(this.sCurrentQueueID == "")
         {
            if(_aTargetQueue != null)
            {
               _nListLength = int(_aTargetQueue.length);
               _nIndex = 0;
               this.sCurrentQueueID = _sVO_ID;
               this.nCurrentQueueIndex = 0;
               while(_nIndex < _nListLength)
               {
                  _oVO = _aTargetQueue[_nIndex];
                  if(_oVO.nPriority == 0)
                  {
                     _oVO.bPlaying = true;
                  }
                  if(this.lCurrentVOQueue[_oVO.nPriority] == null)
                  {
                     this.lCurrentVOQueue[_oVO.nPriority] = new Array();
                  }
                  this.lCurrentVOQueue[_oVO.nPriority].push(_oVO);
                  _nIndex++;
               }
               if(_nListLength > 0)
               {
                  this.oVOQueueTimer.start();
               }
            }
            else
            {
               dispatchEvent(new VOEvent(VOEvent.ERROR,false,false,_sVO_ID,null,ErrorMessages.sVO_DOESNT_EXIST));
            }
         }
         else
         {
            dispatchEvent(new VOEvent(VOEvent.ERROR,false,false,_sVO_ID,null,ErrorMessages.sVO_QUEUE_IS_CURRENTLY_PLAYING));
         }
      }
      
      public function isPlaying(_sVO_ID:String = null) : Boolean
      {
         var _oVO:VoiceOverStruct = null;
         var _nListLength_1:int = int(this.lCurrentVOList.length);
         var _nListLength_2:int = 0;
         var _nIndex_1:int = 0;
         var _nIndex_2:int = 0;
         var _bPlaying:Boolean = false;
         while(_nIndex_1 < _nListLength_1)
         {
            _oVO = this.lCurrentVOList[_nIndex_1];
            if(_oVO.bPlaying)
            {
               if(_sVO_ID == null)
               {
                  return true;
               }
               if(_oVO.sID == _sVO_ID)
               {
                  return true;
               }
            }
            _nIndex_1++;
         }
         _nListLength_1 = int(this.lCurrentVOQueue.length);
         _nIndex_1 = 0;
         while(_nIndex_1 < _nListLength_1)
         {
            _nListLength_2 = int(this.lCurrentVOQueue[_nIndex_1].length);
            while(_nIndex_2 < _nListLength_2)
            {
               _oVO = this.lCurrentVOQueue[_nIndex_1][_nIndex_2];
               if(_oVO.bPlaying)
               {
                  if(_sVO_ID == null)
                  {
                     return true;
                  }
                  if(_oVO.sUnitID == _sVO_ID || _oVO.sID == _sVO_ID)
                  {
                     return true;
                  }
               }
               _nIndex_2++;
            }
            _nIndex_1++;
         }
         return _bPlaying;
      }
      
      public function isAdded(_sVO_ID:String) : Boolean
      {
         if(this.lVOQueues.find(_sVO_ID) != null)
         {
            return true;
         }
         if(this.lSingleVOList.find(_sVO_ID) != null)
         {
            return true;
         }
         return false;
      }
      
      private function init() : void
      {
         this.bGraphicDebugEnabled = false;
         this.bPausable = false;
         this.sCurrentQueueID = "";
         this.oEventManager = new EventManager();
         this.oUpdateManager = UpdateManager.instance;
         this.oPhonemeConverter = new DefaultPhonemeConverter();
         this.lSingleVOList = new ObjectList();
         this.lVOQueues = new ObjectList();
         this.lCharList = new ObjectList();
         this.lCurrentVOList = new Array();
         this.lCurrentVOQueue = new Array();
         this.oVOListTimer = new FrameTimer(1,0,false);
         this.oVOQueueTimer = new FrameTimer(1,0,false);
         this.oSoundManager = SoundManager.instance;
         this.oSoundManager.addCategory(this.sVO_SOUND);
         this.sTextFont = this.sDEFAULT_TEXT_FONT;
         this.nTextColor = this.nDEFAULT_TEXT_COLOR;
         this.nTextColorShadow = this.nDEFAULT_TEXT_COLOR_SHADOW;
         this.nTextSize = this.nDEFAULT_TEXT_SIZE;
         this.sTextAlign = this.sDEFAULT_TEXT_ALIGN;
         this.nTextWidthRatio = this.nDEFAULT_WIDTH_RATIO;
         this.nTextHeightRatio = this.nDEFAULT_HEIGHT_RATIO;
         this.nTextXPosition = this.nDEFAULT_X_POS;
         this.nTextYPosition = this.nDEFAULT_Y_POS;
         this.oEventManager.addEventListener(this.sUPDATE_EVENT,this.oUpdateManager,UpdateEvent.PAUSE,this.onUpdateEvent);
         this.oEventManager.addEventListener(this.sUPDATE_EVENT,this.oUpdateManager,UpdateEvent.RESUME,this.onUpdateEvent);
         this.oEventManager.addEventListener(this.sSOUND_EVENT,this.oSoundManager,SoundEvent.COMPLETED,this.onSoundComplete);
         this.oEventManager.addEventListener(this.sTIMER_EVENT,this.oVOListTimer,TimerEvent.TIMER,this.updateVOList);
         this.oEventManager.addEventListener(this.sTIMER_EVENT,this.oVOQueueTimer,TimerEvent.TIMER,this.updateVOQueue);
      }
      
      private function setTextFormats() : void
      {
         this.oDebugTextFormat.font = this.sTextFont;
         this.oDebugTextFormat.color = this.nTextColor;
         this.oDebugTextFormat.size = this.nTextSize;
         this.oDebugTextFormat.align = this.sTextAlign;
         this.oDebugShadowTextFormat.font = this.sTextFont;
         this.oDebugShadowTextFormat.color = this.nTextColorShadow;
         this.oDebugShadowTextFormat.size = this.nTextSize;
         this.oDebugShadowTextFormat.align = this.sTextAlign;
         this.oDebugText.defaultTextFormat = this.oDebugTextFormat;
         this.oDebugShadowText.defaultTextFormat = this.oDebugShadowTextFormat;
      }
      
      private function getPhonemeFromPosition(_nSoundPos:int, _oSynData:AbstractLipsyncData) : String
      {
         var _nListLength:int = int(_oSynData.timingArray.length);
         var _nIndex:int = 0;
         while(_nIndex < _nListLength)
         {
            if(_nSoundPos > _oSynData.timingArray[_nIndex] && _nSoundPos < _oSynData.timingArray[_nIndex + 1])
            {
               return _oSynData.lipsArray[_nIndex];
            }
            _nIndex++;
         }
         return null;
      }
      
      private function removeVOFromList(_sSoundAssetID:String) : void
      {
         var _mcChar:MovieClip = null;
         var _oVO:VoiceOverStruct = null;
         var i:int = 0;
         var _nListLength_1:int = int(this.lCurrentVOList.length);
         var _nListLength_2:int = 0;
         var _nIndex_1:int = 0;
         var _nIndex_2:int = 0;
         var _bFound:Boolean = false;
         while(_nIndex_1 < _nListLength_1)
         {
            _oVO = this.lCurrentVOList[_nIndex_1];
            if(_oVO.oSound != null)
            {
               if(_oVO.oSound.assetID == _sSoundAssetID)
               {
                  _bFound = true;
               }
            }
            else if(_oVO.oSoundDummy != null)
            {
               if(this.sSOUND_EVENT + _oVO.oSoundDummy.ID == this.sSOUND_EVENT + _sSoundAssetID)
               {
                  _bFound = true;
               }
            }
            if(_bFound)
            {
               for(i = 0; i < _oVO.aCharID.length; i++)
               {
                  if(this.lCharList.length > 0)
                  {
                     _mcChar = this.lCharList.find(_oVO.aCharID[i]).mcMouthRef;
                     if(_mcChar != null)
                     {
                        _mcChar.gotoAndStop(this.oPhonemeConverter.phonemeTolabel("x"));
                     }
                  }
               }
               if(this.bGraphicDebugEnabled)
               {
                  if(_oVO.sVOString != null)
                  {
                     this.removeFromDebugText(_oVO.sVOString);
                  }
               }
               _oVO.bPlaying = false;
               if(_oVO.oSound != null)
               {
                  _oVO.oSound = null;
               }
               else if(_oVO.oSoundDummy != null)
               {
                  this.oEventManager.cleanUp(this.sSOUND_EVENT + _oVO.oSoundDummy.ID);
                  _oVO.oSoundDummy.stop();
                  _oVO.oSoundDummy.destroy();
                  _oVO.oSoundDummy = null;
               }
               dispatchEvent(new VOEvent(VOEvent.COMPLETE,false,false,_oVO.sID));
               this.lCurrentVOList.splice(_nIndex_1,1);
               return;
            }
            _nIndex_1++;
         }
         _nListLength_1 = int(this.lCurrentVOQueue.length);
         _nIndex_1 = 0;
         _bFound = false;
         while(_nIndex_1 < _nListLength_1)
         {
            _nListLength_2 = int(this.lCurrentVOQueue[_nIndex_1].length);
            while(_nIndex_2 < _nListLength_2)
            {
               _oVO = this.lCurrentVOQueue[_nIndex_1][_nIndex_2];
               if(_oVO.oSound != null)
               {
                  if(_oVO.oSound.assetID == _sSoundAssetID)
                  {
                     _bFound = true;
                  }
               }
               else if(_oVO.oSoundDummy != null)
               {
                  if(this.sSOUND_EVENT + _oVO.oSoundDummy.ID == _sSoundAssetID)
                  {
                     _bFound = true;
                  }
               }
               if(_bFound)
               {
                  for(i = 0; i < _oVO.aCharID.length; i++)
                  {
                     if(this.lCharList.length > 0)
                     {
                        _mcChar = this.lCharList.find(_oVO.aCharID[i]).mcMouthRef;
                        if(_mcChar != null)
                        {
                           _mcChar.gotoAndStop(this.oPhonemeConverter.phonemeTolabel("x"));
                        }
                     }
                  }
                  if(this.bGraphicDebugEnabled)
                  {
                     if(_oVO.sVOString != null)
                     {
                        this.removeFromDebugText(_oVO.sVOString);
                     }
                  }
                  _oVO.bPlaying = false;
                  if(_oVO.oSound != null)
                  {
                     _oVO.oSound = null;
                  }
                  else if(_oVO.oSoundDummy != null)
                  {
                     this.oEventManager.cleanUp(this.sSOUND_EVENT + _oVO.oSoundDummy.ID);
                     _oVO.oSoundDummy.stop();
                     _oVO.oSoundDummy.destroy();
                     _oVO.oSoundDummy = null;
                  }
                  dispatchEvent(new VOEvent(VOEvent.COMPLETE,false,false,_oVO.sID,_oVO.sUnitID));
                  this.lCurrentVOQueue[_nIndex_1].splice(_nIndex_2,1);
                  return;
               }
               _nIndex_2++;
            }
            _nIndex_1++;
         }
      }
      
      private function setDebugText(_sText:String) : void
      {
         this.oDebugText.appendText(_sText + "\n");
         this.oDebugShadowText.appendText(_sText + "\n");
      }
      
      private function clearDebugText() : void
      {
         if(this.oDebugText != null)
         {
            this.oDebugText.text = "";
            this.oDebugShadowText.text = "";
         }
      }
      
      private function removeFromDebugText(_sText:String) : void
      {
         var _sDebugString:String = this.oDebugText.text;
         var _nStartIndex:int = _sDebugString.indexOf(_sText);
         var _nEndIndex:int = _nStartIndex + _sText.length;
         var _sStartString:String = "";
         var _sEndString:String = "";
         var _sReturnString:String = "";
         if(_nStartIndex > 0)
         {
            _sStartString = _sDebugString.substr(0,_nStartIndex);
            _sEndString = _sDebugString.substr(_nEndIndex + 1);
            _sReturnString = _sStartString + _sEndString;
         }
         else
         {
            _sReturnString = _sDebugString.substr(_nEndIndex + 1);
         }
         this.oDebugText.text = _sReturnString;
         this.oDebugShadowText.text = _sReturnString;
      }
      
      private function getCharStruct(_mcRef:MovieClip) : CharacterStruct
      {
         var i:CharacterStruct = null;
         for each(i in this.lCharList.object)
         {
            if(i.mcMouthRef == _mcRef)
            {
               return i;
            }
         }
         return null;
      }
      
      private function onUpdateEvent(_oEvent:UpdateEvent) : void
      {
         switch(_oEvent.type)
         {
            case UpdateEvent.PAUSE:
               this.pause();
               break;
            case UpdateEvent.RESUME:
               this.resume();
         }
      }
      
      private function updateVOList(_oEvent:TimerEvent) : void
      {
         var _sPhoneme:String = null;
         var _sLabel:String = null;
         var _mcChar:MovieClip = null;
         var _oVO:VoiceOverStruct = null;
         var i:int = 0;
         var _nListLength:int = int(this.lCurrentVOList.length);
         var _nIndex:int = 0;
         if(_nListLength > 0)
         {
            while(_nIndex < _nListLength)
            {
               _oVO = this.lCurrentVOList[_nIndex];
               if(!_oVO.bIsDummy)
               {
                  _sPhoneme = this.getPhonemeFromPosition(_oVO.oSound.position,_oVO.oVOData);
               }
               else
               {
                  _sPhoneme = this.getPhonemeFromPosition(_oVO.oSoundDummy.position,_oVO.oVOData);
               }
               if(_sPhoneme != null)
               {
                  _sLabel = this.oPhonemeConverter.phonemeTolabel(_sPhoneme);
                  for(i = 0; i < _oVO.aCharID.length; i++)
                  {
                     if(this.lCharList.length > 0)
                     {
                        _mcChar = this.lCharList.find(_oVO.aCharID[i]).mcMouthRef;
                        if(_mcChar != null)
                        {
                           _mcChar.gotoAndStop(_sLabel);
                        }
                     }
                  }
               }
               _nIndex++;
            }
         }
         else
         {
            this.oVOListTimer.stop();
         }
      }
      
      private function updateVOQueue(_oEvent:TimerEvent) : void
      {
         var _nListLength:int = 0;
         var _nIndex:int = 0;
         var _sPhoneme:String = null;
         var _sLabel:String = null;
         var _mcChar:MovieClip = null;
         var _oVO:VoiceOverStruct = null;
         var i:int = 0;
         var _sQueueID:String = null;
         if(this.nCurrentQueueIndex < this.lCurrentVOQueue.length)
         {
            if(this.lCurrentVOQueue[this.nCurrentQueueIndex] != null)
            {
               _nListLength = int(this.lCurrentVOQueue[this.nCurrentQueueIndex].length);
               _nIndex = 0;
               if(_nListLength > 0)
               {
                  while(_nIndex < _nListLength)
                  {
                     _oVO = this.lCurrentVOQueue[this.nCurrentQueueIndex][_nIndex];
                     if(!_oVO.bIsDummy)
                     {
                        if(_oVO.oSound == null)
                        {
                           if(this.bGraphicDebugEnabled)
                           {
                              if(_oVO.sVOString != null)
                              {
                                 this.setDebugText(_oVO.sVOString);
                              }
                           }
                           dispatchEvent(new VOEvent(VOEvent.START,false,false,_oVO.sID,_oVO.sUnitID));
                           _oVO.bPlaying = true;
                           _oVO.oSound = this.oSoundManager.play(this.sVO_SOUND,_oVO.oSoundAssetRef,_oVO.nVolume,1,this.bPausable);
                           if(getQualifiedClassName(_oVO.oVOData) == this.sLIPSYNC_CLASS_NAME)
                           {
                              LipsyncDataDummy(_oVO.oVOData).duration = _oVO.oSound.duration / 1000 + 1;
                           }
                        }
                        _sPhoneme = this.getPhonemeFromPosition(_oVO.oSound.position,_oVO.oVOData);
                     }
                     else
                     {
                        if(_oVO.oSoundDummy == null)
                        {
                           if(this.bGraphicDebugEnabled)
                           {
                              if(_oVO.sVOString != null)
                              {
                                 this.setDebugText(_oVO.sVOString);
                              }
                           }
                           dispatchEvent(new VOEvent(VOEvent.START,false,false,_oVO.sID,_oVO.sUnitID));
                           _oVO.bPlaying = true;
                           _oVO.bIsDummy = true;
                           if(getQualifiedClassName(_oVO.oVOData) == this.sLIPSYNC_CLASS_NAME)
                           {
                              _oVO.oSoundDummy = new SoundDummy(this.nDUMMY_SOUND_DURATION);
                              LipsyncDataDummy(_oVO.oVOData).duration = _oVO.oSoundDummy.duration / 1000 + 1;
                           }
                           else
                           {
                              _oVO.oSoundDummy = new SoundDummy(_oVO.oVOData.timingArray[_oVO.oVOData.timingArray.length - 1] + 1000);
                           }
                           this.oEventManager.addEventListener(this.sSOUND_EVENT + _oVO.oSoundDummy.ID,_oVO.oSoundDummy,SoundDummyEvent.COMPLETED,this.onDummySoundComplete);
                           _oVO.oSoundDummy.play();
                        }
                        _sPhoneme = this.getPhonemeFromPosition(_oVO.oSoundDummy.position,_oVO.oVOData);
                     }
                     if(_sPhoneme != null)
                     {
                        _sLabel = this.oPhonemeConverter.phonemeTolabel(_sPhoneme);
                        for(i = 0; i < _oVO.aCharID.length; i++)
                        {
                           _mcChar = this.lCharList.find(_oVO.aCharID[i]).mcMouthRef;
                           if(_mcChar != null)
                           {
                              _mcChar.gotoAndStop(_sLabel);
                           }
                        }
                     }
                     _nIndex++;
                  }
               }
               else
               {
                  ++this.nCurrentQueueIndex;
               }
            }
         }
         else
         {
            _sQueueID = this.sCurrentQueueID;
            this.sCurrentQueueID = "";
            this.oVOQueueTimer.stop();
            this.nCurrentQueueIndex = 0;
            dispatchEvent(new VOEvent(VOEvent.QUEUE_COMPLETE,false,false,_sQueueID));
         }
      }
      
      private function onSoundComplete(_oEvent:SoundEvent) : void
      {
         this.removeVOFromList(_oEvent.soundUnit.assetID);
      }
      
      private function onDummySoundComplete(_oEvent:SoundDummyEvent) : void
      {
         this.removeVOFromList(this.sSOUND_EVENT + _oEvent.soundDummy.ID);
      }
      
      public function get version() : String
      {
         return this.sVERSION;
      }
      
      public function get pausable() : Boolean
      {
         return this.bPausable;
      }
      
      public function set pausable(_bPause:Boolean) : void
      {
         this.bPausable = _bPause;
      }
      
      public function get textFont() : String
      {
         return this.sTextFont;
      }
      
      public function set textFont(_sFont:String) : void
      {
         this.sTextFont = _sFont;
         if(this.bGraphicDebugEnabled)
         {
            this.setTextFormats();
         }
      }
      
      public function get textSize() : uint
      {
         return this.nTextSize;
      }
      
      public function set textSize(_nSize:uint) : void
      {
         this.nTextSize = _nSize;
         if(this.bGraphicDebugEnabled)
         {
            this.setTextFormats();
         }
      }
      
      public function get textColor() : Number
      {
         return this.nTextColor;
      }
      
      public function set textColor(_nColor:Number) : void
      {
         this.nTextColor = _nColor;
         if(this.bGraphicDebugEnabled)
         {
            this.setTextFormats();
         }
      }
      
      public function get textColorShadow() : Number
      {
         return this.nTextColorShadow;
      }
      
      public function set textColorShadow(_nColor:Number) : void
      {
         this.nTextColorShadow = _nColor;
         if(this.bGraphicDebugEnabled)
         {
            this.setTextFormats();
         }
      }
      
      public function get textAlign() : String
      {
         return this.sTextAlign;
      }
      
      public function set textAlign(_sAlign:String) : void
      {
         this.sTextAlign = _sAlign;
         if(this.bGraphicDebugEnabled)
         {
            this.setTextFormats();
         }
      }
      
      public function get textWidthRatio() : Number
      {
         return this.nTextWidthRatio;
      }
      
      public function set textWidthRatio(_nRatio:Number) : void
      {
         this.nTextWidthRatio = _nRatio;
         if(this.bGraphicDebugEnabled)
         {
            this.oDebugText.width = this.oDebugText.stage.width * this.nTextWidthRatio;
            this.oDebugShadowText.width = this.oDebugShadowText.stage.width * this.nTextWidthRatio;
         }
      }
      
      public function get textHeightRatio() : Number
      {
         return this.nTextHeightRatio;
      }
      
      public function set textHeightRatio(_nRatio:Number) : void
      {
         this.nTextHeightRatio = _nRatio;
         if(this.bGraphicDebugEnabled)
         {
            this.oDebugText.height = this.oDebugText.stage.height * this.nTextHeightRatio;
            this.oDebugShadowText.height = this.oDebugShadowText.stage.height * this.nTextHeightRatio;
         }
      }
      
      public function get textXPosition() : int
      {
         return this.nTextXPosition;
      }
      
      public function set textXPosition(_nXPos:int) : void
      {
         this.nTextXPosition = _nXPos;
         if(this.bGraphicDebugEnabled)
         {
            this.oDebugText.x = this.nTextXPosition;
            this.oDebugShadowText.x = this.nTextXPosition + 1;
         }
      }
      
      public function get textYPosition() : int
      {
         return this.nTextYPosition;
      }
      
      public function set textYPosition(_nYPos:int) : void
      {
         this.nTextYPosition = _nYPos;
         if(this.bGraphicDebugEnabled)
         {
            this.oDebugText.y = this.nTextYPosition;
            this.oDebugShadowText.y = this.nTextYPosition + 1;
         }
      }
   }
}

import com.sarbakan.sbdk.asset.AssetReference;
import com.sarbakan.sbdk.math.random.Random;
import com.sarbakan.sbdk.sound.SoundUnit;
import com.sarbakan.sbdk.utils.EventManager;
import com.sarbakan.sbdk.utils.FrameTimer;
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.utils.getTimer;

class VoiceOverStruct
{
   
   public var sID:String;
   
   public var sUnitID:String;
   
   public var aCharID:Array;
   
   public var nVolume:Number;
   
   public var bPausable:Boolean;
   
   public var oSound:SoundUnit;
   
   public var oSoundDummy:SoundDummy;
   
   public var oSoundAssetRef:AssetReference;
   
   public var oVOData:AbstractLipsyncData;
   
   public var sVOString:String;
   
   public var nPriority:uint;
   
   public var bPlaying:Boolean = false;
   
   public var bIsDummy:Boolean = false;
   
   public function VoiceOverStruct()
   {
      super();
   }
   
   public function destroy() : void
   {
      if(this.oSound != null)
      {
         this.oSound.destroy();
      }
      this.oSound = null;
      this.oVOData = null;
   }
}

class CharacterStruct
{
   
   public var sID:String;
   
   public var mcMouthRef:MovieClip;
   
   public var nNbrFrameDetect:int;
   
   public var nMaxNbrFrameDetect:int;
   
   public function CharacterStruct()
   {
      super();
   }
}

class SoundDummy extends EventDispatcher
{
   
   private static const sTIMER_EVENT:String = "TIMER_EVENT";
   
   private var oTimer:FrameTimer;
   
   private var oEventManager:EventManager;
   
   private var nDuration:int;
   
   private var nPosition:int;
   
   private var nStartTime:int;
   
   private var sID:String;
   
   public function SoundDummy(_nDuration:int)
   {
      super();
      this.nDuration = _nDuration;
      this.oEventManager = new EventManager();
      this.oTimer = new FrameTimer(1,0,false);
      this.oEventManager.addEventListener(sTIMER_EVENT,this.oTimer,TimerEvent.TIMER,this.onTimerUpdate);
      this.sID = String(getTimer() * Random.getFloat());
   }
   
   public function destroy() : void
   {
      this.oEventManager.clearAll();
      this.oEventManager.destroy();
      this.oEventManager = null;
      this.oTimer.stop();
      this.oTimer = null;
   }
   
   public function play() : void
   {
      if(!this.oTimer.running)
      {
         this.oTimer.start();
         this.nStartTime = getTimer();
      }
   }
   
   public function stop() : void
   {
      if(this.oTimer.running)
      {
         this.oTimer.stop();
      }
   }
   
   private function onTimerUpdate(_oEvent:TimerEvent) : void
   {
      if(this.nPosition < this.nDuration)
      {
         this.nPosition = getTimer() - this.nStartTime;
      }
      else
      {
         this.oTimer.stop();
         dispatchEvent(new SoundDummyEvent(SoundDummyEvent.COMPLETED,false,false,this));
      }
   }
   
   public function get position() : int
   {
      return this.nPosition;
   }
   
   public function get ID() : String
   {
      return this.sID;
   }
   
   public function get duration() : int
   {
      return this.nDuration;
   }
}

class SoundDummyEvent extends Event
{
   
   public static const COMPLETED:String = "sbdk_completed";
   
   private var oSoundDummy:SoundDummy;
   
   public function SoundDummyEvent(_sType:String, _bBubbles:Boolean, _bCancelable:Boolean, _oSoundDummy:SoundDummy)
   {
      super(_sType,_bBubbles,_bCancelable);
      this.oSoundDummy = _oSoundDummy;
   }
   
   override public function clone() : Event
   {
      return new SoundDummyEvent(type,bubbles,cancelable,this.soundDummy);
   }
   
   override public function toString() : String
   {
      return formatToString("SoundEvent","type","bubbles","cancelable","soundDummy");
   }
   
   public function get soundDummy() : SoundDummy
   {
      return this.oSoundDummy;
   }
}
