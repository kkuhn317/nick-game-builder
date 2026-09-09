package com.sarbakan.sbdk.tools
{
   import com.sarbakan.sbdk.errors.AbstractMethodError;
   import com.sarbakan.sbdk.errors.AssertError;
   import com.sarbakan.sbdk.errors.ErrorMessages;
   import flash.utils.getQualifiedClassName;
   
   public class Debug
   {
      
      private static var bTrowAssertInConsole:Boolean = false;
      
      public function Debug()
      {
         super();
      }
      
      public static function assert(_bCondition:Boolean, _sMessage:String, _oReplacements:Object = null, _sFunction:String = null, _sClass:String = null) : void
      {
         if(_bCondition != true)
         {
            _sMessage = replaceKeywords(_sMessage,_oReplacements);
            if(!bTrowAssertInConsole)
            {
               throw new AssertError(_sMessage);
            }
         }
      }
      
      public static function forceAbstractImplementation(_oObjectInstance:Object, _sMethodName:String) : void
      {
         _sMethodName = getQualifiedClassName(_oObjectInstance).replace("::",".") + "." + _sMethodName + "()";
         throw new AbstractMethodError(replaceKeywords(ErrorMessages.sABSTRACT_METHOD_NOT_IMPLEMENTED,{"method":_sMethodName}));
      }
      
      public static function stringify(_oObjectInstance:*, _nDepth:int = -1) : String
      {
         var i:* = undefined;
         var _sArrayClass:String = "Array";
         var _sObjectClass:String = "Object";
         var _sProperties:String = "";
         var _aPropertyNameList:Array = new Array();
         var _aPropertyValList:Array = new Array();
         if(getQualifiedClassName(_oObjectInstance) == _sObjectClass)
         {
            _sProperties = "Type : Object\n\n";
         }
         else if(getQualifiedClassName(_oObjectInstance) == _sArrayClass)
         {
            _sProperties = "Type : Array\n\n";
         }
         for(i in _oObjectInstance)
         {
            _aPropertyNameList.push(i);
         }
         for each(i in _oObjectInstance)
         {
            _aPropertyValList.push(i);
         }
         if(_nDepth == -1)
         {
            for(i = 0; i < _aPropertyNameList.length; i++)
            {
               _sProperties += _aPropertyNameList[i] + ": " + _aPropertyValList[i] + "\n";
            }
         }
         else if(_nDepth > 0)
         {
            for(i = 0; i < _nDepth; i++)
            {
               _sProperties += _aPropertyNameList[i] + ": " + _aPropertyValList[i] + "\n";
            }
         }
         return _sProperties;
      }
      
      private static function replaceKeywords(_sString:String, _oReplacements:Object = null) : String
      {
         var _sKeyword:String = null;
         for(_sKeyword in _oReplacements)
         {
            _sString = _sString.replace("%" + _sKeyword + "%",_oReplacements[_sKeyword]);
         }
         return _sString;
      }
      
      public static function get trowAssertInConsole() : Boolean
      {
         return bTrowAssertInConsole;
      }
      
      public static function set trowAssertInConsole(_bConsole:Boolean) : void
      {
         bTrowAssertInConsole = _bConsole;
      }
   }
}

