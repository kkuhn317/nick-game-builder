package com.sarbakan.sbdk.blitting.core
{
   public class BitmappedObjID
   {
      
      private var sClassName:String;
      
      private var sVariantID:String;
      
      public function BitmappedObjID(_oClassName:String, _sVariantID:String)
      {
         super();
         this.sClassName = _oClassName;
         this.sVariantID = _sVariantID;
      }
      
      public function get className() : String
      {
         return this.sClassName;
      }
      
      public function get variantID() : String
      {
         return this.sVariantID;
      }
   }
}

