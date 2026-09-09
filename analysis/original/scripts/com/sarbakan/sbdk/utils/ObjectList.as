package com.sarbakan.sbdk.utils
{
   public class ObjectList
   {
      
      private var oList:Object;
      
      public function ObjectList()
      {
         super();
         this.init();
      }
      
      public function destroy() : void
      {
         this.oList = null;
      }
      
      public function find(_sKey:String) : *
      {
         if(this.oList != null)
         {
            return this.oList[_sKey];
         }
         return null;
      }
      
      public function insert(_sKey:String, _oObject:Object) : Object
      {
         if(this.oList[_sKey] == null)
         {
            this.oList[_sKey] = _oObject;
            return _oObject;
         }
         return null;
      }
      
      public function modify(_sKey:String, _oObject:Object) : void
      {
         if(this.oList[_sKey] != null)
         {
            this.oList[_sKey] = _oObject;
         }
      }
      
      public function remove(_sKey:String) : void
      {
         if(this.oList[_sKey] != null)
         {
            delete this.oList[_sKey];
         }
      }
      
      public function contains(_oObject:Object) : Boolean
      {
         var i:String = null;
         for(i in this.oList)
         {
            if(this.oList[i] == _oObject)
            {
               return true;
            }
         }
         return false;
      }
      
      public function findKey(_oObject:Object) : String
      {
         var i:String = null;
         for(i in this.oList)
         {
            if(this.oList[i] == _oObject)
            {
               return i;
            }
         }
         return null;
      }
      
      public function toArray() : Array
      {
         var i:String = null;
         var aList:Array = new Array();
         for(i in this.oList)
         {
            if(this.oList[i] != null)
            {
               aList.push({
                  "key":i,
                  "object":this.oList[i]
               });
            }
         }
         if(aList.length > 0)
         {
            return aList;
         }
         return [];
      }
      
      public function fromArray(_aArray:Array) : void
      {
         var i:* = undefined;
         for(i in _aArray)
         {
            this.insert(i,_aArray[i]);
         }
      }
      
      public function clear() : void
      {
         var i:String = null;
         for(i in this.oList)
         {
            delete this.oList[i];
         }
      }
      
      private function init() : void
      {
         this.oList = new Object();
      }
      
      public function get length() : int
      {
         var i:String = null;
         var nLength:int = 0;
         for(i in this.oList)
         {
            if(this.oList[i] != null)
            {
               nLength++;
            }
         }
         return nLength;
      }
      
      public function get object() : Object
      {
         return this.oList;
      }
   }
}

