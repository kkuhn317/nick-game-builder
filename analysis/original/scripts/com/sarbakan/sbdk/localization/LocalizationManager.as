package com.sarbakan.sbdk.localization
{
   import com.arabicode.text.Flaraby.*;
   import com.sarbakan.sbdk.asset.AssetLocation;
   import com.sarbakan.sbdk.asset.AssetManager;
   import com.sarbakan.sbdk.asset.AssetReference;
   import com.sarbakan.sbdk.errors.ErrorMessages;
   import com.sarbakan.sbdk.events.LocalizationEvent;
   import com.sarbakan.sbdk.events.PreloadEvent;
   import com.sarbakan.sbdk.math.random.Random;
   import com.sarbakan.sbdk.preload.FileLoader;
   import com.sarbakan.sbdk.preload.PreloadManager;
   import com.sarbakan.sbdk.tools.logger.Logger;
   import com.sarbakan.sbdk.utils.EventManager;
   import com.sarbakan.sbdk.utils.ExternalFontManager;
   import com.sarbakan.sbdk.utils.StringUtils;
   import flash.events.EventDispatcher;
   import flash.text.AntiAliasType;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import flash.utils.getTimer;
   
   [Event(name="STRINGS_READY",type="com.sarbakan.sbdk.events.LocalizationEvent")]
   [Event(name="EXTERNAL_FONTS_LOADED",type="com.sarbakan.sbdk.events.LocalizationEvent")]
   [Event(name="STRING_FILE_LOADED",type="com.sarbakan.sbdk.events.LocalizationEvent")]
   [Event(name="LOCALE_CHANGED",type="com.sarbakan.sbdk.events.LocalizationEvent")]
   public class LocalizationManager extends EventDispatcher
   {
      
      private static var oInstance:LocalizationManager;
      
      private static const sEVENT_MANAGER_ID:String = "localizationManager";
      
      private static const sEVENT_MANAGER_ID_FONT:String = "localizationManager_font";
      
      private static var bAllowConstruction:Boolean = false;
      
      private const sFONT_EVENT_ID:String = "FONT_EVENT_ID";
      
      private const sDEFAULT_STRING_FILE:String = "translation.xml";
      
      private const sDEFAULT_STRING_DIRECTORY:String = "xml";
      
      private const sDEFAULT_FILE_DIRECTORY:String = "media";
      
      private const sDEFAULT_FONT_DIRECTORY:String = "font";
      
      private const sDEFAULT_FONT_XML:String = "fonts.xml";
      
      private const sDEFAULT_FONT_SWF:String = "embeddedFonts.swf";
      
      private const sARABIC_STANDARD:String = "arabic_standard";
      
      private const sARABIC_PERSIAN:String = "arabic_persian";
      
      private const sARABIC_URDU:String = "arabic_urdu";
      
      private const sAMERICAN_LATIN:String = "american_latin";
      
      private var oPreloadManager:PreloadManager;
      
      private var oEventManager:EventManager;
      
      private var aStringFiles:Array;
      
      private var oStrings:Object;
      
      private var oFontXML:XML;
      
      private var bFontsLoaded:Boolean;
      
      private var bStringsLoaded:Boolean;
      
      private var oAssetManager:AssetManager;
      
      private var aAssetList:Array;
      
      private var _oLocalTextField:LocalizedTextField;
      
      private var oFontManager:Object;
      
      private var sCallbackID:String;
      
      private var sAntiAliasType:String;
      
      private var sTargetLanguage:String;
      
      private var oRTLTextConverter:FlarabyAS3Flex;
      
      private var sStringFileName:String;
      
      private var sStringDirectory:String;
      
      private var sFileDirectory:String;
      
      private var sFontDirectory:String;
      
      private var sFontXMLFile:String;
      
      private var sFontSWF:String;
      
      public function LocalizationManager()
      {
         super();
         if(!bAllowConstruction)
         {
            throw new Error(ErrorMessages.sSINGLETON_STAGE);
         }
         this.init();
      }
      
      public static function get instance() : LocalizationManager
      {
         if(oInstance == null)
         {
            bAllowConstruction = true;
            oInstance = new LocalizationManager();
            bAllowConstruction = false;
         }
         return oInstance;
      }
      
      public function destroy() : void
      {
         this.oPreloadManager = null;
         this.oEventManager.clearAll();
         this.oEventManager.destroy();
         this.oEventManager = null;
         this.clearCachedAssets();
         this.oAssetManager = null;
         oInstance = null;
         this.oStrings = null;
         this.oFontManager.unlinkLocalizationManager(this.sCallbackID);
         this.oFontManager = null;
      }
      
      public function loadLocalizedString() : void
      {
         this.loadFonts();
         this.bStringsLoaded = false;
         var _oLoader:FileLoader = new FileLoader(this.sStringDirectory + "/" + this.sStringFileName);
         this.oPreloadManager.addLoader("localizationManager_file_" + this.sStringFileName,_oLoader);
         this.oEventManager.addEventListener(this.sStringFileName,_oLoader,PreloadEvent.COMPLETE,this.onStringFileLoaded,false,0,true,this.sStringFileName);
         this.oEventManager.addEventListener(this.sStringFileName,_oLoader,PreloadEvent.ERROR,this.onLoadFileError,false,0,true,"Unable to load string file " + this.sStringFileName + ": ",this.sStringFileName);
         this.oPreloadManager.start();
      }
      
      public function getString(_sStringID:String, _oReplacements:Object = null) : LocalizedString
      {
         var _oString:LocalizedString = null;
         _oString = this.stringDatabase[_sStringID] as LocalizedString;
         if(_oReplacements != null)
         {
            _oString = _oString.getReplacedString(_oReplacements);
         }
         return _oString;
      }
      
      public function isStringAvailaible(_sStringID:String) : Boolean
      {
         return this.bStringsLoaded && this.stringDatabase[_sStringID] != null;
      }
      
      public function setTextField(_txtField:TextField, _sStringID:String, _oReplacements:Object = null) : void
      {
         var _oString:LocalizedString = this.getString(_sStringID,_oReplacements);
         _txtField.multiline = true;
         var _oTextFormat:TextFormat = new TextFormat();
         _oTextFormat.font = _oString.fontName;
         _oTextFormat.size = _oString.fontSize;
         if(_oString.lineSpace > 0)
         {
            _oTextFormat.leading = _oString.lineSpace;
         }
         if(_oString.charSpace > 0)
         {
            _oTextFormat.letterSpacing = _oString.charSpace;
         }
         if(this.oRTLTextConverter != null)
         {
            _oTextFormat.align = TextFormatAlign.RIGHT;
            _txtField.text = this.convertCariageReturn(this.oRTLTextConverter.convertArabicString(_oString.string,_txtField.width,_oTextFormat));
         }
         else
         {
            _txtField.htmlText = _oString.string;
         }
         if(Boolean(this.oFontManager.isFontRegistered(_oTextFormat.font)))
         {
            _txtField.embedFonts = true;
            _txtField.antiAliasType = this.sAntiAliasType;
            this.oFontManager.setTextFormat(_txtField,_oTextFormat);
         }
         else
         {
            Logger.instance.logWarning("Font \'" + _oTextFormat.font + "\', is unavailaible.");
         }
      }
      
      public function setAntiAliasType(_sAntiAliasType:String) : void
      {
         if(_sAntiAliasType == AntiAliasType.NORMAL || _sAntiAliasType == AntiAliasType.ADVANCED)
         {
            this.sAntiAliasType = _sAntiAliasType;
         }
         else
         {
            Logger.instance.logWarning("AntiAliasType \'" + _sAntiAliasType + "\' is not valid.");
         }
      }
      
      public function requestFileAsset(_sFileName:String, _bByteMode:Boolean, _bCache:Boolean, _fCompleteCallBack:Function, _fErrorCallBack:Function = null) : void
      {
         var _sAssetID:String = this.getAssetID(_sFileName);
         if(this.oAssetManager.assetExists(_sAssetID) == false)
         {
            _sFileName = this.sFileDirectory + "/" + _sFileName;
            this.oAssetManager.addFileAsset(_sAssetID,_sFileName,_bCache,false,_bByteMode);
            this.aAssetList.push(_sAssetID);
         }
         this.oAssetManager.requestAsset(AssetReference.fromAssetManager(_sAssetID),_fCompleteCallBack,_fErrorCallBack);
      }
      
      public function requestDisplayAsset(_sFileName:String, _bCache:Boolean, _fCompleteCallBack:Function, _fErrorCallBack:Function = null) : void
      {
         var _sAssetID:String = this.getAssetID(_sFileName);
         if(this.oAssetManager.assetExists(_sAssetID) == false)
         {
            _sFileName = this.sFileDirectory + "/" + _sFileName;
            this.oAssetManager.addDisplayAsset(_sAssetID,_sFileName,AssetLocation.EXTERNAL,_bCache,false);
            this.aAssetList.push(_sAssetID);
         }
         this.oAssetManager.requestAsset(AssetReference.fromAssetManager(_sAssetID),_fCompleteCallBack,_fErrorCallBack);
      }
      
      public function requestSoundAsset(_sFileName:String, _bCache:Boolean, _fCompleteCallBack:Function, _fErrorCallBack:Function = null, _nBufferTime:int = -1) : void
      {
         var _sAssetID:String = this.getAssetID(_sFileName);
         if(this.oAssetManager.assetExists(_sAssetID) == false)
         {
            _sFileName = this.sFileDirectory + "/" + _sFileName;
            this.oAssetManager.addSoundAsset(_sAssetID,_sFileName,AssetLocation.EXTERNAL,_bCache,_nBufferTime,false);
            this.aAssetList.push(_sAssetID);
         }
         this.oAssetManager.requestAsset(AssetReference.fromAssetManager(_sAssetID),_fCompleteCallBack,_fErrorCallBack);
      }
      
      public function clearCachedAssets() : void
      {
         var _sAssetID:String = null;
         if(this.aAssetList != null)
         {
            for each(_sAssetID in this.aAssetList)
            {
               AssetManager.instance.removeAsset(_sAssetID);
            }
         }
         this.aAssetList = new Array();
      }
      
      private function init() : void
      {
         var _oLocalizedExternalDisplayObject:LocalizedExternalDisplayObject = null;
         var _oLocalizedTextField:LocalizedTextField = null;
         this.oEventManager = new EventManager();
         this.externalFontManager = ExternalFontManager.instance;
         this.oPreloadManager = PreloadManager.instance;
         this.oAssetManager = AssetManager.instance;
         this.oStrings = new Object();
         this.aStringFiles = new Array();
         this.sTargetLanguage = this.sAMERICAN_LATIN;
         this.clearCachedAssets();
         this.sAntiAliasType = AntiAliasType.ADVANCED;
         this.sStringFileName = this.sDEFAULT_STRING_FILE;
         this.sStringDirectory = this.sDEFAULT_STRING_DIRECTORY;
         this.sFileDirectory = this.sDEFAULT_FILE_DIRECTORY;
         this.sFontDirectory = this.sDEFAULT_FONT_DIRECTORY;
         this.sFontXMLFile = this.sDEFAULT_FONT_XML;
         this.sFontSWF = this.sDEFAULT_FONT_SWF;
      }
      
      public function getAbsoluteUrl(_sURLInput:String) : String
      {
         var strResult:String = "";
         if(_sURLInput.indexOf("http://") > -1)
         {
            if(_sURLInput.indexOf(".swf") > -1)
            {
               strResult = _sURLInput.substring(0,_sURLInput.lastIndexOf("/") + 1);
            }
         }
         return strResult;
      }
      
      private function loadFonts() : void
      {
         this.bFontsLoaded = false;
         var _oLoaderXML:FileLoader = new FileLoader(this.sFontDirectory + "/" + this.sFontXMLFile);
         this.oPreloadManager.addLoader("localizationManager_fontsXML",_oLoaderXML);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID_FONT,_oLoaderXML,PreloadEvent.COMPLETE,this.onFontsXMLLoaded);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID_FONT,_oLoaderXML,PreloadEvent.ERROR,this.onLoadFileError,false,0,true,"Unable to load font XML:",sEVENT_MANAGER_ID_FONT);
         this.oPreloadManager.start();
      }
      
      private function parseAndRegisterFonts() : void
      {
         var _oFont:XML = null;
         var _aFontList:Array = new Array();
         var _oFontLibrary:XMLList = this.oFontXML..fontClass;
         this.sCallbackID = String(getTimer() * Random.getFloat());
         for each(_oFont in _oFontLibrary)
         {
            _aFontList.push(String(_oFont.@name));
         }
         this.oFontManager.loadAndRegisterFont(this.sFontDirectory + "/" + this.sFontSWF,_aFontList,this.sCallbackID,this.onFontRegistered,this.onFontError);
      }
      
      private function dispatchFontEvents() : void
      {
         this.oEventManager.cleanUp(sEVENT_MANAGER_ID_FONT);
         dispatchEvent(new LocalizationEvent(LocalizationEvent.EXTERNAL_FONTS_LOADED));
         if(this.bStringsLoaded)
         {
            dispatchEvent(new LocalizationEvent(LocalizationEvent.STRINGS_READY));
         }
      }
      
      private function parseStringXML(_oStringXML:XML) : void
      {
         var _oString:XML = null;
         var _oStrings:XMLList = _oStringXML..string;
         this.setDefaultLanguage(_oStringXML.language);
         for each(_oString in _oStrings)
         {
            this.oStrings[_oString.@id] = new LocalizedString(unescape(_oString),unescape(_oString.@fontName),uint(Number(_oString.@fontSize)),uint(Number(_oString.@charSpace)),uint(Number(_oString.@lineSpace)));
         }
      }
      
      private function convertCariageReturn(_sString:String) : String
      {
         if(_sString.indexOf("<br>") != -1)
         {
            return StringUtils.replace(_sString,"<br>","\n");
         }
         if(_sString.indexOf("<BR>") != -1)
         {
            return StringUtils.replace(_sString,"<BR>","\n");
         }
         if(_sString.indexOf("</BR>") != -1)
         {
            return StringUtils.replace(_sString,"</BR>","\n");
         }
         return _sString;
      }
      
      private function setDefaultLanguage(_sLanguage:String) : void
      {
         this.sTargetLanguage = _sLanguage.toLocaleLowerCase();
         if(this.sTargetLanguage.indexOf("arabic",0) != -1)
         {
            this.oRTLTextConverter = new FlarabyAS3Flex();
            if(this.sTargetLanguage == this.sARABIC_PERSIAN)
            {
               this.oRTLTextConverter.addPersianSupport();
            }
            else if(this.sTargetLanguage == this.sARABIC_URDU)
            {
               this.oRTLTextConverter.addUrduSupport();
            }
         }
      }
      
      private function get stringDatabase() : Object
      {
         return this.oStrings;
      }
      
      private function getAssetID(_sFileName:String) : String
      {
         return "localization_" + _sFileName;
      }
      
      private function onFontsXMLLoaded(_oEvent:PreloadEvent) : void
      {
         this.oFontXML = new XML(_oEvent.content);
         this.parseAndRegisterFonts();
      }
      
      private function onFontRegistered() : void
      {
         this.bFontsLoaded = true;
         this.dispatchFontEvents();
      }
      
      private function onStringFileLoaded(_oEvent:PreloadEvent, _sFileName:String) : void
      {
         this.parseStringXML(new XML(_oEvent.content));
         this.oEventManager.cleanUp(_sFileName);
         this.bStringsLoaded = true;
         dispatchEvent(new LocalizationEvent(LocalizationEvent.STRING_FILE_LOADED,_sFileName));
         if(this.bFontsLoaded && this.bStringsLoaded)
         {
            dispatchEvent(new LocalizationEvent(LocalizationEvent.STRINGS_READY));
         }
      }
      
      private function onLoadFileError(_oEvent:PreloadEvent, _sErrorMessage:String, _sEventManagerID:String) : void
      {
         Logger.instance.logError(_sErrorMessage + "(" + _oEvent.error + ")","onLoadFileError","LocalizationManager");
         this.oEventManager.cleanUp(_sEventManagerID);
         dispatchEvent(_oEvent);
      }
      
      private function onFontError(_sError:String) : void
      {
         this.bFontsLoaded = true;
         this.dispatchFontEvents();
         Logger.instance.logError(_sError,"onFontError","LocalizationManager");
      }
      
      public function get externalFontManager() : Object
      {
         return this.oFontManager;
      }
      
      public function set externalFontManager(_oInstance:*) : void
      {
         this.oFontManager = _oInstance;
      }
      
      public function get defaultStringFileName() : String
      {
         return this.sStringFileName;
      }
      
      public function set defaultStringFileName(_sValue:String) : void
      {
         this.sStringFileName = _sValue;
      }
      
      public function get defaultStringDirectory() : String
      {
         return this.sStringDirectory;
      }
      
      public function set defaultStringDirectory(_sValue:String) : void
      {
         this.sStringDirectory = _sValue;
      }
      
      public function get defaultMediaFileDirectory() : String
      {
         return this.sFileDirectory;
      }
      
      public function set defaultMediaFileDirectory(_sValue:String) : void
      {
         this.sFileDirectory = _sValue;
      }
      
      public function get defaultFontDirectory() : String
      {
         return this.sFontDirectory;
      }
      
      public function set defaultFontDirectory(_sValue:String) : void
      {
         this.sFontDirectory = _sValue;
      }
      
      public function get defaultFontXMLFile() : String
      {
         return this.sFontXMLFile;
      }
      
      public function set defaultFontXMLFile(_sValue:String) : void
      {
         this.sFontXMLFile = _sValue;
      }
      
      public function get defaultFontSWFFile() : String
      {
         return this.sFontSWF;
      }
      
      public function set defaultFontSWFFile(_sValue:String) : void
      {
         this.sFontSWF = _sValue;
      }
   }
}

