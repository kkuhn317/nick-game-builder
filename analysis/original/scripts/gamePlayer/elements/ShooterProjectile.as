package gamePlayer.elements
{
   import Box2D.Collision.Shapes.b2MassData;
   import Box2D.Collision.Shapes.b2PolygonShape;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2BodyDef;
   import Box2D.Dynamics.b2FixtureDef;
   import com.sarbakan.sbdk.blitting.core.BitmappedAnimStateMachine;
   import com.sarbakan.sbdk.utils.ExternalConfig;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import gamePlayer.GamePlayer;
   import gamePlayer.GamePlayerConfig;
   import gamePlayer.events.GamePlayerEvent;
   import gamePlayer.physic.PhysEngine;
   import media.type.AbstractMedia;
   import media.type.OpponentShooterMedia;
   
   public class ShooterProjectile extends AbstractOpponent
   {
      
      public static const TYPE:String = "opponentShooterProjectile";
      
      private static const sSTATE_MOVE:String = "move";
      
      private static const sSTATE_HIT:String = "hit";
      
      private var iDirection:int;
      
      public function ShooterProjectile(_oMedia:AbstractMedia, _oPos:Point, _bFlip:Boolean)
      {
         super(_oMedia,_oPos);
         var _oBodyColliderRect:Rectangle = oBAStateMachine.getColliderByName(sCOLLIDER_BODY,false).rect;
         this.createBody(_oPos,_oBodyColliderRect);
         addHeadSensor(_oPos,_oBodyColliderRect);
         b2StartingPos = body.GetPosition();
         oBAStateMachine.x = _oPos.x;
         oBAStateMachine.y = _oPos.y;
         oBAStateMachine.flip = _bFlip;
         this.iDirection = _bFlip ? -1 : 1;
      }
      
      override public function destroy() : void
      {
         super.destroy();
      }
      
      override public function die(_bInstant:Boolean = false) : void
      {
         super.die();
         animStateMachine.setState(sSTATE_HIT);
      }
      
      override protected function initStateMachine() : void
      {
         oBAStateMachine = new BitmappedAnimStateMachine();
         oBAStateMachine.addBitmappedState(sSTATE_MOVE,oMedia.getClass(OpponentShooterMedia.LINKAGE_PROJECTILE_MOVE),null,this.state_move,this.state_move_init);
         oBAStateMachine.addBitmappedState(sSTATE_HIT,oMedia.getClass(OpponentShooterMedia.LINKAGE_PROJECTILE_HIT),null,this.state_hit,this.state_hit_init);
         animStateMachine.setState(sSTATE_MOVE);
      }
      
      override protected function createBody(_oPos:Point, _oColliderRect:Rectangle) : void
      {
         b2StartingPos = new b2Vec2(_oPos.x / CommonConfig.nCELL_SIZE,_oPos.y / CommonConfig.nCELL_SIZE);
         _oColliderRect = _oColliderRect.clone();
         _oColliderRect.left /= CommonConfig.nCELL_SIZE;
         _oColliderRect.right /= CommonConfig.nCELL_SIZE;
         _oColliderRect.top /= CommonConfig.nCELL_SIZE;
         _oColliderRect.bottom /= CommonConfig.nCELL_SIZE;
         var _oBodyDef:b2BodyDef = new b2BodyDef();
         _oBodyDef.position.Set(b2StartingPos.x,b2StartingPos.y);
         _oBodyDef.type = b2Body.b2_dynamicBody;
         _oBodyDef.allowSleep = true;
         var _nHw:Number = _oColliderRect.width / 2;
         var _nHh:Number = _oColliderRect.height / 2;
         var _oBodyShape:b2PolygonShape = new b2PolygonShape();
         _oBodyShape.SetAsOrientedBox(_nHw,_nHh,new b2Vec2(0,-_nHh));
         var _oBodyFixture:b2FixtureDef = new b2FixtureDef();
         _oBodyFixture.shape = _oBodyShape;
         _oBodyFixture.isSensor = true;
         _oBodyFixture.filter.categoryBits = GamePlayerConfig.uENEMY_CATEGORY_BIT;
         _oBodyFixture.filter.maskBits = GamePlayerConfig.uENEMY_MASK_BIT;
         oBody = PhysEngine.instance.addBody(_oBodyDef);
         oBody.SetFixedRotation(true);
         oBody.SetLinearDamping(this.damping);
         oBody.SetAngularDamping(this.damping);
         _oBodyFixture.friction = friction;
         _oBodyFixture.restitution = restitution;
         var _oMassData:b2MassData = new b2MassData();
         _oMassData.mass = this.mass;
         oBody.SetMassData(_oMassData);
         oBody.CreateFixture(_oBodyFixture);
         oBody.SetBullet(true);
         oBody.SetUserData(this);
      }
      
      private function state_move_init() : void
      {
      }
      
      private function state_move() : void
      {
         if(Boolean(body))
         {
            body.SetPosition(new b2Vec2(body.GetPosition().x,b2StartingPos.y));
            body.SetLinearVelocity(new b2Vec2(ExternalConfig.instance.getPropertyAsNumber("nSHOOTER_PROJECTILE_SPEED") * this.iDirection,0));
         }
         if(!animStateMachine.displayed)
         {
            this.die();
         }
      }
      
      private function state_hit_init() : void
      {
      }
      
      private function state_hit() : void
      {
         if(animStateMachine.isLastFrame)
         {
            dispatchEvent(new GamePlayerEvent(GamePlayerEvent.KILL_OPPONENT));
            GamePlayer.instance.removeElement(this);
         }
      }
      
      override protected function get mass() : Number
      {
         return ExternalConfig.instance.getPropertyAsNumber("nSHOOTER_PROJECTILE_MASS");
      }
      
      override protected function get damping() : Number
      {
         return ExternalConfig.instance.getPropertyAsNumber("nSHOOTER_PROJECTILE_DAMPING");
      }
      
      override public function get type() : String
      {
         return TYPE;
      }
   }
}

