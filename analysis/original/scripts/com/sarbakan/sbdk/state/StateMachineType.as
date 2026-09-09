package com.sarbakan.sbdk.state
{
   import com.sarbakan.sbdk.utils.AbstractEnumeration;
   
   public class StateMachineType extends AbstractEnumeration
   {
      
      public static const FRAME_BASED:StateMachineType = new StateMachineType("frameBased",oProtectionFlag);
      
      public static const TIME_BASED:StateMachineType = new StateMachineType("timeBased",oProtectionFlag);
      
      public function StateMachineType(_sName:String, _oProtectionFlag:Object)
      {
         super(_sName,_oProtectionFlag);
      }
   }
}

