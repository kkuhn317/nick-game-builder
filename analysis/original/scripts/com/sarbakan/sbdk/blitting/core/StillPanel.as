package com.sarbakan.sbdk.blitting.core
{
   import com.sarbakan.sbdk.data.spatialIndexing.ISpatialIndexElement;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class StillPanel extends EventDispatcher implements IBitmappedAnimation
   {
      
      protected var bVisible:Boolean;
      
      protected var nAlpha:Number;
      
      protected var sLayer:String;
      
      protected var bPixelSnapping:Boolean;
      
      protected var oFrameData:BitmapData;
      
      protected var oSpatialIndexHandler:ISpatialIndexElement;
      
      protected var bMoving:Boolean;
      
      protected var oContainer:BitmappedAnimContainer;
      
      protected var bDisplayed:Boolean;
      
      protected var nDepth:int;
      
      protected var nLayerDepth:int;
      
      protected var oRect:Rectangle;
      
      private var oGenerator:StillGenerator;
      
      public function StillPanel(_oGenerator:StillGenerator, _nX:Number, _nY:Number, _nWidth:Number, _nHeight:Number)
      {
         super();
         this.nDepth = -1;
         this.oGenerator = _oGenerator;
         this.oRect = new Rectangle(_nX,_nY,_nWidth,_nHeight);
      }
      
      public function destroy() : void
      {
         if(Boolean(this.oContainer))
         {
            this.oContainer.removeAnimation(this);
         }
         this.oContainer = null;
         this.oSpatialIndexHandler = null;
         this.oRect = null;
         this.oGenerator = null;
         if(Boolean(this.oFrameData))
         {
            this.oFrameData.dispose();
         }
         this.oFrameData = null;
      }
      
      internal function invalidate() : void
      {
         if(Boolean(this.oFrameData))
         {
            this.oFrameData.dispose();
         }
         this.oFrameData = null;
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
            if(!_bValue)
            {
               if(Boolean(this.oFrameData))
               {
                  this.oFrameData.dispose();
               }
               this.oFrameData = null;
            }
         }
      }
      
      public function onMouseEvent(_oEvent:MouseEvent) : void
      {
      }
      
      public function onMouseOut(_oEvent:MouseEvent) : void
      {
      }
      
      protected function render() : void
      {
         var _aElems:Array = null;
         var _oIndex:ISpatialIndexElement = null;
         var _oElement:StillElement = null;
         var _oPos:Point = null;
         var _aIndex:Array = this.oGenerator.queryRectangle(this.oRect);
         if(_aIndex.length > 0)
         {
            this.oFrameData = new BitmapData(this.oRect.width,this.oRect.height,true,0);
            _aElems = new Array();
            for each(_oIndex in _aIndex)
            {
               _aElems.push(_oIndex.data);
            }
            _aElems.sortOn("depth",Array.NUMERIC);
            for each(_oElement in _aElems)
            {
               _oPos = new Point();
               _oPos.x = _oElement.bounds.nXMin - this.oRect.left;
               _oPos.y = _oElement.bounds.nYMin - this.oRect.top;
               this.oFrameData.copyPixels(_oElement.bitmapData,_oElement.bitmapData.rect,_oPos,null,null,true);
            }
         }
         else
         {
            this.oFrameData = new BitmapData(1,1,true,0);
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
         return false;
      }
      
      public function set flip(_bValue:Boolean) : void
      {
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
         return this.oRect;
      }
      
      public function get frameRect() : Rectangle
      {
         return this.frameData.rect;
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
         return 0;
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
         return 1;
      }
      
      public function set scaleX(_nValue:Number) : void
      {
      }
      
      public function get scaleY() : Number
      {
         return 1;
      }
      
      public function set scaleY(_nValue:Number) : void
      {
      }
      
      public function get colorTransform() : ColorTransform
      {
         return null;
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
         if(this.oFrameData == null)
         {
            this.render();
         }
         return this.oFrameData;
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
         return this.oRect.x;
      }
      
      public function set x(_nValue:Number) : void
      {
      }
      
      public function get y() : Number
      {
         return this.oRect.y;
      }
      
      public function set y(_nValue:Number) : void
      {
      }
      
      public function get width() : uint
      {
         return this.oRect.width;
      }
      
      public function set width(_nValue:uint) : void
      {
      }
      
      public function get height() : uint
      {
         return this.oRect.height;
      }
      
      public function set height(_nValue:uint) : void
      {
      }
      
      public function get mouseEnabled() : Boolean
      {
         return false;
      }
      
      public function set mouseEnabled(_bValue:Boolean) : void
      {
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
         return false;
      }
      
      public function set looping(_bValue:Boolean) : void
      {
      }
      
      public function get paused() : Boolean
      {
         return false;
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

