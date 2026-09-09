package
{
   import flash.geom.ColorTransform;
   
   public class CommonConfig
   {
      
      public static const sCONFIG_DOMAIN_MEDIA:String = "media_domain";
      
      public static const sCONFIG_DOMAIN_SERVICES:String = "services_domain";
      
      public static const sCONFIG_ASSETS_PATH:String = "asset_path";
      
      public static const sCONFIG_MEDIA_PATH:String = "media_path";
      
      public static const sCONFIG_FAKED_SERVICES_PATH:String = "fakedService_path";
      
      public static const sCONFIG_PROXY_PATH_MODULE:String = "proxy_url_module";
      
      public static const sCONFIG_PROXY_PATH_PROPS:String = "proxy_url_props";
      
      public static const sPRELOADER_ASSET_ID:String = "preloaderAsset";
      
      public static const sDATA_PATH:String = "../data/";
      
      public static const sPATH_CONFIG_PROPERTY:String = "xml/propertyConfig/";
      
      public static const sPATH_CONFIG_SFX:String = "xml/soundConfig/";
      
      public static const sPATH_STRINGS:String = "xml/translation/";
      
      public static const nCELL_SIZE:Number = 30;
      
      public static const sGOAL_TYPE_DOOR:String = "goal_door";
      
      public static const sGOAL_TYPE_COIN:String = "goal_coin";
      
      public static const sGOAL_TYPE_OPPONENT:String = "goal_opponent";
      
      public static const oINACTIVE_COLOR_TRANSFORM:ColorTransform = new ColorTransform(0.8,0.8,0.8);
      
      public function CommonConfig()
      {
         super();
      }
   }
}

