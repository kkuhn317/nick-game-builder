package com.sarbakan.sbdk.blitting.core
{
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   
   public class TransformConfig
   {
      
      private var sVariantID:String;
      
      private var nRenderScale:Number;
      
      private var oMatrix:Matrix;
      
      private var oColorTransform:ColorTransform;
      
      private var bSmoothing:Boolean;
      
      private var aFilterList:Array;
      
      public function TransformConfig(_sVariantID:String, _nRenderScale:Number = 1, _oMatrix:Matrix = null, _oColorTransform:ColorTransform = null, _aFilters:Array = null, _bSmoothing:Boolean = false)
      {
         super();
         this.sVariantID = _sVariantID;
         this.nRenderScale = _nRenderScale;
         this.oMatrix = _oMatrix;
         this.oColorTransform = _oColorTransform;
         if(this.aFilterList != null)
         {
            this.aFilterList = _aFilters.concat();
         }
         this.bSmoothing = _bSmoothing;
      }
      
      public function get variantID() : String
      {
         return this.sVariantID;
      }
      
      public function set variantID(_sValue:String) : void
      {
         this.sVariantID = _sValue;
      }
      
      public function get renderScale() : Number
      {
         return this.nRenderScale;
      }
      
      public function set renderScale(_nValue:Number) : void
      {
         this.nRenderScale = _nValue;
      }
      
      public function get matrix() : Matrix
      {
         return this.oMatrix;
      }
      
      public function set matrix(_oValue:Matrix) : void
      {
         this.oMatrix = _oValue;
      }
      
      public function get colorTransform() : ColorTransform
      {
         return this.oColorTransform;
      }
      
      public function set colorTransform(_oValue:ColorTransform) : void
      {
         this.oColorTransform = _oValue;
      }
      
      public function get filters() : Array
      {
         return this.aFilterList;
      }
      
      public function set filters(_aValue:Array) : void
      {
         this.aFilterList = _aValue.concat();
      }
      
      public function get smoothing() : Boolean
      {
         return this.bSmoothing;
      }
      
      public function set smoothing(_bValue:Boolean) : void
      {
         this.bSmoothing = _bValue;
      }
   }
}

