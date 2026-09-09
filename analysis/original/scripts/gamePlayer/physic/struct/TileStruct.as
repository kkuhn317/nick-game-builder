package gamePlayer.physic.struct
{
   import flash.geom.Point;
   import gamePlayer.elements.AbstractTileElement;
   
   public class TileStruct
   {
      
      public var oLeft:EdgeStruct;
      
      public var oRight:EdgeStruct;
      
      public var oTop:EdgeStruct;
      
      public var oBottom:EdgeStruct;
      
      public var oAscending:EdgeStruct;
      
      public var oDescending:EdgeStruct;
      
      private var oPos:Point;
      
      private var oTilePos:Point;
      
      private var oTile:AbstractTileElement;
      
      public function TileStruct(_oTile:AbstractTileElement, _oPos:Point)
      {
         super();
         this.oPos = _oPos;
         this.oTilePos = new Point(Math.floor(this.oPos.x / CommonConfig.nCELL_SIZE),Math.floor(this.oPos.y / CommonConfig.nCELL_SIZE));
         this.oTile = _oTile;
      }
      
      public function destroy() : void
      {
         this.oPos = null;
         this.oTilePos = null;
         if(Boolean(this.oLeft))
         {
            this.oLeft.destroy();
         }
         this.oLeft = null;
         if(Boolean(this.oRight))
         {
            this.oRight.destroy();
         }
         this.oRight = null;
         if(Boolean(this.oTop))
         {
            this.oTop.destroy();
         }
         this.oTop = null;
         if(Boolean(this.oBottom))
         {
            this.oBottom.destroy();
         }
         this.oBottom = null;
         if(Boolean(this.oAscending))
         {
            this.oAscending.destroy();
         }
         this.oAscending = null;
         if(Boolean(this.oDescending))
         {
            this.oDescending.destroy();
         }
         this.oDescending = null;
      }
      
      public function addLeft() : void
      {
         this.oLeft = EdgeStruct.createVertical(this.oPos.x,this.oPos.y,false);
      }
      
      public function addRight() : void
      {
         this.oRight = EdgeStruct.createVertical(this.oPos.x + CommonConfig.nCELL_SIZE,this.oPos.y,false);
      }
      
      public function addTop() : void
      {
         this.oTop = EdgeStruct.createHorizontal(this.oPos.x,this.oPos.y,true);
      }
      
      public function addBottom() : void
      {
         this.oBottom = EdgeStruct.createHorizontal(this.oPos.x,this.oPos.y + CommonConfig.nCELL_SIZE,false);
      }
      
      public function addAscending(_bIsFloor:Boolean) : void
      {
         this.oAscending = EdgeStruct.createAscending(this.oPos.x,this.oPos.y,_bIsFloor);
      }
      
      public function addDescending(_bIsFloor:Boolean) : void
      {
         this.oDescending = EdgeStruct.createDescending(this.oPos.x,this.oPos.y,_bIsFloor);
      }
      
      public function get tile() : AbstractTileElement
      {
         return this.oTile;
      }
      
      public function get type() : String
      {
         return this.oTile.type;
      }
      
      public function get tilePos() : Point
      {
         return this.oTilePos;
      }
      
      public function get edges() : Array
      {
         return [this.oLeft,this.oRight,this.oBottom,this.oTop,this.oAscending,this.oDescending];
      }
   }
}

