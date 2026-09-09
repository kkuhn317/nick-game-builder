package de.polygonal.ds
{
   public class SListIterator implements Iterator
   {
      
      public var node:SListNode;
      
      public var list:SLinkedList;
      
      public function SListIterator(list:SLinkedList = null, node:SListNode = null)
      {
         super();
         this.list = list;
         this.node = node;
      }
      
      public function start() : void
      {
         if(Boolean(this.list))
         {
            this.node = this.list.head;
         }
      }
      
      public function next() : *
      {
         var obj:* = undefined;
         if(this.hasNext())
         {
            obj = this.node.data;
            this.node = this.node.next;
            return obj;
         }
         return null;
      }
      
      public function hasNext() : Boolean
      {
         return Boolean(this.node);
      }
      
      public function get data() : *
      {
         if(Boolean(this.node))
         {
            return this.node.data;
         }
         return null;
      }
      
      public function set data(obj:*) : void
      {
         this.node.data = obj;
      }
      
      public function end() : void
      {
         if(Boolean(this.list))
         {
            this.node = this.list.tail;
         }
      }
      
      public function forth() : void
      {
         if(Boolean(this.node))
         {
            this.node = this.node.next;
         }
      }
      
      public function valid() : Boolean
      {
         return Boolean(this.node);
      }
      
      public function remove() : Boolean
      {
         return this.list.remove(this);
      }
      
      public function toString() : String
      {
         return "{SListIterator: data=" + this.node.data + "}";
      }
   }
}

