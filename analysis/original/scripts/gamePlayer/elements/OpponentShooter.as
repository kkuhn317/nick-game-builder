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
   import gamePlayer.GameSession;
   import gamePlayer.events.GamePlayerEvent;
   import gamePlayer.physic.PhysEngine;
   import media.type.AbstractMedia;
   import media.type.OpponentShooterMedia;
   import sound.SfxManager;
   
   public class OpponentShooter extends AbstractOpponent
   {
      
      private static const sSTATE_IDLE:String = "idle";
      
      private static const sSTATE_START_SHOOT:String = "startShoot";
      
      private static const sSTATE_END_SHOOT:String = "endShoot";
      
      private static const sSTATE_HURT:String = "hurt";
      
      private static const sSTATE_DIE:String = "die";
      
      private static const sSFX_SHOOT:String = "sndShooterShot";
      
      private static const sSFX_DIE:String = "sndShooterDie";
      
      private static const sCOLLIDER_SHOOT:String = "shoot";
      
      private var iDirection:int;
      
      public function OpponentShooter(_oMedia:AbstractMedia, _oPos:Point, _bFlip:Boolean)
      {
         super(_oMedia,_oPos);
         var _oBodyColliderRect:Rectangle = oBAStateMachine.getColliderByName(sCOLLIDER_BODY,false).rect;
         this.createBody(_oPos,_oBodyColliderRect);
         addHeadSensor(_oPos,_oBodyColliderRect);
         b2StartingPos = body.GetPosition();
         oBAStateMachine.x = _oPos.x;
         oBAStateMachine.y = _oPos.y;
         oBAStateMachine.flip = _bFlip;
         this.iDirection = _bFlip ? 1 : -1;
         body.SetType(b2Body.b2_staticBody);
      }
      
      override public function destroy() : void
      {
         super.destroy();
      }
      
      override public function die(_bInstant:Boolean = false) : void
      {
         super.die();
         animStateMachine.setState(sSTATE_DIE);
      }
      
      override protected function initStateMachine() : void
      {
         oBAStateMachine = new BitmappedAnimStateMachine();
         oBAStateMachine.addBitmappedState(sSTATE_IDLE,oMedia.getClass(OpponentShooterMedia.LINKAGE_IDLE),null,this.state_idle);
         oBAStateMachine.addBitmappedState(sSTATE_START_SHOOT,oMedia.getClass(OpponentShooterMedia.LINKAGE_START_SHOOT),null,this.state_shoot_start);
         oBAStateMachine.addBitmappedState(sSTATE_END_SHOOT,oMedia.getClass(OpponentShooterMedia.LINKAGE_END_SHOOT),null,this.state_shoot_end,this.state_shoot_end_init);
         oBAStateMachine.addBitmappedState(sSTATE_HURT,oMedia.getClass(OpponentShooterMedia.LINKAGE_HURT),null,this.state_hurt);
         oBAStateMachine.addBitmappedState(sSTATE_DIE,oMedia.getClass(OpponentShooterMedia.LINKAGE_DIE),null,this.state_die,this.state_die_init);
         oBAStateMachine.setState(sSTATE_IDLE);
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
         _oBodyShape.SetAsOrientedBox(_nHw,_nHh,new b2Vec2(0,-_nHh));
         var _oBodyFixture:b2FixtureDef = new b2FixtureDef();
         _oBodyFixture.shape = _oBodyShape;
         _oBodyFixture.isSensor = false;
         _oBodyFixture.filter.categoryBits = GamePlayerConfig.uENEMY_CATEGORY_BIT;
         _oBodyFixture.filter.maskBits = GamePlayerConfig.uENEMY_MASK_BIT;
         oBody = PhysEngine.instance.addBody(_oBodyDef);
         oBody.SetFixedRotation(true);
         oBody.SetLinearDamping(damping);
         oBody.SetAngularDamping(damping);
         _oBodyFixture.friction = friction;
         _oBodyFixture.restitution = restitution;
         var _oMassData:b2MassData = new b2MassData();
         _oMassData.mass = mass;
         oBody.SetMassData(_oMassData);
         oBody.CreateFixture(_oBodyFixture);
         oBody.SetBullet(true);
         oBody.SetUserData(this);
      }
      
      private function shootProjectile() : void
      {
         var _oShootPosCollider:Rectangle = oBAStateMachine.getColliderByName(sCOLLIDER_SHOOT,true).rect;
         GamePlayer.instance.createProjectile(oMedia,new Point(_oShootPosCollider.x,_oShootPosCollider.y),this.iDirection > 0 ? true : false);
         if(oBAStateMachine.displayed)
         {
            SfxManager.instance.playSFX(sSFX_SHOOT);
         }
      }
      
      private function state_idle() : void
      {
         if(animStateMachine.isLastFrame)
         {
            animStateMachine.setState(sSTATE_START_SHOOT);
         }
      }
      
      private function state_shoot_start() : void
      {
         if(animStateMachine.isLastFrame)
         {
            animStateMachine.setState(sSTATE_END_SHOOT);
         }
      }
      
      private function state_shoot_end_init() : void
      {
         this.shootProjectile();
      }
      
      private function state_shoot_end() : void
      {
         if(animStateMachine.isLastFrame)
         {
            animStateMachine.setState(sSTATE_IDLE);
         }
      }
      
      private function state_hurt() : void
      {
      }
      
      private function state_die_init() : void
      {
         SfxManager.instance.playSFX(sSFX_DIE);
         GameSession.instance.score += ExternalConfig.instance.getPropertyAsUint("uPOINT_ENNEMY_JUMPER");
      }
      
      private function state_die() : void
      {
         if(animStateMachine.isLastFrame)
         {
            dispatchEvent(new GamePlayerEvent(GamePlayerEvent.KILL_OPPONENT));
            GamePlayer.instance.removeElement(this);
         }
      }
   }
}

