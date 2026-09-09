package com.sarbakan.sbdk.blitting.core
{
   import com.sarbakan.sbdk.core.UpdateManager;
   import com.sarbakan.sbdk.events.UpdateEvent;
   import com.sarbakan.sbdk.math.SBKMath;
   import com.sarbakan.sbdk.utils.FrameTimer;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Timer;
   
   [Event(name="HIDE",type="flash.events.Event")]
   [Event(name="SHOW",type="flash.events.Event")]
   [Event(name="ENTER_FRAME",type="flash.events.Event")]
   public class BitmappedAnimation extends AbstractBitmappedAnimation implements IBitmappedAnimation
   {
      
      private static const sTIMER_EVENT:String = "TIMER_EVENT";
      
      private static const sUPDATE_EVENT:String = "UPDATE_EVENT";
      
      private static const nBOUNDING_COLOR:uint = 4294901760;
      
      private var sVariant:String;
      
      private var aFrameStructure:Array;
      
      private var aFlippedFrameStructure:Array;
      
      private var aTransFrameList:Array;
      
      private var aTransFlippedFrameList:Array;
      
      private var bPausable:Boolean;
      
      private var bColliders:Boolean;
      
      private var nFrameRate:int;
      
      private var nCurrentFrame:uint;
      
      private var oAnimationMode:BitmappedAnimationMode;
      
      private var oFrameTimer:FrameTimer;
      
      private var oTimer:Timer;
      
      private var bOverridenFrameRate:Boolean;
      
      private var oTransformedData:BitmapData;
      
      private var oID:BitmappedObjID;
      
      private var oClipRect:Rectangle;
      
      private var sBlendMode:String;
      
      private var bCacheTransform:Boolean;
      
      private var bCheckForFilters:Boolean;
      
      private var bRunning:Boolean;
      
      public function BitmappedAnimation(_oClassRef:Class, _sVariantID:String = null, _bPausable:Boolean = true, _nFrameRate:int = -1, _bCacheTransform:Boolean = false)
      {
         super();
         oClassRef = _oClassRef;
         this.sVariant = _sVariantID;
         this.bPausable = _bPausable;
         this.nFrameRate = _nFrameRate;
         this.bCacheTransform = _bCacheTransform;
         this.init();
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.cleanTransformedData();
         this.aTransFrameList = null;
         this.aTransFlippedFrameList = null;
         if(this.aFrameStructure != null)
         {
            this.aFrameStructure.splice(0,this.aFrameStructure.length);
            this.aFrameStructure = null;
         }
         if(this.aFlippedFrameStructure != null)
         {
            this.aFlippedFrameStructure.splice(0,this.aFlippedFrameStructure.length);
            this.aFlippedFrameStructure = null;
         }
         aTransformList = null;
         if(this.oFrameTimer != null)
         {
            this.oFrameTimer.stop();
            this.oFrameTimer = null;
         }
         if(this.oTimer != null)
         {
            this.oTimer.stop();
            this.oTimer = null;
         }
         oFrameData = null;
         if(this.oTransformedData != null)
         {
            this.oTransformedData.dispose();
         }
         this.oTransformedData = null;
         oColorTransform = null;
         oScaleMatrix = null;
         oTransformMatrix = null;
      }
      
      override public function gotoAndStop(_oFrameOrLabel:Object) : void
      {
         var _nListIndex:int = 0;
         if(UpdateManager.instance.paused && this.bPausable)
         {
            return;
         }
         if(this.bOverridenFrameRate)
         {
            if(this.oTimer.running)
            {
               this.oTimer.stop();
            }
         }
         else if(this.oFrameTimer.running)
         {
            this.oFrameTimer.stop();
         }
         if(_oFrameOrLabel is int)
         {
            if(_oFrameOrLabel > 0 && _oFrameOrLabel <= this.aFrameStructure.length)
            {
               this.nCurrentFrame = _oFrameOrLabel as uint;
            }
         }
         else if(_oFrameOrLabel is String)
         {
            _nListIndex = this.findFrameLabel(String(_oFrameOrLabel));
            if(_nListIndex != -1)
            {
               this.nCurrentFrame = _nListIndex;
            }
         }
         oFrameData = this.aFrameStructure[this.nCurrentFrame - 1].frameData;
         this.bRunning = false;
      }
      
      override public function gotoAndPlay(_oFrameOrLabel:Object) : void
      {
         var _nListIndex:int = 0;
         if(UpdateManager.instance.paused && this.bPausable)
         {
            return;
         }
         if(_oFrameOrLabel is int)
         {
            if(_oFrameOrLabel > 0 && _oFrameOrLabel <= this.aFrameStructure.length)
            {
               this.nCurrentFrame = _oFrameOrLabel as uint;
            }
         }
         else if(_oFrameOrLabel is String)
         {
            _nListIndex = this.findFrameLabel(String(_oFrameOrLabel));
            if(_nListIndex != -1)
            {
               this.nCurrentFrame = _nListIndex;
            }
         }
         if(this.bOverridenFrameRate)
         {
            if(!this.oTimer.running)
            {
               this.oTimer.start();
            }
         }
         else if(!this.oFrameTimer.running)
         {
            this.oFrameTimer.start();
         }
         this.bRunning = true;
      }
      
      override public function nextFrame() : void
      {
         if(UpdateManager.instance.paused && this.bPausable)
         {
            return;
         }
         if(this.nCurrentFrame < this.aFrameStructure.length)
         {
            ++this.nCurrentFrame;
         }
         else
         {
            this.nCurrentFrame = 1;
         }
         this.updateCurrentFrame();
      }
      
      override public function prevFrame() : void
      {
         if(UpdateManager.instance.paused && this.bPausable)
         {
            return;
         }
         if(this.nCurrentFrame > 1)
         {
            --this.nCurrentFrame;
         }
         else
         {
            this.nCurrentFrame = this.aFrameStructure.length;
         }
         this.updateCurrentFrame();
      }
      
      override public function play() : void
      {
         this.bRunning = true;
         if(UpdateManager.instance.paused && this.bPausable)
         {
            return;
         }
         if(this.bOverridenFrameRate)
         {
            if(!this.oTimer.running)
            {
               this.oTimer.start();
            }
         }
         else if(!this.oFrameTimer.running)
         {
            this.oFrameTimer.start();
         }
      }
      
      override public function stop() : void
      {
         if(this.bOverridenFrameRate)
         {
            if(this.oTimer.running)
            {
               this.oTimer.stop();
            }
         }
         else if(this.oFrameTimer.running)
         {
            this.oFrameTimer.stop();
         }
         this.bRunning = false;
      }
      
      override public function hitTestObject(_oBmpAnimRef:IBitmappedAnimation, _bPixelPerfect:Boolean = true) : Boolean
      {
         return this.rect.intersects(_oBmpAnimRef.rect);
      }
      
      override public function hitTestPoint(_nX:int, _nY:int, _bPixelPerfect:Boolean = true) : Boolean
      {
         return this.rect.contains(_nX,_nY);
      }
      
      override public function hitTestMovieClip(_mcRef:DisplayObject, _bPixelPerfect:Boolean = true) : Boolean
      {
         return this.rect.intersects(new Rectangle(_mcRef.x,_mcRef.y,_mcRef.width,_mcRef.height));
      }
      
      override public function hitTestRect(_oRect:Rectangle, _bPixelPerfect:Boolean = true) : Boolean
      {
         return this.rect.intersects(_oRect);
      }
      
      override public function getColliderByName(_sName:String, _bGlobal:Boolean = false) : ColliderInfo
      {
         var _oCollider:ColliderInfo = null;
         var i:int = 0;
         if(this.colliders != null)
         {
            while(i < this.colliders.length)
            {
               if(this.colliders[i].name == _sName)
               {
                  _oCollider = this.colliders[i].clone();
                  if(_bGlobal)
                  {
                     _oCollider.rect.x += this.x;
                     _oCollider.rect.y += this.y;
                  }
                  return _oCollider;
               }
               i++;
            }
         }
         return null;
      }
      
      override protected function init() : void
      {
         var _aTempArray:Array = null;
         var i:int = 0;
         super.init();
         this.oID = new BitmappedObjID(String(oClassRef),this.sVariant);
         this.oAnimationMode = BitmappedAnimationMode.FRAME_BASE;
         this.nCurrentFrame = 1;
         bFlip = false;
         bVisible = true;
         bMoving = false;
         bMouseEnabled = false;
         bMouseOver = false;
         nOrigine_X = 0;
         nOrigine_Y = 0;
         nScaleX = 1;
         nScaleY = 1;
         nRotation = 0;
         nAlpha = 1;
         this.bCheckForFilters = false;
         oScaleMatrix = new Matrix();
         oRotateMatrix = new Matrix();
         bTransformed = false;
         this.bRunning = false;
         this.frameRate = this.nFrameRate;
         oEventManager.addEventListener(sUPDATE_EVENT,UpdateManager.instance,UpdateEvent.PAUSE,this.onUpdatePause);
         oEventManager.addEventListener(sUPDATE_EVENT,UpdateManager.instance,UpdateEvent.RESUME,this.onUpdateResume);
         aTransformList[sSMOOTHING] = false;
         aTransformList[sSCALE] = false;
         aTransformList[sREDRAW_REGION] = false;
         aTransformList[sROTATION] = false;
         aTransformList[sALPHA] = false;
         aTransformList[sCOLOR_TRANSFORM] = false;
         aTransformList[sBLEND_MODE] = false;
         aTransformList[sSHOW_COLLIDER] = false;
         this.aFrameStructure = new Array();
         _aTempArray = BitmapDataCollection.instance.requestCollection(oClassRef,this.sVariant);
         if(_aTempArray != null)
         {
            this.aFrameStructure = new Array();
            for(i = 0; i < _aTempArray.length; i++)
            {
               this.aFrameStructure[i] = _aTempArray[i].clone();
            }
            this.bColliders = BitmapDataCollection.instance.colliderExist(oClassRef,this.sVariant);
         }
         _aTempArray = BitmapDataCollection.instance.requestCollection(oClassRef,this.sVariant,true);
         if(_aTempArray != null)
         {
            this.aFlippedFrameStructure = new Array();
            for(i = 0; i < _aTempArray.length; i++)
            {
               this.aFlippedFrameStructure[i] = _aTempArray[i].clone();
            }
         }
         if(this.aFrameStructure != null)
         {
            nWidth = this.aFrameStructure[0].frameWidth;
            nHeight = this.aFrameStructure[0].frameHeight;
            this.aTransFrameList = new Array();
            this.aTransFlippedFrameList = new Array();
         }
      }
      
      private function updateCurrentFrame() : void
      {
         if(!this.bRunning)
         {
            return;
         }
         ++this.nCurrentFrame;
         if(this.nCurrentFrame > this.totalFrames)
         {
            if(bLooping)
            {
               this.nCurrentFrame = 1;
            }
            else
            {
               this.nCurrentFrame = this.aFrameStructure.length;
            }
         }
      }
      
      private function findFrameLabel(_sLabel:String) : int
      {
         for(var i:int = 0; i < this.aFrameStructure.length; i++)
         {
            if(this.aFrameStructure[i].label == _sLabel)
            {
               return i;
            }
         }
         return -1;
      }
      
      private function applyTransformation() : BitmapData
      {
         var _oFrameInfo:FrameInfoStruct = null;
         var i:int = 0;
         if(!bFlip)
         {
            _oFrameInfo = this.aFrameStructure[this.nCurrentFrame - 1];
         }
         else
         {
            _oFrameInfo = this.aFlippedFrameStructure[this.nCurrentFrame - 1];
         }
         var _oNewDimension:Rectangle = _oFrameInfo.initRect.clone();
         _oNewDimension.width = _oFrameInfo.initRect.width * Math.abs(nScaleX);
         _oNewDimension.height = _oFrameInfo.initRect.height * Math.abs(nScaleY);
         _oFrameInfo.rect.width = _oFrameInfo.initRect.width * Math.abs(nScaleX);
         if(nScaleX < 0)
         {
            oScaleMatrix.tx = _oNewDimension.width;
            _oFrameInfo.rect.x = _oFrameInfo.initRect.right * nScaleX;
         }
         else
         {
            _oFrameInfo.rect.x = _oFrameInfo.initRect.x * nScaleX;
         }
         _oFrameInfo.rect.height = _oFrameInfo.initRect.height * Math.abs(nScaleY);
         if(nScaleY < 0)
         {
            oScaleMatrix.ty = _oNewDimension.height;
            _oFrameInfo.rect.y = _oFrameInfo.initRect.bottom * nScaleY;
         }
         else
         {
            _oFrameInfo.rect.y = _oFrameInfo.initRect.y * nScaleY;
         }
         _oFrameInfo.radius = SBKMath.getDistance(0,0,_oFrameInfo.rect.left + _oNewDimension.width / 2,_oFrameInfo.rect.top + _oNewDimension.height / 2);
         _oFrameInfo.angleOffset = SBKMath.getAngle(0,0,_oFrameInfo.rect.left + _oNewDimension.width / 2,_oFrameInfo.rect.top + _oNewDimension.height / 2);
         oRotateMatrix.identity();
         oRotateMatrix.translate(-(_oNewDimension.width / 2),-(_oNewDimension.height / 2));
         _oNewDimension = SBKMath.getDimensionAfterRotation(SBKMath.degToRad(nRotation),_oNewDimension.width,_oNewDimension.height);
         oRotateMatrix.rotate(SBKMath.degToRad(nRotation));
         oRotateMatrix.translate(_oNewDimension.width / 2,_oNewDimension.height / 2);
         var _nLastWidth:Number = _oFrameInfo.rect.width;
         var _nLastHeight:Number = _oFrameInfo.rect.height;
         _oFrameInfo.rect.width = _oNewDimension.width;
         _oFrameInfo.rect.height = _oNewDimension.height;
         if(_oFrameInfo.radius > 0)
         {
            _oFrameInfo.rect.x = Math.cos(SBKMath.degToRad(nRotation + _oFrameInfo.angleOffset)) * _oFrameInfo.radius - _oFrameInfo.rect.width / 2;
            _oFrameInfo.rect.y = Math.sin(SBKMath.degToRad(nRotation + _oFrameInfo.angleOffset)) * _oFrameInfo.radius - _oFrameInfo.rect.height / 2;
         }
         else
         {
            _oFrameInfo.rect.x += (_nLastWidth - _oFrameInfo.rect.width) / 2;
            _oFrameInfo.rect.y += (_nLastHeight - _oFrameInfo.rect.height) / 2;
         }
         oTransformMatrix = oScaleMatrix.clone();
         oTransformMatrix.concat(oRotateMatrix);
         this.oTransformedData = new BitmapData(_oNewDimension.width,_oNewDimension.height,true,0);
         this.oTransformedData.draw(_oFrameInfo.frameData,oTransformMatrix,oColorTransform,null,null,aTransformList[sSMOOTHING]);
         if(this.bColliders)
         {
            this.transformColliders();
            if(Boolean(aTransformList[sSHOW_COLLIDER]))
            {
               this.displayColliders(this.oTransformedData);
            }
         }
         if(Boolean(aTransformList[sREDRAW_REGION]))
         {
            this.displayRedrawRegion(this.oTransformedData);
         }
         if(Boolean(aTransformList[sFILTERS]))
         {
            for(i = 0; i < aFilters.length; i++)
            {
               this.oTransformedData.applyFilter(this.oTransformedData,this.oTransformedData.rect,new Point(0,0),aFilters[i]);
            }
         }
         if(this.bCacheTransform)
         {
            this.cachedTransFrame(this.nCurrentFrame,this.oTransformedData.clone());
         }
         return this.oTransformedData;
      }
      
      private function resetFrameCoordinates() : void
      {
         for(var i:int = 0; i < this.aFrameStructure.length; i++)
         {
            this.aFrameStructure[i].rect.x = this.aFrameStructure[i].initRect.x;
            this.aFrameStructure[i].rect.width = this.aFrameStructure[i].initRect.width;
            this.aFrameStructure[i].rect.y = this.aFrameStructure[i].initRect.y;
            this.aFrameStructure[i].rect.height = this.aFrameStructure[i].initRect.height;
            this.aFrameStructure[i].radius = this.aFrameStructure[i].initRadius;
            this.aFrameStructure[i].angleOffset = this.aFrameStructure[i].initAngleOffset;
            if(this.aFlippedFrameStructure != null)
            {
               this.aFlippedFrameStructure[i].rect.x = this.aFlippedFrameStructure[i].initRect.x;
               this.aFlippedFrameStructure[i].rect.width = this.aFlippedFrameStructure[i].initRect.width;
               this.aFlippedFrameStructure[i].rect.y = this.aFlippedFrameStructure[i].initRect.y;
               this.aFlippedFrameStructure[i].rect.height = this.aFlippedFrameStructure[i].initRect.height;
               this.aFlippedFrameStructure[i].radius = this.aFlippedFrameStructure[i].initRadius;
               this.aFlippedFrameStructure[i].angleOffset = this.aFlippedFrameStructure[i].initAngleOffset;
            }
         }
      }
      
      private function cleanTransformedData() : void
      {
         var i:int = 0;
         if(this.aTransFrameList != null)
         {
            for(i = 0; i < this.aTransFrameList.length; i++)
            {
               if(this.aTransFrameList[i] != null)
               {
                  this.aTransFrameList[i].dispose();
               }
            }
            this.aTransFrameList.splice(0,this.aTransFrameList.length);
         }
         if(this.aTransFlippedFrameList != null)
         {
            for(i = 0; i < this.aTransFlippedFrameList.length; i++)
            {
               if(this.aTransFlippedFrameList[i] != null)
               {
                  this.aTransFlippedFrameList[i].dispose();
               }
            }
            this.aTransFlippedFrameList.splice(0,this.aTransFlippedFrameList.length);
         }
      }
      
      private function checkIfTransformed() : void
      {
         var i:Boolean = false;
         bTransformed = false;
         for each(i in aTransformList)
         {
            if(i)
            {
               bTransformed = i;
               break;
            }
         }
         if(!bTransformed)
         {
            this.resetFrameCoordinates();
         }
         this.cleanTransformedData();
      }
      
      private function displayRedrawRegion(_oFrameData:BitmapData) : void
      {
         for(var i:int = 0; i < _oFrameData.width; i++)
         {
            _oFrameData.setPixel32(i,0,nBOUNDING_COLOR);
         }
         for(i = 0; i < _oFrameData.height; i++)
         {
            _oFrameData.setPixel32(_oFrameData.width - 1,i,nBOUNDING_COLOR);
         }
         for(i = 0; i < _oFrameData.height; i++)
         {
            _oFrameData.setPixel32(0,i,nBOUNDING_COLOR);
         }
         for(i = 0; i < _oFrameData.width; i++)
         {
            _oFrameData.setPixel32(i,_oFrameData.height - 1,nBOUNDING_COLOR);
         }
      }
      
      private function displayColliders(_oFrameData:BitmapData) : void
      {
         var _aColliders:Array = null;
         var _oRect:Rectangle = null;
         var _oColliderData:BitmapData = null;
         var _oFrameInfo:FrameInfoStruct = null;
         var i:int = 0;
         if(!bFlip)
         {
            _oFrameInfo = this.aFrameStructure[this.nCurrentFrame - 1];
            _aColliders = _oFrameInfo.colliders;
         }
         else
         {
            _oFrameInfo = this.aFlippedFrameStructure[this.nCurrentFrame - 1];
            _aColliders = _oFrameInfo.colliders;
         }
         if(_aColliders != null)
         {
            for(i = 0; i < _aColliders.length; i++)
            {
               _oRect = _aColliders[i].rect.clone();
               if(bFlip || nScaleX < 0)
               {
                  _oRect.x = Math.abs(_oFrameInfo.rect.left - _oRect.left);
               }
               else
               {
                  _oRect.x -= _oFrameInfo.rect.left;
               }
               if(nScaleY < 0)
               {
                  _oRect.y = Math.abs(_oFrameInfo.rect.top - _oRect.top);
               }
               else
               {
                  _oRect.y -= _oFrameInfo.rect.top;
               }
               _oColliderData = new BitmapData(_oRect.width,_oRect.height,false,65280);
               _oFrameData.copyPixels(_oColliderData,_oColliderData.rect,new Point(_oRect.left,_oRect.top));
            }
         }
      }
      
      private function resetColliderTransform() : void
      {
         var j:int = 0;
         for(var i:int = 0; i < this.aFrameStructure.length; i++)
         {
            for(j = 0; j < this.aFrameStructure[i].colliders.length; j++)
            {
               this.aFrameStructure[i].colliders[j].reset();
               if(this.aFlippedFrameStructure != null)
               {
                  this.aFlippedFrameStructure[i].colliders[j].reset();
               }
            }
         }
      }
      
      private function transformColliders() : void
      {
         var _oCollider:ColliderInfo = null;
         var i:int = 0;
         this.resetColliderTransform();
         for(i = 0; i < this.aFrameStructure[this.nCurrentFrame - 1].colliders.length; i++)
         {
            _oCollider = this.aFrameStructure[this.nCurrentFrame - 1].colliders[i];
            if(nScaleX != 1)
            {
               if(nScaleX > 0)
               {
                  _oCollider.rect.x *= nScaleX;
                  _oCollider.rect.width *= nScaleX;
               }
               else
               {
                  _oCollider.rect.x = -(_oCollider.rect.left + _oCollider.rect.width) * Math.abs(nScaleX);
                  _oCollider.rect.width *= Math.abs(nScaleX);
               }
            }
            if(nScaleY != 1)
            {
               if(nScaleY > 0)
               {
                  _oCollider.rect.y *= nScaleY;
                  _oCollider.rect.height *= nScaleY;
               }
               else
               {
                  _oCollider.rect.y = -(_oCollider.rect.top + _oCollider.rect.height) * Math.abs(nScaleY);
                  _oCollider.rect.height *= Math.abs(nScaleY);
               }
            }
            if(nScaleX != 1 || nScaleY != 1)
            {
               _oCollider.radius = SBKMath.getDistance(0,0,_oCollider.rect.x + _oCollider.rect.width / 2,_oCollider.rect.y + _oCollider.rect.height / 2);
               _oCollider.angle = SBKMath.getAngle(0,0,_oCollider.rect.x + _oCollider.rect.width / 2,_oCollider.rect.y + _oCollider.rect.height / 2);
            }
         }
         if(this.aFlippedFrameStructure != null)
         {
            for(i = 0; i < this.aFlippedFrameStructure[this.nCurrentFrame - 1].colliders.length; i++)
            {
               _oCollider = this.aFlippedFrameStructure[this.nCurrentFrame - 1].colliders[i];
               if(nScaleX != 1)
               {
                  if(nScaleX > 0)
                  {
                     _oCollider.rect.x *= nScaleX;
                     _oCollider.rect.width *= nScaleX;
                  }
                  else
                  {
                     _oCollider.rect.x = (Math.abs(_oCollider.rect.left) - _oCollider.rect.width) * Math.abs(nScaleX);
                     _oCollider.rect.width *= Math.abs(nScaleX);
                  }
               }
               if(nScaleY != 1)
               {
                  if(nScaleY > 0)
                  {
                     _oCollider.rect.y *= nScaleY;
                     _oCollider.rect.height *= nScaleY;
                  }
                  else
                  {
                     _oCollider.rect.y = -(Math.abs(_oCollider.rect.top) + _oCollider.rect.height) * Math.abs(nScaleY);
                     _oCollider.rect.height *= Math.abs(nScaleY);
                  }
               }
               if(nScaleX != 1 || nScaleY != 1)
               {
                  _oCollider.radius = SBKMath.getDistance(0,0,_oCollider.rect.x + _oCollider.rect.width / 2,_oCollider.rect.y + _oCollider.rect.height / 2);
                  _oCollider.angle = SBKMath.getAngle(0,0,_oCollider.rect.x + _oCollider.rect.width / 2,_oCollider.rect.y + _oCollider.rect.height / 2);
               }
            }
         }
         if(nRotation != 0)
         {
            for(i = 0; i < this.aFrameStructure[this.nCurrentFrame - 1].colliders.length; i++)
            {
               _oCollider = this.aFrameStructure[this.nCurrentFrame - 1].colliders[i];
               _oCollider.angle += nRotation;
               _oCollider.angle = SBKMath.adjustAngle(_oCollider.angle);
               _oCollider.rect.x = Math.cos(SBKMath.degToRad(_oCollider.angle)) * _oCollider.radius - _oCollider.rect.width / 2;
               _oCollider.rect.y = Math.sin(SBKMath.degToRad(_oCollider.angle)) * _oCollider.radius - _oCollider.rect.height / 2;
            }
            if(this.aFlippedFrameStructure != null)
            {
               for(i = 0; i < this.aFlippedFrameStructure[this.nCurrentFrame - 1].colliders.length; i++)
               {
                  _oCollider = this.aFlippedFrameStructure[this.nCurrentFrame - 1].colliders[i];
                  _oCollider.angle += nRotation;
                  _oCollider.angle = SBKMath.adjustAngle(_oCollider.angle);
                  _oCollider.rect.x = Math.cos(SBKMath.degToRad(_oCollider.angle)) * _oCollider.radius - _oCollider.rect.width / 2;
                  _oCollider.rect.y = Math.sin(SBKMath.degToRad(_oCollider.angle)) * _oCollider.radius - _oCollider.rect.height / 2;
               }
            }
         }
      }
      
      private function checkForFilters() : void
      {
         if(aFilters.length > 0)
         {
            aTransformList[sFILTERS] = true;
         }
         else
         {
            aTransformList[sFILTERS] = false;
         }
         this.checkIfTransformed();
      }
      
      private function isTransFrameExist(_iFrame:int) : Boolean
      {
         if(flip)
         {
            return this.aTransFlippedFrameList[_iFrame] != null;
         }
         return this.aTransFrameList[_iFrame] != null;
      }
      
      private function cachedTransFrame(_iFrame:int, _oBitmapData:BitmapData) : void
      {
         if(flip)
         {
            this.aTransFlippedFrameList[_iFrame] = _oBitmapData;
         }
         else
         {
            this.aTransFrameList[_iFrame] = _oBitmapData;
         }
      }
      
      private function getTransFrame(_iFrame:int) : BitmapData
      {
         if(flip)
         {
            return this.aTransFlippedFrameList[_iFrame];
         }
         return this.aTransFrameList[_iFrame];
      }
      
      private function update(_oEvent:TimerEvent) : void
      {
         this.updateCurrentFrame();
      }
      
      private function onUpdatePause(_oEvent:UpdateEvent) : void
      {
         if(this.bPausable)
         {
            if(this.nFrameRate == -1)
            {
               this.oFrameTimer.stop();
            }
            else if(this.nFrameRate > 0)
            {
               this.oTimer.stop();
            }
            bPaused = true;
         }
      }
      
      private function onUpdateResume(_oEvent:UpdateEvent) : void
      {
         if(this.bPausable)
         {
            if(this.bRunning)
            {
               if(this.nFrameRate == -1)
               {
                  this.oFrameTimer.start();
               }
               else if(this.nFrameRate > 0)
               {
                  this.oTimer.start();
               }
            }
            bPaused = false;
         }
      }
      
      override public function get ID() : BitmappedObjID
      {
         return this.oID;
      }
      
      override public function get currentFrame() : uint
      {
         return this.nCurrentFrame;
      }
      
      override public function get colliders() : Array
      {
         if(!bFlip)
         {
            return this.aFrameStructure[this.nCurrentFrame - 1].colliders;
         }
         return this.aFlippedFrameStructure[this.nCurrentFrame - 1].colliders;
      }
      
      override public function set flip(_bValue:Boolean) : void
      {
         if(this.aFlippedFrameStructure != null)
         {
            super.flip = _bValue;
            if(oSpatialIndexHandler != null)
            {
               oSpatialIndexHandler.setPositionRectangle(this.rect);
            }
         }
      }
      
      override public function get totalFrames() : uint
      {
         if(this.aFrameStructure != null)
         {
            return this.aFrameStructure.length;
         }
         return 0;
      }
      
      override public function get smoothing() : Boolean
      {
         return aTransformList[sSMOOTHING];
      }
      
      override public function set smoothing(_bValue:Boolean) : void
      {
         aTransformList[sSMOOTHING] = _bValue;
         this.checkIfTransformed();
      }
      
      override public function set visible(_bValue:Boolean) : void
      {
         super.visible = _bValue;
      }
      
      override public function get showRedrawRegion() : Boolean
      {
         return aTransformList[sREDRAW_REGION];
      }
      
      override public function set showRedrawRegion(_bValue:Boolean) : void
      {
         aTransformList[sREDRAW_REGION] = _bValue;
         this.checkIfTransformed();
      }
      
      override public function get showColliders() : Boolean
      {
         return aTransformList[sSHOW_COLLIDER];
      }
      
      override public function set showColliders(_bValue:Boolean) : void
      {
         if(this.bColliders)
         {
            aTransformList[sSHOW_COLLIDER] = _bValue;
            this.checkIfTransformed();
         }
      }
      
      override public function get frameRate() : int
      {
         return this.nFrameRate;
      }
      
      override public function set frameRate(_nValue:int) : void
      {
         var _bPlaying:Boolean = false;
         this.nFrameRate = _nValue;
         if(this.nFrameRate == -1)
         {
            if(this.oTimer != null)
            {
               oEventManager.cleanUp(sTIMER_EVENT);
               this.oTimer = null;
            }
            if(this.oFrameTimer == null)
            {
               this.oFrameTimer = new FrameTimer(1,0,this.bPausable);
               oEventManager.addEventListener(sTIMER_EVENT,this.oFrameTimer,TimerEvent.TIMER,this.update);
            }
            this.bOverridenFrameRate = false;
         }
         else if(this.nFrameRate > 0)
         {
            _bPlaying = false;
            if(this.oFrameTimer != null)
            {
               oEventManager.cleanUp(sTIMER_EVENT);
               _bPlaying = this.oFrameTimer.running;
               this.oFrameTimer.destroy();
               this.oFrameTimer = null;
            }
            if(this.oTimer == null)
            {
               this.oTimer = new Timer(1000 / this.nFrameRate);
               if(_bPlaying)
               {
                  this.oTimer.start();
               }
               oEventManager.addEventListener(sTIMER_EVENT,this.oTimer,TimerEvent.TIMER,this.update);
            }
            else
            {
               this.oTimer.delay = 1000 / this.nFrameRate;
            }
            this.bOverridenFrameRate = true;
         }
      }
      
      override public function get rect() : Rectangle
      {
         var _oRect:Rectangle = new Rectangle();
         if(!bFlip)
         {
            if(this.aFrameStructure != null)
            {
               _oRect = this.aFrameStructure[this.nCurrentFrame - 1].rect.clone();
            }
         }
         else if(this.aFlippedFrameStructure != null)
         {
            _oRect = this.aFlippedFrameStructure[this.nCurrentFrame - 1].rect.clone();
         }
         if(_oRect != null)
         {
            if(_oRect.left < 0 && _oRect.right <= 0)
            {
               _oRect.left = nOrigine_X + _oRect.left;
               _oRect.right = nOrigine_X;
            }
            else if(_oRect.left < 0 && _oRect.right > 0)
            {
               _oRect.left = nOrigine_X + _oRect.left;
               _oRect.right = nOrigine_X + _oRect.right;
            }
            else if(_oRect.left >= 0)
            {
               _oRect.left = nOrigine_X;
               _oRect.right = nOrigine_X + _oRect.right;
            }
            if(_oRect.top < 0 && _oRect.bottom <= 0)
            {
               _oRect.top = nOrigine_Y + _oRect.top;
               _oRect.bottom = nOrigine_Y;
            }
            else if(_oRect.top < 0 && _oRect.bottom > 0)
            {
               _oRect.top = nOrigine_Y + _oRect.top;
               _oRect.bottom = nOrigine_Y + _oRect.bottom;
            }
            else if(_oRect.top >= 0)
            {
               _oRect.top = nOrigine_Y;
               _oRect.bottom = nOrigine_Y + _oRect.bottom;
            }
         }
         return _oRect;
      }
      
      override public function get frameRect() : Rectangle
      {
         if(!bFlip)
         {
            if(this.aFrameStructure[this.nCurrentFrame - 1] != null)
            {
               return this.aFrameStructure[this.nCurrentFrame - 1].rect;
            }
         }
         else if(this.aFlippedFrameStructure[this.nCurrentFrame - 1] != null)
         {
            return this.aFlippedFrameStructure[this.nCurrentFrame - 1].rect;
         }
         return null;
      }
      
      override public function get x() : Number
      {
         return nOrigine_X;
      }
      
      override public function set x(_nValue:Number) : void
      {
         if(bPixelSnapping)
         {
            nOrigine_X = Math.ceil(_nValue);
         }
         else
         {
            nOrigine_X = _nValue;
         }
         if(oSpatialIndexHandler != null)
         {
            oSpatialIndexHandler.setPositionRectangle(this.rect);
         }
      }
      
      override public function get y() : Number
      {
         return nOrigine_Y;
      }
      
      override public function set y(_nValue:Number) : void
      {
         if(bPixelSnapping)
         {
            nOrigine_Y = Math.ceil(_nValue);
         }
         else
         {
            nOrigine_Y = _nValue;
         }
         if(oSpatialIndexHandler != null)
         {
            oSpatialIndexHandler.setPositionRectangle(this.rect);
         }
      }
      
      override public function get width() : uint
      {
         if(this.rect != null)
         {
            return this.rect.width;
         }
         return 0;
      }
      
      override public function set width(_nValue:uint) : void
      {
         if(nWidth != _nValue && _nValue > 0)
         {
            this.scaleX = _nValue / this.rect.width;
            aTransformList[sSCALE] = true;
         }
         else
         {
            this.scaleX = 1;
            aTransformList[sSCALE] = false;
         }
         this.checkIfTransformed();
      }
      
      override public function get height() : uint
      {
         if(this.rect != null)
         {
            return this.rect.height;
         }
         return 0;
      }
      
      override public function set height(_nValue:uint) : void
      {
         if(nHeight != _nValue && _nValue > 0)
         {
            this.scaleY = _nValue / this.rect.height;
            aTransformList[sSCALE] = true;
         }
         else
         {
            this.scaleY = 1;
            aTransformList[sSCALE] = false;
         }
         this.checkIfTransformed();
      }
      
      public function get clipRect() : Rectangle
      {
         return this.oClipRect;
      }
      
      public function set clipRect(_oValue:Rectangle) : void
      {
         this.oClipRect = _oValue;
         if(this.oClipRect != null)
         {
            aTransformList[sCLIP_RECT] = true;
         }
         else
         {
            aTransformList[sCLIP_RECT] = false;
         }
         this.checkIfTransformed();
      }
      
      override public function get looping() : Boolean
      {
         return super.looping;
      }
      
      override public function set looping(_bValue:Boolean) : void
      {
         super.looping = _bValue;
      }
      
      override public function set rotation(_nValue:Number) : void
      {
         nRotation = SBKMath.adjustAngle(_nValue);
         if(nRotation != 0)
         {
            aTransformList[sROTATION] = true;
         }
         else
         {
            aTransformList[sROTATION] = false;
         }
         this.checkIfTransformed();
      }
      
      override public function set alpha(_nValue:Number) : void
      {
         nAlpha = _nValue;
         if(_nValue == 1)
         {
            if(oColorTransform != null && oColorTransform.alphaOffset == 0 && oColorTransform.blueMultiplier == 1 && oColorTransform.blueOffset == 0 && oColorTransform.greenMultiplier == 1 && oColorTransform.greenOffset == 0 && oColorTransform.redMultiplier == 1 && oColorTransform.redOffset == 0)
            {
               oColorTransform = null;
               aTransformList[sALPHA] = false;
            }
         }
         else
         {
            if(oColorTransform == null)
            {
               oColorTransform = new ColorTransform(1,1,1,nAlpha);
            }
            else
            {
               oColorTransform.alphaMultiplier = nAlpha;
            }
            aTransformList[sALPHA] = true;
         }
         this.checkIfTransformed();
      }
      
      override public function set scaleX(_nValue:Number) : void
      {
         if(nScaleX != _nValue)
         {
            oScaleMatrix.identity();
            nScaleX = _nValue;
            oScaleMatrix.a = nScaleX;
            oScaleMatrix.d = nScaleY;
            if(_nValue != 1)
            {
               aTransformList[sSCALE] = true;
            }
            if(nScaleX == 1 && nScaleY == 1)
            {
               aTransformList[sSCALE] = false;
            }
            this.checkIfTransformed();
         }
      }
      
      override public function set scaleY(_nValue:Number) : void
      {
         if(nScaleY != _nValue)
         {
            oScaleMatrix.identity();
            nScaleY = _nValue;
            oScaleMatrix.d = nScaleY;
            oScaleMatrix.a = nScaleX;
            if(_nValue != 1)
            {
               aTransformList[sSCALE] = true;
            }
            if(nScaleX == 1 && nScaleY == 1)
            {
               aTransformList[sSCALE] = false;
            }
            this.checkIfTransformed();
         }
      }
      
      override public function set colorTransform(_oValue:ColorTransform) : void
      {
         if(oColorTransform == null)
         {
            oColorTransform = _oValue;
         }
         else if(_oValue != null)
         {
            oColorTransform.alphaOffset = _oValue.alphaOffset;
            oColorTransform.blueMultiplier = _oValue.blueMultiplier;
            oColorTransform.blueOffset = _oValue.blueOffset;
            oColorTransform.greenMultiplier = _oValue.greenMultiplier;
            oColorTransform.greenOffset = _oValue.greenOffset;
            oColorTransform.redMultiplier = _oValue.redMultiplier;
            oColorTransform.redOffset = _oValue.redOffset;
         }
         if(oColorTransform != null)
         {
            aTransformList[sCOLOR_TRANSFORM] = true;
         }
         else
         {
            aTransformList[sCOLOR_TRANSFORM] = false;
         }
         this.checkIfTransformed();
      }
      
      public function get blendMode() : String
      {
         return this.sBlendMode;
      }
      
      public function set blendMode(_sValue:String) : void
      {
         this.sBlendMode = _sValue;
         if(this.sBlendMode == null || this.sBlendMode == "")
         {
            this.sBlendMode = null;
            aTransformList[sBLEND_MODE] = false;
         }
         else
         {
            aTransformList[sBLEND_MODE] = true;
         }
         this.checkIfTransformed();
      }
      
      public function get animationMode() : BitmappedAnimationMode
      {
         return this.oAnimationMode;
      }
      
      public function set animationMode(_oValue:BitmappedAnimationMode) : void
      {
         this.oAnimationMode = _oValue;
      }
      
      override public function get filters() : Array
      {
         if(aFilters == null)
         {
            aFilters = new Array();
         }
         this.bCheckForFilters = true;
         return aFilters;
      }
      
      override public function set filters(_aValue:Array) : void
      {
         if(_aValue != null)
         {
            this.bCheckForFilters = true;
            aFilters = _aValue;
         }
      }
      
      public function get isTransformed() : Boolean
      {
         return bTransformed;
      }
      
      override public function get frameData() : BitmapData
      {
         if(!bVisible)
         {
            return null;
         }
         if(this.bCheckForFilters)
         {
            this.checkForFilters();
            this.bCheckForFilters = false;
         }
         if(bTransformed)
         {
            if(this.bCacheTransform)
            {
               if(this.isTransFrameExist(this.nCurrentFrame))
               {
                  oFrameData = this.getTransFrame(this.nCurrentFrame);
               }
               else
               {
                  oFrameData = this.applyTransformation();
               }
            }
            else
            {
               oFrameData = this.applyTransformation();
            }
         }
         else if(!bFlip)
         {
            oFrameData = this.aFrameStructure[this.nCurrentFrame - 1].frameData;
         }
         else if(this.aFlippedFrameStructure != null)
         {
            oFrameData = this.aFlippedFrameStructure[this.nCurrentFrame - 1].frameData;
         }
         dispatchEvent(new Event(Event.ENTER_FRAME));
         return oFrameData;
      }
   }
}

