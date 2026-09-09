package builderManager.elements
{
   import builderManager.BuilderManager;
   import com.sarbakan.sbdk.math.geom.AABB2;
   import flash.display.BitmapData;
   import flash.geom.Point;
   import media.type.AbstractMedia;
   import media.type.TileSurfaceMedia;
   
   public class TileElement extends BuilderElement
   {
      
      private var bIsSlope:Boolean;
      
      private var sLinkage:String;
      
      public function TileElement(_nX:Number, _nY:Number, _oMedia:AbstractMedia, _bFlip:Boolean, _sLinkage:String)
      {
         super(_nX,_nY,_oMedia,_bFlip);
         this.bIsSlope = Boolean(TileSurfaceMedia.SLOPE_LINKAGES.indexOf(_sLinkage) != -1);
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
               if(this.bIsSlope)
               {
                  _sReturn = "mcPlatform_tile05";
               }
               else
               {
                  _sReturn = "mcPlatform_tile01";
               }
               break;
            case 10:
               if(this.bIsSlope)
               {
                  _sReturn = "mcPlatform_tile09";
               }
               else
               {
                  _sReturn = "mcPlatform_tile12";
               }
               break;
            case 11:
               _sReturn = "mcPlatform_tile06";
               break;
            case 100:
               if(this.bIsSlope)
               {
                  _sReturn = "mcPlatform_tile13";
               }
               else
               {
                  _sReturn = "mcPlatform_tile00";
               }
               break;
            case 101:
               if(this.bIsSlope)
               {
                  _sReturn = "mcPlatform_tile04";
               }
               else
               {
                  _sReturn = "mcPlatform_tile01";
               }
               break;
            case 110:
               if(this.bIsSlope)
               {
                  _sReturn = "mcPlatform_tile08";
               }
               else
               {
                  _sReturn = "mcPlatform_tile10";
               }
               break;
            case 111:
               _sReturn = "mcPlatform_tile06";
               break;
            case 1000:
               if(this.bIsSlope)
               {
                  _sReturn = "mcPlatform_tile14";
               }
               else
               {
                  _sReturn = "mcPlatform_tile02";
               }
               break;
            case 1001:
               if(this.bIsSlope)
               {
                  _sReturn = "mcPlatform_tile05";
               }
               else
               {
                  _sReturn = "mcPlatform_tile01";
               }
               break;
            case 1010:
               if(this.bIsSlope)
               {
                  _sReturn = "mcPlatform_tile09";
               }
               else
               {
                  _sReturn = "mcPlatform_tile11";
               }
               break;
            case 1011:
               _sReturn = "mcPlatform_tile06";
               break;
            case 1100:
               _sReturn = "mcPlatform_tile01";
               break;
            case 1101:
               _sReturn = "mcPlatform_tile01";
               break;
            case 1110:
               _sReturn = "mcPlatform_tile07";
               break;
            case 1111:
               _sReturn = "mcPlatform_tile06";
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
         var _bTop:Boolean = false;
         var _bBottom:Boolean = false;
         var _oTile:Point = tilePos;
         for each(_oElement in _aSurrondingElements)
         {
            if(_oElement != this && _oElement.mediaType == mediaType)
            {
               _oElemTile = _oElement.tilePos;
               if(_oTile.x == _oElemTile.x)
               {
                  if(_oTile.y > _oElemTile.y)
                  {
                     _bTop = true;
                  }
                  else if(_oTile.y < _oElemTile.y)
                  {
                     _bBottom = true;
                  }
               }
               else if(_oTile.y == _oElemTile.y)
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
            _nByte += 1000;
         }
         if(_bRight)
         {
            _nByte += 100;
         }
         if(_bTop)
         {
            _nByte += 10;
         }
         if(_bBottom)
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

