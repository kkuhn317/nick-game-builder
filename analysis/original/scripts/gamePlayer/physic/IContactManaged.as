package gamePlayer.physic
{
   import Box2D.Collision.b2Manifold;
   import Box2D.Dynamics.Contacts.b2Contact;
   import Box2D.Dynamics.b2Body;
   
   public interface IContactManaged
   {
      
      function onBeginContact(param1:IContactManaged, param2:b2Body, param3:b2Contact) : void;
      
      function onEndContact(param1:IContactManaged, param2:b2Body, param3:b2Contact) : void;
      
      function onPreSolveContact(param1:IContactManaged, param2:b2Body, param3:b2Contact, param4:b2Manifold) : void;
      
      function get body() : b2Body;
   }
}

