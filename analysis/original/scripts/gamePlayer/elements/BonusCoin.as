package gamePlayer.elements
{
   import com.sarbakan.sbdk.blitting.core.BitmappedAnimStateMachine;
   import com.sarbakan.sbdk.utils.ExternalConfig;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.geom.Point;
   import gamePlayer.GamePlayer;
   import gamePlayer.GameSession;
   import gamePlayer.events.GamePlayerEvent;
   import media.type.AbstractMedia;
   import media.type.BonusCoinMedia;
   import sound.SfxManager;
   
   public class BonusCoin extends AbstractCollectable implements IEventDispatcher
   {
      
      private static const sSFX_COIN:String = "sndCollectableCoin";
      
      private var oEventDispatcher:EventDispatcher;
      
      public function BonusCoin(_oMedia:AbstractMedia, _oPos:Point)
      {
         super(_oMedia,_oPos);
         oBAStateMachine.x = _oPos.x;
         oBAStateMachine.y = _oPos.y;
         this.oEventDispatcher = new EventDispatcher(this);
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.oEventDispatcher = null;
      }
      
      public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false) : void
      {
         this.oEventDispatcher.addEventListener(type,listener,useCapture,priority,useWeakReference);
      }
      
      public function dispatchEvent(event:Event) : Boolean
      {
         return this.oEventDispatcher.dispatchEvent(event);
      }
      
      public function hasEventListener(type:String) : Boolean
      {
         return this.oEventDispatcher.hasEventListener(type);
      }
      
      public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false) : void
      {
         this.oEventDispatcher.removeEventListener(type,listener,useCapture);
      }
      
      public function willTrigger(type:String) : Boolean
      {
         return this.oEventDispatcher.willTrigger(type);
      }
      
      override protected function initStateMachine() : void
      {
         oBAStateMachine = new BitmappedAnimStateMachine();
         oBAStateMachine.addBitmappedState(sSTATE_IDLE,oMedia.getClass(BonusCoinMedia.LINKAGE_IDLE));
         oBAStateMachine.addBitmappedState(sSTATE_COLLECT,oMedia.getClass(BonusCoinMedia.LINKAGE_COLLECTED),null,this.state_collect,this.state_collect_init);
         oBAStateMachine.setState(sSTATE_IDLE);
      }
      
      private function state_collect_init() : void
      {
         SfxManager.instance.playSFX(sSFX_COIN);
         GameSession.instance.score += ExternalConfig.instance.getPropertyAsUint("uPOINTS_COIN");
      }
      
      private function state_collect() : void
      {
         if(animStateMachine.isLastFrame)
         {
            this.dispatchEvent(new GamePlayerEvent(GamePlayerEvent.COLLECT_COIN));
            GamePlayer.instance.removeElement(this);
         }
      }
   }
}

