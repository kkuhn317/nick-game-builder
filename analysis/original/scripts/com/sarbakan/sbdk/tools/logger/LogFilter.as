package com.sarbakan.sbdk.tools.logger
{
   import com.sarbakan.sbdk.utils.ObjectList;
   
   public class LogFilter
   {
      
      private var lNamespaceList:ObjectList;
      
      private var lFunctionList:ObjectList;
      
      private var lLevelList:ObjectList;
      
      public function LogFilter()
      {
         super();
         this.init();
      }
      
      public function destroy() : void
      {
         this.lNamespaceList = null;
         this.lFunctionList = null;
         this.lLevelList = null;
      }
      
      public function excludeNamespace(_sNamespace:String) : void
      {
         if(this.lNamespaceList.contains(_sNamespace))
         {
            this.lNamespaceList.remove(_sNamespace);
         }
      }
      
      public function includeNamespace(_sNamespace:String) : void
      {
         this.lNamespaceList.insert(_sNamespace,_sNamespace);
      }
      
      public function excludeFunction(_sFunctionDef:String) : void
      {
         if(this.lFunctionList.contains(_sFunctionDef))
         {
            this.lFunctionList.remove(_sFunctionDef);
         }
      }
      
      public function includeFunction(_sFunctionDef:String) : void
      {
         this.lFunctionList.insert(_sFunctionDef,_sFunctionDef);
      }
      
      public function excludeLevel(_oLevel:LogLevel) : void
      {
         if(this.lLevelList.contains(_oLevel))
         {
            this.lLevelList.remove(_oLevel.toString());
         }
      }
      
      public function includeLevel(_oLevel:LogLevel) : void
      {
         this.lLevelList.insert(_oLevel.toString(),_oLevel.toString());
      }
      
      public function filter(_sScope:String, _sFunctionDef:String, _sMsg:String, _oLevel:LogLevel) : Boolean
      {
         var i:String = null;
         var _bDoPublish:Boolean = false;
         var _sLevel:String = _oLevel.toString();
         _sScope = _sScope;
         _sFunctionDef = _sFunctionDef;
         _sMsg = _sMsg;
         if(this.lNamespaceList.length > 0)
         {
            for each(i in this.lNamespaceList.object)
            {
               i = i;
               if(_sScope.indexOf(i) != -1)
               {
                  _bDoPublish = true;
                  break;
               }
            }
         }
         if(!_bDoPublish && this.lFunctionList.length > 0)
         {
            for each(i in this.lFunctionList.object)
            {
               i = i;
               if(_sFunctionDef.indexOf(String(i)) != -1)
               {
                  _bDoPublish = true;
                  break;
               }
            }
         }
         if(!_bDoPublish && this.lLevelList.length > 0)
         {
            for each(i in this.lLevelList.object)
            {
               i = i;
               if(_sLevel.indexOf(String(i)) != -1)
               {
                  _bDoPublish = true;
                  break;
               }
            }
         }
         return _bDoPublish;
      }
      
      private function init() : void
      {
         this.lNamespaceList = new ObjectList();
         this.lFunctionList = new ObjectList();
         this.lLevelList = new ObjectList();
      }
   }
}

