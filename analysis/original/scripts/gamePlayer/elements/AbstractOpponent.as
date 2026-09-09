package gamePlayer.elements
{
   import Box2D.Collision.Shapes.b2CircleShape;
   import Box2D.Collision.Shapes.b2MassData;
   import Box2D.Collision.Shapes.b2PolygonShape;
   import Box2D.Collision.b2Manifold;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.Contacts.b2Contact;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2BodyDef;
   import Box2D.Dynamics.b2FixtureDef;
   import com.sarbakan.sbdk.utils.ExternalConfig;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import gamePlayer.GamePlayerConfig;
   import gamePlayer.physic.HeadSensor;
   import gamePlayer.physic.IContactManaged;
   import gamePlayer.physic.PhysEngine;
   import media.type.AbstractMedia;
   import utils.enum.SurfaceType;
   
   public class AbstractOpponent extends AbstractMovingCharacter implements IEventDispatcher
   {
      
      protected static const sCOLLIDER_BODY:String = "body";
      
      protected var aCollidingSurfaces:Array;
      
      private var eventDispatcher:EventDispatcher;
      
      public function AbstractOpponent(_oMedia:AbstractMedia, _oPos:Point)
      {
         super(_oMedia);
         this.initStateMachine();
         this.initForces();
         this.aCollidingSurfaces = [];
         this.eventDispatcher = new EventDispatcher(this);
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.aCollidingSurfaces = [];
         this.eventDispatcher = null;
      }
      
      override public function die(_bInstant:Boolean = false) : void
      {
         if(!diedInPit)
         {
            PhysEngine.instance.setBodyActivation(body,false);
            removeBodies();
         }
      }
      
      public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false) : void
      {
         this.eventDispatcher.addEventListener(type,listener,useCapture,priority,useWeakReference);
      }
      
      public function dispatchEvent(event:Event) : Boolean
      {
         return this.eventDispatcher.dispatchEvent(event);
      }
      
      public function hasEventListener(type:String) : Boolean
      {
         return this.eventDispatcher.hasEventListener(type);
      }
      
      public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false) : void
      {
         this.eventDispatcher.removeEventListener(type,listener,useCapture);
      }
      
      public function willTrigger(type:String) : Boolean
      {
         return this.eventDispatcher.willTrigger(type);
      }
      
      override public function onPreSolveContact(_oObject:IContactManaged, _oBody:b2Body, _oContact:b2Contact, _oManifold:b2Manifold) : void
      {
         super.onPreSolveContact(_oObject,_oBody,_oContact,_oManifold);
      }
      
      override public function onBeginContact(_oObject:IContactManaged, _oBody:b2Body, _oContact:b2Contact) : void
      {
         super.onBeginContact(_oObject,_oBody,_oContact);
         if(_oObject is SurfaceType)
         {
            this.aCollidingSurfaces.push(_oObject);
         }
      }
      
      override public function onEndContact(_oObject:IContactManaged, _oBody:b2Body, _oContact:b2Contact) : void
      {
         super.onBeginContact(_oObject,_oBody,_oContact);
         if(_oObject is SurfaceType)
         {
            this.aCollidingSurfaces.splice(this.aCollidingSurfaces.indexOf(_oObject),1);
         }
      }
      
      protected function initStateMachine() : void
      {
      }
      
      protected function initForces() : void
      {
      }
      
      override protected function createBody(_oPos:Point, _oColliderRect:Rectangle) : void
      {
         _oPos = _oPos.clone();
         _oPos.x /= CommonConfig.nCELL_SIZE;
         _oPos.y /= CommonConfig.nCELL_SIZE;
         _oColliderRect = _oColliderRect.clone();
         _oColliderRect.left /= CommonConfig.nCELL_SIZE;
         _oColliderRect.right /= CommonConfig.nCELL_SIZE;
         _oColliderRect.top /= CommonConfig.nCELL_SIZE;
         _oColliderRect.bottom /= CommonConfig.nCELL_SIZE;
         var _oBodyDef:b2BodyDef = new b2BodyDef();
         _oBodyDef.position.Set(_oPos.x - _oColliderRect.x,_oPos.y - _oColliderRect.y);
         _oBodyDef.type = b2Body.b2_dynamicBody;
         _oBodyDef.allowSleep = true;
         var _nHw:Number = _oColliderRect.width / 2;
         var _nHh:Number = _oColliderRect.height / 2;
         var _oBodyShape:b2PolygonShape = new b2PolygonShape();
         _oBodyShape.SetAsOrientedBox(_nHw - 1 / CommonConfig.nCELL_SIZE,_nHh - _nHw / 2,new b2Vec2(0,-_nHh - _nHw / 2));
         var _oBodyFixture:b2FixtureDef = new b2FixtureDef();
         _oBodyFixture.shape = _oBodyShape;
         _oBodyFixture.isSensor = false;
         _oBodyFixture.filter.categoryBits = GamePlayerConfig.uENEMY_CATEGORY_BIT;
         _oBodyFixture.filter.maskBits = GamePlayerConfig.uENEMY_MASK_BIT;
         var _oFootShape:b2CircleShape = new b2CircleShape(_nHw);
         _oFootShape.SetLocalPosition(new b2Vec2(0,-_nHw));
         var _oFootFixture:b2FixtureDef = new b2FixtureDef();
         _oFootFixture.shape = _oFootShape;
         _oFootFixture.isSensor = false;
         _oFootFixture.filter.categoryBits = GamePlayerConfig.uENEMY_CATEGORY_BIT;
         _oFootFixture.filter.maskBits = GamePlayerConfig.uENEMY_MASK_BIT;
         oBody = PhysEngine.instance.addBody(_oBodyDef);
         oBody.SetFixedRotation(true);
         oBody.SetLinearDamping(this.damping);
         oBody.SetAngularDamping(this.damping);
         _oBodyFixture.friction = this.friction;
         _oBodyFixture.restitution = this.restitution;
         _oFootFixture.friction = this.friction;
         _oFootFixture.restitution = this.restitution;
         var _oMassData:b2MassData = new b2MassData();
         _oMassData.mass = this.mass;
         oBody.SetMassData(_oMassData);
         oBody.CreateFixture(_oBodyFixture);
         oBody.CreateFixture(_oFootFixture);
         oBody.SetBullet(true);
         oBody.SetUserData(this);
      }
      
      protected function isCollidingWithSurface(... _aSurface) : Boolean
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
      
      override protected function get mass() : Number
      {
         return ExternalConfig.instance.getPropertyAsNumber("nOPPONENT_MASS");
      }
      
      override protected function get friction() : Number
      {
         return ExternalConfig.instance.getPropertyAsNumber("nOPPONENT_FRICTION");
      }
      
      override protected function get restitution() : Number
      {
         return ExternalConfig.instance.getPropertyAsNumber("nOPPONENT_RESTITUTION");
      }
      
      override protected function get damping() : Number
      {
         return ExternalConfig.instance.getPropertyAsNumber("nOPPONENT_DAMPING");
      }
      
      public function get head() : HeadSensor
      {
         return oHeadSensor;
      }
   }
}

