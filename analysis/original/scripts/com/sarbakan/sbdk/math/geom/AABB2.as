package com.sarbakan.sbdk.math.geom
{
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class AABB2
   {
      
      public var nXMin:Number;
      
      public var nXMax:Number;
      
      public var nYMin:Number;
      
      public var nYMax:Number;
      
      public function AABB2(_nXMin:Number = Infinity, _nXMax:Number = -Infinity, _nYMin:Number = Infinity, _nYMax:Number = -Infinity)
      {
         super();
         this.nXMin = _nXMin;
         this.nXMax = _nXMax;
         this.nYMin = _nYMin;
         this.nYMax = _nYMax;
      }
      
      public static function fromRectangle(_oRect:Rectangle) : AABB2
      {
         return new AABB2(_oRect.left,_oRect.right,_oRect.top,_oRect.bottom);
      }
      
      public static function fromPoint(_oPoint:Point) : AABB2
      {
         return new AABB2(_oPoint.x,_oPoint.x,_oPoint.y,_oPoint.y);
      }
      
      public function toRectangle() : Rectangle
      {
         return new Rectangle(this.nXMin,this.nYMin,this.nXMax - this.nXMin,this.nYMax - this.nYMin);
      }
      
      public function clone() : AABB2
      {
         return new AABB2(this.nXMin,this.nXMax,this.nYMin,this.nYMax);
      }
      
      public function offset(_nX:Number, _nY:Number) : void
      {
         this.nXMin += _nX;
         this.nXMax += _nX;
         this.nYMin += _nY;
         this.nYMax += _nY;
      }
      
      public function toString() : String
      {
         return "[AABB2 - xMin: " + this.nXMin + ", xMax: " + this.nXMax + ", yMin: " + this.nYMin + ", yMax: " + this.nYMax + "]";
      }
   }
}

