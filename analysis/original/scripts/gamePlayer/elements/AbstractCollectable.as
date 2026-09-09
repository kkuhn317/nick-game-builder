package gamePlayer.elements
{
   import Box2D.Collision.Shapes.b2PolygonShape;
   import Box2D.Collision.b2Manifold;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.Contacts.b2Contact;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2BodyDef;
   import Box2D.Dynamics.b2FixtureDef;
   import com.sarbakan.sbdk.blitting.core.BitmappedAnimStateMachine;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import gamePlayer.GamePlayerConfig;
   import gamePlayer.physic.IContactManaged;
   import gamePlayer.physic.PhysEngine;
   import media.type.AbstractMedia;
   
   public class AbstractCollectable extends AbstractGameElement implements IContactManaged
   {
      
      protected static const sSTATE_IDLE:String = "idle";
      
      protected static const sSTATE_COLLECT:String = "collect";
      
      private static const sCOLLIDER_BODY:String = "body";
      
      protected var oBAStateMachine:BitmappedAnimStateMachine;
      
      private var oBody:b2Body;
      
      public function AbstractCollectable(_oMedia:AbstractMedia, _oPos:Point)
      {
         super(_oMedia);
         this.initStateMachine();
         var _oBodyColliderRect:Rectangle = this.oBAStateMachine.getColliderByName(sCOLLIDER_BODY,false).rect;
         this.createBody(_oPos,_oBodyColliderRect);
      }
      
      override public function destroy() : void
      {
         super.destroy();
         if(Boolean(this.oBAStateMachine))
         {
            this.oBAStateMachine.destroy();
         }
         this.oBAStateMachine = null;
         PhysEngine.instance.removeBody(this.body);
      }
      
      public function onBeginContact(_oObject:IContactManaged, _oBody:b2Body, _oContact:b2Contact) : void
      {
         if(_oObject is PlayableCharacter)
         {
            if(Boolean(this.oBAStateMachine) && this.oBAStateMachine.isState(sSTATE_IDLE))
            {
               this.oBAStateMachine.setState(sSTATE_COLLECT);
            }
         }
      }
      
      public function onEndContact(_oObject:IContactManaged, _oBody:b2Body, _oContact:b2Contact) : void
      {
      }
      
      public function onPreSolveContact(_oObject:IContactManaged, _oBody:b2Body, _oContact:b2Contact, _oManifold:b2Manifold) : void
      {
      }
      
      protected function initStateMachine() : void
      {
      }
      
      protected function createBody(_oPos:Point, _oColliderRect:Rectangle) : void
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
         _oBodyDef.type = b2Body.b2_staticBody;
         _oBodyDef.allowSleep = true;
         var _nHw:Number = _oColliderRect.width / 2;
         var _nHh:Number = _oColliderRect.height / 2;
         var _oBodyShape:b2PolygonShape = new b2PolygonShape();
         _oBodyShape.SetAsOrientedBox(_nHw,_nHh,new b2Vec2(_oColliderRect.right - _nHw,_oColliderRect.bottom - _nHh));
         var _oBodyFixture:b2FixtureDef = new b2FixtureDef();
         _oBodyFixture.shape = _oBodyShape;
         _oBodyFixture.isSensor = true;
         _oBodyFixture.filter.categoryBits = GamePlayerConfig.uCOLLECTABLE_CATEGORY_BIT;
         _oBodyFixture.filter.maskBits = GamePlayerConfig.uCOLLECTABLE_MASK_BIT;
         this.oBody = PhysEngine.instance.addBody(_oBodyDef);
         this.oBody.SetFixedRotation(true);
         this.oBody.CreateFixture(_oBodyFixture);
         this.oBody.SetUserData(this);
      }
      
      public function get animStateMachine() : BitmappedAnimStateMachine
      {
         return this.oBAStateMachine;
      }
      
      public function get body() : b2Body
      {
         return this.oBody;
      }
   }
}

