package com.sarbakan.sbdk.blitting.core
{
   import com.sarbakan.sbdk.data.spatialIndexing.ISpatialIndexElement;
   import com.sarbakan.sbdk.events.BitmappedEvent;
   import com.sarbakan.sbdk.utils.EventManager;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   [Event(name="MOUSE_OUT",type="flash.events.MouseEvent")]
   [Event(name="MOUSE_OVER",type="flash.events.MouseEvent")]
   [Event(name="MOUSE_DOWN",type="flash.events.MouseEvent")]
   [Event(name="MOUSE_UP",type="flash.events.MouseEvent")]
   [Event(name="MOUSE_MOVE",type="flash.events.MouseEvent")]
   internal class AbstractBitmappedAnimation extends EventDispatcher implements IBitmappedAnimation
   {
      
      protected static const sMOUSE_ENABLED:String = "MOUSE_ENABLED";
      
      protected static const sSCALE:String = "SCALE";
      
      protected static const sSCALE_X:String = "SCALE_X";
      
      protected static const sSCALE_Y:String = "SCALE_Y";
      
      protected static const sROTATION:String = "ROTATION";
      
      protected static const sCOLOR_TRANSFORM:String = "COLOR_TRANSFORM";
      
      protected static const sREDRAW_REGION:String = "REDRAW_REGION";
      
      protected static const sSHOW_COLLIDER:String = "SHOW_COLLIDER";
      
      protected static const sSMOOTHING:String = "SMOOTHING";
      
      protected static const sALPHA:String = "ALPHA";
      
      protected static const sBLEND_MODE:String = "BLEND_MODE";
      
      protected static const sCLIP_RECT:String = "CLIP_RECT";
      
      protected static const sFILTERS:String = "FILTERS";
      
      protected static const sVISIBLE:String = "VISIBLE";
      
      protected static const sX:String = "X";
      
      protected static const sY:String = "Y";
      
      protected static const sWIDTH:String = "WIDTH";
      
      protected static const sHEIGHT:String = "HEIGHT";
      
      protected static const sLOOP:String = "LOOP";
      
      protected static const sFLIP:String = "FLIP";
      
      protected static const sFRAME_RATE:String = "FRAME_RATE";
      
      protected static const sPIXEL_SNAPPING:String = "PIXEL_SNAPPING";
      
      protected var aTransformList:Array;
      
      protected var oClassRef:Class;
      
      protected var nOrigine_X:Number;
      
      protected var nOrigine_Y:Number;
      
      protected var nWidth:Number;
      
      protected var nHeight:Number;
      
      protected var nRotation:Number;
      
      protected var bVisible:Boolean;
      
      protected var oScaleMatrix:Matrix;
      
      protected var oRotateMatrix:Matrix;
      
      protected var oTransformMatrix:Matrix;
      
      protected var aFilters:Array;
      
      protected var nScaleX:Number;
      
      protected var nScaleY:Number;
      
      protected var oColorTransform:ColorTransform;
      
      protected var nAlpha:Number;
      
      protected var sLayer:String;
      
      protected var bPixelSnapping:Boolean;
      
      protected var oEventManager:EventManager;
      
      protected var oFrameData:BitmapData;
      
      protected var bTransformed:Boolean;
      
      protected var oSpatialIndexHandler:ISpatialIndexElement;
      
      protected var bMoving:Boolean;
      
      protected var oContainer:BitmappedAnimContainer;
      
      protected var bMouseEnabled:Boolean;
      
      protected var bMouseOver:Boolean;
      
      protected var bLooping:Boolean;
      
      protected var bFlip:Boolean;
      
      protected var bDisplayed:Boolean;
      
      protected var bPaused:Boolean;
      
      protected var nDepth:int;
      
      protected var nLayerDepth:int;
      
      public function AbstractBitmappedAnimation()
      {
         super();
      }
      
      public function destroy() : void
      {
         this.aTransformList = null;
         this.mouseEnabled = false;
         if(this.oEventManager != null)
         {
            this.oEventManager.destroy();
            this.oEventManager = null;
         }
      }
      
      public function gotoAndStop(_oFrameOrLabel:Object) : void
      {
      }
      
      public function gotoAndPlay(_oFrameOrLabel:Object) : void
      {
      }
      
      public function nextFrame() : void
      {
      }
      
      public function prevFrame() : void
      {
      }
      
      public function play() : void
      {
      }
      
      public function stop() : void
      {
      }
      
      public function getColliderByName(_sName:String, _bLocal:Boolean = false) : ColliderInfo
      {
         return null;
      }
      
      public function setContainer(_oContainerRef:BitmappedAnimContainer) : void
      {
         this.oContainer = _oContainerRef;
      }
      
      public function hitTestObject(_oBmpAnimRef:IBitmappedAnimation, _bPixelPerfect:Boolean = true) : Boolean
      {
         return false;
      }
      
      public function hitTestPoint(_nX:int, _nY:int, _bPixelPerfect:Boolean = true) : Boolean
      {
         return false;
      }
      
      public function hitTestRect(_oRect:Rectangle, _bPixelPerfect:Boolean = true) : Boolean
      {
         return false;
      }
      
      public function hitTestMovieClip(_mcRef:DisplayObject, _bPixelPerfect:Boolean = true) : Boolean
      {
         return false;
      }
      
      public function setDisplayed(_bValue:Boolean) : void
      {
         if(this.bDisplayed != _bValue)
         {
            this.bDisplayed = _bValue;
            if(_bValue)
            {
               dispatchEvent(new BitmappedEvent(BitmappedEvent.SHOW,false,false,this.oClassRef));
            }
            else
            {
               dispatchEvent(new BitmappedEvent(BitmappedEvent.HIDE,false,false,this.oClassRef));
            }
         }
      }
      
      public function onMouseEvent(_oEvent:MouseEvent) : void
      {
         if(this.oContainer == null)
         {
            return;
         }
         var _oAbsRect:Rectangle = new Rectangle(this.rect.left - this.oContainer.viewX,this.rect.top - this.oContainer.viewY,this.width,this.height);
         if(_oAbsRect.contains(_oEvent.localX,_oEvent.localY))
         {
            if(_oEvent.type == MouseEvent.MOUSE_MOVE)
            {
               if(!this.bMouseOver)
               {
                  dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OVER,true,false,_oEvent.localX - _oAbsRect.x,_oEvent.localY - _oAbsRect.y,null,_oEvent.ctrlKey,_oEvent.altKey,_oEvent.shiftKey,_oEvent.buttonDown));
                  this.bMouseOver = true;
               }
               dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE,true,false,_oEvent.localX - _oAbsRect.x,_oEvent.localY - _oAbsRect.y,null,_oEvent.ctrlKey,_oEvent.altKey,_oEvent.shiftKey,_oEvent.buttonDown));
            }
            else if(_oEvent.type == MouseEvent.MOUSE_UP)
            {
               dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP,true,false,_oEvent.localX - _oAbsRect.x,_oEvent.localY - _oAbsRect.y,null,_oEvent.ctrlKey,_oEvent.altKey,_oEvent.shiftKey,_oEvent.buttonDown));
               dispatchEvent(new MouseEvent(MouseEvent.CLICK,true,false,_oEvent.localX - _oAbsRect.x,_oEvent.localY - _oAbsRect.y,null,_oEvent.ctrlKey,_oEvent.altKey,_oEvent.shiftKey,_oEvent.buttonDown));
            }
            else if(_oEvent.type == MouseEvent.MOUSE_DOWN)
            {
               dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN,true,false,_oEvent.localX - _oAbsRect.x,_oEvent.localY - _oAbsRect.y,null,_oEvent.ctrlKey,_oEvent.altKey,_oEvent.shiftKey,_oEvent.buttonDown));
            }
         }
      }
      
      public function onMouseOut(_oEvent:MouseEvent) : void
      {
         var _oAbsRect:Rectangle = null;
         if(this.oContainer == null)
         {
            return;
         }
         if(this.bMouseOver)
         {
            _oAbsRect = new Rectangle(this.rect.left - this.oContainer.viewX,this.rect.top - this.oContainer.viewY,this.width,this.height);
            dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT,true,false,_oEvent.localX - _oAbsRect.x,_oEvent.localY - _oAbsRect.y,null,_oEvent.ctrlKey,_oEvent.altKey,_oEvent.shiftKey,_oEvent.buttonDown));
            this.bMouseOver = false;
         }
      }
      
      protected function init() : void
      {
         this.aTransformList = new Array();
         this.oEventManager = new EventManager();
         this.bLooping = true;
         this.bFlip = false;
         this.bVisible = true;
         this.nDepth = -1;
         this.bDisplayed = false;
         this.bPixelSnapping = false;
         this.bPaused = false;
      }
      
      protected function applyFilters(_oFrameData:BitmapData) : void
      {
         for(var i:int = 0; i < this.aFilters.length; i++)
         {
            _oFrameData.applyFilter(_oFrameData,new Rectangle(0,0,_oFrameData.width,_oFrameData.height),new Point(0,0),this.aFilters[i]);
         }
      }
      
      public function get ID() : BitmappedObjID
      {
         return null;
      }
      
      public function get currentFrame() : uint
      {
         return 0;
      }
      
      public function get colliders() : Array
      {
         return null;
      }
      
      public function get totalFrames() : uint
      {
         return 0;
      }
      
      public function get smoothing() : Boolean
      {
         return false;
      }
      
      public function set smoothing(_bValue:Boolean) : void
      {
      }
      
      public function get flip() : Boolean
      {
         return this.bFlip;
      }
      
      public function set flip(_bValue:Boolean) : void
      {
         this.bFlip = _bValue;
      }
      
      public function get visible() : Boolean
      {
         return this.bVisible;
      }
      
      public function set visible(_bValue:Boolean) : void
      {
         this.bVisible = _bValue;
      }
      
      public function get showColliders() : Boolean
      {
         return false;
      }
      
      public function set showColliders(_bValue:Boolean) : void
      {
      }
      
      public function get rect() : Rectangle
      {
         return null;
      }
      
      public function get frameRect() : Rectangle
      {
         return null;
      }
      
      public function get showRedrawRegion() : Boolean
      {
         return false;
      }
      
      public function set showRedrawRegion(_bValue:Boolean) : void
      {
      }
      
      public function get rotation() : Number
      {
         return this.nRotation;
      }
      
      public function set rotation(_nValue:Number) : void
      {
      }
      
      public function get pixelSnapping() : Boolean
      {
         return this.bPixelSnapping;
      }
      
      public function set pixelSnapping(_bValue:Boolean) : void
      {
         this.bPixelSnapping = _bValue;
      }
      
      public function get alpha() : Number
      {
         return this.nAlpha;
      }
      
      public function set alpha(_nValue:Number) : void
      {
      }
      
      public function get scaleX() : Number
      {
         return this.nScaleX;
      }
      
      public function set scaleX(_nValue:Number) : void
      {
      }
      
      public function get scaleY() : Number
      {
         return this.nScaleY;
      }
      
      public function set scaleY(_nValue:Number) : void
      {
      }
      
      public function get colorTransform() : ColorTransform
      {
         return this.oColorTransform;
      }
      
      public function set colorTransform(_oValue:ColorTransform) : void
      {
      }
      
      public function get filters() : Array
      {
         return null;
      }
      
      public function set filters(_aValue:Array) : void
      {
      }
      
      public function get frameData() : BitmapData
      {
         return null;
      }
      
      public function get frameRate() : int
      {
         return -1;
      }
      
      public function set frameRate(_nValue:int) : void
      {
      }
      
      public function get x() : Number
      {
         return 0;
      }
      
      public function set x(_nValue:Number) : void
      {
      }
      
      public function get y() : Number
      {
         return 0;
      }
      
      public function set y(_nValue:Number) : void
      {
      }
      
      public function get width() : uint
      {
         return 0;
      }
      
      public function set width(_nValue:uint) : void
      {
      }
      
      public function get height() : uint
      {
         return 0;
      }
      
      public function set height(_nValue:uint) : void
      {
      }
      
      public function get mouseEnabled() : Boolean
      {
         return this.bMouseEnabled;
      }
      
      public function set mouseEnabled(_bValue:Boolean) : void
      {
         this.bMouseEnabled = _bValue;
      }
      
      public function get depth() : int
      {
         return this.nDepth;
      }
      
      public function set depth(_nValue:int) : void
      {
         this.nDepth = _nValue;
      }
      
      public function get layerDepth() : int
      {
         return this.nLayerDepth;
      }
      
      public function set layerDepth(_nValue:int) : void
      {
         this.nLayerDepth = _nValue;
      }
      
      public function get layer() : String
      {
         return this.sLayer;
      }
      
      public function set layer(_sValue:String) : void
      {
         this.sLayer = _sValue;
      }
      
      public function get spatialIndexHandler() : ISpatialIndexElement
      {
         return this.oSpatialIndexHandler;
      }
      
      public function set spatialIndexHandler(_oHandler:ISpatialIndexElement) : void
      {
         this.oSpatialIndexHandler = _oHandler;
      }
      
      public function get moving() : Boolean
      {
         return this.bMoving;
      }
      
      public function set moving(_bValue:Boolean) : void
      {
         this.bMoving = _bValue;
      }
      
      public function get looping() : Boolean
      {
         return this.bLooping;
      }
      
      public function set looping(_bValue:Boolean) : void
      {
         this.bLooping = _bValue;
      }
      
      public function get paused() : Boolean
      {
         return this.bPaused;
      }
      
      public function get displayed() : Boolean
      {
         return this.bDisplayed;
      }
      
      public function get container() : BitmappedAnimContainer
      {
         return this.oContainer;
      }
   }
}

