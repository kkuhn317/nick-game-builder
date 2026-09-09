package de.polygonal.ds
{
   public class ArrayedQueue implements Collection
   {
      
      private var _que:Array;
      
      private var _size:int;
      
      private var _divisor:int;
      
      private var _count:int;
      
      private var _front:int;
      
      public function ArrayedQueue(size:int)
      {
         super();
         this.init(size);
      }
      
      public function get maxSize() : int
      {
         return this._size;
      }
      
      public function peek() : *
      {
         return this._que[this._front];
      }
      
      public function back() : *
      {
         return this._que[int(this._count - 1 + this._front & this._divisor)];
      }
      
      public function enqueue(obj:*) : Boolean
      {
         if(this._size != this._count)
         {
            this._que[int(this._count++ + this._front & this._divisor)] = obj;
            return true;
         }
         return false;
      }
      
      public function dequeue() : *
      {
         var data:* = undefined;
         if(this._count > 0)
         {
            data = this._que[int(this._front++)];
            if(this._front == this._size)
            {
               this._front = 0;
            }
            --this._count;
            return data;
         }
         return null;
      }
      
      public function dispose() : void
      {
         if(!this._front)
         {
            this._que[int(this._size - 1)] = null;
         }
         else
         {
            this._que[int(this._front - 1)] = null;
         }
      }
      
      public function getAt(i:int) : *
      {
         if(i >= this._count)
         {
            return null;
         }
         return this._que[int(i + this._front & this._divisor)];
      }
      
      public function setAt(i:int, obj:*) : void
      {
         if(i >= this._count)
         {
            return;
         }
         this._que[int(i + this._front & this._divisor)] = obj;
      }
      
      public function contains(obj:*) : Boolean
      {
         for(var i:int = 0; i < this._count; i++)
         {
            if(this._que[int(i + this._front & this._divisor)] === obj)
            {
               return true;
            }
         }
         return false;
      }
      
      public function clear() : void
      {
         this._que = new Array(this._size);
         this._front = this._count = 0;
         var i:int = 0;
         while(i < this._size)
         {
            this._que[i] = null;
            i++;
         }
      }
      
      public function getIterator() : Iterator
      {
         return new ArrayedQueueIterator(this);
      }
      
      public function get size() : int
      {
         return this._count;
      }
      
      public function isEmpty() : Boolean
      {
         return this._count == 0;
      }
      
      public function toArray() : Array
      {
         var a:Array = new Array(this._count);
         for(var i:int = 0; i < this._count; i++)
         {
            a[i] = this._que[int(i + this._front & this._divisor)];
         }
         return a;
      }
      
      public function toString() : String
      {
         return "[ArrayedQueue, size=" + this.size + "]";
      }
      
      public function dump() : String
      {
         var i:int = 0;
         var s:String = "[ArrayedQueue]\n";
         s += "\t" + this.getAt(i) + " -> front\n";
         for(i = 1; i < this._count; i++)
         {
            s += "\t" + this.getAt(i) + "\n";
         }
         return s;
      }
      
      private function init(size:int) : void
      {
         if(!(size > 0 && (size & size - 1) == 0))
         {
            size |= size >> 1;
            size |= size >> 2;
            size |= size >> 4;
            size |= size >> 8;
            size |= size >> 16;
            size++;
         }
         this._size = size;
         this._divisor = size - 1;
         this.clear();
      }
   }
}

class ArrayedQueueIterator implements Iterator
{
   
   private var _que:ArrayedQueue;
   
   private var _cursor:int;
   
   public function ArrayedQueueIterator(que:ArrayedQueue)
   {
      super();
      this._que = que;
      this._cursor = 0;
   }
   
   public function get data() : *
   {
      return this._que.getAt(this._cursor);
   }
   
   public function set data(obj:*) : void
   {
      this._que.setAt(this._cursor,obj);
   }
   
   public function start() : void
   {
      this._cursor = 0;
   }
   
   public function hasNext() : Boolean
   {
      return this._cursor < this._que.size;
   }
   
   public function next() : *
   {
      if(this._cursor < this._que.size)
      {
         return this._que.getAt(this._cursor++);
      }
      return null;
   }
}
