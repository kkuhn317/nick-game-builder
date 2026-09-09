package com.sarbakan.sbdk.events
{
   import flash.events.Event;
   
   public class BitmappedEvent extends Event
   {
      
      public static const PROGRESS:String = "sbdk_progress";
      
      public static const ALL_COMPLETE:String = "sbdk_all_complete";
      
      public static const ERROR:String = "sbdk_error";
      
      public static const ANIM_COMPLETE:String = "sbdk_anim_complete";
      
      public static const START:String = "sbdk_start";
      
      public static const STOP:String = "sbdk_stop";
      
      public static const PAUSE:String = "sbdk_pause";
      
      public static const RESUME:String = "sbdk_resume";
      
      public static const SHOW:String = "sbdk_show";
      
      public static const HIDE:String = "sbdk_hide";
      
      private var sVariantID:String;
      
      private var nTotalFrameToRender:uint;
      
      private var nFrameByteSize:uint;
      
      private var oClassRef:Class;
      
      private var nFrameNumber:uint;
      
      private var nTotalBytes:uint;
      
      private var sError:String;
      
      public function BitmappedEvent(_sType:String, _bBubbles:Boolean = false, _bCancelable:Boolean = false, _oClassRef:Class = null, _sVariantID:String = null, _nFrameNumber:uint = 0, _nTotalFrameToRender:uint = 0, _nFrameByteSize:uint = 0, _nTotalBytes:uint = 0, _sError:String = null)
      {
         super(_sType,_bBubbles,_bCancelable);
         this.oClassRef = _oClassRef;
         this.sVariantID = _sVariantID;
         this.nFrameNumber = _nFrameNumber;
         this.nTotalFrameToRender = _nTotalFrameToRender;
         this.nFrameByteSize = _nFrameByteSize;
         this.nTotalBytes = _nTotalBytes;
         this.sError = _sError;
      }
      
      override public function clone() : Event
      {
         return new BitmappedEvent(type,bubbles,cancelable,this.classRef,this.variantID,this.frameNumber,this.totalFrameToRender,this.frameByteSize,this.bytesTotal);
      }
      
      override public function toString() : String
      {
         return formatToString("AssetEvent","type","bubbles","cancelable","classRef","variantID","frameNumber","totalFrameToRender","frameByteSize","bytesTotal","");
      }
      
      public function get classRef() : Class
      {
         return this.oClassRef;
      }
      
      public function get variantID() : String
      {
         return this.sVariantID;
      }
      
      public function get frameNumber() : uint
      {
         return this.nFrameNumber;
      }
      
      public function get bytesTotal() : uint
      {
         return this.nTotalBytes;
      }
      
      public function get totalFrameToRender() : uint
      {
         return this.nTotalFrameToRender;
      }
      
      public function get frameByteSize() : uint
      {
         return this.nFrameByteSize;
      }
      
      public function get totalBytes() : uint
      {
         return this.nTotalBytes;
      }
      
      public function get totalPercentage() : uint
      {
         return Math.floor(this.nFrameNumber / this.nTotalFrameToRender * 100);
      }
      
      public function get error() : String
      {
         return this.sError;
      }
   }
}

