package com.sarbakan.sbdk.blitting.core
{
   import com.sarbakan.sbdk.errors.ErrorMessages;
   import com.sarbakan.sbdk.events.BitmappedEvent;
   import com.sarbakan.sbdk.math.SBKMath;
   import com.sarbakan.sbdk.utils.DisplayObjectUtils;
   import com.sarbakan.sbdk.utils.EventManager;
   import com.sarbakan.sbdk.utils.FrameTimer;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.utils.getDefinitionByName;
   import flash.utils.getTimer;
   
   [Event(name="RESUME",type="com.sarbakan.sbdk.events.BitmappedEvent")]
   [Event(name="PAUSE",type="com.sarbakan.sbdk.events.BitmappedEvent")]
   [Event(name="STOP",type="com.sarbakan.sbdk.events.BitmappedEvent")]
   [Event(name="START",type="com.sarbakan.sbdk.events.BitmappedEvent")]
   [Event(name="AMIM_COMPLETE",type="com.sarbakan.sbdk.events.BitmappedEvent")]
   [Event(name="ALL_COMPLETE",type="com.sarbakan.sbdk.events.BitmappedEvent")]
   [Event(name="PROGRESS",type="com.sarbakan.sbdk.events.BitmappedEvent")]
   public class VectorToBitmapConverter extends EventDispatcher
   {
      
      private static var oInstance:VectorToBitmapConverter;
      
      private static var bAllowConstruction:Boolean = false;
      
      private const sTIMER_EVENT:String = "TIMER_EVENT";
      
      private const sMOVIECLIP_CLASS_PATH:String = "flash.display::MovieClip";
      
      private var aProcessList:Array;
      
      private var oTimer:FrameTimer;
      
      private var oEventManager:EventManager;
      
      private var bRunning:Boolean;
      
      private var bPaused:Boolean;
      
      private var oCurrentProcessingList:AnimInfoStruct;
      
      private var oFrameData:BitmapData;
      
      private var oFlippedFrameData:BitmapData;
      
      private var oStage:Stage;
      
      private var nTimePerFrame:uint;
      
      private var nStartTime:uint;
      
      private var nTotalFrames:uint;
      
      private var nCurrentFrameCount:uint;
      
      private var nTotalBytes:uint;
      
      private var aTempFrameDataList:Array;
      
      private var aTempFlippedFrameDataList:Array;
      
      private var aColliders:Array;
      
      private var aFlippedColliders:Array;
      
      public function VectorToBitmapConverter(_oStage:Stage)
      {
         super();
         if(!bAllowConstruction)
         {
            throw new Error(ErrorMessages.sSINGLETON_ERROR);
         }
         this.oStage = _oStage;
         this.init();
      }
      
      public static function instance(_oStage:Stage) : VectorToBitmapConverter
      {
         if(!oInstance)
         {
            bAllowConstruction = true;
            oInstance = new VectorToBitmapConverter(_oStage);
            bAllowConstruction = false;
         }
         return oInstance;
      }
      
      public function destroy() : void
      {
         if(this.oCurrentProcessingList != null)
         {
            this.oCurrentProcessingList.destroy();
            this.oCurrentProcessingList = null;
         }
         if(this.oEventManager != null)
         {
            this.oEventManager.destroy();
            this.oEventManager = null;
         }
         if(this.aProcessList != null)
         {
            this.aProcessList.splice(0,this.aProcessList.length);
         }
         this.aTempFrameDataList.splice(0,this.aTempFrameDataList.length);
         this.aTempFlippedFrameDataList.splice(0,this.aTempFlippedFrameDataList.length);
         this.aTempFrameDataList = null;
         this.aTempFlippedFrameDataList = null;
         this.oStage = null;
         this.oTimer.stop();
         this.oTimer = null;
         oInstance = null;
      }
      
      public function start() : void
      {
         if(!this.bRunning)
         {
            this.nTotalBytes = 0;
            this.nTotalFrames = this.getTotalNumberOfFrame();
            this.nCurrentFrameCount = 1;
            this.oCurrentProcessingList = this.aProcessList.pop();
            this.next();
            this.oEventManager.addEventListener(this.sTIMER_EVENT,this.oTimer,TimerEvent.TIMER,this.onUpdate);
            this.oTimer.start();
            this.bRunning = true;
            dispatchEvent(new BitmappedEvent(BitmappedEvent.START));
         }
      }
      
      public function stop() : void
      {
         if(this.bRunning)
         {
            this.oTimer.stop();
            this.oEventManager.cleanUp(this.sTIMER_EVENT);
            this.bRunning = false;
            this.aProcessList.splice(0,this.aProcessList.length);
            this.oCurrentProcessingList = null;
            dispatchEvent(new BitmappedEvent(BitmappedEvent.STOP));
         }
      }
      
      public function pause() : void
      {
         if(!this.bPaused && this.bRunning)
         {
            this.oTimer.stop();
            this.bPaused = true;
            dispatchEvent(new BitmappedEvent(BitmappedEvent.PAUSE));
         }
      }
      
      public function resume() : void
      {
         if(this.bPaused)
         {
            this.bPaused = false;
            this.oTimer.start();
            dispatchEvent(new BitmappedEvent(BitmappedEvent.RESUME));
         }
      }
      
      public function addMovieClipClass(_aClassRefList:Array, _oTransform:TransformConfig = null, _aDuplicationFrameConfigs:Array = null, _bCheckForCollider:Boolean = false, _bFlip:Boolean = false, _sGroupID:String = null) : void
      {
         var _oAnimInfoStruct:AnimInfoStruct = new AnimInfoStruct();
         _oAnimInfoStruct.sGroupID = _sGroupID;
         _oAnimInfoStruct.aClassRefList = _aClassRefList.concat();
         _oAnimInfoStruct.aFrameDataList = new Array();
         if(_oTransform != null)
         {
            _oAnimInfoStruct.sClassVariantID = _oTransform.variantID;
            _oAnimInfoStruct.nRenderScale = _oTransform.renderScale;
            _oAnimInfoStruct.oMatrix = _oTransform.matrix;
            _oAnimInfoStruct.oColorTransform = _oTransform.colorTransform;
            if(_oTransform.filters != null)
            {
               _oAnimInfoStruct.oFilters = _oTransform.filters.concat();
            }
            _oAnimInfoStruct.bSmoothing = _oTransform.smoothing;
         }
         _oAnimInfoStruct.bCollider = _bCheckForCollider;
         _oAnimInfoStruct.bFlip = _bFlip;
         _oAnimInfoStruct.oFlipMatrix = new Matrix();
         _oAnimInfoStruct.oFlipMatrix.scale(-1,1);
         if(_oAnimInfoStruct.oMatrix != null)
         {
            _oAnimInfoStruct.oFlipMatrix.concat(_oAnimInfoStruct.oMatrix);
         }
         if(_aDuplicationFrameConfigs != null && _aDuplicationFrameConfigs.length > 0)
         {
            _oAnimInfoStruct.aDuplicationFrameConfigs = _aDuplicationFrameConfigs.concat();
         }
         this.aProcessList.push(_oAnimInfoStruct);
      }
      
      private function init() : void
      {
         this.bRunning = false;
         this.bPaused = false;
         this.aProcessList = new Array();
         this.nTimePerFrame = 0;
         if(this.oStage != null)
         {
            this.nTimePerFrame = 1000 / this.oStage.frameRate;
         }
         this.oTimer = new FrameTimer(1,0,false);
         this.oEventManager = new EventManager();
         this.aTempFrameDataList = new Array();
         this.aTempFlippedFrameDataList = new Array();
      }
      
      private function getTotalNumberOfFrame() : uint
      {
         var _oFrameStructure:AnimInfoStruct = null;
         var _mcRef:MovieClip = null;
         var j:int = 0;
         var _nFrameCounter:int = 0;
         for(var i:int = 0; i < this.aProcessList.length; i++)
         {
            _oFrameStructure = this.aProcessList[i];
            for(j = 0; j < _oFrameStructure.aClassRefList.length; j++)
            {
               _mcRef = new _oFrameStructure.aClassRefList[j]();
               this.nTotalBytes += this.getByteSize(_mcRef.width,_mcRef.height) * _mcRef.totalFrames;
               _nFrameCounter += _mcRef.totalFrames;
            }
         }
         return _nFrameCounter;
      }
      
      private function next() : void
      {
         if(this.oCurrentProcessingList != null && this.oCurrentProcessingList.aClassRefList.length > 0)
         {
            dispatchEvent(new BitmappedEvent(BitmappedEvent.ANIM_COMPLETE,false,false,this.oCurrentProcessingList.oClassRef,this.oCurrentProcessingList.sClassVariantID));
            this.initializeProcess();
         }
         else if(this.aProcessList.length > 0)
         {
            this.oCurrentProcessingList = this.aProcessList.pop();
            this.initializeProcess();
         }
         else
         {
            this.stop();
            dispatchEvent(new BitmappedEvent(BitmappedEvent.ALL_COMPLETE));
         }
      }
      
      private function sendFrameData(_sGroupID:String, _oClassRef:Class, _sVariantID:String, _oFrameData:BitmapData, _oRect:Rectangle, _oMaxFrameSize:Rectangle, _nRadius:Number, _nAngleOffset:Number, _nFrameNumber:uint, _sLabel:String, _aColliderList:Array, _bFlip:Boolean) : void
      {
         BitmapDataCollection.instance.insertData(_sGroupID,_oClassRef,_sVariantID,_nFrameNumber,_oFrameData,_oRect,_oMaxFrameSize,_nRadius,_nAngleOffset,_sLabel,_aColliderList,_bFlip);
      }
      
      private function initializeProcess() : void
      {
         var i:int = 0;
         this.aTempFlippedFrameDataList.splice(0,this.aTempFlippedFrameDataList.length);
         this.aTempFrameDataList.splice(0,this.aTempFrameDataList.length);
         this.oCurrentProcessingList.oClassRef = this.oCurrentProcessingList.aClassRefList.pop();
         if(this.oCurrentProcessingList.aDuplicationFrameConfigs != null)
         {
            this.oCurrentProcessingList.aFrameConfig = this.oCurrentProcessingList.aDuplicationFrameConfigs.pop();
         }
         try
         {
            this.oCurrentProcessingList.mcRef = new this.oCurrentProcessingList.oClassRef();
            this.oCurrentProcessingList.mcRef.filters = this.oCurrentProcessingList.oFilters;
         }
         catch(e:Error)
         {
            dispatchEvent(new BitmappedEvent(BitmappedEvent.ERROR,false,false,oCurrentProcessingList.oClassRef,oCurrentProcessingList.sClassVariantID,0,0,0,0,e.message));
         }
         this.oCurrentProcessingList.mcRef.gotoAndStop(1);
         this.oCurrentProcessingList.oFrameRect = DisplayObjectUtils.getMaxFrameDimension(this.oCurrentProcessingList.mcRef);
         this.oCurrentProcessingList.aFramesCoordinate = DisplayObjectUtils.getFramesDimension(this.oCurrentProcessingList.mcRef);
         this.oCurrentProcessingList.aFramesRadius = this.getRadius(this.oCurrentProcessingList.aFramesCoordinate);
         if(this.oCurrentProcessingList.nRenderScale != 1)
         {
            for(i = 0; i < this.oCurrentProcessingList.aFramesCoordinate.length; i++)
            {
               Rectangle(this.oCurrentProcessingList.aFramesCoordinate[i]).x = Rectangle(this.oCurrentProcessingList.aFramesCoordinate[i]).x * this.oCurrentProcessingList.nRenderScale;
               Rectangle(this.oCurrentProcessingList.aFramesCoordinate[i]).y = Rectangle(this.oCurrentProcessingList.aFramesCoordinate[i]).y * this.oCurrentProcessingList.nRenderScale;
               Rectangle(this.oCurrentProcessingList.aFramesCoordinate[i]).width = Rectangle(this.oCurrentProcessingList.aFramesCoordinate[i]).width * this.oCurrentProcessingList.nRenderScale;
               Rectangle(this.oCurrentProcessingList.aFramesCoordinate[i]).height = Rectangle(this.oCurrentProcessingList.aFramesCoordinate[i]).height * this.oCurrentProcessingList.nRenderScale;
               this.oCurrentProcessingList.aFramesRadius[i] *= this.oCurrentProcessingList.nRenderScale;
            }
         }
         this.oCurrentProcessingList.aFramesAngleOffset = this.getAngleOffset(this.oCurrentProcessingList.aFramesCoordinate);
         if(this.oCurrentProcessingList.bFlip)
         {
            this.oCurrentProcessingList.aFlipFramesCoordinate = new Array();
            for(i = 0; i < this.oCurrentProcessingList.aFramesCoordinate.length; i++)
            {
               this.oCurrentProcessingList.aFlipFramesCoordinate[i] = this.oCurrentProcessingList.aFramesCoordinate[i].clone();
               this.oCurrentProcessingList.aFlipFramesCoordinate[i].offset(-(this.oCurrentProcessingList.aFlipFramesCoordinate[i].width + this.oCurrentProcessingList.aFlipFramesCoordinate[i].x * 2),0);
            }
            this.oCurrentProcessingList.aFlippedFramesAngleOffset = this.oCurrentProcessingList.aFramesAngleOffset.concat();
            for(i = 0; i < this.oCurrentProcessingList.aFlippedFramesAngleOffset.length; i++)
            {
               this.oCurrentProcessingList.aFlippedFramesAngleOffset[i] = 180 - this.oCurrentProcessingList.aFlippedFramesAngleOffset[i];
            }
         }
      }
      
      private function getAngleOffset(_aFramesCoordinate:Array) : Array
      {
         var _oRect:Rectangle = null;
         var _nLength:int = int(_aFramesCoordinate.length);
         var _aAngleOffset:Array = new Array();
         for(var i:int = 0; i < _nLength; i++)
         {
            _oRect = _aFramesCoordinate[i];
            _aAngleOffset[i] = SBKMath.getAngle(0,0,_oRect.left + _oRect.width / 2,_oRect.top + _oRect.height / 2);
         }
         return _aAngleOffset;
      }
      
      private function getRadius(_aFramesCoordinate:Array) : Array
      {
         var _oRect:Rectangle = null;
         var _nLength:int = int(_aFramesCoordinate.length);
         var _aRadius:Array = new Array();
         for(var i:int = 0; i < _nLength; i++)
         {
            _oRect = _aFramesCoordinate[i];
            _aRadius[i] = SBKMath.getDistance(0,0,_oRect.left + _oRect.width / 2,_oRect.top + _oRect.height / 2);
         }
         return _aRadius;
      }
      
      private function extractFrame(_bFlip:Boolean = false) : BitmapData
      {
         var _oFrameData:BitmapData = null;
         var _oTempFrameData:BitmapData = null;
         var _oRect:Rectangle = null;
         var _nBitmapWidth:Number = NaN;
         var _nBitmapHeight:Number = NaN;
         var _oTempDisplayContainer:Sprite = new Sprite();
         _oRect = this.oCurrentProcessingList.aFramesCoordinate[this.oCurrentProcessingList.mcRef.currentFrame - 1];
         var _oMatrix:Matrix = new Matrix(1,0,0,1,-_oRect.x,-_oRect.y);
         try
         {
            _nBitmapWidth = Math.max(_oRect.width,1);
            _nBitmapHeight = Math.max(_oRect.height,1);
            _oTempDisplayContainer.addChild(this.oCurrentProcessingList.mcRef);
            if(this.oCurrentProcessingList.nRenderScale != 1)
            {
               this.oCurrentProcessingList.mcRef.scaleX = this.oCurrentProcessingList.nRenderScale;
               this.oCurrentProcessingList.mcRef.scaleY = this.oCurrentProcessingList.nRenderScale;
            }
            _oTempFrameData = new BitmapData(_nBitmapWidth,_nBitmapHeight,true,0);
            _oTempFrameData.draw(_oTempDisplayContainer,_oMatrix);
            _oFrameData = new BitmapData(_nBitmapWidth,_nBitmapHeight,true,0);
            if(_bFlip)
            {
               this.oCurrentProcessingList.oFlipMatrix.tx = _oRect.width;
               _oFrameData.draw(_oTempFrameData,this.oCurrentProcessingList.oFlipMatrix,this.oCurrentProcessingList.oColorTransform,null,null,this.oCurrentProcessingList.bSmoothing);
            }
            else
            {
               _oFrameData.draw(_oTempFrameData,this.oCurrentProcessingList.oMatrix,this.oCurrentProcessingList.oColorTransform,null,null,this.oCurrentProcessingList.bSmoothing);
            }
         }
         catch(e:Error)
         {
            dispatchEvent(new BitmappedEvent(BitmappedEvent.ERROR,false,false,oCurrentProcessingList.oClassRef,oCurrentProcessingList.sClassVariantID,0,0,0,0,e.message));
         }
         _oTempFrameData.dispose();
         return _oFrameData;
      }
      
      private function extractCollider(_bFlip:Boolean = false) : Array
      {
         var _mc:DisplayObject = null;
         var _aColliderList:Array = null;
         var _nRadius:Number = NaN;
         var _nAngle:Number = NaN;
         var _oRect:Rectangle = this.oCurrentProcessingList.aFramesCoordinate[this.oCurrentProcessingList.mcRef.currentFrame - 1];
         var _oColliderRect:Rectangle = new Rectangle();
         var _nRenderScale:Number = this.oCurrentProcessingList.nRenderScale;
         for(var i:int = 0; i < this.oCurrentProcessingList.mcRef.numChildren; i++)
         {
            _mc = this.oCurrentProcessingList.mcRef.getChildAt(i);
            if(_mc != null && _mc.name.charAt(0) == "_")
            {
               if(_aColliderList == null)
               {
                  _aColliderList = new Array();
               }
               _nRadius = SBKMath.getDistance(0,0,_mc.x + _mc.width / 2,_mc.y + _mc.height / 2);
               if(!_bFlip)
               {
                  _nAngle = SBKMath.adjustAngle(SBKMath.getAngle(0,0,_mc.x + _mc.width / 2,_mc.y + _mc.height / 2));
                  _aColliderList.push(new ColliderInfo(_mc.name.substr(1,_mc.name.length),new Rectangle(_mc.x * _nRenderScale,_mc.y * _nRenderScale,_mc.width * _nRenderScale,_mc.height * _nRenderScale),_nRadius * _nRenderScale,_nAngle));
               }
               else
               {
                  _nAngle = SBKMath.getAngle(0,0,-(_mc.x + _mc.width / 2),_mc.y + _mc.height / 2);
                  _oColliderRect.width = _mc.width * _nRenderScale;
                  _oColliderRect.height = _mc.height * _nRenderScale;
                  if(_mc.x >= 0)
                  {
                     _oColliderRect.x = -(_mc.x + _mc.width) * _nRenderScale;
                  }
                  else
                  {
                     _oColliderRect.x = (Math.abs(_mc.x) - _mc.width) * _nRenderScale;
                  }
                  _oColliderRect.y = _mc.y * _nRenderScale;
                  _aColliderList.push(new ColliderInfo(_mc.name.substr(1,_mc.name.length),_oColliderRect.clone(),_nRadius * _nRenderScale,_nAngle));
               }
               _mc.visible = false;
            }
         }
         return _aColliderList;
      }
      
      private function getByteSize(_nWidth:uint, _nHeight:uint) : uint
      {
         return _nWidth * _nHeight * 32 / 8;
      }
      
      private function doExtraction() : void
      {
         if(this.oCurrentProcessingList.bCollider)
         {
            this.aColliders = this.extractCollider();
            if(this.oCurrentProcessingList.bFlip)
            {
               this.aFlippedColliders = this.extractCollider(true);
            }
         }
         if(this.oCurrentProcessingList.aFrameConfig != null && this.oCurrentProcessingList.aFrameConfig.length > 0)
         {
            if(this.oCurrentProcessingList.aFrameConfig[this.oCurrentProcessingList.mcRef.currentFrame - 1] == this.oCurrentProcessingList.mcRef.currentFrame - 1)
            {
               this.oFrameData = this.extractFrame();
               if(this.oCurrentProcessingList.bFlip)
               {
                  this.oFlippedFrameData = this.extractFrame(true);
               }
            }
            else
            {
               if(this.oCurrentProcessingList.bFlip)
               {
                  this.sendFrameData(this.oCurrentProcessingList.sGroupID,this.oCurrentProcessingList.oClassRef,this.oCurrentProcessingList.sClassVariantID,this.aTempFlippedFrameDataList[this.oCurrentProcessingList.aFrameConfig[this.oCurrentProcessingList.mcRef.currentFrame - 1]],this.oCurrentProcessingList.aFlipFramesCoordinate[this.oCurrentProcessingList.mcRef.currentFrame - 1],this.oCurrentProcessingList.oFrameRect,this.oCurrentProcessingList.aFramesRadius[this.oCurrentProcessingList.mcRef.currentFrame - 1],this.oCurrentProcessingList.aFlippedFramesAngleOffset[this.oCurrentProcessingList.mcRef.currentFrame - 1],this.oCurrentProcessingList.mcRef.currentFrame,this.oCurrentProcessingList.mcRef.currentLabel,this.aFlippedColliders,true);
               }
               this.sendFrameData(this.oCurrentProcessingList.sGroupID,this.oCurrentProcessingList.oClassRef,this.oCurrentProcessingList.sClassVariantID,this.aTempFrameDataList[this.oCurrentProcessingList.aFrameConfig[this.oCurrentProcessingList.mcRef.currentFrame - 1]],this.oCurrentProcessingList.aFramesCoordinate[this.oCurrentProcessingList.mcRef.currentFrame - 1],this.oCurrentProcessingList.oFrameRect,this.oCurrentProcessingList.aFramesRadius[this.oCurrentProcessingList.mcRef.currentFrame - 1],this.oCurrentProcessingList.aFramesAngleOffset[this.oCurrentProcessingList.mcRef.currentFrame - 1],this.oCurrentProcessingList.mcRef.currentFrame,this.oCurrentProcessingList.mcRef.currentLabel,this.aColliders,false);
            }
         }
         else
         {
            this.oFrameData = this.extractFrame();
            if(this.oCurrentProcessingList.bFlip)
            {
               this.oFlippedFrameData = this.extractFrame(true);
            }
         }
         if(this.oFrameData != null)
         {
            this.aTempFrameDataList[this.oCurrentProcessingList.mcRef.currentFrame - 1] = this.oFrameData;
            this.sendFrameData(this.oCurrentProcessingList.sGroupID,this.oCurrentProcessingList.oClassRef,this.oCurrentProcessingList.sClassVariantID,this.oFrameData,this.oCurrentProcessingList.aFramesCoordinate[this.oCurrentProcessingList.mcRef.currentFrame - 1],this.oCurrentProcessingList.oFrameRect,this.oCurrentProcessingList.aFramesRadius[this.oCurrentProcessingList.mcRef.currentFrame - 1],this.oCurrentProcessingList.aFramesAngleOffset[this.oCurrentProcessingList.mcRef.currentFrame - 1],this.oCurrentProcessingList.mcRef.currentFrame,this.oCurrentProcessingList.mcRef.currentLabel,this.aColliders,false);
            this.oFrameData = null;
         }
         if(this.oFlippedFrameData != null)
         {
            this.aTempFlippedFrameDataList[this.oCurrentProcessingList.mcRef.currentFrame - 1] = this.oFlippedFrameData;
            this.sendFrameData(this.oCurrentProcessingList.sGroupID,this.oCurrentProcessingList.oClassRef,this.oCurrentProcessingList.sClassVariantID,this.oFlippedFrameData,this.oCurrentProcessingList.aFlipFramesCoordinate[this.oCurrentProcessingList.mcRef.currentFrame - 1],this.oCurrentProcessingList.oFrameRect,this.oCurrentProcessingList.aFramesRadius[this.oCurrentProcessingList.mcRef.currentFrame - 1],this.oCurrentProcessingList.aFlippedFramesAngleOffset[this.oCurrentProcessingList.mcRef.currentFrame - 1],this.oCurrentProcessingList.mcRef.currentFrame,this.oCurrentProcessingList.mcRef.currentLabel,this.aFlippedColliders,true);
            this.oFlippedFrameData = null;
         }
         dispatchEvent(new BitmappedEvent(BitmappedEvent.PROGRESS,false,false,this.oCurrentProcessingList.oClassRef,this.oCurrentProcessingList.sClassVariantID,this.nCurrentFrameCount,this.nTotalFrames,this.getByteSize(this.oCurrentProcessingList.mcRef.width,this.oCurrentProcessingList.mcRef.height),this.nTotalBytes));
         if(this.oCurrentProcessingList.mcRef.totalFrames > 1)
         {
            this.oCurrentProcessingList.mcRef.nextFrame();
         }
         this.aColliders = null;
         this.aFlippedColliders = null;
         if(this.nCurrentFrameCount < this.nTotalFrames)
         {
            ++this.nCurrentFrameCount;
         }
      }
      
      private function onUpdate(_oEvent:TimerEvent) : void
      {
         var _aColliders:Array = null;
         var _aFlippedColliders:Array = null;
         this.nStartTime = getTimer();
         while(getTimer() - this.nStartTime < this.nTimePerFrame && this.oCurrentProcessingList != null)
         {
            if(this.oCurrentProcessingList.mcRef.totalFrames == 1)
            {
               this.doExtraction();
               this.next();
               break;
            }
            if(this.oCurrentProcessingList.mcRef.currentFrame < this.oCurrentProcessingList.mcRef.totalFrames)
            {
               this.doExtraction();
            }
            else
            {
               this.doExtraction();
               this.next();
            }
         }
      }
      
      public function get running() : Boolean
      {
         return this.bRunning;
      }
      
      public function get progressPercentage() : int
      {
         return Math.round(this.nCurrentFrameCount / this.nTotalFrames * 100);
      }
      
      public function get isEmpty() : Boolean
      {
         return Boolean(this.aProcessList.length == 0 && this.oCurrentProcessingList == null);
      }
   }
}

import flash.display.MovieClip;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Rectangle;

class AnimInfoStruct
{
   
   public var sGroupID:String;
   
   public var aClassRefList:Array;
   
   public var aFrameDataList:Array;
   
   public var oClassRef:Class;
   
   public var oFrameRect:Rectangle;
   
   public var mcRef:MovieClip;
   
   public var sClassVariantID:String;
   
   public var nRenderScale:Number = 1;
   
   public var oMatrix:Matrix;
   
   public var oFlipMatrix:Matrix;
   
   public var oColorTransform:ColorTransform;
   
   public var oFilters:Array;
   
   public var bSmoothing:Boolean;
   
   public var aDuplicationFrameConfigs:Array;
   
   public var aFrameConfig:Array;
   
   public var bCollider:Boolean;
   
   public var aFramesCoordinate:Array;
   
   public var aFlipFramesCoordinate:Array;
   
   public var aFramesRadius:Array;
   
   public var aFramesAngleOffset:Array;
   
   public var aFlippedFramesAngleOffset:Array;
   
   public var bFlip:Boolean;
   
   public function AnimInfoStruct()
   {
      super();
   }
   
   public function destroy() : void
   {
      if(this.aClassRefList != null)
      {
         this.aClassRefList.splice(0,this.aClassRefList.length);
         this.aClassRefList = null;
      }
      if(this.aFrameDataList != null)
      {
         this.aFrameDataList.splice(0,this.aFrameDataList.length);
         this.aFrameDataList = null;
      }
      this.oClassRef = null;
      this.oMatrix = null;
      this.oColorTransform = null;
      if(this.aDuplicationFrameConfigs != null)
      {
         this.aDuplicationFrameConfigs.splice(0,this.aDuplicationFrameConfigs.length);
         this.aDuplicationFrameConfigs = null;
      }
      if(this.aFrameConfig != null)
      {
         this.aFrameConfig.splice(0,this.aFrameConfig.length);
         this.aFrameConfig = null;
      }
      if(this.aFramesCoordinate != null)
      {
         this.aFramesCoordinate.splice(0,this.aFramesCoordinate.length);
         this.aFramesCoordinate = null;
      }
      if(this.aFlipFramesCoordinate != null)
      {
         this.aFlipFramesCoordinate.splice(0,this.aFlipFramesCoordinate.length);
         this.aFlipFramesCoordinate = null;
      }
      if(this.aFramesRadius != null)
      {
         this.aFramesRadius.splice(0,this.aFramesRadius.length);
         this.aFramesRadius = null;
      }
      if(this.oFilters != null)
      {
         this.oFilters.splice(0,this.oFilters.length);
         this.oFilters = null;
      }
      if(this.aFramesAngleOffset != null)
      {
         this.aFramesAngleOffset.splice(0,this.aFramesAngleOffset.length);
         this.aFramesAngleOffset = null;
      }
      if(this.aFlippedFramesAngleOffset != null)
      {
         this.aFlippedFramesAngleOffset.splice(0,this.aFlippedFramesAngleOffset.length);
         this.aFlippedFramesAngleOffset = null;
      }
   }
}
