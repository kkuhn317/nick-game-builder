package com.sarbakan.sbdk.utils
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.FrameLabel;
   import flash.display.MovieClip;
   import flash.geom.Rectangle;
   
   public class DisplayObjectUtils
   {
      
      public function DisplayObjectUtils()
      {
         super();
      }
      
      public static function labelExists(_sLabelName:String, _mcTimeline:MovieClip) : Boolean
      {
         var _oLabel:FrameLabel = null;
         var _bFound:Boolean = false;
         for each(_oLabel in _mcTimeline.currentLabels)
         {
            if(_oLabel.name == _sLabelName)
            {
               _bFound = true;
               break;
            }
         }
         return _bFound;
      }
      
      public static function getMaxFrameDimension(_mcRef:MovieClip) : Rectangle
      {
         var _nLength:int = _mcRef.totalFrames;
         var _oRect:Rectangle = new Rectangle();
         var _oFrameRect:Rectangle = _mcRef.getBounds(_mcRef);
         _oRect.width = _oFrameRect.width;
         _oRect.height = _oFrameRect.height;
         for(var i:int = 1; i <= _nLength; i++)
         {
            _mcRef.gotoAndStop(i);
            _oFrameRect = _mcRef.getBounds(_mcRef);
            if(_oFrameRect.width > _oRect.width)
            {
               _oRect.width = _oFrameRect.width;
            }
            if(_oFrameRect.height > _oRect.height)
            {
               _oRect.height = _oFrameRect.height;
            }
         }
         _mcRef.gotoAndStop(1);
         return _oRect;
      }
      
      public static function getFramesDimension(_mcRef:MovieClip) : Array
      {
         var _nLength:int = _mcRef.totalFrames;
         var _aFrameCoordinates:Array = new Array();
         for(var i:int = 1; i <= _nLength; i++)
         {
            _mcRef.gotoAndStop(i);
            _aFrameCoordinates[i - 1] = _mcRef.getBounds(_mcRef);
         }
         _mcRef.gotoAndStop(1);
         return _aFrameCoordinates;
      }
      
      public static function fitIconInFrame(_mcIcon:DisplayObject, _mcContainer:DisplayObjectContainer, _nMaxScale:Number = 1) : void
      {
         var _nScale:Number = Math.min(_nMaxScale,_mcContainer.width / _mcIcon.width,_mcContainer.height / _mcIcon.height);
         _mcIcon.scaleX = _nScale;
         _mcIcon.scaleY = _nScale;
         var _oBounds:Rectangle = _mcIcon.getBounds(_mcIcon);
         _mcIcon.x = -(_oBounds.x * _nScale) - _mcIcon.width / 2;
         _mcIcon.y = -(_oBounds.y * _nScale) - _mcIcon.height / 2;
         _mcContainer.addChild(_mcIcon);
      }
   }
}

