package de.polygonal.ds
{
   public class SListNode implements LinkedListNode
   {
      
      public var data:*;
      
      public var next:SListNode;
      
      public function SListNode(obj:*)
      {
         super();
         this.data = obj;
         this.next = null;
      }
      
      public function insertAfter(node:SListNode) : void
      {
         node.next = this.next;
         this.next = node;
      }
      
      public function toString() : String
      {
         return "[SListNode, data=" + this.data + "]";
      }
   }
}

