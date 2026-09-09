package gamePlayer.elements
{
   import Box2D.Collision.Shapes.b2CircleShape;
   import Box2D.Collision.Shapes.b2MassData;
   import Box2D.Collision.Shapes.b2PolygonShape;
   import Box2D.Collision.b2Manifold;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.Contacts.b2Contact;
   import Box2D.Dynamics.Joints.b2LineJoint;
   import Box2D.Dynamics.Joints.b2LineJointDef;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2BodyDef;
   import Box2D.Dynamics.b2FixtureDef;
   import com.sarbakan.sbdk.blitting.core.BitmappedAnimStateMachine;
   import com.sarbakan.sbdk.core.UpdateManager;
   import com.sarbakan.sbdk.events.UpdateEvent;
   import com.sarbakan.sbdk.utils.EventManager;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import gamePlayer.GamePlayer;
   import gamePlayer.GamePlayerConfig;
   import gamePlayer.physic.ClingSensor;
   import gamePlayer.physic.FootSensor;
   import gamePlayer.physic.HeadSensor;
   import gamePlayer.physic.IContactManaged;
   import gamePlayer.physic.PhysEngine;
   import media.type.AbstractMedia;
   import utils.enum.SurfaceType;
   
   public class AbstractMovingCharacter extends AbstractGameElement implements IContactManaged
   {
      
      protected static const sEVENT_MANAGER_ID:String = "movingCharengine_event";
      
      protected var oBAStateMachine:BitmappedAnimStateMachine;
      
      protected var oBody:b2Body;
      
      protected var oCrouchedBody:b2Body;
      
      protected var oFootSensor:FootSensor;
      
      protected var oHeadSensor:HeadSensor;
      
      protected var oClingSensor:ClingSensor;
      
      protected var oJointFoot:b2LineJoint;
      
      protected var oJointHead:b2LineJoint;
      
      protected var oJointCling:b2LineJoint;
      
      protected var oJointCrouched:b2LineJoint;
      
      protected var oEventManager:EventManager;
      
      protected var bDiedInPit:Boolean;
      
      private var oStartingPos:b2Vec2;
      
      public function AbstractMovingCharacter(_oMedia:AbstractMedia)
      {
         super(_oMedia);
         this.oEventManager = new EventManager();
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,UpdateManager.instance,UpdateEvent.UPDATE,this.onUpdate);
         this.bDiedInPit = false;
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.removeBodies();
         if(Boolean(this.oJointFoot))
         {
            PhysEngine.instance.world.DestroyJoint(this.oJointFoot);
         }
         this.oJointFoot = null;
         if(Boolean(this.oJointHead))
         {
            PhysEngine.instance.world.DestroyJoint(this.oJointHead);
         }
         this.oJointHead = null;
         if(Boolean(this.oJointCling))
         {
            PhysEngine.instance.world.DestroyJoint(this.oJointCling);
         }
         this.oJointCling = null;
         if(Boolean(this.oJointCrouched))
         {
            PhysEngine.instance.world.DestroyJoint(this.oJointCrouched);
         }
         this.oJointCrouched = null;
         if(Boolean(this.oBAStateMachine))
         {
            this.oBAStateMachine.destroy();
         }
         this.oBAStateMachine = null;
         if(Boolean(this.oEventManager))
         {
            this.oEventManager.destroy();
         }
         this.oEventManager = null;
         this.bDiedInPit = false;
         this.oStartingPos = null;
      }
      
      public function removeBodies() : void
      {
         if(Boolean(this.oBody))
         {
            PhysEngine.instance.removeBody(this.oBody);
         }
         this.oBody = null;
         if(Boolean(this.oCrouchedBody))
         {
            PhysEngine.instance.removeBody(this.oCrouchedBody);
         }
         this.oCrouchedBody = null;
         if(Boolean(this.oFootSensor))
         {
            this.oFootSensor.destroy();
         }
         this.oFootSensor = null;
         if(Boolean(this.oHeadSensor))
         {
            this.oHeadSensor.destroy();
         }
         this.oHeadSensor = null;
         if(Boolean(this.oClingSensor))
         {
            this.oClingSensor.destroy();
         }
         this.oClingSensor = null;
      }
      
      protected function createBody(_oPos:Point, _oColliderRect:Rectangle) : void
      {
         var _oBodyFixture:b2FixtureDef = null;
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
         _oBodyFixture = new b2FixtureDef();
         _oBodyFixture.shape = _oBodyShape;
         _oBodyFixture.isSensor = false;
         _oBodyFixture.filter.categoryBits = GamePlayerConfig.uPLAYER_CATEGORY_BIT;
         _oBodyFixture.filter.maskBits = GamePlayerConfig.uPLAYER_MASK_BIT;
         var _oFootShape:b2CircleShape = new b2CircleShape(_nHw);
         _oFootShape.SetLocalPosition(new b2Vec2(0,-_nHw));
         var _oFootFixture:b2FixtureDef = new b2FixtureDef();
         _oFootFixture.shape = _oFootShape;
         _oFootFixture.isSensor = false;
         _oFootFixture.filter.categoryBits = GamePlayerConfig.uPLAYER_CATEGORY_BIT;
         _oFootFixture.filter.maskBits = GamePlayerConfig.uPLAYER_MASK_BIT;
         this.oBody = PhysEngine.instance.addBody(_oBodyDef);
         this.oBody.SetFixedRotation(true);
         this.oBody.SetLinearDamping(this.damping);
         this.oBody.SetAngularDamping(this.damping);
         _oBodyFixture.friction = this.friction;
         _oBodyFixture.restitution = this.restitution;
         _oFootFixture.friction = this.friction;
         _oFootFixture.restitution = this.restitution;
         var _oMassData:b2MassData = new b2MassData();
         _oMassData.mass = this.mass;
         this.oBody.SetMassData(_oMassData);
         this.oBody.CreateFixture(_oBodyFixture);
         this.oBody.CreateFixture(_oFootFixture);
         this.oBody.SetBullet(true);
         this.oBody.SetUserData(this);
      }
      
      protected function createCrouchBody(_oPos:Point, _oColliderRect:Rectangle) : void
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
         _oBodyDef.position.Set(_oPos.x,_oPos.y);
         _oBodyDef.type = b2Body.b2_dynamicBody;
         _oBodyDef.allowSleep = true;
         var _nRadius:Number = Math.abs(_oColliderRect.top / 2);
         var _oCrouchShape:b2CircleShape = new b2CircleShape(_nRadius);
         _oCrouchShape.SetLocalPosition(new b2Vec2(0,-_nRadius));
         var _oCrouchFixture:b2FixtureDef = new b2FixtureDef();
         _oCrouchFixture.shape = _oCrouchShape;
         _oCrouchFixture.isSensor = false;
         _oCrouchFixture.filter.categoryBits = GamePlayerConfig.uPLAYER_CATEGORY_BIT;
         _oCrouchFixture.filter.maskBits = GamePlayerConfig.uPLAYER_MASK_BIT;
         this.oCrouchedBody = PhysEngine.instance.addBody(_oBodyDef);
         this.oCrouchedBody.SetFixedRotation(true);
         this.oBody.SetLinearDamping(this.damping);
         this.oCrouchedBody.SetAngularDamping(this.damping);
         _oCrouchFixture.friction = this.friction;
         _oCrouchFixture.restitution = this.restitution;
         var _oMassData:b2MassData = new b2MassData();
         _oMassData.mass = this.mass;
         this.oCrouchedBody.SetMassData(_oMassData);
         this.oCrouchedBody.CreateFixture(_oCrouchFixture);
         this.oCrouchedBody.SetBullet(true);
         this.oCrouchedBody.SetUserData(this);
         PhysEngine.instance.setBodyActivation(this.oCrouchedBody,false);
      }
      
      protected function addFootSensor(_oPos:Point, _oColliderRect:Rectangle) : void
      {
         _oPos = _oPos.clone();
         _oPos.x /= CommonConfig.nCELL_SIZE;
         _oPos.y /= CommonConfig.nCELL_SIZE;
         _oColliderRect = _oColliderRect.clone();
         _oColliderRect.left /= CommonConfig.nCELL_SIZE;
         _oColliderRect.right /= CommonConfig.nCELL_SIZE;
         _oColliderRect.top /= CommonConfig.nCELL_SIZE;
         _oColliderRect.bottom /= CommonConfig.nCELL_SIZE;
         this.oFootSensor = new FootSensor(_oColliderRect,this.body);
         var _oAnchor:b2Vec2 = this.oFootSensor.body.GetPosition();
         var _oJointDef:b2LineJointDef = new b2LineJointDef();
         _oJointDef.Initialize(this.oBody,this.oFootSensor.body,_oAnchor,new b2Vec2(0,1));
         _oJointDef.enableLimit = true;
         _oJointDef.lowerTranslation = 0;
         _oJointDef.upperTranslation = 0;
         this.oJointFoot = PhysEngine.instance.world.CreateJoint(_oJointDef) as b2LineJoint;
      }
      
      protected function addHeadSensor(_oPos:Point, _oColliderRect:Rectangle) : void
      {
         _oPos = _oPos.clone();
         _oPos.x /= CommonConfig.nCELL_SIZE;
         _oPos.y /= CommonConfig.nCELL_SIZE;
         _oColliderRect = _oColliderRect.clone();
         _oColliderRect.left /= CommonConfig.nCELL_SIZE;
         _oColliderRect.right /= CommonConfig.nCELL_SIZE;
         _oColliderRect.top /= CommonConfig.nCELL_SIZE;
         _oColliderRect.bottom /= CommonConfig.nCELL_SIZE;
         this.oHeadSensor = new HeadSensor(_oColliderRect,this.body);
         var _oAnchor:b2Vec2 = this.oHeadSensor.body.GetPosition();
         var _oJointDef:b2LineJointDef = new b2LineJointDef();
         _oJointDef.Initialize(this.oBody,this.oHeadSensor.body,_oAnchor,new b2Vec2(0,1));
         _oJointDef.enableLimit = true;
         _oJointDef.lowerTranslation = 0;
         _oJointDef.upperTranslation = 0;
         this.oJointHead = PhysEngine.instance.world.CreateJoint(_oJointDef) as b2LineJoint;
      }
      
      protected function addClingSensor(_oPos:Point, _oColliderRect:Rectangle) : void
      {
         _oPos = _oPos.clone();
         _oPos.x /= CommonConfig.nCELL_SIZE;
         _oPos.y /= CommonConfig.nCELL_SIZE;
         _oColliderRect = _oColliderRect.clone();
         _oColliderRect.left /= CommonConfig.nCELL_SIZE;
         _oColliderRect.right /= CommonConfig.nCELL_SIZE;
         _oColliderRect.top /= CommonConfig.nCELL_SIZE;
         _oColliderRect.bottom /= CommonConfig.nCELL_SIZE;
         this.oClingSensor = new ClingSensor(_oPos,_oColliderRect,this.body);
         var _oAnchor:b2Vec2 = this.oClingSensor.body.GetPosition();
         var _oJointDef:b2LineJointDef = new b2LineJointDef();
         _oJointDef.Initialize(this.oBody,this.oClingSensor.body,_oAnchor,new b2Vec2(0,1));
         _oJointDef.enableLimit = true;
         _oJointDef.lowerTranslation = 0;
         _oJointDef.upperTranslation = 0;
         this.oJointCling = PhysEngine.instance.world.CreateJoint(_oJointDef) as b2LineJoint;
      }
      
      protected function checkPit() : void
      {
         if(this.oBAStateMachine.rect.top > GamePlayer.instance.levelHeight)
         {
            this.diedInPit = true;
            this.die(true);
         }
      }
      
      public function die(_bInstant:Boolean = false) : void
      {
      }
      
      public function onBeginContact(_oObject:IContactManaged, _oBody:b2Body, _oContact:b2Contact) : void
      {
      }
      
      public function onEndContact(_oObject:IContactManaged, _oBody:b2Body, _oContact:b2Contact) : void
      {
      }
      
      public function onPreSolveContact(_oObject:IContactManaged, _oBody:b2Body, _oContact:b2Contact, _oManifold:b2Manifold) : void
      {
         if(_oObject == SurfaceType.PLATFORM)
         {
            if(this.body.GetPosition().y - 5 / CommonConfig.nCELL_SIZE > _oBody.GetPosition().y)
            {
               _oContact.SetEnabled(false);
            }
         }
      }
      
      protected function onUpdate(_e:UpdateEvent) : void
      {
         if(Boolean(this.oBAStateMachine) && Boolean(this.body))
         {
            this.oBAStateMachine.x = this.body.GetPosition().x * CommonConfig.nCELL_SIZE;
            this.oBAStateMachine.y = this.body.GetPosition().y * CommonConfig.nCELL_SIZE;
         }
      }
      
      public function get animStateMachine() : BitmappedAnimStateMachine
      {
         return this.oBAStateMachine;
      }
      
      public function get body() : b2Body
      {
         return this.oBody;
      }
      
      public function get b2StartingPos() : b2Vec2
      {
         return this.oStartingPos;
      }
      
      public function set b2StartingPos(_oPos:b2Vec2) : void
      {
         this.oStartingPos = _oPos.Copy();
      }
      
      public function get diedInPit() : Boolean
      {
         return this.bDiedInPit;
      }
      
      public function set diedInPit(_bDiedInPit:Boolean) : void
      {
         this.bDiedInPit = _bDiedInPit;
      }
      
      protected function get mass() : Number
      {
         return 0;
      }
      
      protected function get friction() : Number
      {
         return 0;
      }
      
      protected function get restitution() : Number
      {
         return 0;
      }
      
      protected function get damping() : Number
      {
         return 0;
      }
   }
}

