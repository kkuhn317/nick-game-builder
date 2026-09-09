package gamePlayer.physic
{
   import Box2D.Collision.Shapes.b2PolygonShape;
   import Box2D.Collision.b2Manifold;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.Contacts.b2Contact;
   import Box2D.Dynamics.Contacts.b2ContactEdge;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2BodyDef;
   import Box2D.Dynamics.b2FilterData;
   import Box2D.Dynamics.b2FixtureDef;
   import com.sarbakan.sbdk.utils.ExternalConfig;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import gamePlayer.GamePlayerConfig;
   import utils.enum.SurfaceType;
   
   public class ClingSensor implements IContactManaged
   {
      
      private var aCollidingSurfaces:Array;
      
      private var oBody:b2Body;
      
      private var oFilterData:b2FilterData;
      
      private var oParentBody:b2Body;
      
      private var oClingPosition:b2Vec2;
      
      public function ClingSensor(_oPos:Point, _oColliderRect:Rectangle, _oParentBody:b2Body)
      {
         super();
         this.aCollidingSurfaces = [];
         this.oParentBody = _oParentBody;
         this.initBody(_oPos,_oColliderRect);
      }
      
      public function destroy() : void
      {
         this.aCollidingSurfaces = [];
         if(Boolean(this.oBody))
         {
            PhysEngine.instance.removeBody(this.oBody);
         }
         this.oBody = null;
         this.oFilterData = null;
         this.oParentBody = null;
      }
      
      public function isCollidingWithSurface(... _aSurface) : Boolean
      {
         var _oSurface:SurfaceType = null;
         for each(_oSurface in _aSurface)
         {
            if(this.aCollidingSurfaces.indexOf(_oSurface) != -1)
            {
               return true;
            }
         }
         return false;
      }
      
      public function repositionBody() : void
      {
         this.body.SetPosition(this.oParentBody.GetPosition());
      }
      
      public function flip(_iDirection:int) : void
      {
         this.body.SetAngle(90 * _iDirection * Math.PI / 180);
      }
      
      private function initBody(_oPos:Point, _oColliderRect:Rectangle) : void
      {
         var _nRadius:Number = NaN;
         _nRadius = _oColliderRect.width / 2;
         var _oBodyDef:b2BodyDef = new b2BodyDef();
         _oBodyDef.position.Set(_oPos.x - _oColliderRect.x,_oPos.y - (_oColliderRect.y + _oColliderRect.height));
         _oBodyDef.type = b2Body.b2_dynamicBody;
         _oBodyDef.allowSleep = true;
         this.oBody = PhysEngine.instance.addBody(_oBodyDef);
         this.oBody.SetFixedRotation(true);
         this.oBody.SetBullet(true);
         var _oSensorShape:b2PolygonShape = new b2PolygonShape();
         _oSensorShape.SetAsOrientedBox(ExternalConfig.instance.getPropertyAsNumber("nPLAYER_CLING_SENSOR_HEIGHT"),ExternalConfig.instance.getPropertyAsNumber("nPLAYER_CLING_SENSOR_WIDTH"),new b2Vec2(0,-_nRadius));
         var _oSensorFixture:b2FixtureDef = new b2FixtureDef();
         _oSensorFixture.shape = _oSensorShape;
         _oSensorFixture.isSensor = true;
         this.oFilterData = new b2FilterData();
         this.oFilterData.categoryBits = GamePlayerConfig.uPLAYER_CATEGORY_BIT;
         this.oFilterData.maskBits = GamePlayerConfig.uPLAYER_MASK_BIT;
         _oSensorFixture.filter = this.oFilterData;
         this.oBody.CreateFixture(_oSensorFixture);
         this.oBody.SetUserData(this);
      }
      
      public function onBeginContact(_oObject:IContactManaged, _oBody:b2Body, _oContact:b2Contact) : void
      {
         if(_oObject is SurfaceType)
         {
            this.aCollidingSurfaces.push(_oObject);
            if(_oObject == SurfaceType.GROUND || _oObject == SurfaceType.SLIPPERY || _oObject == SurfaceType.FATAL_FLOOR)
            {
               this.oClingPosition = _oBody.GetPosition();
            }
         }
      }
      
      public function onEndContact(_oObject:IContactManaged, _oBody:b2Body, _oContact:b2Contact) : void
      {
         if(_oObject is SurfaceType)
         {
            this.aCollidingSurfaces.splice(this.aCollidingSurfaces.indexOf(_oObject),1);
         }
      }
      
      public function onPreSolveContact(_oObject:IContactManaged, _oBody:b2Body, _oContact:b2Contact, _oManifold:b2Manifold) : void
      {
      }
      
      public function isTouching(_oObject:IContactManaged) : Boolean
      {
         var _bIsTouching:Boolean = false;
         for(var _oContact:b2ContactEdge = this.body.GetContactList(); Boolean(_oContact); _oContact = _oContact.next)
         {
            if(_oContact.other.GetUserData() == _oObject)
            {
               _bIsTouching = true;
            }
         }
         return _bIsTouching;
      }
      
      public function get parent() : IContactManaged
      {
         return this.oParentBody.GetUserData();
      }
      
      public function get body() : b2Body
      {
         return this.oBody;
      }
      
      public function get clingPosition() : b2Vec2
      {
         return this.oClingPosition;
      }
   }
}

