package services.events
{
   import flash.events.Event;
   
   public class LoginEvent extends Event
   {
      
      public static const LOGIN_SUCCEED:String = "loginSucceed";
      
      public static const LOGIN_CANCEL:String = "loginCancel";
      
      private var sUser:String;
      
      public function LoginEvent(type:String, _sUser:String = null, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super(type,bubbles,cancelable);
         this.sUser = _sUser;
      }
      
      public function get user() : String
      {
         return this.sUser;
      }
   }
}

