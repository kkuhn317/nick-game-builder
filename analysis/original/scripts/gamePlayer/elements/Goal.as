package gamePlayer.elements
{
   import com.sarbakan.sbdk.blitting.core.BitmappedAnimStateMachine;
   import com.sarbakan.sbdk.sound.SoundManager;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.geom.Point;
   import gamePlayer.GameSession;
   import gamePlayer.events.GamePlayerEvent;
   import gamePlayer.viewport.IViewportTargetable;
   import gamePlayer.viewport.Viewport;
   import media.type.AbstractMedia;
   import media.type.GoalMedia;
   import sound.SfxManager;
   
   public class Goal extends AbstractCollectable implements IViewportTargetable, IEventDispatcher
   {
      
      private static const sSTATE_COLLECTED:String = "collected";
      
      private static const sSFX_GOAL:String = "sndCollectableGoal";
      
      private var bCollected:Boolean;
      
      private var oViewportPos:Point;
      
      private var eventDispatcher:EventDispatcher;
      
      public function Goal(_oMedia:AbstractMedia, _oPos:Point)
      {
         super(_oMedia,_oPos);
         oBAStateMachine.x = _oPos.x;
         oBAStateMachine.y = _oPos.y;
         this.oViewportPos = _oPos;
         this.eventDispatcher = new EventDispatcher(this);
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.oViewportPos = null;
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
      
      override protected function initStateMachine() : void
      {
         oBAStateMachine = new BitmappedAnimStateMachine();
         oBAStateMachine.addBitmappedState(sSTATE_IDLE,oMedia.getClass(GoalMedia.LINKAGE_IDLE));
         oBAStateMachine.addBitmappedState(sSTATE_COLLECT,oMedia.getClass(GoalMedia.LINKAGE_COLLECT),null,this.state_collect,this.state_collectInit);
         oBAStateMachine.addBitmappedState(sSTATE_COLLECTED,oMedia.getClass(GoalMedia.LINKAGE_COLLECTED));
         oBAStateMachine.setStateLooping(sSTATE_COLLECT,false);
         oBAStateMachine.setState(sSTATE_IDLE);
      }
      
      private function state_collectInit() : void
      {
         if(GameSession.instance.goalLeft <= 1)
         {
            Viewport.instance.easeTo(this,0.1);
            SoundManager.instance.fadeVolume(SoundConfig.sSOUND_CATEGORY_MUSIC,0,SoundConfig.nMUSIC_SWITCH_FADE_DURATION,false,false);
         }
         SfxManager.instance.playSFX(sSFX_GOAL);
      }
      
      private function state_collect() : void
      {
         if(this.bCollected == false && oBAStateMachine.isLastFrame)
         {
            this.dispatchEvent(new GamePlayerEvent(GamePlayerEvent.COLLECT_GOAL));
            oBAStateMachine.setState(sSTATE_COLLECTED);
         }
      }
      
      public function get viewportPos() : Point
      {
         return this.oViewportPos;
      }
   }
}

