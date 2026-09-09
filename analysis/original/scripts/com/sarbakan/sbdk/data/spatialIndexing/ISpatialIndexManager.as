package com.sarbakan.sbdk.data.spatialIndexing
{
   import com.sarbakan.sbdk.math.geom.AABB2;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public interface ISpatialIndexManager
   {
      
      function destroy() : void;
      
      function addElement(param1:AABB2, param2:*) : ISpatialIndexElement;
      
      function removeElement(param1:ISpatialIndexElement) : void;
      
      function queryElement(param1:ISpatialIndexElement) : Array;
      
      function queryRectangle(param1:Rectangle) : Array;
      
      function queryPoint(param1:Point) : Array;
      
      function queryBounds(param1:Number, param2:Number, param3:Number, param4:Number) : Array;
      
      function update() : void;
   }
}

