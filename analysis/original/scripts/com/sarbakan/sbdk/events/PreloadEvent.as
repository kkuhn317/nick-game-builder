package com.sarbakan.sbdk.events
{
   import flash.events.Event;
   
   public class PreloadEvent extends Event
   {
      
      public static const COMPLETE:String = "sbdk_complete";
      
      public static const GROUP_COMPLETE:String = "sbdk_group_complete";
      
      public static const START:String = "sbdk_start";
      
      public static const STOP:String = "sbdk_stop";
      
      public static const ERROR:String = "sbdk_error";
      
      public static const PROGRESS:String = "sbdk_progress";
      
      public static const ALL_COMPLETE:String = "sbdk_all_complete";
      
      private var oContent:*;
      
      private var sId:String;
      
      private var sFileName:String;
      
      private var sError:String;
      
      private var nBytesLoaded:int;
      
      private var nBytesTotal:int;
      
      private var nPercentage:int;
      
      private var nNbrFile:int;
      
      private var nTotalNbrFile:int;
      
      private var nTotalPercentage:int;
      
      private var bIsGroup:Boolean;
      
      public function PreloadEvent(_sType:String, _bBubbles:Boolean = false, _bCancelable:Boolean = false, _sId:String = "", _sFileName:String = "", _sError:String = "", _nBytesLoaded:int = 0, _nBytesTotal:int = 0, _nPercentage:int = 0, _nNbrFile:int = 0, _nTotalNbrFile:int = 0, _nTotalPercentage:int = 0, _oContent:* = null, _bIsGroup:Boolean = false)
      {
         super(_sType,_bBubbles,_bCancelable);
         this.sId = _sId;
         this.sFileName = _sFileName;
         this.sError = _sError;
         this.nBytesLoaded = _nBytesLoaded;
         this.nBytesTotal = _nBytesTotal;
         this.nPercentage = _nPercentage;
         this.nNbrFile = _nNbrFile;
         this.nTotalNbrFile = _nTotalNbrFile;
         this.nTotalPercentage = _nTotalPercentage;
         this.oContent = _oContent;
         this.bIsGroup = _bIsGroup;
      }
      
      override public function clone() : Event
      {
         return new PreloadEvent(type,bubbles,cancelable,this.ID,this.fileName,this.error,this.bytesLoaded,this.bytesTotal,this.percentage,this.nbrFile,this.totalNbrFile,this.totalPercentage,this.content,this.isGroup);
      }
      
      override public function toString() : String
      {
         return formatToString("PreloadEvent","type","bubbles","cancelable","ID","fileName","error","bytesLoaded","bytesTotal","bytesTotal","percentage","nbrFile","totalNbrFile","totalPercentage","content","isGroup");
      }
      
      public function get ID() : String
      {
         return this.sId;
      }
      
      public function get fileName() : String
      {
         return this.sFileName;
      }
      
      public function get error() : String
      {
         return this.sError;
      }
      
      public function get bytesLoaded() : int
      {
         return this.nBytesLoaded;
      }
      
      public function get bytesTotal() : int
      {
         return this.nBytesTotal;
      }
      
      public function get percentage() : int
      {
         return this.nPercentage;
      }
      
      public function get nbrFile() : int
      {
         return this.nNbrFile;
      }
      
      public function get totalNbrFile() : int
      {
         return this.nTotalNbrFile;
      }
      
      public function get totalPercentage() : int
      {
         return this.nTotalPercentage;
      }
      
      public function get content() : *
      {
         return this.oContent;
      }
      
      public function get isGroup() : Boolean
      {
         return this.bIsGroup;
      }
   }
}

