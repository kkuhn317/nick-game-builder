package com.sarbakan.sbdk.math
{
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class SBKMath
   {
      
      private static var aSin:Array = new Array();
      
      private static var aCos:Array = new Array();
      
      private static var nSinQuickPrecision:Number = 0;
      
      private static var nCosQuickPrecision:Number = 0;
      
      public function SBKMath()
      {
         super();
      }
      
      public static function roundDecPl(_nNumber:Number, _nDecPl:uint = 0) : Number
      {
         var _nMultiplier:Number = Math.pow(10,_nDecPl);
         return Math.round(_nNumber * _nMultiplier) / _nMultiplier;
      }
      
      public static function radToDeg(_nRad:Number) : Number
      {
         return _nRad * 180 / Math.PI;
      }
      
      public static function degToRad(_nDeg:Number) : Number
      {
         return Math.PI * _nDeg / 180;
      }
      
      public static function getDimensionAfterRotation(_nRotation:Number, _nWidth:Number, _nHeight:Number) : Rectangle
      {
         var nw:Number = NaN;
         var nh:Number = NaN;
         var oDimension:Rectangle = new Rectangle();
         if(_nRotation >= Math.PI)
         {
            _nRotation -= Math.PI;
         }
         if(_nRotation <= Math.PI / 2)
         {
            nh = _nWidth * Math.sin(_nRotation) + _nHeight * Math.cos(_nRotation);
            nw = _nWidth * Math.cos(_nRotation) + _nHeight * Math.sin(_nRotation);
         }
         else
         {
            nh = _nWidth * Math.sin(_nRotation) - _nHeight * Math.cos(_nRotation);
            nw = -_nWidth * Math.cos(_nRotation) + _nHeight * Math.sin(_nRotation);
         }
         oDimension.left = 0;
         oDimension.top = 0;
         oDimension.right = nw;
         oDimension.height = nh;
         return oDimension;
      }
      
      public static function headsOrTails() : Boolean
      {
         return Math.random() < 0.5;
      }
      
      public static function getPolarity(_nNum:int) : int
      {
         var _nPolarity:Number = 0;
         if(_nNum < 0)
         {
            _nPolarity = -1;
         }
         else if(_nNum > 0)
         {
            _nPolarity = 1;
         }
         return _nPolarity;
      }
      
      public static function getReachNum(_nNum:Number, _nTargetNum:Number, _nReducer:Number) : Number
      {
         var _tmpNum:Number = _nNum;
         if(_tmpNum != _nTargetNum)
         {
            if(_tmpNum < _nTargetNum)
            {
               _tmpNum += _nReducer;
               if(_tmpNum > _nTargetNum)
               {
                  _tmpNum = _nTargetNum;
               }
            }
            else
            {
               _tmpNum -= _nReducer;
               if(_tmpNum < _nTargetNum)
               {
                  _tmpNum = _nTargetNum;
               }
            }
         }
         return _tmpNum;
      }
      
      public static function getDistance(_nX1:Number, _nY1:Number, _nX2:Number, _nY2:Number) : Number
      {
         return Math.sqrt(Math.pow(_nX2 - _nX1,2) + Math.pow(_nY2 - _nY1,2));
      }
      
      public static function getDistanceSq(_nX1:Number, _nY1:Number, _nX2:Number, _nY2:Number) : Number
      {
         return Math.pow(_nX2 - _nX1,2) + Math.pow(_nY2 - _nY1,2);
      }
      
      public static function getHypotenuse(_nDX:Number, _nDY:Number) : Number
      {
         return Math.sqrt(Math.pow(_nDX,2) + Math.pow(_nDY,2));
      }
      
      public static function getAngle(_nX1:Number, _nY1:Number, _nX2:Number, _nY2:Number) : Number
      {
         var _nXdiff:Number = NaN;
         var _nYdiff:Number = NaN;
         var _nRadius:Number = NaN;
         var _nAngle:Number = NaN;
         _nXdiff = _nX2 - _nX1;
         _nYdiff = _nY2 - _nY1;
         _nRadius = Math.atan2(_nYdiff,_nXdiff);
         return getDegreeFromRadius(_nRadius);
      }
      
      public static function getAngleRadian(_nX1:Number, _nY1:Number, _nX2:Number, _nY2:Number) : Number
      {
         var _nXdiff:Number = NaN;
         var _nYdiff:Number = NaN;
         var _nRadius:Number = NaN;
         _nXdiff = _nX2 - _nX1;
         _nYdiff = _nY2 - _nY1;
         return Math.atan2(_nYdiff,_nXdiff);
      }
      
      public static function getTurnAngle(_nOrigin:Number, _nTarget:Number) : Number
      {
         var _nTurn:Number = _nTarget - _nOrigin;
         if(Math.abs(_nTurn) > 180)
         {
            if(_nTarget > _nOrigin)
            {
               _nTurn -= 360;
            }
            else
            {
               _nTurn = 360 - Math.abs(_nTurn);
            }
         }
         return _nTurn;
      }
      
      public static function adjustAngle(_nAngle:Number) : Number
      {
         while(_nAngle >= 360)
         {
            _nAngle -= 360;
         }
         while(_nAngle < 0)
         {
            _nAngle += 360;
         }
         return _nAngle;
      }
      
      public static function getDegreeFromRadius(_nRadius:Number) : Number
      {
         return _nRadius / Math.PI * 180;
      }
      
      public static function getRadianFromDegree(_nDegree:Number) : Number
      {
         return _nDegree * (Math.PI / 180);
      }
      
      public static function getBoundsCenter(_oBox:Rectangle) : Point
      {
         var _oCenter:Point = new Point();
         _oCenter.x = _oBox.x + _oBox.width / 2;
         _oCenter.y = _oBox.y + _oBox.height / 2;
         return _oCenter;
      }
      
      public static function initSinQuick(_nPrecision:Number) : void
      {
         aSin.splice(0);
         nSinQuickPrecision = _nPrecision;
         for(var i:Number = 0; i <= _nPrecision; i++)
         {
            aSin.push(Math.sin(i * (2 * Math.PI) / _nPrecision));
         }
      }
      
      public static function sinQuick(_nAngle:Number) : Number
      {
         if(nSinQuickPrecision == 0)
         {
            return Math.sin(_nAngle);
         }
         var _nA:Number = _nAngle;
         while(_nA < 0)
         {
            _nA += Math.PI * 2;
         }
         while(_nA > Math.PI * 2)
         {
            _nA -= Math.PI * 2;
         }
         return aSin[Math.floor(_nA * nSinQuickPrecision / (2 * Math.PI))];
      }
      
      public static function cosQuick(_nAngle:Number) : Number
      {
         if(nCosQuickPrecision == 0)
         {
            return Math.cos(_nAngle);
         }
         var _nA:Number = _nAngle;
         while(_nA < 0)
         {
            _nA += Math.PI * 2;
         }
         while(_nA > Math.PI * 2)
         {
            _nA -= Math.PI * 2;
         }
         return aCos[Math.floor(_nA * nCosQuickPrecision / (2 * Math.PI))];
      }
      
      public static function initCosQuick(_nPrecision:Number) : void
      {
         aCos.splice(0);
         nCosQuickPrecision = _nPrecision;
         for(var i:Number = 0; i <= _nPrecision; i++)
         {
            aCos.push(Math.cos(i * (2 * Math.PI) / _nPrecision));
         }
      }
   }
}

