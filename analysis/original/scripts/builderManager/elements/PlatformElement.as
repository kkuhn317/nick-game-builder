package builderManager.elements
{
   import builderManager.BuilderManager;
   import com.sarbakan.sbdk.math.geom.AABB2;
   import flash.display.BitmapData;
   import flash.geom.Point;
   import media.type.AbstractMedia;
   
   public class PlatformElement extends BuilderElement
   {
      
      private var sLinkage:String;
      
      public function PlatformElement(_nX:Number, _nY:Number, _oMedia:AbstractMedia, _bFlip:Boolean)
      {
         super(_nX,_nY,_oMedia,_bFlip);
         oBounds.nXMax = _nX + CommonConfig.nCELL_SIZE - 0.1;
         oBounds.nYMax = _nY + CommonConfig.nCELL_SIZE - 0.1;
      }
      
      override public function destroy() : void
      {
         super.destroy();
      }
      
      override public function invalidate() : void
      {
         super.invalidate();
         this.sLinkage = null;
      }
      
      override public function getBitmapData(_nScale:Number = 1) : BitmapData
      {
         return oMedia.getPreview(this.linkage,_nScale);
      }
      
      private function findLinkage() : String
      {
         var _sReturn:String = null;
         switch(this.getSurroundingType())
         {
            case 0:
               _sReturn = "mcPlatform_tile03";
               break;
            case 1:
               _sReturn = "mcPlatform_tile00";
               break;
            case 10:
               _sReturn = "mcPlatform_tile02";
               break;
            case 11:
               _sReturn = "mcPlatform_tile01";
         }
         return _sReturn;
      }
      
      private function getSurroundingType() : Number
      {
         var _oElemTile:Point = null;
         var _oElement:BuilderElement = null;
         var _nByte:Number = NaN;
         var _oBounds:AABB2 = oBounds.clone();
         _oBounds.nXMin -= CommonConfig.nCELL_SIZE / 2;
         _oBounds.nXMax += CommonConfig.nCELL_SIZE / 2;
         _oBounds.nYMin -= CommonConfig.nCELL_SIZE / 2;
         _oBounds.nYMax += CommonConfig.nCELL_SIZE / 2;
         var _aSurrondingElements:Array = BuilderManager.instance.getElementInRegion(_oBounds);
         var _bLeft:Boolean = false;
         var _bRight:Boolean = false;
         var _oTile:Point = tilePos;
         for each(_oElement in _aSurrondingElements)
         {
            if(_oElement != this && _oElement.mediaType == mediaType)
            {
               _oElemTile = _oElement.tilePos;
               if(_oTile.y == _oElemTile.y)
               {
                  if(_oTile.x > _oElemTile.x)
                  {
                     _bLeft = true;
                  }
                  else
                  {
                     _bRight = true;
                  }
               }
            }
         }
         _nByte = 0;
         if(_bLeft)
         {
            _nByte += 10;
         }
         if(_bRight)
         {
            _nByte += 1;
         }
         return _nByte;
      }
      
      override public function get previewAlias() : String
      {
         return oMedia.alias + "_" + this.linkage;
      }
      
      override public function get linkage() : String
      {
         if(this.sLinkage == null)
         {
            this.sLinkage = this.findLinkage();
         }
         return this.sLinkage;
      }
   }
}

