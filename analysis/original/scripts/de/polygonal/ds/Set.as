package de.polygonal.ds
{
   import flash.utils.Dictionary;
   
   public class Set implements Collection
   {
      
      private var _set:Dictionary = new Dictionary(true);
      
      private var _size:int;
      
      public function Set()
      {
         super();
         this._set = new Dictionary();
      }
      
      public function get(obj:*) : *
      {
         var val:* = this._set[obj];
         return val != undefined ? val : null;
      }
      
      public function set(obj:*) : void
      {
         if(obj == null)
         {
            return;
         }
         if(obj == undefined)
         {
            return;
         }
         if(Boolean(this._set[obj]))
         {
            return;
         }
         this._set[obj] = obj;
         ++this._size;
      }
      
      public function remove(obj:*) : Boolean
      {
         if(this._set[obj] != undefined)
         {
            delete this._set[obj];
            --this._size;
            return true;
         }
         return false;
      }
      
      public function contains(obj:*) : Boolean
      {
         return this._set[obj] != undefined;
      }
      
      public function clear() : void
      {
         this._set = new Dictionary();
         this._size = 0;
      }
      
      public function getIterator() : Iterator
      {
         return new SetIterator(this);
      }
      
      public function get size() : int
      {
         return this._size;
      }
      
      public function isEmpty() : Boolean
      {
         return this._size == 0;
      }
      
      public function toArray() : Array
      {
         var j:int = 0;
         var i:* = undefined;
         var a:Array = new Array(this._size);
         for(i in this._set)
         {
            a[j++] = i;
         }
         return a;
      }
      
      public function toString() : String
      {
         return "[Set, size=" + this.size + "]";
      }
      
      public function dump() : String
      {
         var i:* = undefined;
         var s:String = "Set:\n";
         for each(i in this._set)
         {
            s += "[val: " + i + "]\n";
         }
         return s;
      }
   }
}

class SetIterator implements Iterator
{
   
   private var _s:Set;
   
   private var _a:Array;
   
   private var _cursor:int;
   
   private var _size:int;
   
   public function SetIterator(s:Set)
   {
      super();
      this._s = s;
      this._a = s.toArray();
      this._cursor = 0;
      this._size = s.size;
   }
   
   public function next() : *
   {
      return this._a[this._cursor++];
   }
   
   public function hasNext() : Boolean
   {
      return this._cursor < this._size;
   }
   
   public function start() : void
   {
      this._cursor = 0;
   }
   
   public function get data() : *
   {
      return this._a[this._cursor];
   }
   
   public function set data(obj:*) : void
   {
      this._s.remove(this._a[this._cursor]);
      this._s.set(obj);
   }
}
