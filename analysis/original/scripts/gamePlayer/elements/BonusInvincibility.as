package gamePlayer.elements
{
   import com.sarbakan.sbdk.blitting.core.BitmappedAnimStateMachine;
   import flash.geom.Point;
   import gamePlayer.GamePlayer;
   import media.type.AbstractMedia;
   import media.type.BonusInvincibilityMedia;
   
   public class BonusInvincibility extends AbstractCollectable
   {
      
      public function BonusInvincibility(_oMedia:AbstractMedia, _oPos:Point)
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
         oBAStateMachine.addBitmappedState(sSTATE_IDLE,oMedia.getClass(BonusInvincibilityMedia.LINKAGE_IDLE));
         oBAStateMachine.addBitmappedState(sSTATE_COLLECT,oMedia.getClass(BonusInvincibilityMedia.LINKAGE_COLLECTED),null,this.state_collect,this.state_collect_init);
         oBAStateMachine.setState(sSTATE_IDLE);
      }
      
      private function state_collect_init() : void
      {
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

