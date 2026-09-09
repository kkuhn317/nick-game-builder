package gamePlayer
{
   import com.sarbakan.sbdk.blitting.core.BitmappedAnimContainer;
   import com.sarbakan.sbdk.blitting.core.MCAnimation;
   import com.sarbakan.sbdk.events.BitmappedEvent;
   import com.sarbakan.sbdk.localization.LocalizationManager;
   import com.sarbakan.sbdk.utils.EventManager;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class GoalDisplay
   {
      
      private static const sEVENT_MANAGER_ID:String = "event";
      
      private var oEventManager:EventManager;
      
      private var mcAnimation:MCAnimation;
      
      private var sGoalLocale:String;
      
      private var cGoalIcon:Class;
      
      public function GoalDisplay(_oContainer:BitmappedAnimContainer, _nX:Number, _nY:Number, _sLayer:String, _sGoalType:String)
      {
         super();
         this.oEventManager = new EventManager();
         switch(_sGoalType)
         {
            case CommonConfig.sGOAL_TYPE_COIN:
               this.sGoalLocale = "id_ui_goal_coin";
               this.cGoalIcon = mcCoinGoalIcon;
               break;
            case CommonConfig.sGOAL_TYPE_OPPONENT:
               this.sGoalLocale = "id_ui_goal_opponent";
               this.cGoalIcon = mcOpponentGoalIcon;
               break;
            default:
               this.sGoalLocale = "id_ui_goal_door";
               this.cGoalIcon = mcDoorGoalIcon;
         }
         this.mcAnimation = _oContainer.addMovieClip(mcGoalDisplay,_nX,_nY,_sLayer);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.mcAnimation,Event.ENTER_FRAME,this.onUpdate);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.mcAnimation,BitmappedEvent.HIDE,this.onHide);
      }
      
      public function destroy() : void
      {
         if(Boolean(this.mcAnimation))
         {
            this.mcAnimation.destroy();
         }
         this.mcAnimation = null;
      }
      
      private function onUpdate(_e:Event) : void
      {
         this.oEventManager.removeEventListener(sEVENT_MANAGER_ID,this.mcAnimation,Event.ENTER_FRAME,this.onUpdate);
         LocalizationManager.instance.setTextField(this.mcAnimation.mc.mcText.txtText,this.sGoalLocale);
         var _mcIcon:MovieClip = new this.cGoalIcon();
         this.mcAnimation.mc.mcIcon.addChild(_mcIcon);
      }
      
      private function onHide(_e:Event) : void
      {
         this.destroy();
      }
   }
}

