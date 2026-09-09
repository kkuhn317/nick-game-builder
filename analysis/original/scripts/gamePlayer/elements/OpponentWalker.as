package gamePlayer.elements
{
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.Contacts.b2Contact;
   import Box2D.Dynamics.b2Body;
   import com.sarbakan.sbdk.blitting.core.BitmappedAnimStateMachine;
   import com.sarbakan.sbdk.utils.ExternalConfig;
   import com.sarbakan.sbdk.utils.FrameTimer;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import gamePlayer.GamePlayer;
   import gamePlayer.GameSession;
   import gamePlayer.events.GamePlayerEvent;
   import gamePlayer.physic.IContactManaged;
   import gamePlayer.physic.PhysEngine;
   import media.type.AbstractMedia;
   import media.type.OpponentWalkerMedia;
   import sound.SfxManager;
   import utils.enum.SurfaceType;
   
   public class OpponentWalker extends AbstractOpponent
   {
      
      private static const sSTATE_WALK:String = "walk";
      
      private static const sSTATE_SLIDE:String = "slide";
      
      private static const sSTATE_FALL:String = "fall";
      
      private static const sSTATE_LAND:String = "land";
      
      private static const sSTATE_HURT:String = "hurt";
      
      private static const sSTATE_DIE:String = "die";
      
      private static const sSTATE_RESPAWN:String = "respawn";
      
      private static const sSFX_LAND:String = "sndWalkerLand";
      
      private static const sSFX_DIE:String = "sndWalkerDie";
      
      private const nFLIP_DElAY:uint = 8;
      
      private var nWalkForce:Number;
      
      private var iDirection:int;
      
      private var oFlipTimer:FrameTimer;
      
      private var bCanFlip:Boolean;
      
      public function OpponentWalker(_oMedia:AbstractMedia, _oPos:Point, _bFlip:Boolean)
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
         this.bCanFlip = true;
      }
      
      override public function destroy() : void
      {
         super.destroy();
         if(Boolean(this.oFlipTimer))
         {
            this.oFlipTimer.destroy();
         }
         this.oFlipTimer = null;
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
         oBAStateMachine.addBitmappedState(sSTATE_WALK,oMedia.getClass(OpponentWalkerMedia.LINKAGE_WALK),null,this.state_walk);
         oBAStateMachine.addBitmappedState(sSTATE_SLIDE,oMedia.getClass(OpponentWalkerMedia.LINKAGE_SLIDE),null,this.state_slide);
         oBAStateMachine.addBitmappedState(sSTATE_FALL,oMedia.getClass(OpponentWalkerMedia.LINKAGE_FALL),null,this.state_fall);
         oBAStateMachine.addBitmappedState(sSTATE_LAND,oMedia.getClass(OpponentWalkerMedia.LINKAGE_LAND),null,this.state_land,this.state_land_init);
         oBAStateMachine.addBitmappedState(sSTATE_HURT,oMedia.getClass(OpponentWalkerMedia.LINKAGE_HURT),null,this.state_hurt);
         oBAStateMachine.addBitmappedState(sSTATE_DIE,oMedia.getClass(OpponentWalkerMedia.LINKAGE_DIE),null,this.state_die,this.state_die_init);
         oBAStateMachine.addBitmappedState(sSTATE_RESPAWN,oMedia.getClass(OpponentWalkerMedia.LINKAGE_DIE),null,this.state_respawn,this.state_respawn_init);
         oBAStateMachine.setState(sSTATE_WALK);
      }
      
      override protected function initForces() : void
      {
         this.nWalkForce = ExternalConfig.instance.getPropertyAsNumber("nWALKER_WALK_FORCE");
      }
      
      private function applyWalkForce() : void
      {
         body.SetLinearVelocity(new b2Vec2(this.nWalkForce * this.iDirection,body.GetLinearVelocity().y));
      }
      
      private function checkLanding() : void
      {
         if(isCollidingWithSurface(SurfaceType.GROUND,SurfaceType.SLIPPERY,SurfaceType.PLATFORM,SurfaceType.FATAL_FLOOR))
         {
            animStateMachine.setState(sSTATE_LAND);
         }
         else if(isCollidingWithSurface(SurfaceType.GROUND_SLOPE,SurfaceType.SLIPPERY_SLOPE))
         {
            animStateMachine.setState(sSTATE_SLIDE);
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
      
      private function checkStates() : void
      {
         if(aCollidingSurfaces.length == 0 && body.GetLinearVelocity().y > 1)
         {
            animStateMachine.setState(sSTATE_FALL);
         }
         else if(isCollidingWithSurface(SurfaceType.GROUND_SLOPE,SurfaceType.SLIPPERY_SLOPE) && body.GetLinearVelocity().y > 0)
         {
            animStateMachine.setState(sSTATE_SLIDE);
         }
         else
         {
            animStateMachine.setState(sSTATE_WALK);
         }
      }
      
      private function state_walk() : void
      {
         this.applyWalkForce();
         this.checkOrientation();
         this.checkStates();
      }
      
      private function state_slide() : void
      {
         this.checkOrientation();
         this.checkStates();
      }
      
      private function state_fall() : void
      {
         this.checkLanding();
         checkPit();
      }
      
      private function state_land_init() : void
      {
         if(oBAStateMachine.displayed)
         {
            SfxManager.instance.playSFX(sSFX_LAND);
         }
      }
      
      private function state_land() : void
      {
         if(animStateMachine.isLastFrame)
         {
            animStateMachine.setState(sSTATE_WALK);
         }
      }
      
      private function state_hurt() : void
      {
      }
      
      private function state_die_init() : void
      {
         SfxManager.instance.playSFX(sSFX_DIE);
         GameSession.instance.score += ExternalConfig.instance.getPropertyAsUint("uPOINT_ENNEMY_WALKER");
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
               animStateMachine.setState(sSTATE_WALK);
               animStateMachine.visible = true;
               PhysEngine.instance.setBodyActivation(body,true);
               diedInPit = false;
            }
         }
      }
      
      override public function onBeginContact(_oObject:IContactManaged, _oBody:b2Body, _oContact:b2Contact) : void
      {
         super.onBeginContact(_oObject,_oBody,_oContact);
         if(Boolean(oFootSensor))
         {
            if((_oObject == SurfaceType.WALL || _oObject == SurfaceType.CEILING || _oObject == SurfaceType.FATAL_WALL || _oObject == SurfaceType.FATAL_CEILING) && !oFootSensor.isCollidingWithSurface(SurfaceType.WALL,SurfaceType.CEILING,SurfaceType.FATAL_WALL,SurfaceType.FATAL_CEILING))
            {
               this.iDirection *= -1;
               this.bCanFlip = false;
               this.oFlipTimer = new FrameTimer(this.nFLIP_DElAY,1);
               oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oFlipTimer,TimerEvent.TIMER_COMPLETE,this.onFlipDelayComplete);
               this.oFlipTimer.start();
            }
         }
      }
      
      private function onFlipDelayComplete(_e:TimerEvent) : void
      {
         this.bCanFlip = true;
         oEventManager.removeEventListener(sEVENT_MANAGER_ID,this.oFlipTimer,TimerEvent.TIMER_COMPLETE,this.onFlipDelayComplete);
         this.oFlipTimer.stop();
         this.oFlipTimer.destroy();
         this.oFlipTimer = null;
      }
   }
}

