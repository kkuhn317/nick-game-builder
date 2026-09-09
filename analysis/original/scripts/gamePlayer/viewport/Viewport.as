package gamePlayer.viewport
{
   import com.sarbakan.sbdk.blitting.core.BitmappedAnimContainer;
   import com.sarbakan.sbdk.math.geom.AABB2;
   import com.sarbakan.sbdk.math.random.Random;
   import flash.display.Sprite;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class Viewport extends EventDispatcher
   {
      
      private static var oInstance:Viewport;
      
      private static var bAllowConstruction:Boolean = false;
      
      private const nMIN_DISPLACEMENT:Number = 1;
      
      public var oDebugLayer:Sprite;
      
      private var nCurrentEasing:Number;
      
      private var nShakeIteration:int;
      
      private var nCurrentShakeX:Number;
      
      private var nCurrentShakeY:Number;
      
      private var oContainerRef:BitmappedAnimContainer;
      
      private var oFocusedElementRef:IViewportTargetable;
      
      private var oViewportBounds:AABB2;
      
      public function Viewport()
      {
         super();
         this.nShakeIteration = 0;
         this.nCurrentShakeX = 0;
         this.nCurrentShakeY = 0;
         this.nCurrentEasing = 1;
      }
      
      public static function get instance() : Viewport
      {
         if(oInstance == null)
         {
            bAllowConstruction = true;
            oInstance = new Viewport();
            bAllowConstruction = false;
         }
         return oInstance;
      }
      
      public function destroy() : void
      {
         this.oDebugLayer = null;
         this.oFocusedElementRef = null;
         this.oViewportBounds = null;
         this.oContainerRef = null;
         oInstance = null;
      }
      
      public function setContainer(_oContainer:BitmappedAnimContainer, _oBounds:AABB2) : void
      {
         this.oContainerRef = _oContainer;
         this.oViewportBounds = _oBounds;
         this.oDebugLayer = new Sprite();
         this.oContainerRef.parent.addChild(this.oDebugLayer);
      }
      
      public function targetPoint(_oPos:Point) : void
      {
         var _nX:Number = NaN;
         var _nY:Number = NaN;
         if(Boolean(this.oContainerRef))
         {
            _nX = _oPos.x - this.oContainerRef.viewWidth / 2;
            if(_nX < this.oViewportBounds.nXMin)
            {
               _nX = this.oViewportBounds.nXMin;
            }
            else if(_nX > this.oViewportBounds.nXMax - this.oContainerRef.viewWidth)
            {
               _nX = this.oViewportBounds.nXMax - this.oContainerRef.viewWidth;
            }
            _nY = _oPos.y - this.oContainerRef.viewHeight / 2;
            if(_nY < this.oViewportBounds.nYMin)
            {
               _nY = this.oViewportBounds.nYMin;
            }
            else if(_nY > this.oViewportBounds.nYMax - this.oContainerRef.viewHeight)
            {
               _nY = this.oViewportBounds.nYMax - this.oContainerRef.viewHeight;
            }
            this.oContainerRef.display(_nX,_nY);
         }
      }
      
      public function easeTo(_oFocusedElement:IViewportTargetable, _nEasingValue:Number = 1) : void
      {
         this.oFocusedElementRef = _oFocusedElement;
         this.nCurrentEasing = _nEasingValue;
      }
      
      public function startShake(_nShakeX:Number, _nShakeY:Number, _nDuration:uint = 1) : void
      {
         this.nShakeIteration = _nDuration;
         this.nCurrentShakeX = _nShakeX;
         this.nCurrentShakeY = _nShakeY;
      }
      
      public function stopShake() : void
      {
         this.nShakeIteration = 0;
         this.nCurrentShakeX = 0;
         this.nCurrentShakeY = 0;
      }
      
      public function applyFilter(_aFilters:Array) : void
      {
         this.oContainerRef.filters = _aFilters;
      }
      
      public function update() : void
      {
         var _oPos:Point = null;
         var _nX:Number = NaN;
         var _nY:Number = NaN;
         var _nDeltaX:Number = NaN;
         var _nDeltaY:Number = NaN;
         if(this.oContainerRef != null && this.oFocusedElementRef != null)
         {
            _oPos = this.oFocusedElementRef.viewportPos;
            _nX = _oPos.x - this.oContainerRef.viewWidth / 2;
            if(_nX < this.oViewportBounds.nXMin)
            {
               _nX = this.oViewportBounds.nXMin;
            }
            else if(_nX > this.oViewportBounds.nXMax - this.oContainerRef.viewWidth)
            {
               _nX = this.oViewportBounds.nXMax - this.oContainerRef.viewWidth;
            }
            _nY = _oPos.y - this.oContainerRef.viewHeight / 2;
            if(_nY < this.oViewportBounds.nYMin)
            {
               _nY = this.oViewportBounds.nYMin;
            }
            else if(_nY > this.oViewportBounds.nYMax - this.oContainerRef.viewHeight)
            {
               _nY = this.oViewportBounds.nYMax - this.oContainerRef.viewHeight;
            }
            if(this.nShakeIteration > 0)
            {
               _nX += Random.getFloat(-this.nCurrentShakeX,this.nCurrentShakeX);
               _nY += Random.getFloat(-this.nCurrentShakeY,this.nCurrentShakeY);
               --this.nShakeIteration;
               if(this.nShakeIteration == 0)
               {
                  this.stopShake();
               }
            }
            if(this.nCurrentEasing != 1)
            {
               _nDeltaX = _nX - this.oContainerRef.viewX;
               _nDeltaY = _nY - this.oContainerRef.viewY;
               if(Math.abs(_nDeltaX * this.nCurrentEasing) < this.nMIN_DISPLACEMENT && Math.abs(_nDeltaY * this.nCurrentEasing) < this.nMIN_DISPLACEMENT)
               {
                  this.nCurrentEasing = 1;
                  dispatchEvent(new ViewportEvent(ViewportEvent.EASING_COMPLETE));
               }
               _nX = this.oContainerRef.viewX + _nDeltaX * this.nCurrentEasing;
               _nY = this.oContainerRef.viewY + _nDeltaY * this.nCurrentEasing;
            }
            if(uint(this.oContainerRef.viewX) != uint(_nX) || uint(this.oContainerRef.viewY) != uint(_nY))
            {
               this.oContainerRef.display(_nX,_nY);
               this.oDebugLayer.x = -_nX;
               this.oDebugLayer.y = -_nY;
            }
         }
      }
      
      public function get viewRect() : Rectangle
      {
         return this.oContainerRef.viewRect;
      }
      
      public function set focusedElement(_oElement:IViewportTargetable) : void
      {
         this.oFocusedElementRef = _oElement;
      }
      
      public function get focusedElement() : IViewportTargetable
      {
         return this.oFocusedElementRef;
      }
   }
}

