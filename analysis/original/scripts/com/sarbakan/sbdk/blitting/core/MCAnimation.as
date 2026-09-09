package com.sarbakan.sbdk.blitting.core
{
   import com.sarbakan.sbdk.core.UpdateManager;
   import com.sarbakan.sbdk.events.UpdateEvent;
   import com.sarbakan.sbdk.math.SBKMath;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   [Event(name="HIDE",type="flash.events.Event")]
   [Event(name="SHOW",type="flash.events.Event")]
   [Event(name="ENTER_FRAME",type="flash.events.Event")]
   public class MCAnimation extends AbstractBitmappedAnimation implements IBitmappedAnimation
   {
      
      public static const sSTATIC:String = "STATIC";
      
      public static const sDYNAMIC:String = "DYNAMIC";
      
      private static const sENTER_FRAME:String = "ENTER_FRAME";
      
      private static const sUPDATE_EVENT:String = "sUPDATE_EVENT";
      
      private var mcContainer:Sprite;
      
      private var mcRef:MovieClip;
      
      private var sType:String;
      
      private var bSmoothing:Boolean;
      
      private var aColliders:Array;
      
      private var bCollider:Boolean;
      
      private var bPlaying:Boolean;
      
      private var oDimension:Rectangle;
      
      private var nRadius:Number;
      
      private var nAngleOffset:Number;
      
      private var oOffsetMatrix:Matrix;
      
      private var oFrameRect:Rectangle;
      
      private var oInitFrameRect:Rectangle;
      
      private var oTempBitmapData:BitmapData;
      
      public function MCAnimation(_oClass:Class, _nX:Number, _nY:Number, _sLayer:String, _nDepth:int = -1, _sType:String = "DYNAMIC", _bCheckForCollider:Boolean = false)
      {
         super();
         sLayer = _sLayer;
         nDepth = _nDepth;
         oClassRef = _oClass;
         this.sType = _sType;
         nOrigine_X = _nX;
         nOrigine_Y = _nY;
         this.bCollider = _bCheckForCollider;
         this.init();
      }
      
      override public function destroy() : void
      {
         super.destroy();
         if(this.mcRef != null)
         {
            if(this.mcContainer.contains(this.mcRef))
            {
               this.mcContainer.removeChild(this.mcRef);
            }
            this.mcRef = null;
         }
         this.mcContainer = null;
         if(oFrameData != null)
         {
            oFrameData.dispose();
            oFrameData = null;
         }
         if(this.oTempBitmapData != null)
         {
            this.oTempBitmapData.dispose();
            this.oTempBitmapData = null;
         }
         oRotateMatrix = null;
         oScaleMatrix = null;
         this.oOffsetMatrix = null;
         if(this.aColliders != null)
         {
            this.aColliders.splice(0,this.aColliders.length);
            this.aColliders = null;
         }
      }
      
      override public function getColliderByName(_sName:String, _bLocal:Boolean = false) : ColliderInfo
      {
         var _oCollider:ColliderInfo = null;
         var i:int = 0;
         var _nGlobalXOffset:int = container.x;
         var _nGlobalYOffset:int = container.y;
         if(this.currentFrame > 0)
         {
            if(this.aColliders[this.currentFrame - 1] != null)
            {
               for(i = 0; i < this.aColliders[this.currentFrame - 1].length; i++)
               {
                  if(this.aColliders[this.currentFrame - 1][i].name == _sName)
                  {
                     _oCollider = this.aColliders[this.currentFrame - 1][i].clone();
                     if(!_bLocal)
                     {
                        _oCollider.rect.x += this.x;
                        _oCollider.rect.y += this.y;
                     }
                     return _oCollider;
                  }
               }
            }
         }
         return null;
      }
      
      override public function gotoAndPlay(_oFrameOrLabel:Object) : void
      {
         this.mcRef.gotoAndPlay(_oFrameOrLabel);
      }
      
      override public function gotoAndStop(_oFrameOrLabel:Object) : void
      {
         this.looping = false;
         this.mcRef.gotoAndStop(_oFrameOrLabel);
      }
      
      override public function nextFrame() : void
      {
         this.mcRef.nextFrame();
      }
      
      override public function prevFrame() : void
      {
         this.mcRef.prevFrame();
      }
      
      override public function stop() : void
      {
         if(this.mcRef != null)
         {
            oEventManager.cleanUp(sENTER_FRAME);
            this.mcRef.stop();
         }
         this.bPlaying = false;
      }
      
      override public function play() : void
      {
         if(this.mcRef != null)
         {
            if(!bLooping)
            {
               oEventManager.addEventListener(sENTER_FRAME,this.mcRef,Event.ENTER_FRAME,this.onEnterframe);
            }
            this.mcRef.play();
         }
         this.bPlaying = true;
      }
      
      override public function hitTestObject(_oBmpAnimRef:IBitmappedAnimation, _bPixelPerfect:Boolean = true) : Boolean
      {
         return this.rect.intersects(_oBmpAnimRef.rect);
      }
      
      override public function hitTestPoint(_nX:int, _nY:int, _bShapeFlag:Boolean = true) : Boolean
      {
         return this.rect.contains(_nX,_nY);
      }
      
      override public function hitTestMovieClip(_mcRef:DisplayObject, _bPixelPerfect:Boolean = true) : Boolean
      {
         return this.rect.intersects(new Rectangle(_mcRef.x,_mcRef.y,_mcRef.width,_mcRef.height));
      }
      
      internal function kill() : void
      {
         if(this.sType == MCAnimation.sDYNAMIC)
         {
            if(this.mcRef != null)
            {
               if(this.mcContainer.contains(this.mcRef))
               {
                  this.mcContainer.removeChild(this.mcRef);
               }
               oEventManager.cleanUp(sENTER_FRAME);
               this.mcRef.stop();
               this.mcRef = null;
            }
         }
         if(oFrameData != null)
         {
            oFrameData.dispose();
            oFrameData = null;
         }
      }
      
      internal function draw() : void
      {
         var i:int = 0;
         if(!bVisible)
         {
            return;
         }
         if(this.mcRef == null && this.sType == MCAnimation.sDYNAMIC)
         {
            this.mcRef = new oClassRef();
            if(this.bPlaying)
            {
               if(!bLooping)
               {
                  oEventManager.addEventListener(sENTER_FRAME,this.mcRef,Event.ENTER_FRAME,this.onEnterframe);
               }
               this.mcRef.play();
            }
            this.mcContainer.addChild(this.mcRef);
         }
         if(oFrameData != null)
         {
            oFrameData.dispose();
         }
         this.oFrameRect = this.mcRef.getBounds(this.mcRef);
         this.oFrameRect.width = Math.max(this.oFrameRect.width,1);
         this.oFrameRect.height = Math.max(this.oFrameRect.height,1);
         this.oInitFrameRect = this.oFrameRect.clone();
         this.oOffsetMatrix = new Matrix(1,0,0,1,-this.oInitFrameRect.x,-this.oInitFrameRect.y);
         this.oTempBitmapData = new BitmapData(this.oInitFrameRect.width,this.oInitFrameRect.height,true,0);
         this.oTempBitmapData.draw(this.mcContainer,this.oOffsetMatrix);
         oScaleMatrix.identity();
         oScaleMatrix.a = nScaleX;
         oScaleMatrix.d = nScaleY;
         this.oFrameRect.width = this.oInitFrameRect.width * Math.abs(nScaleX);
         if(nScaleX < 0)
         {
            oScaleMatrix.tx = this.oInitFrameRect.width * Math.abs(nScaleX);
            this.oFrameRect.x = this.oInitFrameRect.right * nScaleX;
         }
         else
         {
            this.oFrameRect.x = this.oInitFrameRect.x * nScaleX;
         }
         this.oFrameRect.height = this.oInitFrameRect.height * Math.abs(nScaleY);
         if(nScaleY < 0)
         {
            oScaleMatrix.ty = this.oInitFrameRect.height * Math.abs(nScaleY);
            this.oFrameRect.y = this.oInitFrameRect.bottom * nScaleY;
         }
         else
         {
            this.oFrameRect.y = this.oInitFrameRect.y * nScaleY;
         }
         this.nRadius = SBKMath.getDistance(0,0,this.oFrameRect.left + this.oFrameRect.width / 2,this.oFrameRect.top + this.oFrameRect.height / 2);
         this.nAngleOffset = SBKMath.getAngle(0,0,this.oFrameRect.left + this.oFrameRect.width / 2,this.oFrameRect.top + this.oFrameRect.height / 2);
         oRotateMatrix.identity();
         oRotateMatrix.translate(-(this.oFrameRect.width / 2),-(this.oFrameRect.height / 2));
         this.oDimension = SBKMath.getDimensionAfterRotation(SBKMath.degToRad(nRotation),this.oFrameRect.width,this.oFrameRect.height);
         this.oFrameRect.width = this.oDimension.width;
         this.oFrameRect.height = this.oDimension.height;
         oRotateMatrix.rotate(SBKMath.degToRad(nRotation));
         oRotateMatrix.translate(this.oFrameRect.width / 2,this.oFrameRect.height / 2);
         if(this.nRadius > 0)
         {
            this.oFrameRect.x = Math.cos(SBKMath.degToRad(nRotation + this.nAngleOffset)) * this.nRadius - this.oFrameRect.width / 2;
            this.oFrameRect.y = Math.sin(SBKMath.degToRad(nRotation + this.nAngleOffset)) * this.nRadius - this.oFrameRect.height / 2;
         }
         else
         {
            this.oFrameRect.x = this.oInitFrameRect.x - (this.oFrameRect.width - this.oInitFrameRect.width) / 2;
            this.oFrameRect.y = this.oInitFrameRect.y - (this.oFrameRect.height - this.oInitFrameRect.height) / 2;
         }
         oTransformMatrix = oScaleMatrix.clone();
         oTransformMatrix.concat(oRotateMatrix);
         this.oFrameRect.width = Math.max(this.oFrameRect.width,1);
         this.oFrameRect.height = Math.max(this.oFrameRect.height,1);
         oFrameData = new BitmapData(this.oFrameRect.width,this.oFrameRect.height,true,0);
         oFrameData.draw(this.oTempBitmapData,oTransformMatrix,oColorTransform,null,null,aTransformList[sSMOOTHING]);
         if(this.oTempBitmapData != null)
         {
            this.oTempBitmapData.dispose();
            this.oTempBitmapData = null;
         }
         if(aFilters != null)
         {
            for(i = 0; i < aFilters.length; i++)
            {
               oFrameData.applyFilter(oFrameData,oFrameData.rect,new Point(0,0),aFilters[i]);
            }
         }
         if(this.bCollider)
         {
            this.extractColliders();
            this.transformColliders();
            if(Boolean(aTransformList[sSHOW_COLLIDER]))
            {
               this.displayColliders(oFrameData);
            }
         }
         if(Boolean(aTransformList[sREDRAW_REGION]))
         {
            this.displayRedrawRegion(oFrameData);
         }
         dispatchEvent(new Event(Event.ENTER_FRAME));
      }
      
      override protected function init() : void
      {
         super.init();
         nRotation = 0;
         try
         {
            this.mcRef = new oClassRef();
         }
         catch(e:Error)
         {
         }
         this.mcContainer = new Sprite();
         this.oFrameRect = this.mcRef.getBounds(this.mcRef);
         this.oFrameRect.width = Math.max(this.oFrameRect.width,1);
         this.oFrameRect.height = Math.max(this.oFrameRect.height,1);
         if(this.sType == sDYNAMIC)
         {
            if(this.mcRef != null)
            {
               this.mcRef = null;
            }
         }
         else
         {
            this.mcContainer.addChild(this.mcRef);
            this.mcRef.stop();
         }
         this.bPlaying = false;
         bMoving = false;
         this.bSmoothing = false;
         bMouseOver = false;
         nRotation = 0;
         nAlpha = 1;
         nScaleX = 1;
         nScaleY = 1;
         nWidth = this.oFrameRect.width;
         nHeight = this.oFrameRect.height;
         oRotateMatrix = new Matrix();
         oScaleMatrix = new Matrix();
         this.aColliders = new Array();
         oEventManager.addEventListener(sUPDATE_EVENT,UpdateManager.instance,UpdateEvent.PAUSE,this.onUpdatePause);
         oEventManager.addEventListener(sUPDATE_EVENT,UpdateManager.instance,UpdateEvent.RESUME,this.onUpdateResume);
      }
      
      private function resetMatrix(_oMatrix:Matrix) : void
      {
         _oMatrix.a = 1;
         _oMatrix.b = 0;
         _oMatrix.c = 0;
         _oMatrix.d = 1;
         _oMatrix.tx = 0;
         _oMatrix.ty = 0;
      }
      
      private function extractColliders() : void
      {
         var _mc:DisplayObject = null;
         var _nRadius:Number = NaN;
         var _nAngle:Number = NaN;
         var i:int = 0;
         if(this.mcRef != null)
         {
            if(this.aColliders[this.currentFrame - 1] == null)
            {
               this.aColliders[this.currentFrame - 1] = new Array();
            }
            else
            {
               this.aColliders[this.currentFrame - 1].splice(0,this.aColliders[this.currentFrame - 1].length);
            }
            for(i = 0; i < this.mcRef.numChildren; i++)
            {
               _mc = this.mcRef.getChildAt(i);
               if(_mc != null && _mc.name.charAt(0) == "_")
               {
                  _mc.visible = false;
                  _nRadius = SBKMath.getDistance(0,0,_mc.x + _mc.width / 2,_mc.y + _mc.height / 2);
                  _nAngle = SBKMath.getAngle(0,0,_mc.x + _mc.width / 2,_mc.y + _mc.height / 2);
                  this.aColliders[this.mcRef.currentFrame - 1].push(new ColliderInfo(_mc.name.substr(1,_mc.name.length),new Rectangle(_mc.x,_mc.y,_mc.width,_mc.height),_nRadius,_nAngle));
               }
            }
         }
      }
      
      private function resetColliderTransform() : void
      {
         var i:int = 0;
         if(this.aColliders[this.currentFrame - 1].length > 0)
         {
            for(i = 0; i < this.aColliders[this.currentFrame - 1].length; i++)
            {
               this.aColliders[this.currentFrame - 1][i].rect.x = this.aColliders[this.currentFrame - 1][i].initRect.x;
               this.aColliders[this.currentFrame - 1][i].rect.y = this.aColliders[this.currentFrame - 1][i].initRect.y;
               this.aColliders[this.currentFrame - 1][i].rect.width = this.aColliders[this.currentFrame - 1][i].initRect.width;
               this.aColliders[this.currentFrame - 1][i].rect.height = this.aColliders[this.currentFrame - 1][i].initRect.height;
               this.aColliders[this.currentFrame - 1][i].radius = this.aColliders[this.currentFrame - 1][i].initRadius;
               this.aColliders[this.currentFrame - 1][i].angle = this.aColliders[this.currentFrame - 1][i].initAngle;
            }
         }
      }
      
      private function transformColliders() : void
      {
         var _oCollider:ColliderInfo = null;
         this.resetColliderTransform();
         for(var i:int = 0; i < this.aColliders[this.currentFrame - 1].length; i++)
         {
            _oCollider = this.aColliders[this.currentFrame - 1][i];
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
         if(nRotation != 0)
         {
            for(i = 0; i < this.aColliders[this.currentFrame - 1].length; i++)
            {
               _oCollider = this.aColliders[this.currentFrame - 1][i];
               _oCollider.angle += nRotation;
               _oCollider.angle = SBKMath.adjustAngle(_oCollider.angle);
               _oCollider.rect.x = Math.cos(SBKMath.degToRad(_oCollider.angle)) * _oCollider.radius - _oCollider.rect.width / 2;
               _oCollider.rect.y = Math.sin(SBKMath.degToRad(_oCollider.angle)) * _oCollider.radius - _oCollider.rect.height / 2;
            }
         }
      }
      
      private function displayColliders(_oFrameData:BitmapData) : void
      {
         var _oRect:Rectangle = null;
         var _oColliderData:BitmapData = null;
         var i:int = 0;
         if(this.aColliders[this.currentFrame - 1] != null)
         {
            for(i = 0; i < this.aColliders[this.currentFrame - 1].length; i++)
            {
               _oRect = this.aColliders[this.currentFrame - 1][i].rect.clone();
               if(nScaleX < 0)
               {
                  _oRect.x = Math.abs(this.oFrameRect.left - _oRect.left);
               }
               else
               {
                  _oRect.x -= this.oFrameRect.left;
               }
               if(nScaleY < 0)
               {
                  _oRect.y = Math.abs(this.oFrameRect.top - _oRect.top);
               }
               else
               {
                  _oRect.y -= this.oFrameRect.top;
               }
               _oColliderData = new BitmapData(_oRect.width,_oRect.height,false,65280);
               _oFrameData.copyPixels(_oColliderData,_oColliderData.rect,new Point(_oRect.left,_oRect.top));
            }
         }
      }
      
      private function displayRedrawRegion(_oFrameData:BitmapData) : void
      {
         var _nBoundingColor:int = 4294901760;
         for(var i:int = 0; i < _oFrameData.width; i++)
         {
            _oFrameData.setPixel32(i,0,_nBoundingColor);
         }
         for(i = 0; i < _oFrameData.height; i++)
         {
            _oFrameData.setPixel32(_oFrameData.width - 1,i,_nBoundingColor);
         }
         for(i = 0; i < _oFrameData.height; i++)
         {
            _oFrameData.setPixel32(0,i,_nBoundingColor);
         }
         for(i = 0; i < _oFrameData.width; i++)
         {
            _oFrameData.setPixel32(i,_oFrameData.height - 1,_nBoundingColor);
         }
      }
      
      private function onEnterframe(_oEvent:Event) : void
      {
         if(this.mcRef.currentFrame >= this.mcRef.totalFrames)
         {
            this.mcRef.stop();
            oEventManager.cleanUp(sENTER_FRAME);
         }
      }
      
      private function onUpdatePause(_oEvent:UpdateEvent) : void
      {
         if(this.mcRef != null)
         {
            this.mcRef.stop();
            bPaused = true;
         }
      }
      
      private function onUpdateResume(_oEvent:UpdateEvent) : void
      {
         if(this.mcRef != null && this.bPlaying)
         {
            this.mcRef.play();
            bPaused = false;
         }
      }
      
      override public function get ID() : BitmappedObjID
      {
         return new BitmappedObjID(this.mcRef.name,null);
      }
      
      override public function get colliders() : Array
      {
         return this.aColliders[this.currentFrame];
      }
      
      public function get transformed() : Boolean
      {
         return bTransformed;
      }
      
      override public function get frameData() : BitmapData
      {
         return oFrameData;
      }
      
      override public function set scaleX(_nValue:Number) : void
      {
         if(nScaleX != _nValue)
         {
            nScaleX = _nValue;
         }
      }
      
      override public function set scaleY(_nValue:Number) : void
      {
         if(nScaleY != _nValue)
         {
            nScaleY = _nValue;
         }
      }
      
      override public function get width() : uint
      {
         if(this.oFrameRect != null)
         {
            return this.oFrameRect.width;
         }
         return 0;
      }
      
      override public function set width(_nValue:uint) : void
      {
         if(_nValue > 0)
         {
            this.scaleX = _nValue / this.oFrameRect.width;
         }
      }
      
      override public function get height() : uint
      {
         if(this.oFrameRect != null)
         {
            return this.oFrameRect.height;
         }
         return 0;
      }
      
      override public function set height(_nValue:uint) : void
      {
         if(_nValue > 0)
         {
            this.scaleY = _nValue / this.oFrameRect.height;
         }
      }
      
      override public function get filters() : Array
      {
         if(aFilters == null)
         {
            aFilters = new Array();
         }
         return aFilters;
      }
      
      public function get mc() : MovieClip
      {
         return this.mcRef;
      }
      
      override public function set colorTransform(_oValue:ColorTransform) : void
      {
         oColorTransform = _oValue;
      }
      
      override public function set rotation(_nValue:Number) : void
      {
         nRotation = SBKMath.adjustAngle(_nValue);
      }
      
      override public function set visible(_bValue:Boolean) : void
      {
         super.visible = _bValue;
      }
      
      override public function set alpha(_nValue:Number) : void
      {
         nAlpha = _nValue;
         if(this.mcRef != null)
         {
            this.mcRef.alpha = _nValue;
         }
      }
      
      override public function get totalFrames() : uint
      {
         if(this.mcRef != null)
         {
            return this.mcRef.totalFrames;
         }
         return 0;
      }
      
      override public function get rect() : Rectangle
      {
         return new Rectangle(this.x + this.oFrameRect.left,this.y + this.oFrameRect.top,nWidth,nHeight);
      }
      
      override public function get frameRect() : Rectangle
      {
         return this.oFrameRect;
      }
      
      override public function get smoothing() : Boolean
      {
         return this.bSmoothing;
      }
      
      override public function set smoothing(_bValue:Boolean) : void
      {
         this.bSmoothing = _bValue;
      }
      
      override public function get looping() : Boolean
      {
         return super.looping;
      }
      
      override public function set looping(_bValue:Boolean) : void
      {
         super.looping = _bValue;
         if(_bValue)
         {
            if(this.mcRef != null)
            {
               oEventManager.cleanUp(sENTER_FRAME);
            }
         }
         else if(this.mcRef != null)
         {
            oEventManager.addEventListener(sENTER_FRAME,this.mcRef,Event.ENTER_FRAME,this.onEnterframe);
         }
      }
      
      override public function get currentFrame() : uint
      {
         if(this.mcRef != null)
         {
            return this.mcRef.currentFrame;
         }
         return 0;
      }
      
      override public function get frameRate() : int
      {
         return -1;
      }
      
      override public function set frameRate(_nValue:int) : void
      {
      }
      
      override public function get showRedrawRegion() : Boolean
      {
         return aTransformList[sREDRAW_REGION];
      }
      
      override public function set showRedrawRegion(_bValue:Boolean) : void
      {
         aTransformList[sREDRAW_REGION] = _bValue;
      }
      
      override public function get showColliders() : Boolean
      {
         return aTransformList[sSHOW_COLLIDER];
      }
      
      override public function set showColliders(_bValue:Boolean) : void
      {
         aTransformList[sSHOW_COLLIDER] = _bValue;
      }
      
      override public function get x() : Number
      {
         return nOrigine_X;
      }
      
      override public function set x(_nValue:Number) : void
      {
         var _nLastX:Number = NaN;
         if(nOrigine_X != _nValue)
         {
            _nLastX = nOrigine_X;
            if(bPixelSnapping)
            {
               nOrigine_X = _nValue;
            }
            else
            {
               nOrigine_X = Math.round(_nValue);
            }
            if(oSpatialIndexHandler != null)
            {
               oSpatialIndexHandler.setPositionRectangle(this.rect);
            }
         }
      }
      
      override public function get y() : Number
      {
         return nOrigine_Y;
      }
      
      override public function set y(_nValue:Number) : void
      {
         var _nLastY:Number = NaN;
         if(nOrigine_Y != _nValue)
         {
            _nLastY = nOrigine_Y;
            if(bPixelSnapping)
            {
               nOrigine_Y = _nValue;
            }
            else
            {
               nOrigine_Y = Math.round(_nValue);
            }
            if(oSpatialIndexHandler != null)
            {
               oSpatialIndexHandler.setPositionRectangle(this.rect);
            }
         }
      }
   }
}

