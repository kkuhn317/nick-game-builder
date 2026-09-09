package com.sarbakan.sbdk.tools.logger
{
   public class TracePublisher extends AbstractPublisher
   {
      
      private var bShowSBDKLog:Boolean;
      
      public function TracePublisher()
      {
         super();
      }
      
      override protected function init() : void
      {
         this.bShowSBDKLog = true;
      }
      
      override protected function publish(_sScope:String, _sFunctionDef:String, _sMsg:String, _oLevel:LogLevel) : void
      {
         var _sLogString:String = null;
         var _bPublish:Boolean = true;
         if(oFilter != null)
         {
            _bPublish = oFilter.filter(_sScope,_sFunctionDef,_sMsg,_oLevel);
         }
         if(_oLevel == LogLevel.SBDK && !this.bShowSBDKLog)
         {
            _bPublish = false;
         }
         if(_bPublish)
         {
            _sLogString = _oLevel.toString() + "\t: ";
            if(_sScope != null)
            {
               _sLogString += _sScope + ".";
            }
            if(_sFunctionDef != null)
            {
               _sLogString += _sFunctionDef + "() ";
            }
            _sLogString += _sMsg;
            trace(_sLogString);
         }
      }
      
      public function get showSBDKLog() : Boolean
      {
         return this.bShowSBDKLog;
      }
      
      public function set showSBDKLog(_bShow:Boolean) : void
      {
         this.bShowSBDKLog = _bShow;
      }
   }
}

