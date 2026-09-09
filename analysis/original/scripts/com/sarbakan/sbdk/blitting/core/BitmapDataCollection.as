package com.sarbakan.sbdk.blitting.core
{
   import com.sarbakan.sbdk.errors.ErrorMessages;
   import flash.display.BitmapData;
   import flash.geom.Rectangle;
   
   public class BitmapDataCollection
   {
      
      private static var oInstance:BitmapDataCollection;
      
      private static var bAllowConstruction:Boolean = false;
      
      private var aDataCollectionList:Array;
      
      public function BitmapDataCollection()
      {
         super();
         if(!bAllowConstruction)
         {
            throw new Error(ErrorMessages.sSINGLETON_ERROR);
         }
         this.init();
      }
      
      public static function get instance() : BitmapDataCollection
      {
         if(!oInstance)
         {
            bAllowConstruction = true;
            oInstance = new BitmapDataCollection();
            bAllowConstruction = false;
         }
         return oInstance;
      }
      
      public function destroy() : void
      {
         oInstance = null;
         for(var i:int = 0; i < this.aDataCollectionList.length; i++)
         {
            this.aDataCollectionList[i].destroy();
            this.aDataCollectionList[i] = null;
         }
         this.aDataCollectionList.splice(0,this.aDataCollectionList.length);
         this.aDataCollectionList = null;
      }
      
      public function containsCollection(_oClassRef:Class, _sVariantID:String = null, _bFlip:Boolean = false) : Boolean
      {
         return this.findCollectionInfo(_oClassRef,_sVariantID,_bFlip) != null;
      }
      
      public function requestCollection(_oClassRef:Class, _sVariantID:String = null, _bFlip:Boolean = false) : Array
      {
         var _oCollectionInfo:CollectionInfoStruct = this.findCollectionInfo(_oClassRef,_sVariantID,_bFlip);
         if(_oCollectionInfo != null)
         {
            return _oCollectionInfo.aFrameStructureList;
         }
         return null;
      }
      
      public function disposeCollection(_oClassRef:Class, _sVariantID:String = null) : void
      {
         var _oCollectionInfo:CollectionInfoStruct = null;
         var _nLength:int = int(this.aDataCollectionList.length);
         for(var i:int = 0; i < _nLength; i++)
         {
            _oCollectionInfo = this.aDataCollectionList[i];
            if(_oCollectionInfo.oClassRef == _oClassRef && _oCollectionInfo.sVariantID == _sVariantID)
            {
               _oCollectionInfo.destroy();
               this.aDataCollectionList.splice(i,1);
               break;
            }
         }
      }
      
      public function disposeGroup(_sGroupID:String) : void
      {
         for(var i:int = 0; i < this.aDataCollectionList.length; i++)
         {
            if(this.aDataCollectionList[i].sGroupID == _sGroupID && this.aDataCollectionList[i].sGroupID != null)
            {
               this.disposeCollection(this.aDataCollectionList[i].oClassRef,this.aDataCollectionList[i].sVariantID);
               i--;
            }
         }
      }
      
      public function disposeAll() : void
      {
         var _oCollectionInfo:CollectionInfoStruct = null;
         var _nLength:int = int(this.aDataCollectionList.length);
         for(var i:int = 0; i < _nLength; i++)
         {
            _oCollectionInfo = this.aDataCollectionList[i];
            _oCollectionInfo.destroy();
         }
         this.aDataCollectionList.splice(0,this.aDataCollectionList.length);
      }
      
      public function disposeData(_oClassRef:Class, _nFrameNumber:uint, _sVariantID:String = null) : Boolean
      {
         var _oCollectionInfo:CollectionInfoStruct = this.findCollectionInfo(_oClassRef,_sVariantID,false);
         var _oFlipCollectionInfo:CollectionInfoStruct = this.findCollectionInfo(_oClassRef,_sVariantID,true);
         if(_oCollectionInfo != null)
         {
            if(_oCollectionInfo.aFrameStructureList.length > _nFrameNumber)
            {
               _oCollectionInfo.aFrameStructureList.slice(_nFrameNumber,1);
               return true;
            }
         }
         if(_oFlipCollectionInfo != null)
         {
            if(_oFlipCollectionInfo.aFrameStructureList.length > _nFrameNumber)
            {
               _oFlipCollectionInfo.aFrameStructureList.slice(_nFrameNumber,1);
               return true;
            }
         }
         return false;
      }
      
      public function insertData(_sGroupID:String, _oClassRef:Class, _sVariantID:String, _nFrameNumber:uint, _oBitmapData:BitmapData, _oRect:Rectangle, _oMaxFrameSize:Rectangle, _nRadius:Number, _nAngleOffset:Number, _sLabel:String, _aColliders:Array, _bFlip:Boolean) : void
      {
         var _oCollectionInfo:CollectionInfoStruct = this.findCollectionInfo(_oClassRef,_sVariantID,_bFlip);
         if(_oCollectionInfo == null)
         {
            _oCollectionInfo = new CollectionInfoStruct();
            this.aDataCollectionList.push(_oCollectionInfo);
         }
         _oCollectionInfo.sGroupID = _sGroupID;
         _oCollectionInfo.oClassRef = _oClassRef;
         _oCollectionInfo.sVariantID = _sVariantID;
         _oCollectionInfo.bFlip = _bFlip;
         _oCollectionInfo.bColliders = _aColliders != null;
         _oCollectionInfo.aFrameStructureList[_nFrameNumber - 1] = new FrameInfoStruct(_oBitmapData,_oRect,_oMaxFrameSize,_nRadius,_nAngleOffset,_sLabel,_aColliders);
         for(var i:int = 0; i < _oCollectionInfo.aFrameStructureList.length; i++)
         {
            if(_oCollectionInfo.aFrameStructureList[i] == undefined)
            {
               if(_oCollectionInfo.aFrameStructureList[i - 1] != undefined && _oCollectionInfo.aFrameStructureList[i - 1] != null)
               {
                  _oCollectionInfo.aFrameStructureList[i] = _oCollectionInfo.aFrameStructureList[i - 1];
               }
            }
         }
      }
      
      public function colliderExist(_oClassRef:Class, _sVariantID:String) : Boolean
      {
         var _oCollectionInfo:CollectionInfoStruct = this.findCollectionInfo(_oClassRef,_sVariantID,false);
         if(_oCollectionInfo != null)
         {
            return _oCollectionInfo.bColliders;
         }
         return false;
      }
      
      private function init() : void
      {
         this.aDataCollectionList = new Array();
      }
      
      private function findCollectionInfo(_oClassRef:Class, _sVariantID:String, _bFlip:Boolean) : CollectionInfoStruct
      {
         var _oCollectionInfo:CollectionInfoStruct = null;
         for(var i:int = 0; i < this.aDataCollectionList.length; i++)
         {
            _oCollectionInfo = this.aDataCollectionList[i];
            if(_sVariantID != null || _sVariantID != "")
            {
               if(_oCollectionInfo.oClassRef == _oClassRef && _oCollectionInfo.sVariantID == _sVariantID && _oCollectionInfo.bFlip == _bFlip)
               {
                  return _oCollectionInfo;
               }
            }
            else if(_oCollectionInfo.oClassRef == _oClassRef && _oCollectionInfo.bFlip == _bFlip)
            {
               return _oCollectionInfo;
            }
         }
         return null;
      }
   }
}

class CollectionInfoStruct
{
   
   public var sGroupID:String;
   
   public var oClassRef:Class;
   
   public var sVariantID:String;
   
   public var bFlip:Boolean;
   
   public var aFrameStructureList:Array;
   
   public var bColliders:Boolean;
   
   public function CollectionInfoStruct()
   {
      super();
      this.aFrameStructureList = new Array();
   }
   
   public function destroy() : void
   {
      var _nLength:int = int(this.aFrameStructureList.length);
      this.oClassRef = null;
      for(var i:int = 0; i < _nLength; i++)
      {
         this.aFrameStructureList[i].frameData.dispose();
      }
      this.aFrameStructureList.splice(0,this.aFrameStructureList.length);
      this.aFrameStructureList = null;
   }
}
