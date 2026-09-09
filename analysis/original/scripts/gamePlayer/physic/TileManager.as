package gamePlayer.physic
{
   import Box2D.Collision.Shapes.b2PolygonShape;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2BodyDef;
   import Box2D.Dynamics.b2FixtureDef;
   import com.sarbakan.sbdk.errors.ErrorMessages;
   import com.sarbakan.sbdk.utils.ExternalConfig;
   import com.sarbakan.sbdk.utils.ObjectList;
   import com.sarbakan.sbdk.view.ViewManager;
   import flash.geom.Point;
   import gamePlayer.GamePlayer;
   import gamePlayer.GamePlayerConfig;
   import gamePlayer.elements.AbstractTileElement;
   import gamePlayer.physic.struct.EdgeStruct;
   import gamePlayer.physic.struct.TileStruct;
   import utils.enum.SurfaceType;
   
   public class TileManager
   {
      
      private static var oInstance:TileManager;
      
      public static const EDGES_FULL:uint = 1;
      
      public static const EDGES_TOP_ASCENDING:uint = 2;
      
      public static const EDGES_TOP_DESCENDING:uint = 3;
      
      public static const EDGES_BOTTOM_ASCENDING:uint = 4;
      
      public static const EDGES_BOTTOM_DESCENDING:uint = 5;
      
      public static const EDGES_PLATFORM:uint = 6;
      
      private static var bAllowConstruction:Boolean = false;
      
      private var oTiles:ObjectList;
      
      public function TileManager()
      {
         super();
         if(!bAllowConstruction)
         {
            throw new Error(ErrorMessages.sSINGLETON_STAGE);
         }
         this.init();
      }
      
      public static function get instance() : TileManager
      {
         if(oInstance == null)
         {
            bAllowConstruction = true;
            oInstance = new TileManager();
            bAllowConstruction = false;
         }
         return oInstance;
      }
      
      public function destroy() : void
      {
         this.clearAllTilesStruct();
         oInstance = null;
      }
      
      public function addTile(_oTile:AbstractTileElement, _oPos:Point, _nEdgesDefinition:uint) : void
      {
         var _nTileX:int = 0;
         var _nTileY:int = 0;
         var _oStruct:TileStruct = new TileStruct(_oTile,_oPos);
         switch(_nEdgesDefinition)
         {
            case EDGES_FULL:
               _oStruct.addLeft();
               _oStruct.addRight();
               _oStruct.addTop();
               _oStruct.addBottom();
               break;
            case EDGES_TOP_ASCENDING:
               _oStruct.addRight();
               _oStruct.addBottom();
               _oStruct.addAscending(true);
               break;
            case EDGES_TOP_DESCENDING:
               _oStruct.addLeft();
               _oStruct.addBottom();
               _oStruct.addDescending(true);
               break;
            case EDGES_BOTTOM_DESCENDING:
               _oStruct.addRight();
               _oStruct.addTop();
               _oStruct.addDescending(false);
               break;
            case EDGES_BOTTOM_ASCENDING:
               _oStruct.addLeft();
               _oStruct.addTop();
               _oStruct.addAscending(false);
               break;
            case EDGES_PLATFORM:
               _oStruct.addTop();
               break;
            default:
               _oStruct.destroy();
               _oStruct = null;
         }
         if(Boolean(_oStruct))
         {
            _nTileX = Math.floor(_oPos.x / CommonConfig.nCELL_SIZE);
            _nTileY = Math.floor(_oPos.y / CommonConfig.nCELL_SIZE);
            this.oTiles.insert(_nTileX + "_" + _nTileY,_oStruct);
         }
      }
      
      public function addPlatformObject(_oPos:Point, _nWidth:Number) : void
      {
         this.createPlatformBody(SurfaceType.PLATFORM,new b2Vec2(_oPos.x / CommonConfig.nCELL_SIZE,_oPos.y / CommonConfig.nCELL_SIZE),new b2Vec2((_oPos.x + _nWidth) / CommonConfig.nCELL_SIZE,_oPos.y / CommonConfig.nCELL_SIZE));
      }
      
      public function initTilesPhysic() : void
      {
         this.clearDoubledEdges();
         this.mergeEdges();
         this.generateShapes();
         this.clearAllTilesStruct();
         this.createSurroundingBody();
      }
      
      private function init() : void
      {
         this.oTiles = new ObjectList();
      }
      
      private function getTileAt(_nX:int, _nY:int) : TileStruct
      {
         return this.oTiles.find(_nX + "_" + _nY);
      }
      
      private function clearDoubledEdges() : void
      {
         var _oTile:TileStruct = null;
         var _oRight:TileStruct = null;
         var _oBottom:TileStruct = null;
         for each(_oTile in this.oTiles.object)
         {
            if(Boolean(_oTile.oRight))
            {
               _oRight = this.getTileAt(_oTile.tilePos.x + 1,_oTile.tilePos.y);
               if(Boolean(_oRight) && Boolean(_oRight.oLeft) && _oTile.type == _oRight.type)
               {
                  _oTile.oRight = null;
                  _oRight.oLeft = null;
               }
            }
            if(Boolean(_oTile.oBottom))
            {
               _oBottom = this.getTileAt(_oTile.tilePos.x,_oTile.tilePos.y + 1);
               if(Boolean(_oBottom) && Boolean(_oBottom.oTop) && _oTile.type == _oBottom.type)
               {
                  _oTile.oBottom = null;
                  _oBottom.oTop = null;
               }
            }
         }
      }
      
      private function mergeEdges() : void
      {
         var _oTile:TileStruct = null;
         for each(_oTile in this.oTiles.object)
         {
            this.mergeVerticals(_oTile);
            this.mergeHorizontals(_oTile);
            this.mergeAscending(_oTile);
            this.mergeDescending(_oTile);
         }
      }
      
      private function mergeVerticals(_oTile:TileStruct) : void
      {
         var _oBottom:TileStruct = this.getTileAt(_oTile.tilePos.x,_oTile.tilePos.y + 1);
         if(Boolean(_oBottom) && _oTile.type == _oBottom.type)
         {
            if(Boolean(_oTile.oLeft) && Boolean(_oBottom.oLeft))
            {
               _oTile.oLeft.oEdgeB = _oBottom.oLeft;
               _oBottom.oLeft.oEdgeA = _oTile.oLeft;
            }
            if(Boolean(_oTile.oRight) && Boolean(_oBottom.oRight))
            {
               _oTile.oRight.oEdgeB = _oBottom.oRight;
               _oBottom.oRight.oEdgeA = _oTile.oRight;
            }
         }
      }
      
      private function mergeHorizontals(_oTile:TileStruct) : void
      {
         var _oRight:TileStruct = this.getTileAt(_oTile.tilePos.x + 1,_oTile.tilePos.y);
         if(Boolean(_oRight) && _oTile.type == _oRight.type)
         {
            if(Boolean(_oTile.oBottom) && Boolean(_oRight.oBottom))
            {
               _oTile.oBottom.oEdgeB = _oRight.oBottom;
               _oRight.oBottom.oEdgeA = _oTile.oBottom;
            }
            if(Boolean(_oTile.oTop) && Boolean(_oRight.oTop))
            {
               _oTile.oTop.oEdgeB = _oRight.oTop;
               _oRight.oTop.oEdgeA = _oTile.oTop;
            }
         }
      }
      
      private function mergeAscending(_oTile:TileStruct) : void
      {
         var _oTopRight:TileStruct = null;
         if(Boolean(_oTile.oAscending))
         {
            _oTopRight = this.getTileAt(_oTile.tilePos.x + 1,_oTile.tilePos.y - 1);
            if(Boolean(_oTopRight && _oTopRight.oAscending) && Boolean(_oTile.type == _oTopRight.type) && _oTile.oAscending.bIsFloor == _oTopRight.oAscending.bIsFloor)
            {
               _oTile.oAscending.oEdgeB = _oTopRight.oAscending;
               _oTopRight.oAscending.oEdgeA = _oTile.oAscending;
            }
         }
      }
      
      private function mergeDescending(_oTile:TileStruct) : void
      {
         var _oBottomRight:TileStruct = null;
         if(Boolean(_oTile.oDescending))
         {
            _oBottomRight = this.getTileAt(_oTile.tilePos.x + 1,_oTile.tilePos.y + 1);
            if(Boolean(_oBottomRight && _oBottomRight.oDescending) && Boolean(_oTile.type == _oBottomRight.type) && _oTile.oDescending.bIsFloor == _oBottomRight.oDescending.bIsFloor)
            {
               _oTile.oDescending.oEdgeB = _oBottomRight.oDescending;
               _oBottomRight.oDescending.oEdgeA = _oTile.oDescending;
            }
         }
      }
      
      private function generateShapes() : void
      {
         var _oTile:TileStruct = null;
         var _oEdge:EdgeStruct = null;
         var _oStart:EdgeStruct = null;
         var _oEdgeA:EdgeStruct = null;
         var _oEdgeB:EdgeStruct = null;
         var _sType:SurfaceType = null;
         var _bIsFlat:Boolean = false;
         var _aCheckedEdges:Array = new Array();
         for each(_oTile in this.oTiles.object)
         {
            for each(_oEdge in _oTile.edges)
            {
               if(Boolean(_oEdge) && _aCheckedEdges.indexOf(_oEdge) == -1)
               {
                  _oStart = _oEdge;
                  _aCheckedEdges.push(_oStart);
                  _oEdgeA = _oStart;
                  while(Boolean(_oEdgeA.oEdgeA))
                  {
                     _oEdgeA = _oEdgeA.oEdgeA;
                     _aCheckedEdges.push(_oEdgeA);
                  }
                  _oEdgeB = _oStart;
                  while(Boolean(_oEdgeB.oEdgeB))
                  {
                     _oEdgeB = _oEdgeB.oEdgeB;
                     _aCheckedEdges.push(_oEdgeB);
                  }
                  _bIsFlat = Boolean(_oEdgeA.oPointA.y == _oEdgeB.oPointB.y);
                  if(_oEdge.bIsFloor)
                  {
                     if(_bIsFlat)
                     {
                        _sType = _oTile.tile.floorType;
                     }
                     else
                     {
                        _sType = _oTile.tile.slopeType;
                     }
                  }
                  else if(_bIsFlat)
                  {
                     _sType = _oTile.tile.ceillingType;
                  }
                  else
                  {
                     _sType = _oTile.tile.wallType;
                  }
                  if(_sType == SurfaceType.PLATFORM)
                  {
                     this.createOneSidedPlatformBody(_sType,_oEdgeA.oPointA,_oEdgeB.oPointB);
                  }
                  else if(_sType == SurfaceType.GROUND || _sType == SurfaceType.SLIPPERY || _sType == SurfaceType.FATAL_FLOOR)
                  {
                     _oEdgeA.oPointA.x += 1 / CommonConfig.nCELL_SIZE;
                     _oEdgeB.oPointB.x -= 1 / CommonConfig.nCELL_SIZE;
                     this.createPlatformBody(_sType,_oEdgeA.oPointA,_oEdgeB.oPointB);
                  }
                  else
                  {
                     this.createPlatformBody(_sType,_oEdgeA.oPointA,_oEdgeB.oPointB);
                  }
               }
            }
         }
      }
      
      private function createPlatformBody(_sType:SurfaceType, _oPointA:b2Vec2, _oPointB:b2Vec2) : void
      {
         var _oBody:b2Body = null;
         var _oRectDef:b2BodyDef = new b2BodyDef();
         _oRectDef.position.Set(_oPointA.x,_oPointA.y);
         _oRectDef.type = b2Body.b2_staticBody;
         _oRectDef.allowSleep = true;
         var _oShape:b2PolygonShape = new b2PolygonShape();
         _oShape.SetAsEdge(new b2Vec2(),_oPointB.Subtract(_oPointA));
         var _oFixtureDef:b2FixtureDef = new b2FixtureDef();
         _oFixtureDef.shape = _oShape;
         _oFixtureDef.isSensor = false;
         _oFixtureDef.filter.categoryBits = GamePlayerConfig.uSURFACE_CATEGORY_BIT;
         _oFixtureDef.filter.maskBits = GamePlayerConfig.uSURFACE_MASK_BIT;
         _oFixtureDef.density = ExternalConfig.instance.getPropertyAsNumber("n" + _sType.toString().toLocaleUpperCase() + "_SURFACE_DENSITY");
         _oFixtureDef.friction = ExternalConfig.instance.getPropertyAsNumber("n" + _sType.toString().toLocaleUpperCase() + "_SURFACE_FRICTION");
         _oFixtureDef.restitution = ExternalConfig.instance.getPropertyAsNumber("n" + _sType.toString().toLocaleUpperCase() + "_SURFACE_RESTITUTION");
         _oBody = PhysEngine.instance.addBody(_oRectDef);
         _oBody.CreateFixture(_oFixtureDef);
         _oBody.SetUserData(_sType);
      }
      
      private function createOneSidedPlatformBody(_sType:SurfaceType, _oPointA:b2Vec2, _oPointB:b2Vec2) : void
      {
         var _oBody:b2Body = null;
         var _oRectDef:b2BodyDef = new b2BodyDef();
         _oRectDef.position.Set(_oPointA.x,_oPointA.y);
         _oRectDef.type = b2Body.b2_staticBody;
         _oRectDef.allowSleep = true;
         var _oShape:b2PolygonShape = new b2PolygonShape();
         _oShape.SetAsEdge(new b2Vec2(),_oPointB.Subtract(_oPointA));
         var _oFixtureDef:b2FixtureDef = new b2FixtureDef();
         _oFixtureDef.shape = _oShape;
         _oFixtureDef.isSensor = false;
         _oFixtureDef.filter.categoryBits = GamePlayerConfig.uPLATFORM_CATEGORY_BIT;
         _oFixtureDef.filter.maskBits = GamePlayerConfig.uPLATFORM_MASK_BIT;
         _oFixtureDef.density = ExternalConfig.instance.getPropertyAsNumber("n" + _sType.toString().toLocaleUpperCase() + "_SURFACE_DENSITY");
         _oFixtureDef.friction = ExternalConfig.instance.getPropertyAsNumber("n" + _sType.toString().toLocaleUpperCase() + "_SURFACE_FRICTION");
         _oFixtureDef.restitution = ExternalConfig.instance.getPropertyAsNumber("n" + _sType.toString().toLocaleUpperCase() + "_SURFACE_RESTITUTION");
         _oBody = PhysEngine.instance.addBody(_oRectDef);
         _oBody.CreateFixture(_oFixtureDef);
         _oBody.SetUserData(_sType);
      }
      
      private function clearAllTilesStruct() : void
      {
         var _oTile:TileStruct = null;
         if(Boolean(this.oTiles))
         {
            for each(_oTile in this.oTiles.object)
            {
               if(Boolean(_oTile))
               {
                  _oTile.destroy();
               }
            }
            this.oTiles.destroy();
         }
         this.oTiles = null;
      }
      
      private function createSurroundingBody() : void
      {
         var _nWidth:Number = GamePlayer.instance.levelWidth;
         var _nHeight:Number = GamePlayer.instance.levelHeight;
         var _nStageHeight:Number = ViewManager.instance.stage.stageHeight / 2;
         var _oTopLeft:b2Vec2 = new b2Vec2(0,0);
         var _oTopRight:b2Vec2 = new b2Vec2(_nWidth / CommonConfig.nCELL_SIZE,0);
         var _oBottomLeft:b2Vec2 = new b2Vec2(0,_nHeight / CommonConfig.nCELL_SIZE + _nStageHeight);
         var _oBottomRight:b2Vec2 = new b2Vec2(_nWidth / CommonConfig.nCELL_SIZE,_nHeight / CommonConfig.nCELL_SIZE + _nStageHeight);
         this.createPlatformBody(SurfaceType.CEILING,_oTopLeft,_oTopRight);
         this.createPlatformBody(SurfaceType.WALL,_oTopRight,_oBottomRight);
         this.createPlatformBody(SurfaceType.WALL,_oBottomLeft,_oTopLeft);
      }
   }
}

