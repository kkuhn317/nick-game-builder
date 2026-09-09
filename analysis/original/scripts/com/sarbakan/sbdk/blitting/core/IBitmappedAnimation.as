package com.sarbakan.sbdk.blitting.core
{
   import com.sarbakan.sbdk.data.spatialIndexing.ISpatialIndexElement;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import flash.geom.Rectangle;
   
   public interface IBitmappedAnimation
   {
      
      function destroy() : void;
      
      function gotoAndStop(param1:Object) : void;
      
      function gotoAndPlay(param1:Object) : void;
      
      function nextFrame() : void;
      
      function prevFrame() : void;
      
      function play() : void;
      
      function stop() : void;
      
      function getColliderByName(param1:String, param2:Boolean = false) : ColliderInfo;
      
      function hitTestObject(param1:IBitmappedAnimation, param2:Boolean = true) : Boolean;
      
      function hitTestPoint(param1:int, param2:int, param3:Boolean = true) : Boolean;
      
      function hitTestRect(param1:Rectangle, param2:Boolean = true) : Boolean;
      
      function hitTestMovieClip(param1:DisplayObject, param2:Boolean = true) : Boolean;
      
      function setDisplayed(param1:Boolean) : void;
      
      function onMouseEvent(param1:MouseEvent) : void;
      
      function onMouseOut(param1:MouseEvent) : void;
      
      function get paused() : Boolean;
      
      function get currentFrame() : uint;
      
      function get frameRate() : int;
      
      function set frameRate(param1:int) : void;
      
      function get colliders() : Array;
      
      function get totalFrames() : uint;
      
      function get smoothing() : Boolean;
      
      function set smoothing(param1:Boolean) : void;
      
      function get looping() : Boolean;
      
      function set looping(param1:Boolean) : void;
      
      function get ID() : BitmappedObjID;
      
      function get visible() : Boolean;
      
      function set visible(param1:Boolean) : void;
      
      function get showColliders() : Boolean;
      
      function set showColliders(param1:Boolean) : void;
      
      function get rect() : Rectangle;
      
      function get frameRect() : Rectangle;
      
      function get showRedrawRegion() : Boolean;
      
      function set showRedrawRegion(param1:Boolean) : void;
      
      function get rotation() : Number;
      
      function set rotation(param1:Number) : void;
      
      function get alpha() : Number;
      
      function set alpha(param1:Number) : void;
      
      function get scaleX() : Number;
      
      function set scaleX(param1:Number) : void;
      
      function get scaleY() : Number;
      
      function set scaleY(param1:Number) : void;
      
      function get colorTransform() : ColorTransform;
      
      function set colorTransform(param1:ColorTransform) : void;
      
      function get filters() : Array;
      
      function set filters(param1:Array) : void;
      
      function get flip() : Boolean;
      
      function set flip(param1:Boolean) : void;
      
      function get frameData() : BitmapData;
      
      function get x() : Number;
      
      function set x(param1:Number) : void;
      
      function get y() : Number;
      
      function set y(param1:Number) : void;
      
      function get width() : uint;
      
      function set width(param1:uint) : void;
      
      function get mouseEnabled() : Boolean;
      
      function set mouseEnabled(param1:Boolean) : void;
      
      function get pixelSnapping() : Boolean;
      
      function set pixelSnapping(param1:Boolean) : void;
      
      function get height() : uint;
      
      function set height(param1:uint) : void;
      
      function get depth() : int;
      
      function set depth(param1:int) : void;
      
      function get layer() : String;
      
      function set layer(param1:String) : void;
      
      function get layerDepth() : int;
      
      function set layerDepth(param1:int) : void;
      
      function get spatialIndexHandler() : ISpatialIndexElement;
      
      function set spatialIndexHandler(param1:ISpatialIndexElement) : void;
      
      function get moving() : Boolean;
      
      function set moving(param1:Boolean) : void;
      
      function get displayed() : Boolean;
      
      function setContainer(param1:BitmappedAnimContainer) : void;
      
      function get container() : BitmappedAnimContainer;
   }
}

