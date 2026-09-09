package gamePlayer.physic
{
   import Box2D.Collision.Shapes.b2PolygonShape;
   import Box2D.Collision.b2Manifold;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.Contacts.b2Contact;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2BodyDef;
   import Box2D.Dynamics.b2FilterData;
   import Box2D.Dynamics.b2FixtureDef;
   import flash.geom.Rectangle;
   import utils.enum.SurfaceType;
   
   public class FootSensor implements IContactManaged
   {
      
      private var aCollidingSurfaces:Vector.<SurfaceType>;
      
      private var aCollidingObjects:Vector.<IContactManaged>;
      
      private var oBody:b2Body;
      
      private var oFilterData:b2FilterData;
      
      private var oParentBody:b2Body;
      
      public function FootSensor(_oColliderRect:Rectangle, _oParentBody:b2Body)
      {
         super();
         this.aCollidingSurfaces = new Vector.<SurfaceType>();
         this.aCollidingObjects = new Vector.<IContactManaged>();
         this.oParentBody = _oParentBody;
         this.initBody(_oColliderRect);
      }
      
      public function destroy() : void
      {
         this.aCollidingSurfaces = null;
         this.aCollidingObjects = null;
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
      
      private function initBody(_oColliderRect:Rectangle) : void
      {
         var _nRadius:Number = _oColliderRect.width / 2;
         var _oBodyDef:b2BodyDef = new b2BodyDef();
         _oBodyDef.position.Set(this.oParentBody.GetPosition().x,this.oParentBody.GetPosition().y);
         _oBodyDef.type = b2Body.b2_dynamicBody;
         _oBodyDef.allowSleep = true;
         this.oBody = PhysEngine.instance.addBody(_oBodyDef);
         this.oBody.SetFixedRotation(true);
         this.oBody.SetBullet(true);
         var _oSensorShape:b2PolygonShape = new b2PolygonShape();
         _oSensorShape.SetAsOrientedBox(_nRadius - _nRadius / 4,10 / CommonConfig.nCELL_SIZE,new b2Vec2(0,-5 / CommonConfig.nCELL_SIZE));
         var _oSensorFixture:b2FixtureDef = new b2FixtureDef();
         _oSensorFixture.shape = _oSensorShape;
         _oSensorFixture.isSensor = true;
         this.oFilterData = this.parent.body.GetFixtureList().GetFilterData();
         _oSensorFixture.filter = this.oFilterData;
         this.oBody.CreateFixture(_oSensorFixture);
         this.oBody.SetUserData(this);
      }
      
      public function onBeginContact(_oObject:IContactManaged, _oBody:b2Body, _oContact:b2Contact) : void
      {
         if(_oObject is SurfaceType)
         {
            if(Boolean(this.aCollidingSurfaces))
            {
               this.aCollidingSurfaces.push(_oObject);
            }
         }
         else if(Boolean(this.aCollidingObjects))
         {
            this.aCollidingObjects.push(_oObject);
         }
      }
      
      public function onEndContact(_oObject:IContactManaged, _oBody:b2Body, _oContact:b2Contact) : void
      {
         if(_oObject is SurfaceType)
         {
            if(Boolean(this.aCollidingSurfaces))
            {
               this.aCollidingSurfaces.splice(this.aCollidingSurfaces.indexOf(_oObject),1);
            }
         }
         else if(Boolean(this.aCollidingObjects))
         {
            this.aCollidingObjects.splice(this.aCollidingObjects.indexOf(_oObject),1);
         }
      }
      
      public function onPreSolveContact(_oObject:IContactManaged, _oBody:b2Body, _oContact:b2Contact, _oManifold:b2Manifold) : void
      {
      }
      
      public function isTouchingGround() : Boolean
      {
         var _isOnGround:Boolean = false;
         if(this.isCollidingWithSurface(SurfaceType.GROUND,SurfaceType.GROUND_SLOPE,SurfaceType.PLATFORM,SurfaceType.SLIPPERY,SurfaceType.SLIPPERY_SLOPE))
         {
            _isOnGround = true;
         }
         return _isOnGround;
      }
      
      public function isTouching(_oObject:IContactManaged) : Boolean
      {
         if(this.aCollidingObjects.indexOf(_oObject) != -1)
         {
            return true;
         }
         return false;
      }
      
      public function get parent() : IContactManaged
      {
         return this.oParentBody.GetUserData();
      }
      
      public function get body() : b2Body
      {
         return this.oBody;
      }
   }
}

