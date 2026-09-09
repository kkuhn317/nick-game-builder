package builderManager.elements
{
   import com.sarbakan.sbdk.data.spatialIndexing.ISpatialIndexElement;
   import com.sarbakan.sbdk.math.geom.AABB2;
   import flash.display.BitmapData;
   import flash.geom.Point;
   import media.type.AbstractMedia;
   
   public class BuilderElement
   {
      
      protected var oBounds:AABB2;
      
      protected var bFlip:Boolean;
      
      private var oSpatialIndex:ISpatialIndexElement;
      
      protected var oMedia:AbstractMedia;
      
      public function BuilderElement(_nX:Number, _nY:Number, _oMedia:AbstractMedia, _bFlip:Boolean)
      {
         super();
         this.oMedia = _oMedia;
         if(this.flippable)
         {
            this.bFlip = _bFlip;
         }
         this.oBounds = new AABB2(_nX,_nX + this.oMedia.getPreview().width - 0.01,_nY,_nY + this.oMedia.getPreview().height - 0.01);
      }
      
      public function destroy() : void
      {
         this.oBounds = null;
         this.oMedia = null;
         this.oSpatialIndex = null;
      }
      
      public function invalidate() : void
      {
      }
      
      public function getBitmapData(_nScale:Number = 1) : BitmapData
      {
         return this.oMedia.getPreview(null,_nScale,this.bFlip);
      }
      
      public function get spatialIndex() : ISpatialIndexElement
      {
         return this.oSpatialIndex;
      }
      
      public function set spatialIndex(_oValue:ISpatialIndexElement) : void
      {
         this.oSpatialIndex = _oValue;
      }
      
      public function get bounds() : AABB2
      {
         return this.oBounds;
      }
      
      public function get tilePos() : Point
      {
         return new Point(Math.floor(this.oBounds.nXMin / CommonConfig.nCELL_SIZE),Math.floor(this.oBounds.nYMin / CommonConfig.nCELL_SIZE));
      }
      
      public function get previewAlias() : String
      {
         return this.oMedia.alias;
      }
      
      public function get mediaAlias() : String
      {
         return this.oMedia.alias;
      }
      
      public function get mediaType() : String
      {
         return this.oMedia.type;
      }
      
      public function get isUnique() : Boolean
      {
         return false;
      }
      
      public function get flippable() : Boolean
      {
         return false;
      }
      
      public function get flip() : Boolean
      {
         return this.bFlip;
      }
      
      public function set flip(_bValue:Boolean) : void
      {
         this.bFlip = _bValue;
      }
      
      public function get linkage() : String
      {
         return null;
      }
   }
}

