package Box2D.Collision.Shapes
{
   import Box2D.Collision.b2AABB;
   import Box2D.Collision.b2Distance;
   import Box2D.Collision.b2DistanceInput;
   import Box2D.Collision.b2DistanceOutput;
   import Box2D.Collision.b2DistanceProxy;
   import Box2D.Collision.b2RayCastInput;
   import Box2D.Collision.b2RayCastOutput;
   import Box2D.Collision.b2SimplexCache;
   import Box2D.Common.Math.b2Transform;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Common.b2Settings;
   import Box2D.Common.b2internal;
   
   use namespace b2internal;
   
   public class b2Shape
   {
      
      b2internal static const e_unknownShape:int = -1;
      
      b2internal static const e_circleShape:int = 0;
      
      b2internal static const e_polygonShape:int = 1;
      
      b2internal static const e_edgeShape:int = 2;
      
      b2internal static const e_shapeTypeCount:int = 3;
      
      public static const e_hitCollide:int = 1;
      
      public static const e_missCollide:int = 0;
      
      public static const e_startsInsideCollide:int = -1;
      
      b2internal var m_type:int;
      
      b2internal var m_radius:Number;
      
      public function b2Shape()
      {
         super();
         this.m_type = b2internal::e_unknownShape;
         this.m_radius = b2Settings.b2_linearSlop;
      }
      
      public static function TestOverlap(shape1:b2Shape, transform1:b2Transform, shape2:b2Shape, transform2:b2Transform) : Boolean
      {
         var input:b2DistanceInput = new b2DistanceInput();
         input.proxyA = new b2DistanceProxy();
         input.proxyA.Set(shape1);
         input.proxyB = new b2DistanceProxy();
         input.proxyB.Set(shape2);
         input.transformA = transform1;
         input.transformB = transform2;
         input.useRadii = true;
         var simplexCache:b2SimplexCache = new b2SimplexCache();
         simplexCache.count = 0;
         var output:b2DistanceOutput = new b2DistanceOutput();
         b2Distance.Distance(output,simplexCache,input);
         return output.distance < 10 * Number.MIN_VALUE;
      }
      
      public function Copy() : b2Shape
      {
         return null;
      }
      
      public function Set(other:b2Shape) : void
      {
         this.m_radius = other.m_radius;
      }
      
      public function GetType() : int
      {
         return this.m_type;
      }
      
      public function TestPoint(xf:b2Transform, p:b2Vec2) : Boolean
      {
         return false;
      }
      
      public function RayCast(output:b2RayCastOutput, input:b2RayCastInput, transform:b2Transform) : Boolean
      {
         return false;
      }
      
      public function ComputeAABB(aabb:b2AABB, xf:b2Transform) : void
      {
      }
      
      public function ComputeMass(massData:b2MassData, density:Number) : void
      {
      }
      
      public function ComputeSubmergedArea(normal:b2Vec2, offset:Number, xf:b2Transform, c:b2Vec2) : Number
      {
         return 0;
      }
   }
}

