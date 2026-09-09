package gamePlayer.elements
{
   import Box2D.Collision.Shapes.b2MassData;
   import Box2D.Collision.b2Manifold;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.Contacts.b2Contact;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2FilterData;
   import Box2D.Dynamics.b2Fixture;
   import com.sarbakan.sbdk.blitting.core.BitmappedAnimStateMachine;
   import com.sarbakan.sbdk.blitting.core.BitmappedAnimation;
   import com.sarbakan.sbdk.events.KeyEvent;
   import com.sarbakan.sbdk.events.SequenceEvent;
   import com.sarbakan.sbdk.events.SoundEvent;
   import com.sarbakan.sbdk.events.UpdateEvent;
   import com.sarbakan.sbdk.input.KeyCode;
   import com.sarbakan.sbdk.input.KeyManager;
   import com.sarbakan.sbdk.input.KeySequence;
   import com.sarbakan.sbdk.input.KeySequenceManager;
   import com.sarbakan.sbdk.sound.SoundManager;
   import com.sarbakan.sbdk.sound.SoundUnit;
   import com.sarbakan.sbdk.utils.ExternalConfig;
   import com.sarbakan.sbdk.utils.FrameTimer;
   import com.sarbakan.sbdk.view.ViewManager;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import gamePlayer.GamePlayer;
   import gamePlayer.GamePlayerConfig;
   import gamePlayer.GameSession;
   import gamePlayer.events.GamePlayerEvent;
   import gamePlayer.physic.FootSensor;
   import gamePlayer.physic.IContactManaged;
   import gamePlayer.physic.PhysEngine;
   import gamePlayer.viewport.IViewportTargetable;
   import media.type.AbstractMedia;
   import media.type.PlayableCharacterMedia;
   import sound.SfxManager;
   import utils.enum.SurfaceType;
   
   public class PlayableCharacter extends AbstractMovingCharacter implements IViewportTargetable, IEventDispatcher
   {
      
      private static const sSFX_JUMP:String = "sndPlayerJump";
      
      private static const sSFX_DOUBLE_JUMP:String = "sndPlayerDoubleJump";
      
      private static const sSFX_JUMP_STOMP:String = "sndPlayerStomp";
      
      private static const sSFX_JUMP_LAND:String = "sndPlayerLand";
      
      private static const sSFX_CLING:String = "sndPlayerCling";
      
      private static const sSFX_CROUCH:String = "sndPlayerCrouch";
      
      private static const sSFX_DIE:String = "sndPlayerDie";
      
      private static const sSFX_RESPAWN:String = "sndPlayerRespawn";
      
      private static const sSFX_RUN:String = "sndPlayerRun";
      
      private static const sSFX_SLIDE:String = "sndPlayerSlide";
      
      private static const sSFX_INVINSIBILITY:String = "sndPlayerInvinsibility";
      
      private static const sSFX_INVINSIBILITY_TICK:String = "sndPlayerInvinsibilityTick";
      
      private static const aKEY_LEFT:Array = [KeyCode.LEFT,KeyCode.A];
      
      private static const aKEY_RIGHT:Array = [KeyCode.RIGHT,KeyCode.D];
      
      private static const aKEY_JUMP:Array = [KeyCode.SPACE,KeyCode.W,KeyCode.UP];
      
      private static const aKEY_RUN:Array = [KeyCode.SHIFT];
      
      private static const aKEY_DOWN:Array = [KeyCode.DOWN,KeyCode.S];
      
      private static const sSTATE_IDLE:String = "idle";
      
      private static const sSTATE_START_RUN:String = "startRun";
      
      private static const sSTATE_RUN:String = "run";
      
      private static const sSTATE_RUN_ICE:String = "runOnIce";
      
      private static const sSTATE_JUMP_START:String = "jumpStart";
      
      private static const sSTATE_JUMP_UP:String = "jumpUp";
      
      private static const sSTATE_JUMP_TOP:String = "jumpTop";
      
      private static const sSTATE_JUMP_DOWN:String = "jumpDown";
      
      private static const sSTATE_JUMP_LAND:String = "jumpLand";
      
      private static const sSTATE_JUMP_STOMP:String = "jumpStomp";
      
      private static const sSTATE_DOUBLE_JUMP:String = "jumpDoubleJump";
      
      private static const sSTATE_CROUCH:String = "crouch";
      
      private static const sSTATE_SLIDE:String = "slide";
      
      private static const sSTATE_CLING:String = "cling";
      
      private static const sSTATE_HURT:String = "hurt";
      
      private static const sSTATE_START_DIE:String = "startDie";
      
      private static const sSTATE_DIE:String = "die";
      
      private static const sSTATE_RESPAWN:String = "respawn";
      
      private static const sCOLLIDER_BODY:String = "body";
      
      private static const sCOLLIDER_CROUCH:String = "crouch";
      
      private static const sPASS_THROUGH_PLATFORM_COMBO_1:String = "keyCombo_PassThroughPlatforms_1";
      
      private static const sPASS_THROUGH_PLATFORM_COMBO_2:String = "keyCombo_PassThroughPlatforms_2";
      
      private static const sRUN_COMBO_1:String = "keyCombo_run_1";
      
      private static const sRUN_COMBO_2:String = "keyCombo_run_2";
      
      private static const sRUN_COMBO_3:String = "keyCombo_run_3";
      
      private static const sRUN_COMBO_4:String = "keyCombo_run_4";
      
      private static const uCLING_DELAY:uint = 10;
      
      private var oViewportPos:Point;
      
      private var oKeyManager:KeyManager;
      
      private var oKeyComboManager:KeySequenceManager;
      
      private var bControlsEnable:Boolean;
      
      private var bInvincible:Boolean;
      
      private var bAsClinged:Boolean;
      
      private var bIsStucked:Boolean;
      
      private var bRunning:Boolean;
      
      private var bPassThroughPlatform:Boolean;
      
      private var nAcceleration:Number;
      
      private var nAccelerationSloppes:Number;
      
      private var nWalkSpeed:Number;
      
      private var nRunSpeed:Number;
      
      private var nJumpForce:Number;
      
      private var nSlidingForce:Number;
      
      private var oFloorNormal:b2Vec2;
      
      private var uPlayerExtraJumpsLimit:uint;
      
      private var oInvinsibilityTimer:FrameTimer;
      
      private var mcInvinsibilityOverlay:BitmappedAnimation;
      
      private var oClingTimer:FrameTimer;
      
      private var aCollidingSurfaces:Vector.<SurfaceType>;
      
      private var eventDispatcher:EventDispatcher;
      
      private var bGameRestarted:Boolean;
      
      public function PlayableCharacter(_oMedia:AbstractMedia, _oPos:Point, _bFlip:Boolean)
      {
         super(_oMedia);
         this.aCollidingSurfaces = new Vector.<SurfaceType>();
         this.eventDispatcher = new EventDispatcher(this);
         oBAStateMachine = new BitmappedAnimStateMachine();
         oBAStateMachine.addBitmappedState(sSTATE_IDLE,_oMedia.getClass(PlayableCharacterMedia.LINKAGE_IDLE),null,this.state_idle,this.state_idle_init);
         oBAStateMachine.addBitmappedState(sSTATE_START_RUN,_oMedia.getClass(PlayableCharacterMedia.LINKAGE_START_RUN),null,this.state_run_start,this.state_run_init);
         oBAStateMachine.addBitmappedState(sSTATE_RUN,_oMedia.getClass(PlayableCharacterMedia.LINKAGE_RUN),null,this.state_run,this.state_run_init);
         oBAStateMachine.addBitmappedState(sSTATE_RUN_ICE,_oMedia.getClass(PlayableCharacterMedia.LINKAGE_RUN_ICE),null,this.state_run_ice,this.state_run_init);
         oBAStateMachine.addBitmappedState(sSTATE_JUMP_START,_oMedia.getClass(PlayableCharacterMedia.LINKAGE_JUMP_UP),null,this.state_jump_start);
         oBAStateMachine.addBitmappedState(sSTATE_JUMP_UP,_oMedia.getClass(PlayableCharacterMedia.LINKAGE_JUMP_UP),null,this.state_jump_up);
         oBAStateMachine.addBitmappedState(sSTATE_JUMP_TOP,_oMedia.getClass(PlayableCharacterMedia.LINKAGE_JUMP_TOP),null,this.state_jump_top);
         oBAStateMachine.addBitmappedState(sSTATE_JUMP_DOWN,_oMedia.getClass(PlayableCharacterMedia.LINKAGE_JUMP_DOWN),null,this.state_jump_down,this.state_jump_down_start);
         oBAStateMachine.addBitmappedState(sSTATE_JUMP_LAND,_oMedia.getClass(PlayableCharacterMedia.LINKAGE_JUMP_END),null,this.state_jump_end,this.state_jump_end_init);
         oBAStateMachine.addBitmappedState(sSTATE_DOUBLE_JUMP,_oMedia.getClass(PlayableCharacterMedia.LINKAGE_JUMP_AIR),null,this.state_jump_air,this.state_jump_air_init);
         oBAStateMachine.addBitmappedState(sSTATE_JUMP_STOMP,_oMedia.getClass(PlayableCharacterMedia.LINKAGE_JUMP_STOMP),null,this.state_stomp,this.state_stomp_init);
         oBAStateMachine.addBitmappedState(sSTATE_CROUCH,_oMedia.getClass(PlayableCharacterMedia.LINKAGE_CROUCH),null,this.state_crouch,this.state_crouch_init,this.state_crouch_end);
         oBAStateMachine.addBitmappedState(sSTATE_SLIDE,_oMedia.getClass(PlayableCharacterMedia.LINKAGE_SLIDE),null,this.state_slide,this.state_slide_init);
         oBAStateMachine.addBitmappedState(sSTATE_CLING,_oMedia.getClass(PlayableCharacterMedia.LINKAGE_CLING),null,this.state_cling,this.state_cling_init,this.state_cling_end);
         oBAStateMachine.addBitmappedState(sSTATE_HURT,_oMedia.getClass(PlayableCharacterMedia.LINKAGE_HURT),null,this.state_hurt);
         oBAStateMachine.addBitmappedState(sSTATE_START_DIE,_oMedia.getClass(PlayableCharacterMedia.LINKAGE_START_DIE),null,this.state_die_start,this.state_die_start_init);
         oBAStateMachine.addBitmappedState(sSTATE_DIE,_oMedia.getClass(PlayableCharacterMedia.LINKAGE_DIE),null,this.state_die);
         oBAStateMachine.addBitmappedState(sSTATE_RESPAWN,_oMedia.getClass(PlayableCharacterMedia.LINKAGE_RESPAWN),null,this.state_respawn,this.state_respawn_init);
         oBAStateMachine.setState(sSTATE_IDLE);
         var _oBodyColliderRect:Rectangle = oBAStateMachine.getColliderByName(sCOLLIDER_BODY,false).rect;
         var _oCrouchColliderRect:Rectangle = oBAStateMachine.getColliderByName(sCOLLIDER_CROUCH,false).rect;
         oBAStateMachine.x = _oPos.x - _oBodyColliderRect.x;
         oBAStateMachine.y = _oPos.y - _oBodyColliderRect.y;
         oBAStateMachine.flip = _bFlip;
         this.mcInvinsibilityOverlay = new BitmappedAnimation(_oMedia.getClass(PlayableCharacterMedia.LINKAGE_INVINCIBILITY_OVERLAY));
         this.mcInvinsibilityOverlay.x = _oPos.x - _oBodyColliderRect.x;
         this.mcInvinsibilityOverlay.y = _oPos.y - _oBodyColliderRect.y;
         this.mcInvinsibilityOverlay.play();
         this.mcInvinsibilityOverlay.visible = false;
         this.bAsClinged = false;
         this.bRunning = false;
         this.bPassThroughPlatform = false;
         this.oClingTimer = new FrameTimer(uCLING_DELAY,1);
         oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oClingTimer,TimerEvent.TIMER_COMPLETE,this.onClingTimerComplete);
         createBody(_oPos,_oBodyColliderRect);
         createCrouchBody(_oPos,_oCrouchColliderRect);
         addHeadSensor(_oPos,_oBodyColliderRect);
         addFootSensor(_oPos,_oBodyColliderRect);
         addClingSensor(_oPos,_oBodyColliderRect);
         b2StartingPos = this.body.GetPosition();
         oClingSensor.flip(_bFlip ? -1 : 1);
         this.oViewportPos = new Point(oBAStateMachine.x,oBAStateMachine.y);
         this.initControls();
         this.initForces();
         this.resetJumpCount();
         this.startInvincibility();
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.oViewportPos = null;
         if(Boolean(this.oKeyManager))
         {
            this.oKeyManager.destroy();
         }
         this.oKeyManager = null;
         if(Boolean(this.oKeyComboManager))
         {
            this.oKeyComboManager.destroy();
         }
         this.oKeyComboManager = null;
         this.bControlsEnable = false;
         this.bAsClinged = false;
         this.bRunning = false;
         this.bPassThroughPlatform = false;
         this.nAcceleration = 0;
         this.nAccelerationSloppes = 0;
         this.nWalkSpeed = 0;
         this.nRunSpeed = 0;
         this.nJumpForce = 0;
         this.nSlidingForce = 0;
         this.oFloorNormal = null;
         this.uPlayerExtraJumpsLimit = 0;
         if(Boolean(this.oInvinsibilityTimer))
         {
            this.oInvinsibilityTimer.destroy();
         }
         this.oInvinsibilityTimer = null;
         if(Boolean(this.mcInvinsibilityOverlay))
         {
            this.mcInvinsibilityOverlay.destroy();
         }
         this.mcInvinsibilityOverlay = null;
         this.aCollidingSurfaces = null;
         this.eventDispatcher = null;
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
      
      public function setControlsEnabled(_bEnable:Boolean) : void
      {
         this.bControlsEnable = _bEnable;
      }
      
      override public function die(_bInstant:Boolean = false) : void
      {
         if(!GamePlayer.instance.bGameCompleted)
         {
            if(_bInstant)
            {
               animStateMachine.setState(sSTATE_RESPAWN);
            }
            else
            {
               animStateMachine.setState(sSTATE_START_DIE);
            }
         }
      }
      
      private function initControls() : void
      {
         var _uKeyCode:uint = 0;
         var _oKeySequence:KeySequence = null;
         this.oKeyManager = new KeyManager(ViewManager.instance.stage);
         for each(_uKeyCode in aKEY_DOWN.concat(aKEY_LEFT,aKEY_RIGHT))
         {
            this.oKeyManager.addKey(_uKeyCode);
         }
         oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oKeyManager,KeyEvent.KEY_UP,this.onKeyUp);
         this.oKeyComboManager = new KeySequenceManager(ViewManager.instance.stage);
         _oKeySequence = new KeySequence(ExternalConfig.instance.getPropertyAsNumber("nKEY_COMBO_MAX_DELAY"),false,32,true);
         _oKeySequence.addKey(KeyCode.S);
         _oKeySequence.addKey(KeyCode.S);
         this.oKeyComboManager.addSequence(sPASS_THROUGH_PLATFORM_COMBO_1,_oKeySequence);
         _oKeySequence = new KeySequence(ExternalConfig.instance.getPropertyAsNumber("nKEY_COMBO_MAX_DELAY"),false,32,true);
         _oKeySequence.addKey(KeyCode.DOWN);
         _oKeySequence.addKey(KeyCode.DOWN);
         this.oKeyComboManager.addSequence(sPASS_THROUGH_PLATFORM_COMBO_2,_oKeySequence);
         _oKeySequence = new KeySequence(ExternalConfig.instance.getPropertyAsNumber("nKEY_COMBO_MAX_DELAY"),false,32,true);
         _oKeySequence.addKey(KeyCode.A);
         _oKeySequence.addKey(KeyCode.A);
         this.oKeyComboManager.addSequence(sRUN_COMBO_1,_oKeySequence);
         _oKeySequence = new KeySequence(ExternalConfig.instance.getPropertyAsNumber("nKEY_COMBO_MAX_DELAY"),false,32,true);
         _oKeySequence.addKey(KeyCode.D);
         _oKeySequence.addKey(KeyCode.D);
         this.oKeyComboManager.addSequence(sRUN_COMBO_2,_oKeySequence);
         _oKeySequence = new KeySequence(ExternalConfig.instance.getPropertyAsNumber("nKEY_COMBO_MAX_DELAY"),false,32,true);
         _oKeySequence.addKey(KeyCode.LEFT);
         _oKeySequence.addKey(KeyCode.LEFT);
         this.oKeyComboManager.addSequence(sRUN_COMBO_3,_oKeySequence);
         _oKeySequence = new KeySequence(ExternalConfig.instance.getPropertyAsNumber("nKEY_COMBO_MAX_DELAY"),false,32,true);
         _oKeySequence.addKey(KeyCode.RIGHT);
         _oKeySequence.addKey(KeyCode.RIGHT);
         this.oKeyComboManager.addSequence(sRUN_COMBO_4,_oKeySequence);
         oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oKeyComboManager,SequenceEvent.SEQUENCE_COMPLETED,this.onComboEntered);
      }
      
      private function initForces() : void
      {
         this.nAcceleration = ExternalConfig.instance.getPropertyAsNumber("nPLAYER_ACCELERATION");
         this.nAccelerationSloppes = ExternalConfig.instance.getPropertyAsNumber("nPLAYER_ACCELERATION_SLOPPES");
         this.nWalkSpeed = ExternalConfig.instance.getPropertyAsNumber("nPLAYER_WALK_SPEED");
         this.nRunSpeed = ExternalConfig.instance.getPropertyAsNumber("nPLAYER_RUN_SPEED");
         this.nJumpForce = ExternalConfig.instance.getPropertyAsNumber("nPLAYER_JUMP_IMPULSE");
         this.nSlidingForce = ExternalConfig.instance.getPropertyAsNumber("nPLAYER_SLIDING_FORCE");
      }
      
      private function checkDisplacementKey() : void
      {
         var _oDelta:b2Vec2 = null;
         var _iDirection:int = 0;
         if(this.bControlsEnable)
         {
            _oDelta = this.body.GetLinearVelocity();
            _iDirection = 0;
            if(this.oKeyManager.isOneOfKeyDown(aKEY_LEFT))
            {
               if(_oDelta.x == 0)
               {
                  _oDelta.Add(new b2Vec2(-1,0));
               }
               else if(_oDelta.x > -this.nWalkSpeed)
               {
                  _iDirection = -1;
               }
               else if((this.bRunning || this.oKeyManager.isOneOfKeyDown(aKEY_RUN)) && _oDelta.x > -this.nRunSpeed && this.isCollidingWithSurface(SurfaceType.GROUND,SurfaceType.GROUND_SLOPE,SurfaceType.PLATFORM,SurfaceType.SLIPPERY,SurfaceType.SLIPPERY_SLOPE))
               {
                  _iDirection = -1;
               }
            }
            else if(this.oKeyManager.isOneOfKeyDown(aKEY_RIGHT))
            {
               if(_oDelta.x == 0)
               {
                  _oDelta.Add(new b2Vec2(1,0));
               }
               else if(_oDelta.x < this.nWalkSpeed)
               {
                  _iDirection = 1;
               }
               else if((this.bRunning || this.oKeyManager.isOneOfKeyDown(aKEY_RUN)) && _oDelta.x < this.nRunSpeed && this.isCollidingWithSurface(SurfaceType.GROUND,SurfaceType.GROUND_SLOPE,SurfaceType.PLATFORM,SurfaceType.SLIPPERY,SurfaceType.SLIPPERY_SLOPE))
               {
                  _iDirection = 1;
               }
            }
            if(_iDirection != 0)
            {
               if(this.isCollidingWithSurface(SurfaceType.GROUND_SLOPE,SurfaceType.SLIPPERY_SLOPE))
               {
                  _oDelta.Add(new b2Vec2(this.nAccelerationSloppes * _iDirection,0));
               }
               else
               {
                  _oDelta.Add(new b2Vec2(this.nAcceleration * _iDirection,0));
               }
               this.body.SetLinearVelocity(_oDelta);
               if(!this.body.IsAwake())
               {
                  this.body.SetAwake(true);
               }
            }
         }
      }
      
      private function checkJumpKey() : void
      {
         if(this.bControlsEnable)
         {
            if(this.oKeyManager.isOneOfKeyJustPressed(aKEY_JUMP) && animStateMachine.state != sSTATE_CROUCH)
            {
               if(this.uPlayerExtraJumpsLimit > 0)
               {
                  if(animStateMachine.state == sSTATE_JUMP_TOP || animStateMachine.state == sSTATE_JUMP_DOWN)
                  {
                     animStateMachine.setState(sSTATE_DOUBLE_JUMP);
                     this.body.ApplyImpulse(new b2Vec2(0,-this.nJumpForce),this.body.GetPosition());
                     --this.uPlayerExtraJumpsLimit;
                  }
                  else
                  {
                     animStateMachine.setState(sSTATE_JUMP_START);
                     this.body.ApplyImpulse(new b2Vec2(0,-this.nJumpForce),this.body.GetPosition());
                  }
               }
            }
         }
      }
      
      private function checkOrientation() : void
      {
         if(this.body.GetLinearVelocity().x > 1)
         {
            oBAStateMachine.flip = false;
            oClingSensor.flip(1);
         }
         else if(this.body.GetLinearVelocity().x < -1)
         {
            oBAStateMachine.flip = true;
            oClingSensor.flip(-1);
         }
      }
      
      private function checkStates() : void
      {
         if(this.oKeyManager.isOneOfKeyDown(aKEY_DOWN) && this.bControlsEnable)
         {
            if(this.isCollidingWithSurface(SurfaceType.SLIPPERY_SLOPE,SurfaceType.GROUND_SLOPE) && !this.isCollidingWithSurface(SurfaceType.GROUND,SurfaceType.PLATFORM,SurfaceType.SLIPPERY,SurfaceType.WALL))
            {
               if(this.body.GetLinearVelocity().y > 1)
               {
                  animStateMachine.setState(sSTATE_SLIDE);
               }
            }
            else if(animStateMachine.state == sSTATE_CLING || this.aCollidingSurfaces.length == 0 && this.body.GetLinearVelocity().y > 2)
            {
               animStateMachine.setState(sSTATE_JUMP_DOWN);
            }
            else
            {
               animStateMachine.setState(sSTATE_CROUCH);
            }
         }
         else if(this.aCollidingSurfaces.length == 0 && this.body.GetLinearVelocity().y > 1)
         {
            animStateMachine.setState(sSTATE_JUMP_DOWN);
         }
         else if(Math.abs(this.body.GetLinearVelocity().x) > 1)
         {
            if(animStateMachine.state != sSTATE_START_RUN && animStateMachine.state != sSTATE_RUN && animStateMachine.state != sSTATE_RUN_ICE && animStateMachine.state != sSTATE_JUMP_UP)
            {
               animStateMachine.setState(sSTATE_START_RUN);
            }
         }
         else if(!this.oKeyManager.isOneOfKeyDown(aKEY_JUMP.concat(aKEY_LEFT,aKEY_RIGHT)) && this.body.GetLinearVelocity().Length() < 1)
         {
            if(animStateMachine.state != sSTATE_CLING)
            {
               animStateMachine.setState(sSTATE_IDLE);
            }
         }
      }
      
      private function checkStucked() : void
      {
         var _nForce:Number = NaN;
         if(Boolean(oHeadSensor))
         {
            if(oHeadSensor.isCollidingWithSurface(SurfaceType.CEILING) && this.isCollidingWithSurface(SurfaceType.GROUND,SurfaceType.PLATFORM,SurfaceType.SLIPPERY))
            {
               this.isStucked = true;
               _nForce = this.nWalkSpeed / 2 * (animStateMachine.flip ? 1 : -1);
               this.body.SetLinearVelocity(new b2Vec2(_nForce,0));
            }
            else
            {
               this.isStucked = false;
            }
         }
      }
      
      private function isCollidingWithSurface(... _aSurface) : Boolean
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
      
      private function checkLanding() : void
      {
         if(this.isCollidingWithSurface(SurfaceType.GROUND,SurfaceType.SLIPPERY,SurfaceType.GROUND_SLOPE,SurfaceType.SLIPPERY_SLOPE,SurfaceType.FATAL_FLOOR) || this.isCollidingWithSurface(SurfaceType.PLATFORM) && animStateMachine.state != sSTATE_JUMP_UP)
         {
            if(animStateMachine.state == sSTATE_JUMP_UP)
            {
               if(!this.isCollidingWithSurface(SurfaceType.WALL))
               {
                  animStateMachine.setState(sSTATE_JUMP_LAND);
                  this.resetJumpCount();
               }
            }
            else
            {
               animStateMachine.setState(sSTATE_JUMP_LAND);
               this.resetJumpCount();
            }
         }
      }
      
      private function checkSlopes() : void
      {
         var _oFixture:b2Fixture = null;
         if(!this.oKeyManager.isOneOfKeyDown(aKEY_DOWN.concat(aKEY_LEFT,aKEY_RIGHT)) && this.isCollidingWithSurface(SurfaceType.GROUND_SLOPE,SurfaceType.SLIPPERY_SLOPE))
         {
            for(_oFixture = this.body.GetFixtureList(); Boolean(_oFixture); _oFixture = _oFixture.GetNext())
            {
               _oFixture.SetFriction(ExternalConfig.instance.getPropertyAsNumber("nPLAYER_FRICTION_ON_SLOPES"));
            }
         }
         else
         {
            for(_oFixture = this.body.GetFixtureList(); Boolean(_oFixture); _oFixture = _oFixture.GetNext())
            {
               _oFixture.SetFriction(this.friction);
            }
         }
      }
      
      private function checkSliding() : void
      {
         if(this.oKeyManager.isOneOfKeyDown(aKEY_DOWN) && this.isCollidingWithSurface(SurfaceType.GROUND_SLOPE,SurfaceType.SLIPPERY_SLOPE))
         {
            this.body.ApplyForce(new b2Vec2(0,this.nSlidingForce),this.body.GetPosition());
         }
      }
      
      private function checkClinging() : void
      {
         var _oRect:Rectangle = null;
         if(oClingSensor.isCollidingWithSurface(SurfaceType.GROUND,SurfaceType.SLIPPERY) && !oFootSensor.isTouchingGround() && this.bAsClinged == false)
         {
            animStateMachine.setState(sSTATE_CLING);
            this.body.SetLinearVelocity(new b2Vec2());
            this.body.SetType(b2Body.b2_staticBody);
            _oRect = oBAStateMachine.getColliderByName(sCOLLIDER_BODY,false).rect;
            this.body.SetPosition(new b2Vec2(this.body.GetPosition().x,oClingSensor.clingPosition.y + _oRect.height / CommonConfig.nCELL_SIZE));
            animStateMachine.flip = this.body.GetPosition().x > oClingSensor.clingPosition.x ? true : false;
            oClingSensor.flip(animStateMachine.flip ? -1 : 1);
         }
      }
      
      private function startInvincibility(_bIsCollectable:Boolean = false) : void
      {
         this.onInvinsibilityTimer(null,true);
         var _nDelay:uint = GamePlayerConfig.uINVINSIBILITY_RESPAWN;
         if(_bIsCollectable)
         {
            _nDelay = GamePlayerConfig.uINVINSIBILITY_COLLECTABLE;
            SfxManager.instance.playSFX(sSFX_INVINSIBILITY);
         }
         this.mcInvinsibilityOverlay.visible = _bIsCollectable;
         this.oInvinsibilityTimer = new FrameTimer(1,_nDelay);
         if(_bIsCollectable)
         {
            oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oInvinsibilityTimer,TimerEvent.TIMER,this.onInvinsibilityTick);
         }
         oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oInvinsibilityTimer,TimerEvent.TIMER_COMPLETE,this.onInvinsibilityTimer);
         this.oInvinsibilityTimer.start();
         this.bInvincible = true;
      }
      
      private function resetJumpCount() : void
      {
         this.uPlayerExtraJumpsLimit = ExternalConfig.instance.getPropertyAsNumber("nPLAYER_EXTRA_JUMPS_LIMIT");
      }
      
      private function changeCollisionData(_oFilterData:b2FilterData) : void
      {
         var _oFixture:b2Fixture = null;
         for(_oFixture = oBody.GetFixtureList(); Boolean(_oFixture); _oFixture = _oFixture.GetNext())
         {
            _oFixture.SetFilterData(_oFilterData);
         }
         for(_oFixture = oCrouchedBody.GetFixtureList(); Boolean(_oFixture); _oFixture = _oFixture.GetNext())
         {
            _oFixture.SetFilterData(_oFilterData);
         }
      }
      
      private function resetCollisionData() : void
      {
         var _oFilterData:b2FilterData = new b2FilterData();
         _oFilterData.categoryBits = GamePlayerConfig.uPLAYER_CATEGORY_BIT;
         _oFilterData.maskBits = GamePlayerConfig.uPLAYER_MASK_BIT;
         this.changeCollisionData(_oFilterData);
      }
      
      private function state_cling_init() : void
      {
         SfxManager.instance.playSFX(sSFX_CLING);
         this.bAsClinged = true;
         this.resetJumpCount();
      }
      
      private function state_cling() : void
      {
         this.checkJumpKey();
         this.checkStates();
      }
      
      private function state_cling_end() : void
      {
         var _oMassData:b2MassData = null;
         if(Boolean(oBody))
         {
            oBody.SetType(b2Body.b2_dynamicBody);
            _oMassData = new b2MassData();
            _oMassData.mass = this.mass;
            oBody.SetMassData(_oMassData);
         }
         this.oClingTimer.start();
      }
      
      private function state_crouch_init() : void
      {
         SfxManager.instance.playSFX(sSFX_CROUCH);
         PhysEngine.instance.setBodyActivation(oCrouchedBody,true);
         oCrouchedBody.SetPosition(oBody.GetPosition());
         oCrouchedBody.SetLinearVelocity(oBody.GetLinearVelocity());
         PhysEngine.instance.setBodyActivation(oBody,false);
         oBody.SetLinearVelocity(new b2Vec2());
         PhysEngine.instance.setBodyActivation(oFootSensor.body,false);
         PhysEngine.instance.setBodyActivation(oHeadSensor.body,false);
         PhysEngine.instance.setBodyActivation(oClingSensor.body,false);
      }
      
      private function state_crouch() : void
      {
         if(!this.oKeyManager.isOneOfKeyDown(aKEY_DOWN))
         {
            animStateMachine.setState(sSTATE_IDLE);
         }
         this.checkSlopes();
         this.checkSliding();
         this.checkJumpKey();
         checkPit();
         this.checkStates();
      }
      
      private function state_crouch_end() : void
      {
         if(Boolean(oBody) && Boolean(oCrouchedBody))
         {
            PhysEngine.instance.setBodyActivation(oBody,true);
            oBody.SetPosition(oCrouchedBody.GetPosition());
            oBody.SetLinearVelocity(oCrouchedBody.GetLinearVelocity());
            PhysEngine.instance.setBodyActivation(oCrouchedBody,false);
            oCrouchedBody.SetLinearVelocity(new b2Vec2());
            oFootSensor.repositionBody();
            oHeadSensor.repositionBody();
            oClingSensor.repositionBody();
            PhysEngine.instance.setBodyActivation(oFootSensor.body,true);
            PhysEngine.instance.setBodyActivation(oHeadSensor.body,true);
            PhysEngine.instance.setBodyActivation(oClingSensor.body,true);
         }
      }
      
      private function state_die_start_init() : void
      {
         SfxManager.instance.playSFX(sSFX_DIE);
         PhysEngine.instance.setBodyActivation(this.body,false);
         this.body.SetLinearVelocity(new b2Vec2());
      }
      
      private function state_die_start() : void
      {
         if(animStateMachine.isLastFrame)
         {
            animStateMachine.setState(sSTATE_DIE);
         }
      }
      
      private function state_die() : void
      {
         var _oSfxDie:SoundUnit = null;
         if(animStateMachine.isLastFrame)
         {
            _oSfxDie = SfxManager.instance.getCurrentSound(sSFX_DIE);
            if(_oSfxDie == null || _oSfxDie.playing == false)
            {
               animStateMachine.setState(sSTATE_RESPAWN);
               PhysEngine.instance.setBodyActivation(this.body,true);
            }
         }
      }
      
      private function state_hurt() : void
      {
      }
      
      private function state_idle_init() : void
      {
         this.checkStucked();
      }
      
      private function state_idle() : void
      {
         this.checkStucked();
         if(!this.isStucked)
         {
            this.checkOrientation();
            this.checkStates();
            this.checkDisplacementKey();
            this.checkSlopes();
            this.checkSliding();
            this.checkJumpKey();
         }
      }
      
      private function state_jump_air_init() : void
      {
         SfxManager.instance.playSFX(sSFX_DOUBLE_JUMP);
      }
      
      private function state_jump_air() : void
      {
         this.checkOrientation();
         this.checkDisplacementKey();
         if(animStateMachine.isLastFrame)
         {
            animStateMachine.setState(sSTATE_JUMP_TOP);
         }
      }
      
      private function state_jump_end_init() : void
      {
         SfxManager.instance.playSFX(sSFX_JUMP_LAND);
      }
      
      private function state_jump_end() : void
      {
         this.checkOrientation();
         this.checkJumpKey();
         this.checkDisplacementKey();
         if(animStateMachine.isLastFrame)
         {
            animStateMachine.setState(sSTATE_IDLE);
         }
      }
      
      private function state_jump_top() : void
      {
         this.checkOrientation();
         this.checkDisplacementKey();
         this.checkJumpKey();
         this.checkClinging();
         this.checkLanding();
         if(animStateMachine.isLastFrame)
         {
            animStateMachine.setState(sSTATE_JUMP_DOWN);
         }
      }
      
      private function state_jump_start() : void
      {
         SfxManager.instance.playSFX(sSFX_JUMP);
         this.checkOrientation();
         this.checkDisplacementKey();
         animStateMachine.setState(sSTATE_JUMP_UP);
      }
      
      private function state_jump_up() : void
      {
         this.checkOrientation();
         this.checkDisplacementKey();
         this.checkLanding();
         if(this.body.GetLinearVelocity().y > -1)
         {
            animStateMachine.setState(sSTATE_JUMP_TOP);
         }
      }
      
      private function state_jump_down_start() : void
      {
      }
      
      private function state_jump_down() : void
      {
         this.checkOrientation();
         this.checkDisplacementKey();
         this.checkJumpKey();
         this.checkLanding();
         this.checkClinging();
         if(oBAStateMachine.rect.top > GamePlayer.instance.levelHeight)
         {
            this.die(true);
         }
      }
      
      private function state_respawn_init() : void
      {
         var _oPos:Point = null;
         if(GameSession.instance.lives > 0)
         {
            if(!this.bGameRestarted)
            {
               --GameSession.instance.lives;
            }
            else
            {
               this.bGameRestarted = false;
            }
            SfxManager.instance.playSFX(sSFX_RESPAWN);
            if(Boolean(SfxManager.instance.getCurrentSound(sSFX_RESPAWN)))
            {
               oEventManager.addEventListener(sEVENT_MANAGER_ID,SfxManager.instance.getCurrentSound(sSFX_RESPAWN),SoundEvent.COMPLETED,this.onSfxRespawn);
            }
            this.startInvincibility();
            _oPos = GamePlayer.instance.oCheckpoint.clone();
            _oPos.x /= CommonConfig.nCELL_SIZE;
            _oPos.y /= CommonConfig.nCELL_SIZE;
            this.body.SetLinearVelocity(new b2Vec2());
            this.body.SetPosition(new b2Vec2(_oPos.x,_oPos.y));
            this.body.SetType(b2Body.b2_staticBody);
         }
         else
         {
            animStateMachine.pause();
            this.dispatchEvent(new GamePlayerEvent(GamePlayerEvent.GAME_LOSE));
         }
         animStateMachine.visible = false;
      }
      
      private function state_respawn() : void
      {
         var _oMassData:b2MassData = null;
         animStateMachine.visible = !animStateMachine.isFirstFrame;
         if(animStateMachine.isLastFrame)
         {
            this.resetJumpCount();
            animStateMachine.setState(sSTATE_IDLE);
            this.body.SetType(b2Body.b2_dynamicBody);
            _oMassData = new b2MassData();
            _oMassData.mass = this.mass;
            oBody.SetMassData(_oMassData);
         }
      }
      
      private function state_run_init() : void
      {
         this.checkStucked();
      }
      
      private function state_run_start() : void
      {
         this.checkStucked();
         if(!this.isStucked)
         {
            this.checkOrientation();
            this.checkStates();
            this.checkDisplacementKey();
            this.checkSlopes();
            this.checkSliding();
            this.checkJumpKey();
         }
         if(animStateMachine.isLastFrame)
         {
            if(this.isCollidingWithSurface(SurfaceType.SLIPPERY,SurfaceType.SLIPPERY_SLOPE))
            {
               animStateMachine.setState(sSTATE_RUN_ICE);
            }
            else
            {
               animStateMachine.setState(sSTATE_RUN);
            }
         }
      }
      
      private function state_run_ice() : void
      {
         this.checkStucked();
         if(!this.isStucked)
         {
            this.checkOrientation();
            this.checkStates();
            this.checkDisplacementKey();
            this.checkSlopes();
            this.checkSliding();
            this.checkJumpKey();
            if(this.isCollidingWithSurface(SurfaceType.GROUND,SurfaceType.GROUND_SLOPE))
            {
               animStateMachine.setState(sSTATE_RUN);
            }
         }
      }
      
      private function state_run() : void
      {
         this.checkStucked();
         if(!this.isStucked)
         {
            this.checkOrientation();
            this.checkStates();
            this.checkDisplacementKey();
            this.checkSlopes();
            this.checkSliding();
            this.checkJumpKey();
            if(this.isCollidingWithSurface(SurfaceType.SLIPPERY,SurfaceType.SLIPPERY_SLOPE))
            {
               animStateMachine.setState(sSTATE_RUN_ICE);
            }
         }
      }
      
      private function state_slide_init() : void
      {
         SfxManager.instance.playSFX(sSFX_SLIDE);
      }
      
      private function state_slide() : void
      {
         this.checkOrientation();
         this.checkStates();
         this.checkSliding();
         checkPit();
         this.checkJumpKey();
      }
      
      private function state_stomp_init() : void
      {
         SfxManager.instance.playSFX(sSFX_JUMP_STOMP);
      }
      
      private function state_stomp() : void
      {
         this.checkOrientation();
         this.checkDisplacementKey();
         this.checkLanding();
         if(this.body.GetLinearVelocity().y > -1)
         {
            animStateMachine.setState(sSTATE_JUMP_TOP);
         }
      }
      
      override protected function onUpdate(_e:UpdateEvent) : void
      {
         super.onUpdate(_e);
         if(Boolean(this.mcInvinsibilityOverlay) && Boolean(this.body))
         {
            this.mcInvinsibilityOverlay.x = this.body.GetPosition().x * CommonConfig.nCELL_SIZE;
            this.mcInvinsibilityOverlay.y = this.body.GetPosition().y * CommonConfig.nCELL_SIZE;
         }
      }
      
      private function onInvinsibilityTick(_e:TimerEvent) : void
      {
         if(this.oInvinsibilityTimer.currentCount > 0.75 * this.oInvinsibilityTimer.repeatCount)
         {
            if(Boolean(SfxManager.instance.getCurrentSound(sSFX_INVINSIBILITY)))
            {
               SfxManager.instance.stopSFX(sSFX_INVINSIBILITY);
               SfxManager.instance.playSFX(sSFX_INVINSIBILITY_TICK);
            }
            this.mcInvinsibilityOverlay.visible = !this.mcInvinsibilityOverlay.visible;
         }
      }
      
      private function onInvinsibilityTimer(_e:TimerEvent, _bIsReset:Boolean = false) : void
      {
         if(Boolean(this.oInvinsibilityTimer))
         {
            this.oInvinsibilityTimer.destroy();
         }
         this.oInvinsibilityTimer = null;
         this.mcInvinsibilityOverlay.visible = false;
         SfxManager.instance.stopSFX(sSFX_INVINSIBILITY);
         SfxManager.instance.stopSFX(sSFX_INVINSIBILITY_TICK);
         this.bInvincible = false;
         if(!_bIsReset)
         {
            if(this.isCollidingWithSurface(SurfaceType.FATAL_CEILING,SurfaceType.FATAL_WALL,SurfaceType.FATAL_FLOOR))
            {
               this.die();
            }
         }
      }
      
      private function onSfxRespawn(_e:SoundEvent) : void
      {
         oEventManager.removeEventListener(sEVENT_MANAGER_ID,_e.target as IEventDispatcher,_e.type,this.onSfxRespawn);
         SoundManager.instance.fadeVolume(SoundConfig.sSOUND_CATEGORY_MUSIC,SoundConfig.nDEFAULT_VOLUME_MUSIC,SoundConfig.nMUSIC_SWITCH_FADE_DURATION,false,false);
      }
      
      private function onClingTimerComplete(_e:TimerEvent) : void
      {
         this.oClingTimer.reset();
         this.bAsClinged = false;
      }
      
      private function onKeyUp(_e:KeyEvent) : void
      {
         switch(_e.keyCode)
         {
            case KeyCode.DOWN:
            case KeyCode.S:
               if(this.bPassThroughPlatform)
               {
                  this.bPassThroughPlatform = false;
                  this.resetCollisionData();
               }
               break;
            case KeyCode.A:
            case KeyCode.D:
            case KeyCode.LEFT:
            case KeyCode.RIGHT:
               this.bRunning = false;
         }
      }
      
      private function onComboEntered(_e:SequenceEvent) : void
      {
         var _oFilterData:b2FilterData = null;
         switch(_e.ID)
         {
            case sPASS_THROUGH_PLATFORM_COMBO_1:
            case sPASS_THROUGH_PLATFORM_COMBO_2:
               this.bPassThroughPlatform = true;
               _oFilterData = new b2FilterData();
               _oFilterData.categoryBits = GamePlayerConfig.uPASS_THROUGH_PLATFORMS_CATEGORY_BIT;
               _oFilterData.maskBits = GamePlayerConfig.uPASS_THROUGH_PLATFORMS_MASK_BIT;
               this.changeCollisionData(_oFilterData);
               break;
            case sRUN_COMBO_1:
            case sRUN_COMBO_2:
            case sRUN_COMBO_3:
            case sRUN_COMBO_4:
               this.bRunning = true;
         }
      }
      
      override public function onBeginContact(_oObject:IContactManaged, _oBody:b2Body, _oContact:b2Contact) : void
      {
         super.onBeginContact(_oObject,_oBody,_oContact);
         if(_oObject == SurfaceType.PLATFORM)
         {
            if(this.body.GetPosition().y - 5 / CommonConfig.nCELL_SIZE > _oBody.GetPosition().y)
            {
               _oContact.SetEnabled(false);
               return;
            }
         }
         if(_oObject is SurfaceType)
         {
            this.resetCollisionData();
            if((_oObject == SurfaceType.FATAL_CEILING || _oObject == SurfaceType.FATAL_WALL || _oObject == SurfaceType.FATAL_FLOOR) && !this.isInvincible)
            {
               this.die();
            }
            else
            {
               this.aCollidingSurfaces.push(_oObject);
            }
         }
         else if(_oObject is AbstractOpponent)
         {
            if(this.isInvincible || animStateMachine.state == sSTATE_SLIDE)
            {
               AbstractOpponent(_oObject).die();
            }
            else if(oFootSensor.isTouching(AbstractOpponent(_oObject).head))
            {
               this.body.ApplyImpulse(new b2Vec2(0,-this.nJumpForce),this.body.GetPosition());
               animStateMachine.setState(sSTATE_JUMP_STOMP);
               AbstractOpponent(_oObject).die();
            }
            else
            {
               this.die();
            }
         }
         else if(_oObject is BonusInvincibility)
         {
            this.startInvincibility(true);
         }
         if(this.isCollidingWithSurface(SurfaceType.GROUND,SurfaceType.GROUND_SLOPE,SurfaceType.SLIPPERY,SurfaceType.SLIPPERY_SLOPE,SurfaceType.PLATFORM))
         {
            this.oFloorNormal = _oContact.GetManifold().m_localPlaneNormal;
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
      
      override public function onPreSolveContact(_oObject:IContactManaged, _oBody:b2Body, _oContact:b2Contact, _oManifold:b2Manifold) : void
      {
         super.onPreSolveContact(_oObject,_oBody,_oContact,_oManifold);
         if(animStateMachine.state == sSTATE_START_DIE || animStateMachine.state == sSTATE_DIE)
         {
            _oContact.SetEnabled(false);
         }
         else if(_oObject == SurfaceType.CEILING || _oObject == SurfaceType.WALL)
         {
            if(this.isStucked)
            {
               _oContact.SetEnabled(false);
            }
         }
         else if(_oObject == SurfaceType.PLATFORM && this.bPassThroughPlatform)
         {
            _oContact.SetEnabled(false);
         }
      }
      
      public function get viewportPos() : Point
      {
         this.oViewportPos.x = oBAStateMachine.x;
         this.oViewportPos.y = oBAStateMachine.y;
         return this.oViewportPos;
      }
      
      override protected function get mass() : Number
      {
         return ExternalConfig.instance.getPropertyAsNumber("nPLAYER_MASS");
      }
      
      override protected function get friction() : Number
      {
         return ExternalConfig.instance.getPropertyAsNumber("nPLAYER_FRICTION");
      }
      
      override protected function get restitution() : Number
      {
         return ExternalConfig.instance.getPropertyAsNumber("nPLAYER_RESTITUTION");
      }
      
      override protected function get damping() : Number
      {
         return ExternalConfig.instance.getPropertyAsNumber("nPLAYER_DAMPING");
      }
      
      public function get isInvincible() : Boolean
      {
         return this.bInvincible;
      }
      
      public function get invinsibilityOverlay() : BitmappedAnimation
      {
         return this.mcInvinsibilityOverlay;
      }
      
      public function get isStucked() : Boolean
      {
         return this.bIsStucked;
      }
      
      public function set isStucked(_bStucked:Boolean) : void
      {
         this.bIsStucked = _bStucked;
      }
      
      override public function get body() : b2Body
      {
         if(animStateMachine.state == sSTATE_CROUCH)
         {
            return oCrouchedBody;
         }
         return oBody;
      }
      
      public function get foot() : FootSensor
      {
         return oFootSensor;
      }
      
      public function get gameRestarted() : Boolean
      {
         return this.bGameRestarted;
      }
      
      public function set gameRestarted(_value:Boolean) : void
      {
         this.bGameRestarted = _value;
      }
   }
}

