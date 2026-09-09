package media.type
{
   import com.sarbakan.sbdk.events.PreloadEvent;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.geom.Matrix;
   
   public class PropsMedia extends AbstractMedia
   {
      
      public static const TYPE:String = "props";
      
      private var oBD:BitmapData;
      
      public function PropsMedia(_sAlias:String, _sMediaDirectory:String)
      {
         super(_sAlias,_sMediaDirectory);
      }
      
      override public function destroy() : void
      {
         super.destroy();
         if(Boolean(this.oBD))
         {
            this.oBD.dispose();
         }
         this.oBD = null;
      }
      
      override public function getPreview(_sPreviewLinkage:String = null, _nScale:Number = 1, _bFlip:Boolean = false) : BitmapData
      {
         var _oReturn:BitmapData = null;
         if(_nScale == 1)
         {
            _oReturn = this.oBD;
         }
         else
         {
            _oReturn = new BitmapData(this.oBD.width * _nScale,this.oBD.height * _nScale,true,0);
            _oReturn.draw(this.oBD,new Matrix(_nScale,0,0,_nScale),null,null,null,true);
         }
         return _oReturn;
      }
      
      override protected function onGameLoaded(_e:PreloadEvent) : void
      {
         bGameLoaded = true;
         this.oBD = Bitmap(_e.content).bitmapData;
      }
      
      override protected function onPreviewLoaded(_e:PreloadEvent) : void
      {
         bPreviewLoaded = true;
      }
      
      override public function get type() : String
      {
         return TYPE;
      }
      
      override public function get gameSuffixe() : String
      {
         return ".png";
      }
      
      override public function get previewSuffixe() : String
      {
         return null;
      }
      
      public function get bitmapData() : BitmapData
      {
         return this.oBD;
      }
   }
}

