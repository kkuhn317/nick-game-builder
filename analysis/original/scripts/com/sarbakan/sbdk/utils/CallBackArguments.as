package com.sarbakan.sbdk.utils
{
   public class CallBackArguments
   {
      
      public function CallBackArguments()
      {
         super();
      }
      
      public static function create(_fCallBack:Function, ... _aCallBackArgs) : Function
      {
         return function(... _aWrapperArgs):*
         {
            return _fCallBack.apply(this,_aWrapperArgs.concat(_aCallBackArgs));
         };
      }
   }
}

