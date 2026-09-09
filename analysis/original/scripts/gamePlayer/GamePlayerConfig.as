package gamePlayer
{
   public class GamePlayerConfig
   {
      
      public static const uPLAYER_CATEGORY_BIT:uint = 1;
      
      public static const uPLAYER_MASK_BIT:uint = 65535 - uPLAYER_CATEGORY_BIT;
      
      public static const uSURFACE_CATEGORY_BIT:uint = 2;
      
      public static const uSURFACE_MASK_BIT:uint = 65535;
      
      public static const uPLATFORM_CATEGORY_BIT:uint = 4;
      
      public static const uPLATFORM_MASK_BIT:uint = 65535;
      
      public static const uCOLLECTABLE_CATEGORY_BIT:uint = 8;
      
      public static const uCOLLECTABLE_MASK_BIT:uint = 65535 - uENEMY_CATEGORY_BIT;
      
      public static const uENEMY_CATEGORY_BIT:uint = 16;
      
      public static const uENEMY_MASK_BIT:uint = 65535 - uCOLLECTABLE_CATEGORY_BIT - uENEMY_CATEGORY_BIT;
      
      public static const uPASS_THROUGH_PLATFORMS_CATEGORY_BIT:uint = 32;
      
      public static const uPASS_THROUGH_PLATFORMS_MASK_BIT:uint = 65535 - uPLATFORM_CATEGORY_BIT;
      
      public static const uNO_COLLISIONS_CATEGORY_BIT:uint = 64;
      
      public static const uNO_COLLISIONS_MASK_BIT:uint = 1;
      
      public static const nHUD_COUNTER_SPEED:uint = 5;
      
      public static const uCOINS_FOR_LIFE:uint = 100;
      
      public static const uLIFES_START:uint = 5;
      
      public static const uINVINSIBILITY_RESPAWN:uint = 100;
      
      public static const uINVINSIBILITY_COLLECTABLE:uint = 350;
      
      public function GamePlayerConfig()
      {
         super();
      }
   }
}

