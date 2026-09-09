package mx.effects.easing
{
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   [Alternative(replacement="spark.effects.easing.Sine",since="4.0")]
   public class Sine
   {
      
      mx_internal static const VERSION:String = "4.0.0.14159";
      
      public function Sine()
      {
         super();
      }
      
      public static function easeIn(t:Number, b:Number, c:Number, d:Number) : Number
      {
         return -c * Math.cos(t / d * (Math.PI / 2)) + c + b;
      }
      
      public static function easeOut(t:Number, b:Number, c:Number, d:Number) : Number
      {
         return c * Math.sin(t / d * (Math.PI / 2)) + b;
      }
      
      public static function easeInOut(t:Number, b:Number, c:Number, d:Number) : Number
      {
         return -c / 2 * (Math.cos(Math.PI * t / d) - 1) + b;
      }
   }
}

