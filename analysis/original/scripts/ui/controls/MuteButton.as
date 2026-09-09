package ui.controls
{
   import com.sarbakan.sbdk.sound.SoundManager;
   import com.sarbakan.sbdk.ui.CheckBox;
   import flash.display.MovieClip;
   
   public class MuteButton extends CheckBox
   {
      
      public function MuteButton(_mcRef:MovieClip)
      {
         super(_mcRef,null,true);
         this.checked = SoundManager.instance.isMuted();
      }
      
      override public function set checked(_b:Boolean) : void
      {
         if(checked != _b)
         {
            if(_b)
            {
               SoundManager.instance.mute();
            }
            else
            {
               SoundManager.instance.unmute();
            }
            super.checked = _b;
         }
      }
   }
}

