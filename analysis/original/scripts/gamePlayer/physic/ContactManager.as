package gamePlayer.physic
{
   import Box2D.Collision.b2Manifold;
   import Box2D.Dynamics.Contacts.b2Contact;
   import Box2D.Dynamics.b2ContactListener;
   import Box2D.Dynamics.b2Fixture;
   
   public class ContactManager extends b2ContactListener
   {
      
      public function ContactManager()
      {
         super();
      }
      
      public function destroy() : void
      {
      }
      
      override public function BeginContact(_oContact:b2Contact) : void
      {
         var _oFixtureA:b2Fixture = _oContact.GetFixtureA();
         var _oFixtureB:b2Fixture = _oContact.GetFixtureB();
         if(Boolean(_oFixtureA.GetBody().GetUserData()))
         {
            _oFixtureA.GetBody().GetUserData().onBeginContact(_oFixtureB.GetBody().GetUserData(),_oFixtureB.GetBody(),_oContact);
         }
         if(Boolean(_oFixtureB.GetBody().GetUserData()))
         {
            _oFixtureB.GetBody().GetUserData().onBeginContact(_oFixtureA.GetBody().GetUserData(),_oFixtureA.GetBody(),_oContact);
         }
      }
      
      override public function EndContact(_oContact:b2Contact) : void
      {
         var _oFixtureA:b2Fixture = _oContact.GetFixtureA();
         var _oFixtureB:b2Fixture = _oContact.GetFixtureB();
         if(Boolean(_oFixtureA.GetBody().GetUserData()))
         {
            _oFixtureA.GetBody().GetUserData().onEndContact(_oFixtureB.GetBody().GetUserData(),_oFixtureB.GetBody(),_oContact);
         }
         if(Boolean(_oFixtureB.GetBody().GetUserData()))
         {
            _oFixtureB.GetBody().GetUserData().onEndContact(_oFixtureA.GetBody().GetUserData(),_oFixtureA.GetBody(),_oContact);
         }
      }
      
      override public function PreSolve(_oContact:b2Contact, _oOldManifold:b2Manifold) : void
      {
         var _oFixtureA:b2Fixture = _oContact.GetFixtureA();
         var _oFixtureB:b2Fixture = _oContact.GetFixtureB();
         if(Boolean(_oFixtureA.GetBody().GetUserData()))
         {
            _oFixtureA.GetBody().GetUserData().onPreSolveContact(_oFixtureB.GetBody().GetUserData(),_oFixtureB.GetBody(),_oContact,_oOldManifold);
         }
         if(Boolean(_oFixtureB.GetBody().GetUserData()))
         {
            _oFixtureB.GetBody().GetUserData().onPreSolveContact(_oFixtureA.GetBody().GetUserData(),_oFixtureA.GetBody(),_oContact,_oOldManifold);
         }
      }
   }
}

