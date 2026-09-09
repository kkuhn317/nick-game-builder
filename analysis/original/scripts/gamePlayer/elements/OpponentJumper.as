package gamePlayer.elements
{
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.Contacts.b2Contact;
   import Box2D.Dynamics.b2Body;
   import com.sarbakan.sbdk.blitting.core.BitmappedAnimStateMachine;
   import com.sarbakan.sbdk.utils.ExternalConfig;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import gamePlayer.GamePlayer;
   import gamePlayer.GameSession;
   import gamePlayer.events.GamePlayerEvent;
   import gamePlayer.physic.IContactManaged;
   import gamePlayer.physic.PhysEngine;
   import media.type.AbstractMedia;
   import media.type.OpponentJumperMedia;
   import sound.SfxManager;
   import utils.enum.SurfaceType;
   
   public class OpponentJumper extends AbstractOpponent
   {
      
      private static const sSTATE_JUMP_UP:String = "jumpUp";
      
      private static const sSTATE_JUMP_TOP:String = "jumpTop";
      
      private static const sSTATE_JUMP_END:String = "jumpEnd";
      
      private static const sSTATE_JUMP_DOWN:String = "jumpDown";
      
      private static const sSTATE_HURT:String = "hurt";
      
      private static const sSTATE_DIE:String = "die";
      
      private static const sSTATE_RESPAWN:String = "respawn";
      
      private static const sSFX_JUMP:String = "sndJumperJump";
      
      private static const sSFX_DIE:String = "sndJumperDie";
      
      private var nJumpForce:Number;
      
      private var nJumpAngle:Number;
      
      private var iDirection:int;
      
      public function OpponentJumper(_oMedia:AbstractMedia, _oPos:Point, _bFlip:Boolean)
      {
         super(_oMedia,_oPos);
         var _oBodyColliderRect:Rectangle = oBAStateMachine.getColliderByName(sCOLLIDER_BODY,false).rect;
         createBody(_oPos,_oBodyColliderRect);
         addHeadSensor(_oPos,_oBodyColliderRect);
         addFootSensor(_oPos,_oBodyColliderRect);
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
         if(!diedInPit)
         {
            animStateMachine.setState(sSTATE_DIE);
         }
         else
         {
            animStateMachine.setState(sSTATE_RESPAWN);
         }
      }
      
      override protected function initStateMachine() : void
      {
         oBAStateMachine = new BitmappedAnimStateMachine();
         oBAStateMachine.addBitmappedState(sSTATE_JUMP_UP,oMedia.getClass(OpponentJumperMedia.LINKAGE_JUMP_UP),null,this.state_jump_up,this.state_jump_up_init);
         oBAStateMachine.addBitmappedState(sSTATE_JUMP_TOP,oMedia.getClass(OpponentJumperMedia.LINKAGE_JUMP_TOP),null,this.state_jump_top);
         oBAStateMachine.addBitmappedState(sSTATE_JUMP_DOWN,oMedia.getClass(OpponentJumperMedia.LINKAGE_JUMP_DOWN),null,this.state_jump_down);
         oBAStateMachine.addBitmappedState(sSTATE_JUMP_END,oMedia.getClass(OpponentJumperMedia.LINKAGE_JUMP_END),null,this.state_jump_land,null,this.state_jump_land_end);
         oBAStateMachine.addBitmappedState(sSTATE_HURT,oMedia.getClass(OpponentJumperMedia.LINKAGE_HURT),null,this.state_hurt);
         oBAStateMachine.addBitmappedState(sSTATE_DIE,oMedia.getClass(OpponentJumperMedia.LINKAGE_DIE),null,this.state_die,this.state_die_init);
         oBAStateMachine.addBitmappedState(sSTATE_RESPAWN,oMedia.getClass(OpponentJumperMedia.LINKAGE_DIE),null,this.state_respawn,this.state_respawn_init);
         oBAStateMachine.setState(sSTATE_JUMP_TOP);
      }
      
      override protected function initForces() : void
      {
         this.nJumpForce = ExternalConfig.instance.getPropertyAsNumber("nJUMPER_JUMP_IMPULSE");
         this.nJumpAngle = ExternalConfig.instance.getPropertyAsNumber("nJUMPER_JUMP_ANGLE") * Math.PI / 180;
      }
      
      private function applyJumpImpulse() : void
      {
         var _nDeltaX:Number = Math.sin(this.nJumpAngle) * this.nJumpForce;
         var _nDeltaY:Number = Math.cos(this.nJumpAngle) * this.nJumpForce;
         if(Boolean(body))
         {
            body.ApplyImpulse(new b2Vec2(_nDeltaX * this.iDirection,-_nDeltaY),body.GetPosition());
         }
      }
      
      private function checkLanding() : void
      {
         if(isCollidingWithSurface(SurfaceType.GROUND,SurfaceType.SLIPPERY,SurfaceType.GROUND_SLOPE,SurfaceType.SLIPPERY_SLOPE,SurfaceType.PLATFORM,SurfaceType.FATAL_FLOOR) || body.GetLinearVelocity().y == 0)
         {
            animStateMachine.setState(sSTATE_JUMP_END);
            if(oHeadSensor.isTouchingCeiling())
            {
               this.iDirection *= -1;
            }
         }
      }
      
      private function checkOrientation() : void
      {
         if(body.GetLinearVelocity().x > 1)
         {
            oBAStateMachine.flip = false;
         }
         else if(body.GetLinearVelocity().x < -1)
         {
            oBAStateMachine.flip = true;
         }
      }
      
      private function state_jump_up_init() : void
      {
         if(oBAStateMachine.displayed)
         {
            SfxManager.instance.playSFX(sSFX_JUMP);
         }
      }
      
      private function state_jump_up() : void
      {
         this.checkOrientation();
         if(body.GetLinearVelocity().y > -1)
         {
            animStateMachine.setState(sSTATE_JUMP_TOP);
         }
      }
      
      private function state_jump_top() : void
      {
         if(animStateMachine.isLastFrame)
         {
            animStateMachine.setState(sSTATE_JUMP_DOWN);
         }
      }
      
      private function state_jump_down() : void
      {
         this.checkOrientation();
         this.checkLanding();
         checkPit();
      }
      
      private function state_jump_land() : void
      {
         if(animStateMachine.isLastFrame)
         {
            animStateMachine.setState(sSTATE_JUMP_UP);
         }
      }
      
      private function state_jump_land_end() : void
      {
         this.applyJumpImpulse();
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
      
      private function state_respawn_init() : void
      {
         body.SetPosition(b2StartingPos);
         animStateMachine.visible = false;
         PhysEngine.instance.setBodyActivation(body,false);
         onUpdate(null);
      }
      
      private function state_respawn() : void
      {
         if(!body.IsActive())
         {
            if(!animStateMachine.displayed)
            {
               animStateMachine.setState(sSTATE_JUMP_DOWN);
               animStateMachine.visible = true;
               PhysEngine.instance.setBodyActivation(body,true);
               diedInPit = false;
            }
         }
      }
      
      override public function onBeginContact(_oObject:IContactManaged, _oBody:b2Body, _oContact:b2Contact) : void
      {
         super.onBeginContact(_oObject,_oBody,_oContact);
         if(_oObject == SurfaceType.WALL || _oObject == SurfaceType.FATAL_WALL)
         {
            this.iDirection *= -1;
         }
      }
   }
}

