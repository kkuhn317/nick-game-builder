package de.polygonal.ds
{
   import de.polygonal.ds.sort.compare.compareStringCaseInSensitive;
   import de.polygonal.ds.sort.compare.compareStringCaseInSensitiveDesc;
   import de.polygonal.ds.sort.compare.compareStringCaseSensitive;
   import de.polygonal.ds.sort.compare.compareStringCaseSensitiveDesc;
   import de.polygonal.ds.sort.sLinkedInsertionSort;
   import de.polygonal.ds.sort.sLinkedInsertionSortCmp;
   import de.polygonal.ds.sort.sLinkedMergeSort;
   import de.polygonal.ds.sort.sLinkedMergeSortCmp;
   
   public class SLinkedList implements Collection
   {
      
      public static const INSERTION_SORT:int = 1 << 1;
      
      public static const MERGE_SORT:int = 1 << 2;
      
      public static const NUMERIC:int = 1 << 3;
      
      public static const DESCENDING:int = 1 << 4;
      
      private var _count:int;
      
      public var head:SListNode;
      
      public var tail:SListNode;
      
      public function SLinkedList(... args)
      {
         super();
         this.head = this.tail = null;
         this._count = 0;
         if(args.length > 0)
         {
            this.append.apply(this,args);
         }
      }
      
      public function append(... args) : SListNode
      {
         var t:SListNode = null;
         var i:int = 0;
         var k:int = int(args.length);
         var node:SListNode = new SListNode(args[0]);
         if(Boolean(this.head))
         {
            this.tail.next = node;
            this.tail = node;
         }
         else
         {
            this.head = this.tail = node;
         }
         if(k > 1)
         {
            t = node;
            for(i = 1; i < k; i++)
            {
               node = new SListNode(args[i]);
               this.tail.next = node;
               this.tail = node;
            }
            this._count += k;
            return t;
         }
         ++this._count;
         return node;
      }
      
      public function prepend(... args) : SListNode
      {
         var t:SListNode = null;
         var i:int = 0;
         var k:int = int(args.length);
         var node:SListNode = new SListNode(args[int(k - 1)]);
         if(Boolean(this.head))
         {
            node.next = this.head;
            this.head = node;
         }
         else
         {
            this.head = this.tail = node;
         }
         if(k > 1)
         {
            t = node;
            for(i = k - 2; i >= 0; i--)
            {
               node = new SListNode(args[i]);
               node.next = this.head;
               this.head = node;
            }
            this._count += k;
            return t;
         }
         ++this._count;
         return node;
      }
      
      public function insertAfter(itr:SListIterator, obj:*) : SListNode
      {
         var node:SListNode = null;
         if(itr.list != this)
         {
            return null;
         }
         if(Boolean(itr.node))
         {
            node = new SListNode(obj);
            itr.node.insertAfter(node);
            if(itr.node == this.tail)
            {
               this.tail = itr.node.next;
            }
            ++this._count;
            return node;
         }
         return this.append(obj);
      }
      
      public function remove(itr:SListIterator) : Boolean
      {
         if(itr.list != this || !itr.node)
         {
            return false;
         }
         var node:SListNode = this.head;
         if(itr.node == this.head)
         {
            itr.forth();
            this.removeHead();
            return true;
         }
         while(node.next != itr.node)
         {
            node = node.next;
         }
         itr.forth();
         if(node.next == this.tail)
         {
            this.tail = node;
         }
         node.next = itr.node;
         --this._count;
         return true;
      }
      
      public function removeHead() : *
      {
         var obj:* = undefined;
         var node:SListNode = null;
         if(Boolean(this.head))
         {
            obj = this.head.data;
            if(this.head == this.tail)
            {
               this.head = this.tail = null;
            }
            else
            {
               node = this.head;
               this.head = this.head.next;
               node.next = null;
               if(this.head == null)
               {
                  this.tail = null;
               }
            }
            --this._count;
            return obj;
         }
         return null;
      }
      
      public function removeTail() : *
      {
         var obj:* = undefined;
         var node:SListNode = null;
         if(Boolean(this.tail))
         {
            obj = this.tail.data;
            if(this.head == this.tail)
            {
               this.head = this.tail = null;
            }
            else
            {
               node = this.head;
               while(node.next != this.tail)
               {
                  node = node.next;
               }
               this.tail = node;
               node.next = null;
            }
            --this._count;
            return obj;
         }
         return null;
      }
      
      public function merge(... args) : void
      {
         var a:SLinkedList = null;
         a = args[0];
         if(Boolean(this.head))
         {
            this.tail.next = a.head;
            this.tail = a.tail;
         }
         else
         {
            this.head = a.head;
            this.tail = a.tail;
         }
         var k:int = int(args.length);
         for(var i:int = 1; i < k; i++)
         {
            a = args[i];
            this.tail.next = a.head;
            this.tail = a.tail;
            this._count += a.size;
         }
      }
      
      public function concat(... args) : SLinkedList
      {
         var a:SLinkedList = null;
         var n:SListNode = null;
         var c:SLinkedList = new SLinkedList();
         n = this.head;
         while(Boolean(n))
         {
            c.append(n.data);
            n = n.next;
         }
         var k:int = int(args.length);
         for(var i:int = 0; i < k; i++)
         {
            a = args[i];
            n = a.head;
            while(Boolean(n))
            {
               c.append(n.data);
               n = n.next;
            }
         }
         return c;
      }
      
      public function sort(... sortOptions) : void
      {
         var b:int = 0;
         var cmp:Function = null;
         var o:* = undefined;
         if(this._count <= 1)
         {
            return;
         }
         if(sortOptions.length > 0)
         {
            b = 0;
            cmp = null;
            o = sortOptions[0];
            if(o is Function)
            {
               cmp = o;
               if(sortOptions.length > 1)
               {
                  o = sortOptions[1];
                  if(o is int)
                  {
                     b = o;
                  }
               }
            }
            else if(o is int)
            {
               b = o;
            }
            if(Boolean(cmp))
            {
               if(Boolean(b & 2))
               {
                  this.head = sLinkedInsertionSortCmp(this.head,cmp,b == 18);
               }
               else
               {
                  this.head = sLinkedMergeSortCmp(this.head,cmp,b == 16);
               }
            }
            else if(Boolean(b & 2))
            {
               if(Boolean(b & 4))
               {
                  if(b == 22)
                  {
                     this.head = sLinkedInsertionSortCmp(this.head,compareStringCaseSensitiveDesc);
                  }
                  else if(b == 14)
                  {
                     this.head = sLinkedInsertionSortCmp(this.head,compareStringCaseInSensitive);
                  }
                  else if(b == 30)
                  {
                     this.head = sLinkedInsertionSortCmp(this.head,compareStringCaseInSensitiveDesc);
                  }
                  else
                  {
                     this.head = sLinkedInsertionSortCmp(this.head,compareStringCaseSensitive);
                  }
               }
               else
               {
                  this.head = sLinkedInsertionSort(this.head,b == 18);
               }
            }
            else if(Boolean(b & 4))
            {
               if(b == 20)
               {
                  this.head = sLinkedMergeSortCmp(this.head,compareStringCaseSensitiveDesc);
               }
               else if(b == 12)
               {
                  this.head = sLinkedMergeSortCmp(this.head,compareStringCaseInSensitive);
               }
               else if(b == 28)
               {
                  this.head = sLinkedMergeSortCmp(this.head,compareStringCaseInSensitiveDesc);
               }
               else
               {
                  this.head = sLinkedMergeSortCmp(this.head,compareStringCaseSensitive);
               }
            }
            else if(Boolean(b & 0x10))
            {
               this.head = sLinkedMergeSort(this.head,true);
            }
         }
         else
         {
            this.head = sLinkedMergeSort(this.head);
         }
      }
      
      public function nodeOf(obj:*, from:SListIterator = null) : SListIterator
      {
         if(from != null)
         {
            if(from.list != null)
            {
               return null;
            }
         }
         var node:SListNode = from == null ? this.head : from.node;
         while(Boolean(node))
         {
            if(node.data === obj)
            {
               return new SListIterator(this,node);
            }
            node = node.next;
         }
         return null;
      }
      
      public function splice(start:SListIterator, deleteCount:uint = 4294967295, ... args) : SLinkedList
      {
         var s:SListNode = null;
         var t:SListNode = null;
         var c:SLinkedList = null;
         var i:int = 0;
         var k:int = 0;
         var n:SListNode = null;
         if(Boolean(start))
         {
            if(start.list != this)
            {
               return null;
            }
         }
         if(Boolean(start.node))
         {
            s = start.node;
            t = this.head;
            while(t.next != s)
            {
               t = t.next;
            }
            c = new SLinkedList();
            if(deleteCount == 4294967295)
            {
               if(start.node == this.tail)
               {
                  return c;
               }
               while(Boolean(start.node))
               {
                  c.append(start.node.data);
                  start.remove();
               }
               start.list = c;
               start.node = s;
               return c;
            }
            for(i = 0; i < deleteCount; i++)
            {
               if(!Boolean(start.node))
               {
                  break;
               }
               c.append(start.node.data);
               start.remove();
            }
            k = int(args.length);
            if(k > 0)
            {
               if(this._count == 0)
               {
                  for(i = 0; i < k; i++)
                  {
                     this.append(args[i]);
                  }
               }
               else if(t == null)
               {
                  n = this.prepend(args[0]);
                  for(i = 1; i < k; i++)
                  {
                     n.insertAfter(new SListNode(args[i]));
                     if(n == this.tail)
                     {
                        this.tail = n.next;
                     }
                     n = n.next;
                     ++this._count;
                  }
               }
               else
               {
                  n = t;
                  for(i = 0; i < k; i++)
                  {
                     n.insertAfter(new SListNode(args[i]));
                     if(n == this.tail)
                     {
                        this.tail = n.next;
                     }
                     n = n.next;
                     ++this._count;
                  }
               }
               start.node = n;
            }
            else
            {
               start.node = s;
            }
            start.list = c;
            return c;
         }
         return null;
      }
      
      public function shiftUp() : void
      {
         var t:SListNode = this.head;
         if(this.head.next == this.tail)
         {
            this.head = this.tail;
            this.tail = t;
            this.tail.next = null;
            this.head.next = this.tail;
         }
         else
         {
            this.head = this.head.next;
            this.tail.next = t;
            t.next = null;
            this.tail = t;
         }
      }
      
      public function popDown() : void
      {
         var node:SListNode = null;
         var t:SListNode = this.tail;
         if(this.head.next == this.tail)
         {
            this.tail = this.head;
            this.head = t;
            this.tail.next = null;
            this.head.next = this.tail;
         }
         else
         {
            node = this.head;
            while(node.next != this.tail)
            {
               node = node.next;
            }
            this.tail = node;
            this.tail.next = null;
            t.next = this.head;
            this.head = t;
         }
      }
      
      public function reverse() : void
      {
         if(this._count == 0)
         {
            return;
         }
         var a:Array = new Array(this._count);
         var i:int = 0;
         var node:SListNode = this.head;
         while(Boolean(node))
         {
            a[i++] = node;
            node = node.next;
         }
         a.reverse();
         node = this.head = a[0];
         for(i = 1; i < this._count; i++)
         {
            node = node.next = a[i];
         }
         node.next = null;
         this.tail = node;
         a = null;
      }
      
      public function join(sep:*) : String
      {
         if(this._count == 0)
         {
            return "";
         }
         var s:String = "";
         var node:SListNode = this.head;
         while(Boolean(node.next))
         {
            s += node.data + sep;
            node = node.next;
         }
         return s + node.data;
      }
      
      public function contains(obj:*) : Boolean
      {
         var node:SListNode = this.head;
         while(Boolean(node))
         {
            if(node.data == obj)
            {
               return true;
            }
            node = node.next;
         }
         return false;
      }
      
      public function clear() : void
      {
         var next:SListNode = null;
         var node:SListNode = this.head;
         this.head = null;
         while(Boolean(node))
         {
            next = node.next;
            node.next = null;
            node = next;
         }
         this._count = 0;
      }
      
      public function getIterator() : Iterator
      {
         return new SListIterator(this,this.head);
      }
      
      public function getListIterator() : SListIterator
      {
         return new SListIterator(this,this.head);
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
         var a:Array = [];
         var node:SListNode = this.head;
         while(Boolean(node))
         {
            a.push(node.data);
            node = node.next;
         }
         return a;
      }
      
      public function toString() : String
      {
         return "[SlinkedList, size=" + this.size + "]";
      }
      
      public function dump() : String
      {
         if(!this.head)
         {
            return "SLinkedList: (empty)";
         }
         var s:String = "SLinkedList: has " + this._count + " node" + (this._count == 1 ? "" : "s") + "\n|< Head\n";
         for(var itr:SListIterator = this.getListIterator(); itr.valid(); )
         {
            s += "\t" + itr.data + "\n";
            itr.forth();
         }
         return s + "Tail >|";
      }
   }
}

