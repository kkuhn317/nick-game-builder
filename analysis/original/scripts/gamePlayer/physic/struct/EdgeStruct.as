package gamePlayer.physic.struct
{
   import Box2D.Common.Math.b2Vec2;
   import flash.geom.Point;
   
   public class EdgeStruct
   {
      
      public var oPointA:b2Vec2;
      
      public var oEdgeA:EdgeStruct;
      
      public var oPointB:b2Vec2;
      
      public var oEdgeB:EdgeStruct;
      
      public var bIsFloor:Boolean;
      
      public function EdgeStruct(_oPointA:Point, _oPointB:Point, _bIsFloor:Boolean)
      {
         super();
         this.oPointA = b2Vec2.Make(_oPointA.x / CommonConfig.nCELL_SIZE,_oPointA.y / CommonConfig.nCELL_SIZE);
         this.oPointB = b2Vec2.Make(_oPointB.x / CommonConfig.nCELL_SIZE,_oPointB.y / CommonConfig.nCELL_SIZE);
         this.bIsFloor = _bIsFloor;
      }
      
      public static function createVertical(_nX:Number, _nY:Number, _bIsFloor:Boolean) : EdgeStruct
      {
         var _oPointA:Point = new Point(_nX,_nY);
         var _oPointB:Point = new Point(_nX,_nY + CommonConfig.nCELL_SIZE);
         return new EdgeStruct(_oPointA,_oPointB,_bIsFloor);
      }
      
      public static function createHorizontal(_nX:Number, _nY:Number, _bIsFloor:Boolean) : EdgeStruct
      {
         var _oPointA:Point = new Point(_nX,_nY);
         var _oPointB:Point = new Point(_nX + CommonConfig.nCELL_SIZE,_nY);
         return new EdgeStruct(_oPointA,_oPointB,_bIsFloor);
      }
      
      public static function createAscending(_nX:Number, _nY:Number, _bIsFloor:Boolean) : EdgeStruct
      {
         var _oPointA:Point = new Point(_nX,_nY + CommonConfig.nCELL_SIZE);
         var _oPointB:Point = new Point(_nX + CommonConfig.nCELL_SIZE,_nY);
         return new EdgeStruct(_oPointA,_oPointB,_bIsFloor);
      }
      
      public static function createDescending(_nX:Number, _nY:Number, _bIsFloor:Boolean) : EdgeStruct
      {
         var _oPointA:Point = new Point(_nX,_nY);
         var _oPointB:Point = new Point(_nX + CommonConfig.nCELL_SIZE,_nY + CommonConfig.nCELL_SIZE);
         return new EdgeStruct(_oPointA,_oPointB,_bIsFloor);
      }
      
      public function destroy() : void
      {
         this.oEdgeA = null;
         this.oEdgeB = null;
         this.oPointA = null;
         this.oPointB = null;
      }
   }
}

