package utils.enum
{
   import Box2D.Collision.b2Manifold;
   import Box2D.Dynamics.Contacts.b2Contact;
   import Box2D.Dynamics.b2Body;
   import com.sarbakan.sbdk.utils.AbstractEnumeration;
   import gamePlayer.physic.IContactManaged;
   
   public class SurfaceType extends AbstractEnumeration implements IContactManaged
   {
      
      public static const GROUND:SurfaceType = new SurfaceType("ground",oProtectionFlag);
      
      public static const GROUND_SLOPE:SurfaceType = new SurfaceType("groundSlope",oProtectionFlag);
      
      public static const CEILING:SurfaceType = new SurfaceType("ceiling",oProtectionFlag);
      
      public static const WALL:SurfaceType = new SurfaceType("wall",oProtectionFlag);
      
      public static const SLIPPERY:SurfaceType = new SurfaceType("slippery",oProtectionFlag);
      
      public static const SLIPPERY_SLOPE:SurfaceType = new SurfaceType("slipperySlope",oProtectionFlag);
      
      public static const FATAL_FLOOR:SurfaceType = new SurfaceType("fatalFloor",oProtectionFlag);
      
      public static const FATAL_WALL:SurfaceType = new SurfaceType("fatalWall",oProtectionFlag);
      
      public static const FATAL_CEILING:SurfaceType = new SurfaceType("fatalCeiling",oProtectionFlag);
      
      public static const PLATFORM:SurfaceType = new SurfaceType("platform",oProtectionFlag);
      
      public function SurfaceType(_sName:String, _oProtectionFlag:Object)
      {
         super(_sName,_oProtectionFlag);
      }
      
      public function onBeginContact(_oObject:IContactManaged, _oBody:b2Body, _oContact:b2Contact) : void
      {
      }
      
      public function onEndContact(_oObject:IContactManaged, _oBody:b2Body, _oContact:b2Contact) : void
      {
      }
      
      public function onPreSolveContact(_oObject:IContactManaged, _oBody:b2Body, _oContact:b2Contact, _oManifold:b2Manifold) : void
      {
      }
      
      public function get body() : b2Body
      {
         return null;
      }
   }
}

