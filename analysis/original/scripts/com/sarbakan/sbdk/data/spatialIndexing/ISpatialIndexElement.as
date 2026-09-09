package com.sarbakan.sbdk.data.spatialIndexing
{
   import com.sarbakan.sbdk.math.geom.AABB2;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public interface ISpatialIndexElement
   {
      
      function setPositionPoint(param1:Point) : void;
      
      function setPositionRectangle(param1:Rectangle) : void;
      
      function setPositionBox(param1:AABB2) : void;
      
      function setPosition(param1:Number, param2:Number, param3:Number, param4:Number) : void;
      
      function get bounds() : AABB2;
      
      function get boundsRectangle() : Rectangle;
      
      function get data() : *;
      
      function set data(param1:*) : void;
   }
}

