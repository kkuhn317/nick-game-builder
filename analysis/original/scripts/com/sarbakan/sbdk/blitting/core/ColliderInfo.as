package com.sarbakan.sbdk.blitting.core
{
   import flash.geom.Rectangle;
   
   public class ColliderInfo
   {
      
      private var sName:String;
      
      private var oRect:Rectangle;
      
      private var oInitRect:Rectangle;
      
      private var nRadius:Number;
      
      private var nAngle:Number;
      
      private var nInitRadius:Number;
      
      private var nInitAngle:Number;
      
      public function ColliderInfo(_sName:String, _oRect:Rectangle, _nRadius:Number, _nAngle:Number)
      {
         super();
         this.sName = _sName;
         this.oRect = _oRect;
         this.oInitRect = this.oRect.clone();
         this.nRadius = _nRadius;
         this.nAngle = _nAngle;
         this.nInitRadius = this.nRadius;
         this.nInitAngle = this.nAngle;
      }
      
      public function clone() : ColliderInfo
      {
         return new ColliderInfo(this.sName,this.oRect.clone(),this.nRadius,this.nAngle);
      }
      
      public function reset() : void
      {
         this.oRect.x = this.initRect.x;
         this.oRect.y = this.initRect.y;
         this.oRect.width = this.initRect.width;
         this.oRect.height = this.initRect.height;
         this.nRadius = this.initRadius;
         this.nAngle = this.initAngle;
      }
      
      public function get name() : String
      {
         return this.sName;
      }
      
      public function get rect() : Rectangle
      {
         return this.oRect;
      }
      
      internal function get initRect() : Rectangle
      {
         return this.oInitRect;
      }
      
      public function get radius() : Number
      {
         return this.nRadius;
      }
      
      public function set radius(_nValue:Number) : void
      {
         this.nRadius = _nValue;
      }
      
      internal function get initRadius() : Number
      {
         return this.nInitRadius;
      }
      
      public function get angle() : Number
      {
         return this.nAngle;
      }
      
      public function set angle(_nValue:Number) : void
      {
         this.nAngle = _nValue;
      }
      
      internal function get initAngle() : Number
      {
         return this.nInitAngle;
      }
   }
}

