package com.sarbakan.sbdk.blitting.core
{
   import flash.display.BitmapData;
   import flash.geom.Rectangle;
   
   public class FrameInfoStruct
   {
      
      private var oFrameData:BitmapData;
      
      private var sLabel:String;
      
      private var aColliders:Array;
      
      private var oRect:Rectangle;
      
      private var oInitRect:Rectangle;
      
      private var nRadius:Number;
      
      private var nInitRadius:Number;
      
      private var nAngleOffset:Number;
      
      private var nInitAngleOffset:Number;
      
      private var nMaxFrameWidth:Number;
      
      private var nMaxFrameHeight:Number;
      
      public function FrameInfoStruct(_oFrameData:BitmapData, _oRect:Rectangle, _oMaxFrameSize:Rectangle, _nRadius:Number, _nAngleOffset:Number, _sLabel:String = null, _aColliders:Array = null)
      {
         super();
         this.oFrameData = _oFrameData;
         this.oRect = _oRect;
         this.oInitRect = this.oRect.clone();
         this.nRadius = _nRadius;
         this.nInitRadius = this.nRadius;
         this.nAngleOffset = _nAngleOffset;
         this.nInitAngleOffset = this.nAngleOffset;
         this.sLabel = _sLabel;
         this.aColliders = _aColliders;
         this.nMaxFrameWidth = _oMaxFrameSize.width;
         this.nMaxFrameHeight = _oMaxFrameSize.height;
      }
      
      public function destroy() : void
      {
         this.oFrameData.dispose();
         this.aColliders.splice(0,this.aColliders.length);
         this.oRect = null;
         this.oInitRect = null;
      }
      
      public function clone() : FrameInfoStruct
      {
         if(this.aColliders == null)
         {
            return new FrameInfoStruct(this.oFrameData,this.oRect.clone(),new Rectangle(0,0,this.nMaxFrameWidth,this.nMaxFrameHeight),this.nRadius,this.nAngleOffset,this.sLabel,null);
         }
         return new FrameInfoStruct(this.oFrameData,this.oRect.clone(),new Rectangle(0,0,this.nMaxFrameWidth,this.nMaxFrameHeight),this.nRadius,this.nAngleOffset,this.sLabel,this.aColliders.concat());
      }
      
      public function get frameData() : BitmapData
      {
         return this.oFrameData;
      }
      
      public function get label() : String
      {
         return this.sLabel;
      }
      
      internal function get radius() : Number
      {
         return this.nRadius;
      }
      
      internal function set radius(_nValue:Number) : void
      {
         this.nRadius = _nValue;
      }
      
      internal function get initRadius() : Number
      {
         return this.nInitRadius;
      }
      
      internal function get angleOffset() : Number
      {
         return this.nAngleOffset;
      }
      
      internal function set angleOffset(_nValue:Number) : void
      {
         this.nAngleOffset = _nValue;
      }
      
      internal function get initAngleOffset() : Number
      {
         return this.nInitAngleOffset;
      }
      
      public function get colliders() : Array
      {
         return this.aColliders;
      }
      
      public function get rect() : Rectangle
      {
         return this.oRect;
      }
      
      internal function get initRect() : Rectangle
      {
         return this.oInitRect;
      }
      
      public function get frameWidth() : Number
      {
         return this.nMaxFrameWidth;
      }
      
      public function get frameHeight() : Number
      {
         return this.nMaxFrameHeight;
      }
   }
}

