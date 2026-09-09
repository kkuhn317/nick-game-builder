package data
{
   public class GameDataElement
   {
      
      private var sAlias:String;
      
      private var nX:int;
      
      private var nY:int;
      
      private var bFlip:Boolean;
      
      private var sLinkage:String;
      
      public function GameDataElement(_sAlias:String, _nX:int, _nY:int, _bFlip:Boolean = false, _sLinkage:String = null)
      {
         super();
         this.sAlias = _sAlias;
         this.nX = _nX;
         this.nY = _nY;
         this.bFlip = _bFlip;
         this.sLinkage = _sLinkage;
      }
      
      public static function fromXML(_oXML:XML) : GameDataElement
      {
         var _bFlip:Boolean = Boolean(Number(_oXML.@a) < 0);
         var _sLinkage:String = _oXML.@linkage;
         if(_sLinkage == "")
         {
            _sLinkage = null;
         }
         return new GameDataElement(_oXML.@alias,int(_oXML.@tx),int(_oXML.@ty),_bFlip,_sLinkage);
      }
      
      public function destroy() : void
      {
      }
      
      public function xmlOut() : XML
      {
         var _oXML:XML = <element alias={this.sAlias} tx={this.nX} ty={this.nY}/>;
         if(this.bFlip)
         {
            _oXML.@a = -1;
         }
         else
         {
            _oXML.@a = 1;
         }
         if(Boolean(this.sLinkage))
         {
            _oXML.@linkage = this.sLinkage;
         }
         return _oXML;
      }
      
      public function get alias() : String
      {
         return this.sAlias;
      }
      
      public function get x() : int
      {
         return this.nX;
      }
      
      public function set x(value:int) : void
      {
         this.nX = value;
      }
      
      public function get y() : int
      {
         return this.nY;
      }
      
      public function set y(value:int) : void
      {
         this.nY = value;
      }
      
      public function get flip() : Boolean
      {
         return this.bFlip;
      }
      
      public function set flip(value:Boolean) : void
      {
         this.bFlip = value;
      }
      
      public function get linkage() : String
      {
         return this.sLinkage;
      }
   }
}

