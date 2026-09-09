package gamePlayer.elements
{
   import com.sarbakan.sbdk.blitting.core.BitmappedAnimStateMachine;
   import flash.geom.Point;
   import gamePlayer.GamePlayer;
   import gamePlayer.GameSession;
   import media.type.AbstractMedia;
   import media.type.BonusCoinMedia;
   import sound.SfxManager;
   
   public class BonusExtraLife extends AbstractCollectable
   {
      
      private static const sSFX_LIFE:String = "sndCollectableLife";
      
      public function BonusExtraLife(_oMedia:AbstractMedia, _oPos:Point)
      {
         super(_oMedia,_oPos);
         oBAStateMachine.x = _oPos.x;
         oBAStateMachine.y = _oPos.y;
      }
      
      override public function destroy() : void
      {
         super.destroy();
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
         SfxManager.instance.playSFX(sSFX_LIFE);
         ++GameSession.instance.lives;
      }
      
      private function state_collect() : void
      {
         if(oBAStateMachine.isLastFrame)
         {
            GamePlayer.instance.removeElement(this);
         }
      }
   }
}

