package gamePlayer.physic
{
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2BodyDef;
   import Box2D.Dynamics.b2DebugDraw;
   import Box2D.Dynamics.b2World;
   import com.sarbakan.sbdk.errors.ErrorMessages;
   import com.sarbakan.sbdk.utils.EventManager;
   import com.sarbakan.sbdk.utils.ExternalConfig;
   import de.polygonal.ds.HashMap;
   import flash.display.Sprite;
   import flash.geom.Point;
   
   public class PhysEngine
   {
      
      private static var oGRAVITY:b2Vec2;
      
      private static var oInstance:PhysEngine;
      
      private static const sEVENT_MANAGER_ID:String = "physengine_event";
      
      private static const bIS_SLEEP_ALLOWED:Boolean = true;
      
      private static const nTIME_STEP:Number = 1 / 35;
      
      private static const iITERATIONS_COUNT:uint = 100;
      
      private static var bAllowConstruction:Boolean = false;
      
      private var oEventManager:EventManager;
      
      private var oWorld:b2World;
      
      private var oContactManager:ContactManager;
      
      private var aBodyToDestroy:Vector.<b2Body>;
      
      private var aBodyActivationList:HashMap;
      
      private var dbgDraw:b2DebugDraw;
      
      public function PhysEngine()
      {
         super();
         if(!bAllowConstruction)
         {
            throw new Error(ErrorMessages.sSINGLETON_STAGE);
         }
         this.init();
      }
      
      public static function get instance() : PhysEngine
      {
         if(oInstance == null)
         {
            bAllowConstruction = true;
            oInstance = new PhysEngine();
            bAllowConstruction = false;
         }
         return oInstance;
      }
      
      public function destroy() : void
      {
         for(var _oBody:b2Body = this.world.GetBodyList(); Boolean(_oBody); _oBody = _oBody.GetNext())
         {
            this.aBodyToDestroy.push(_oBody);
         }
         if(Boolean(this.oEventManager))
         {
            this.oEventManager.destroy();
         }
         this.oEventManager = null;
         this.oWorld = null;
         if(Boolean(this.oContactManager))
         {
            this.oContactManager.destroy();
         }
         this.oContactManager = null;
         oInstance = null;
         this.aBodyToDestroy = null;
         this.aBodyActivationList = null;
      }
      
      public function init() : void
      {
         this.aBodyToDestroy = new Vector.<b2Body>();
         this.aBodyActivationList = new HashMap();
         oGRAVITY = new b2Vec2(0,ExternalConfig.instance.getPropertyAsNumber("nWORLD_GRAVITY"));
         this.oWorld = new b2World(oGRAVITY,bIS_SLEEP_ALLOWED);
         this.oContactManager = new ContactManager();
         this.oWorld.SetContactListener(this.oContactManager);
      }
      
      public function initDebugDraw(_oSprite:Sprite) : void
      {
         while(_oSprite.numChildren > 0)
         {
            _oSprite.removeChildAt(0);
         }
         this.dbgDraw = new b2DebugDraw();
         this.dbgDraw.SetSprite(_oSprite);
         this.dbgDraw.SetDrawScale(CommonConfig.nCELL_SIZE);
         this.dbgDraw.SetFillAlpha(0.5);
         this.dbgDraw.SetAlpha(1);
         this.dbgDraw.SetLineThickness(1);
         this.dbgDraw.SetFlags(b2DebugDraw.e_shapeBit + b2DebugDraw.e_jointBit + b2DebugDraw.e_centerOfMassBit);
         this.oWorld.SetDebugDraw(this.dbgDraw);
      }
      
      public function setDebugLayerPos(_oPos:Point) : void
      {
         this.dbgDraw.GetSprite().x = -_oPos.x;
         this.dbgDraw.GetSprite().y = -_oPos.y;
         this.oWorld.DrawDebugData();
      }
      
      public function addBody(_oBodyDef:b2BodyDef) : b2Body
      {
         return this.world.CreateBody(_oBodyDef);
      }
      
      public function removeBody(_oBody:b2Body) : void
      {
         this.aBodyToDestroy.push(_oBody);
      }
      
      public function setBodyActivation(_oBody:b2Body, _bActive:Boolean) : void
      {
         if(this.aBodyActivationList.containsKey(_oBody))
         {
            this.aBodyActivationList.remove(_oBody);
         }
         this.aBodyActivationList.insert(_oBody,_bActive);
      }
      
      public function update() : void
      {
         this.oWorld.Step(nTIME_STEP,iITERATIONS_COUNT,iITERATIONS_COUNT);
         this.oWorld.ClearForces();
         this.cleanWorld();
         this.manageBodyActivation();
      }
      
      private function cleanWorld() : void
      {
         var _oBody:b2Body = null;
         while(this.aBodyToDestroy.length > 0)
         {
            _oBody = this.aBodyToDestroy.shift();
            if(Boolean(_oBody.GetUserData()))
            {
               _oBody.SetUserData(null);
            }
            this.world.DestroyBody(_oBody);
         }
      }
      
      private function manageBodyActivation() : void
      {
         var _oBody:b2Body = null;
         var _aBodies:Array = this.aBodyActivationList.getKeySet();
         while(_aBodies.length > 0)
         {
            _oBody = _aBodies.shift();
            _oBody.SetActive(this.aBodyActivationList.find(_oBody));
            this.aBodyActivationList.remove(_oBody);
         }
      }
      
      public function get world() : b2World
      {
         return this.oWorld;
      }
      
      public function get bodyToDestroy() : Vector.<b2Body>
      {
         return this.aBodyToDestroy;
      }
      
      public function get gravity() : b2Vec2
      {
         return oGRAVITY;
      }
   }
}

