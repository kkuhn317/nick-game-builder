package com.sarbakan.sbdk.utils
{
   import flash.display.DisplayObjectContainer;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   
   public class GraphicDebugTextManager
   {
      
      private static var oInstance:GraphicDebugTextManager;
      
      public static const sDEFAULT_TEXT_FONT:String = "Verdana";
      
      public static const nDEFAULT_TEXT_COLOR:Number = 16777215;
      
      public static const nDEFAULT_TEXT_COLOR_SHADOW:Number = 0;
      
      public static const nDEFAULT_TEXT_SIZE:uint = 10;
      
      public static const sDEFAULT_TEXT_ALIGN:String = TextFormatAlign.RIGHT;
      
      private static var bAllowConstruction:Boolean = false;
      
      private var oDisplayContainer:DisplayObjectContainer;
      
      private var aTextConfigList:Array;
      
      private var nNext_Y_Pos:uint;
      
      private var oTextFormat:TextFormat;
      
      private var sTextFont:String = "Verdana";
      
      private var nTextColor:Number = 16777215;
      
      private var nTextColorShadow:Number = 0;
      
      private var nTextSize:uint = 10;
      
      private var sTextAlign:String = "right";
      
      public function GraphicDebugTextManager()
      {
         super();
         this.init();
      }
      
      public static function get instance() : GraphicDebugTextManager
      {
         if(oInstance == null)
         {
            bAllowConstruction = true;
            oInstance = new GraphicDebugTextManager();
            bAllowConstruction = false;
         }
         return oInstance;
      }
      
      public function destroy() : void
      {
         for(var i:int = 0; i < this.aTextConfigList.length; i++)
         {
            this.removeTextField(this.aTextConfigList[i].sID);
         }
         this.aTextConfigList.splice(0,this.aTextConfigList.length);
         this.aTextConfigList = null;
         this.oDisplayContainer = null;
         oInstance = null;
      }
      
      public function setDisplayContainer(_oDisplayContainer:DisplayObjectContainer) : void
      {
         if(this.oDisplayContainer == null)
         {
            this.oDisplayContainer = _oDisplayContainer;
         }
      }
      
      public function createTextField(_sID:String, _uLineCount:uint = 1) : void
      {
         var _oTextField:TextField = null;
         var _oShadowTextField:TextField = null;
         var i:uint = 0;
         var _oTextConfig:TextConfigStruct = this.findTextConfig(_sID);
         if(_oTextConfig == null)
         {
            if(this.oDisplayContainer != null)
            {
               _oTextField = new TextField();
               _oShadowTextField = new TextField();
               _oTextConfig = new TextConfigStruct();
               _oTextField.mouseEnabled = false;
               _oTextField.selectable = false;
               _oTextField.autoSize = TextFieldAutoSize.LEFT;
               _oTextField.x = 0;
               _oTextField.y = this.nNext_Y_Pos;
               _oTextField.text = "LINE";
               for(i = 1; i <= _uLineCount - 1; i++)
               {
                  _oTextField.appendText("NEW_LINE\n");
               }
               _oShadowTextField.mouseEnabled = false;
               _oShadowTextField.selectable = false;
               _oShadowTextField.autoSize = TextFieldAutoSize.LEFT;
               _oShadowTextField.x = _oTextField.x + 1;
               _oShadowTextField.y = _oTextField.y + 1;
               _oTextConfig.sID = _sID;
               _oTextConfig.oText = _oTextField;
               _oTextConfig.oShadowText = _oShadowTextField;
               this.nNext_Y_Pos += _oTextField.height;
               this.aTextConfigList.push(_oTextConfig);
               _oTextField.visible = false;
               _oShadowTextField.visible = false;
               this.setTextFormats(_oTextField,_oShadowTextField);
               this.oDisplayContainer.addChild(_oTextConfig.oShadowText);
               this.oDisplayContainer.addChild(_oTextConfig.oText);
            }
         }
      }
      
      public function removeTextField(_sID:String) : void
      {
         var _oTextConfig:TextConfigStruct = this.findTextConfig(_sID);
         if(_oTextConfig != null)
         {
            if(this.oDisplayContainer.contains(_oTextConfig.oShadowText))
            {
               this.oDisplayContainer.removeChild(_oTextConfig.oShadowText);
            }
            if(this.oDisplayContainer.contains(_oTextConfig.oText))
            {
               this.oDisplayContainer.removeChild(_oTextConfig.oText);
            }
         }
         this.removeTextConfig(_sID);
         this.rearangeTextPosition();
      }
      
      public function displayText(_sID:String, _sText:String) : void
      {
         var _oTextConfig:TextConfigStruct = this.findTextConfig(_sID);
         if(_oTextConfig != null)
         {
            if(_oTextConfig.oText.visible == false)
            {
               _oTextConfig.oText.visible = true;
               _oTextConfig.oShadowText.visible = true;
            }
            _oTextConfig.oText.text = _sText;
            _oTextConfig.oShadowText.text = _sText;
         }
      }
      
      private function init() : void
      {
         this.aTextConfigList = new Array();
         this.nNext_Y_Pos = 0;
      }
      
      private function setTextFormats(_oTfNormal:TextField, _oTfShadow:TextField) : void
      {
         var _oTextFormat:TextFormat = null;
         _oTextFormat = new TextFormat();
         _oTextFormat.font = this.sTextFont;
         _oTextFormat.color = this.nTextColor;
         _oTextFormat.size = this.nTextSize;
         _oTextFormat.align = this.sTextAlign;
         _oTfNormal.defaultTextFormat = _oTextFormat;
         var _oTextFormatShadow:TextFormat = new TextFormat();
         _oTextFormatShadow.font = this.sTextFont;
         _oTextFormatShadow.color = this.nTextColorShadow;
         _oTextFormatShadow.size = this.nTextSize;
         _oTextFormatShadow.align = this.sTextAlign;
         _oTfShadow.defaultTextFormat = _oTextFormatShadow;
      }
      
      private function rearangeTextPosition() : void
      {
         this.nNext_Y_Pos = 0;
         for(var i:int = 0; i < this.aTextConfigList.length; i++)
         {
            this.aTextConfigList[i].oText.y = this.nNext_Y_Pos;
            this.aTextConfigList[i].oShadowText.y = this.aTextConfigList[i].oText.y + 1;
            this.nNext_Y_Pos += this.aTextConfigList[i].oText.height;
         }
      }
      
      private function findTextConfig(_sID:String) : TextConfigStruct
      {
         for(var i:int = 0; i < this.aTextConfigList.length; i++)
         {
            if(this.aTextConfigList[i].sID == _sID)
            {
               return this.aTextConfigList[i];
            }
         }
         return null;
      }
      
      private function removeTextConfig(_sID:String) : void
      {
         for(var i:int = 0; i < this.aTextConfigList.length; i++)
         {
            if(this.aTextConfigList[i].sID == _sID)
            {
               this.aTextConfigList.splice(i,1);
               return;
            }
         }
      }
      
      private function updateFormats() : void
      {
         var _oText:TextConfigStruct = null;
         for each(_oText in this.aTextConfigList)
         {
            this.setTextFormats(_oText.oText,_oText.oShadowText);
         }
      }
      
      public function get textFont() : String
      {
         return this.sTextFont;
      }
      
      public function set textFont(_sFont:String) : void
      {
         this.sTextFont = _sFont;
         this.updateFormats();
      }
      
      public function get textSize() : uint
      {
         return this.nTextSize;
      }
      
      public function set textSize(_nSize:uint) : void
      {
         this.nTextSize = _nSize;
         this.updateFormats();
      }
      
      public function get textColor() : Number
      {
         return this.nTextColor;
      }
      
      public function set textColor(_nColor:Number) : void
      {
         this.nTextColor = _nColor;
         this.updateFormats();
      }
      
      public function get textColorShadow() : Number
      {
         return this.nTextColorShadow;
      }
      
      public function set textColorShadow(_nColor:Number) : void
      {
         this.nTextColorShadow = _nColor;
         this.updateFormats();
      }
      
      public function get textAlign() : String
      {
         return this.sTextAlign;
      }
      
      public function set textAlign(_sAlign:String) : void
      {
         this.sTextAlign = _sAlign;
         this.updateFormats();
      }
   }
}

import flash.text.TextField;

class TextConfigStruct
{
   
   public var sID:String;
   
   public var oShadowText:TextField;
   
   public var oText:TextField;
   
   public function TextConfigStruct()
   {
      super();
   }
}
