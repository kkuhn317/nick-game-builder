package com.sarbakan.sbdk.blitting.core
{
   import com.sarbakan.sbdk.data.spatialIndexing.ISpatialIndexElement;
   import com.sarbakan.sbdk.math.geom.AABB2;
   import flash.display.BitmapData;
   import flash.geom.Point;
   
   public class StillElement
   {
      
      private var oBounds:AABB2;
      
      private var oOffset:Point;
      
      private var nDepth:uint;
      
      private var oBD:BitmapData;
      
      private var oContainer:StillGenerator;
      
      private var oSpatialIndex:ISpatialIndexElement;
      
      public function StillElement(_oBD:BitmapData, _nX:Number, _nY:Number, _nDepth:uint = 0)
      {
         super();
         this.oBD = _oBD;
         this.oBounds = new AABB2(_nX,_nX + this.oBD.width,_nY,_nY + this.oBD.height);
         this.oOffset = new Point();
         this.nDepth = _nDepth;
      }
      
      public static function fromClass(_oClass:Class, _sVariant:String, _nX:Number, _nY:Number, _nFrame:uint = 0, _nDepth:int = 0) : StillElement
      {
         var _oAssetFrame:FrameInfoStruct = BitmapDataCollection.instance.requestCollection(_oClass,_sVariant)[_nFrame];
         var _oAssetBD:BitmapData = _oAssetFrame.frameData;
         var _oReturn:StillElement = new StillElement(_oAssetBD,_nX,_nY,_nDepth);
         _oReturn.offset = _oAssetFrame.rect.topLeft.clone();
         return _oReturn;
      }
      
      public function destroy() : void
      {
         if(Boolean(this.oContainer))
         {
            this.oContainer.removeElement(this);
         }
         this.oOffset = null;
         this.oBD = null;
      }
      
      public function setPos(_nX:Number, _nY:Number) : void
      {
         if(Boolean(this.oContainer))
         {
            this.oContainer.invalidate(this.oBounds);
         }
         this.oBounds.nXMin = _nX + this.oOffset.x;
         this.oBounds.nXMax = _nX + this.oBD.width + this.oOffset.x;
         this.oBounds.nYMin = _nY + this.oOffset.y;
         this.oBounds.nYMax = _nY + this.oBD.height + this.oOffset.y;
         if(Boolean(this.oSpatialIndex))
         {
            this.oSpatialIndex.setPositionBox(this.oBounds);
         }
         if(Boolean(this.oContainer))
         {
            this.oContainer.invalidate(this.oBounds,true);
         }
      }
      
      public function get depth() : uint
      {
         return this.nDepth;
      }
      
      public function set offset(_oValue:Point) : void
      {
         this.oOffset = _oValue;
         this.setPos(this.oBounds.nXMin,this.oBounds.nYMin);
      }
      
      public function get width() : Number
      {
         return this.oBD.width;
      }
      
      public function get height() : Number
      {
         return this.oBD.height;
      }
      
      internal function get container() : StillGenerator
      {
         return this.oContainer;
      }
      
      internal function set container(_oValue:StillGenerator) : void
      {
         this.oContainer = _oValue;
      }
      
      internal function get spatialIndex() : ISpatialIndexElement
      {
         return this.oSpatialIndex;
      }
      
      internal function set spatialIndex(_oIndex:ISpatialIndexElement) : void
      {
         this.oSpatialIndex = _oIndex;
      }
      
      internal function get bounds() : AABB2
      {
         return this.oBounds;
      }
      
      internal function get bitmapData() : BitmapData
      {
         return this.oBD;
      }
   }
}

