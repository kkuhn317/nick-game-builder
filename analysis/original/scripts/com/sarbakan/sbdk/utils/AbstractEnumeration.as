package com.sarbakan.sbdk.utils
{
   import com.sarbakan.sbdk.errors.ErrorMessages;
   import flash.errors.IllegalOperationError;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public class AbstractEnumeration
   {
      
      protected static var oProtectionFlag:Object = new Object();
      
      private var sName:String;
      
      public function AbstractEnumeration(_sName:String, _oProtectionFlag:Object)
      {
         super();
         if(Class(getDefinitionByName(getQualifiedClassName(this))) == AbstractEnumeration)
         {
            throw new IllegalOperationError(ErrorMessages.sABSTRACT_CLASS_ERROR);
         }
         if(_oProtectionFlag == oProtectionFlag)
         {
            this.sName = _sName;
         }
      }
      
      public function toString() : String
      {
         return this.sName;
      }
   }
}

