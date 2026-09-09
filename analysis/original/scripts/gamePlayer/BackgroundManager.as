package gamePlayer
{
   import com.sarbakan.sbdk.blitting.core.BitmapDataCollection;
   import com.sarbakan.sbdk.math.random.Random;
   import com.sarbakan.sbdk.math.random.seedAlgorithm.BitmapBased;
   import com.sarbakan.sbdk.utils.ObjectList;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.PixelSnapping;
   import flash.geom.Point;
   import media.type.BackgroundMedia;
   
   public class BackgroundManager
   {
      
      private static const nSPEED_FIRST_LAYER:Number = 0.5;
      
      private static const nSPEED_SECOND_LAYER:Number = 0.8;
      
      private static const nRANDOM_LENGTH:uint = 15;
      
      private var oStillBD:BitmapData;
      
      private var lLinkageDef:ObjectList;
      
      private var oBitmap:Bitmap;
      
      private var oBackbuffer:BitmapData;
      
      private var oLastPos:Point;
      
      private var nCurrentZoom:Number;
      
      private var aRandom:Array;
      
      private var oMedia:BackgroundMedia;
      
      private var oPosOffset:Point;
      
      public function BackgroundManager()
      {
         super();
      }
      
      public function destroy() : void
      {
         if(Boolean(this.oBackbuffer))
         {
            this.oBackbuffer.dispose();
         }
         this.oBackbuffer = null;
         this.oBitmap = null;
         this.clearScaledPanel();
         this.aRandom = null;
         this.oPosOffset = null;
         this.oMedia = null;
      }
      
      public function init(_nWidth:uint, _nHeight:uint, _oMedia:BackgroundMedia, _oPosOffset:Point) : void
      {
         this.oMedia = _oMedia;
         this.oPosOffset = _oPosOffset;
         this.oLastPos = new Point(NaN,NaN);
         this.oBackbuffer = new BitmapData(_nWidth,_nHeight);
         this.oBitmap = new Bitmap(this.oBackbuffer,PixelSnapping.ALWAYS,true);
         this.nCurrentZoom = 1;
         this.initLinkageDefs();
         this.initRandom();
      }
      
      public function updatePos(_nX:Number, _nY:Number, _bInvalidate:Boolean = false) : void
      {
         if(this.oLastPos.x != _nX || this.oLastPos.y != _nY)
         {
            this.oLastPos.x = _nX;
            this.oLastPos.y = _nY;
            _bInvalidate = true;
         }
         if(_bInvalidate)
         {
            this.oBackbuffer.lock();
            this.oBackbuffer.copyPixels(this.oStillBD,this.oStillBD.rect,new Point());
            _nX += this.oPosOffset.x * this.nCurrentZoom;
            _nY += this.oPosOffset.y * this.nCurrentZoom;
            this.renderLayer(0,Math.floor(nSPEED_FIRST_LAYER * this.nCurrentZoom * _nX),Math.floor(nSPEED_FIRST_LAYER * this.nCurrentZoom * _nY));
            this.renderLayer(1,Math.floor(nSPEED_SECOND_LAYER * this.nCurrentZoom * _nX),Math.floor(nSPEED_SECOND_LAYER * this.nCurrentZoom * _nY));
            this.oBackbuffer.unlock();
         }
      }
      
      private function initLinkageDefs() : void
      {
         this.oStillBD = BitmapDataCollection.instance.requestCollection(this.oMedia.getClass(BackgroundMedia.LINKAGE_STILL))[0].frameData;
         this.lLinkageDef = new ObjectList();
         this.addLinkageDef(BackgroundMedia.LINKAGE_BOTTOM_FIRST);
         this.addLinkageDef(BackgroundMedia.LINKAGE_BOTTOM_SECOND);
         this.addLinkageDef(BackgroundMedia.LINKAGE_MIDDLE_FIRST);
         this.addLinkageDef(BackgroundMedia.LINKAGE_MIDDLE_SECOND);
         this.addLinkageDef(BackgroundMedia.LINKAGE_TOP_FIRST);
         this.addLinkageDef(BackgroundMedia.LINKAGE_TOP_SECOND);
      }
      
      private function addLinkageDef(_sClass:String) : void
      {
         this.lLinkageDef.insert(_sClass,new LinkageDef(this.oMedia.getClass(_sClass)));
      }
      
      private function initRandom() : void
      {
         var _oRand:Random = new Random(new BitmapBased(1921885));
         this.aRandom = new Array();
         for(var y:uint = 0; y < nRANDOM_LENGTH; y++)
         {
            this.aRandom.push(new Array());
            while(this.aRandom[y].length < nRANDOM_LENGTH)
            {
               this.aRandom[y].push(_oRand.getFloat());
            }
         }
      }
      
      private function renderLayer(_nLayerID:uint, _nX:Number, _nY:Number) : void
      {
         var _oLinkage:LinkageDef = null;
         var _nCurrentLine:int = 0;
         var _nCenterY:Number = NaN;
         var _nCenterHeight:Number = NaN;
         var _nLineHeight:Number = NaN;
         var _nZero:Number = NaN;
         _oLinkage = this.lLinkageDef.find(this.getRowLinkage(_nLayerID,0));
         _nCenterHeight = Math.floor(_oLinkage.rect.height * this.nCurrentZoom);
         _nCenterY = -_nY - _nCenterHeight / 2;
         _nCurrentLine = 0;
         this.renderLine(_oLinkage,_nX,_nCenterY,_nCurrentLine);
         _oLinkage = this.lLinkageDef.find(this.getRowLinkage(_nLayerID,-1));
         _nLineHeight = Math.floor(_oLinkage.rect.height * this.nCurrentZoom);
         _nZero = _nCenterY;
         _nCurrentLine = -Math.floor(_nZero / _nLineHeight) - 1;
         while(_nCurrentLine < 0 && this.renderLine(_oLinkage,_nX,_nZero + _nCurrentLine * _nLineHeight,_nCurrentLine))
         {
            _nCurrentLine++;
         }
         _oLinkage = this.lLinkageDef.find(this.getRowLinkage(_nLayerID,1));
         _nLineHeight = _oLinkage.getBD(this.nCurrentZoom,0).rect.height;
         _nZero = _nCenterY + _nCenterHeight;
         _nCurrentLine = -Math.ceil((_nZero - this.oBackbuffer.height) / _nLineHeight) + 1;
         while(_nCurrentLine > 0 && this.renderLine(_oLinkage,_nX,_nZero + (_nCurrentLine - 1) * _nLineHeight,_nCurrentLine))
         {
            _nCurrentLine--;
         }
      }
      
      private function renderLine(_oLinkage:LinkageDef, _nX:Number, _nRenderY:Number, _nLine:int) : Boolean
      {
         var _nFrameWidth:Number = NaN;
         var _nCol:int = 0;
         var _nRenderX:Number = NaN;
         var _bRender:Boolean = false;
         if(_nRenderY <= this.oBackbuffer.height && _nRenderY + _oLinkage.rect.height >= 0)
         {
            _nFrameWidth = _oLinkage.getBD(this.nCurrentZoom,0).rect.width;
            _nCol = Math.floor(_nX / _nFrameWidth);
            _nRenderX = _nCol * _nFrameWidth - _nX;
            while(_nRenderX < this.oBackbuffer.width)
            {
               this.addFrame(_oLinkage,_nRenderX,_nRenderY,this.getRandom(_nCol,_nLine));
               _nRenderX += _nFrameWidth;
               _nCol++;
            }
            _bRender = true;
         }
         return _bRender;
      }
      
      private function addFrame(_oLinkage:LinkageDef, _nRenderX:Number, _nRenderY:Number, _nRandom:Number) : void
      {
         var _oBD:BitmapData = _oLinkage.getBD(this.nCurrentZoom,_nRandom);
         this.oBackbuffer.copyPixels(_oBD,_oBD.rect,new Point(_nRenderX,_nRenderY),null,null,true);
      }
      
      private function clearScaledPanel() : void
      {
         var _oDef:LinkageDef = null;
         for each(_oDef in this.lLinkageDef.object)
         {
            _oDef.clearScaled();
         }
      }
      
      private function getRowLinkage(_nLayerID:uint, _nRowID:int = 0) : String
      {
         var _sReturn:String = null;
         if(_nLayerID == 0)
         {
            switch(_nRowID)
            {
               case -1:
                  _sReturn = BackgroundMedia.LINKAGE_TOP_SECOND;
                  break;
               case 0:
                  _sReturn = BackgroundMedia.LINKAGE_MIDDLE_SECOND;
                  break;
               case 1:
                  _sReturn = BackgroundMedia.LINKAGE_BOTTOM_SECOND;
            }
         }
         else
         {
            switch(_nRowID)
            {
               case -1:
                  _sReturn = BackgroundMedia.LINKAGE_TOP_FIRST;
                  break;
               case 0:
                  _sReturn = BackgroundMedia.LINKAGE_MIDDLE_FIRST;
                  break;
               case 1:
                  _sReturn = BackgroundMedia.LINKAGE_BOTTOM_FIRST;
            }
         }
         return _sReturn;
      }
      
      private function getRandom(_nCol:int, _nLine:int) : Number
      {
         _nCol = Math.abs(_nCol) % nRANDOM_LENGTH;
         _nLine = Math.abs(_nLine) % nRANDOM_LENGTH;
         return this.aRandom[_nCol][_nLine];
      }
      
      public function get alias() : String
      {
         return this.oMedia.alias;
      }
      
      public function get bitmap() : Bitmap
      {
         return this.oBitmap;
      }
      
      public function set zoom(_nValue:Number) : void
      {
         if(this.nCurrentZoom != _nValue)
         {
            this.nCurrentZoom = _nValue;
            this.clearScaledPanel();
         }
      }
   }
}

import com.sarbakan.sbdk.blitting.core.BitmapDataCollection;
import com.sarbakan.sbdk.blitting.core.ColliderInfo;
import com.sarbakan.sbdk.blitting.core.FrameInfoStruct;
import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

class LinkageDef
{
   
   private static const sCOLLIDER_NAME:String = "zone";
   
   private var aBD:Array;
   
   private var aScaledBD:Array;
   
   private var oRect:Rectangle;
   
   public function LinkageDef(_oClass:Class)
   {
      var _oFrameInfo:FrameInfoStruct = null;
      var _oBD:BitmapData = null;
      var _oSourceRect:Rectangle = null;
      super();
      var _aFrames:Array = this.getFramesList(_oClass);
      this.aBD = new Array();
      this.oRect = this.getFrameRect(_aFrames);
      for(var i:uint = 0; i < _aFrames.length; i++)
      {
         _oFrameInfo = _aFrames[i];
         _oBD = new BitmapData(this.oRect.width,this.oRect.height,true,0);
         _oSourceRect = new Rectangle(this.oRect.x - _oFrameInfo.rect.x,this.oRect.y - _oFrameInfo.rect.y,this.oRect.width,this.oRect.height);
         _oBD.copyPixels(_oFrameInfo.frameData,_oSourceRect,new Point());
         this.aBD.push(_oBD);
      }
   }
   
   public function clearScaled() : void
   {
      var _oBD:BitmapData = null;
      if(Boolean(this.aScaledBD))
      {
         for each(_oBD in this.aScaledBD)
         {
            _oBD.dispose();
         }
      }
      this.aScaledBD = null;
   }
   
   public function getBD(_nScale:Number, _nRandom:Number) : BitmapData
   {
      var _oReturn:BitmapData = null;
      var _nFrame:uint = uint(this.getFrameFromRandom(_nRandom));
      if(_nScale == 1)
      {
         _oReturn = this.aBD[_nFrame];
      }
      else
      {
         _oReturn = this.getScaledBD(_nFrame,_nScale);
      }
      return _oReturn;
   }
   
   private function getFramesList(_cClass:Class) : Array
   {
      return BitmapDataCollection.instance.requestCollection(_cClass);
   }
   
   private function getFrameRect(_aFrameList:Array) : Rectangle
   {
      var i:uint = 0;
      var _oCollider:ColliderInfo = null;
      var _oFrameInfo:FrameInfoStruct = _aFrameList[0];
      var _oReturn:Rectangle = _oFrameInfo.frameData.rect.clone();
      var _aColliders:Array = _oFrameInfo.colliders;
      if(Boolean(_aColliders))
      {
         for(i = 0; i < _aColliders.length; i++)
         {
            _oCollider = _aColliders[i];
            if(_oCollider.name == sCOLLIDER_NAME)
            {
               _oReturn = _oCollider.rect;
               break;
            }
         }
      }
      return _oReturn;
   }
   
   private function getScaledBD(_nFrame:uint, _nScale:Number, _bSmooth:Boolean = true) : BitmapData
   {
      var _oBD:BitmapData = null;
      var _nScaleX:Number = NaN;
      var _nScaleY:Number = NaN;
      if(this.aScaledBD == null)
      {
         this.aScaledBD = new Array();
      }
      var _oReturn:BitmapData = this.aScaledBD[_nFrame];
      if(_oReturn == null)
      {
         _oBD = this.aBD[_nFrame];
         _nScaleX = Math.ceil(_oBD.width * _nScale) / _oBD.width;
         _nScaleY = Math.ceil(_oBD.height * _nScale) / _oBD.height;
         _oReturn = new BitmapData(_oBD.width * _nScaleX,_oBD.height * _nScaleY,true,0);
         _oReturn.draw(_oBD,new Matrix(_nScaleX,0,0,_nScaleY),null,null,null,_bSmooth);
         this.aScaledBD[_nFrame] = _oReturn;
      }
      return _oReturn;
   }
   
   private function getFrameFromRandom(_nRandom:Number) : uint
   {
      return this.aBD.length * _nRandom;
   }
   
   public function get rect() : Rectangle
   {
      return this.oRect;
   }
}
