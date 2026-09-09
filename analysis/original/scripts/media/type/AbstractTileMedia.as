package media.type
{
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   
   public class AbstractTileMedia extends AbstractMedia
   {
      
      public function AbstractTileMedia(_sAlias:String, _sMediaDirectory:String)
      {
         super(_sAlias,_sMediaDirectory);
      }
      
      override public function destroy() : void
      {
         super.destroy();
      }
      
      override protected function createPreview(_sPreviewLinkage:String, _nScale:Number = 1, _bFlip:Boolean = false) : BitmapData
      {
         var _oRect:Rectangle = null;
         var _cClass:Class = getClass(_sPreviewLinkage);
         var _mcPreview:MovieClip = new _cClass();
         var _mcMarquee:MovieClip = _mcPreview.getChildByName(sMARQUEE_PREVIEW_ZONE) as MovieClip;
         if(_mcMarquee != null)
         {
            _mcMarquee.visible = false;
            _oRect = _mcMarquee.getBounds(_mcPreview);
         }
         else
         {
            _oRect = _mcPreview.getBounds(_mcPreview);
         }
         if(_oRect.left < 0)
         {
            _oRect.x = 0;
            _oRect.width = Math.min(CommonConfig.nCELL_SIZE,_oRect.width);
         }
         if(_oRect.top < 0)
         {
            _oRect.y = 0;
            _oRect.height = Math.min(CommonConfig.nCELL_SIZE,_oRect.height);
         }
         var _oReturn:BitmapData = new BitmapData(_nScale * _oRect.width,_nScale * _oRect.height,true,0);
         if(_bFlip)
         {
            _oReturn.draw(_mcPreview,new Matrix(-_nScale,0,0,_nScale,_nScale * _oRect.width + _nScale * _oRect.left,-_nScale * _oRect.top));
         }
         else
         {
            _oReturn.draw(_mcPreview,new Matrix(_nScale,0,0,_nScale,-_nScale * _oRect.left,-_nScale * _oRect.top));
         }
         return _oReturn;
      }
   }
}

