package ui.selectionGrid
{
   import com.sarbakan.sbdk.core.UpdateManager;
   import com.sarbakan.sbdk.events.UIEvent;
   import com.sarbakan.sbdk.events.UpdateEvent;
   import com.sarbakan.sbdk.ui.Radio;
   import com.sarbakan.sbdk.ui.RadioGroup;
   import com.sarbakan.sbdk.utils.EventManager;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   
   public class SelectionGrid extends EventDispatcher
   {
      
      protected static const sEVENT_MANAGER_ID:String = "eventManager";
      
      public var mcContainer:MovieClip;
      
      protected var oEventManager:EventManager;
      
      protected var oRadioGroup:RadioGroup;
      
      protected var aCategories:Array;
      
      protected var nItemHeightRatio:Number;
      
      protected var nWidth:Number;
      
      protected var nHeight:Number;
      
      protected var nCols:uint;
      
      protected var nCellSize:Number;
      
      private var bEnabled:Boolean;
      
      private var bInvalidate:Boolean;
      
      private var nOverRatio:Number;
      
      public function SelectionGrid(_mcContainer:MovieClip, _nItemHeightRatio:Number = 1, _nOverRatio:Number = 1, _nHeightModifier:Number = 0)
      {
         super();
         this.oEventManager = new EventManager();
         this.mcContainer = _mcContainer;
         this.nWidth = this.mcContainer.width;
         this.nHeight = this.mcContainer.height - _nHeightModifier;
         this.oRadioGroup = new RadioGroup(false);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,this.oRadioGroup,UIEvent.CHANGE,this.onChange);
         this.aCategories = new Array();
         this.nItemHeightRatio = _nItemHeightRatio;
         this.nOverRatio = _nOverRatio;
      }
      
      public function destroy() : void
      {
         var _oCat:SelectionCategoryStruct = null;
         for each(_oCat in this.aCategories)
         {
            _oCat.destroy();
         }
         this.aCategories = null;
         if(Boolean(this.oRadioGroup))
         {
            this.oRadioGroup.destroy();
         }
         this.oRadioGroup = null;
         this.mcContainer = null;
      }
      
      public function addItem(_sCat:String, _oValue:*, _oImage:DisplayObject, _sTooltip:String = null) : void
      {
         this.invalidate();
         var _oRadio:SelectionGridRadio = new SelectionGridRadio(_oImage,_oValue);
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,_oRadio.mcContainer,MouseEvent.MOUSE_OVER,this.onRollOver,false,0,true,_oRadio);
         var _oCat:SelectionCategoryStruct = this.getCatByID(_sCat);
         _oCat.title.mc.visible = false;
         _oCat.addRadio(_oRadio);
         this.oRadioGroup.addRadio(_oRadio);
         _oRadio.mcContainer.visible = false;
         this.mcContainer.addChild(_oRadio.mcContainer);
         if(Boolean(_sTooltip))
         {
            _oRadio.setToolTipLocalized(_sTooltip);
         }
      }
      
      public function selectNone() : void
      {
         this.oRadioGroup.selectNone();
      }
      
      protected function invalidate() : void
      {
         if(!this.bInvalidate)
         {
            this.oEventManager.addEventListener(sEVENT_MANAGER_ID,UpdateManager.instance,UpdateEvent.UPDATE,this.onInvalidate);
            this.bInvalidate = true;
         }
      }
      
      protected function updateCellSize() : void
      {
         var _nLines:uint = 0;
         var _nTitleHeight:Number = NaN;
         var i:uint = 0;
         var _oCat:SelectionCategoryStruct = null;
         this.nCols = 0;
         do
         {
            ++this.nCols;
            this.nCellSize = this.nWidth / this.nCols;
            _nLines = 0;
            _nTitleHeight = 0;
            for(i = 0; i < this.aCategories.length; i++)
            {
               _oCat = this.aCategories[i];
               _nLines += _oCat.getCatHeight(this.nCols);
               if(this.aCategories.length > 1)
               {
                  _nTitleHeight += _oCat.title.height;
               }
            }
         }
         while(this.nCellSize * _nLines * this.nItemHeightRatio + _nTitleHeight > this.nHeight);
      }
      
      protected function render() : void
      {
         var _nY:Number = NaN;
         var _oCat:SelectionCategoryStruct = null;
         var i:uint = 0;
         var _nCol:uint = 0;
         var _nLine:uint = 0;
         var _nX:Number = NaN;
         var _oRadio:SelectionGridRadio = null;
         var _nCellHeight:Number = this.nCellSize * this.nItemHeightRatio;
         var _nCategoryOffsetY:Number = 0;
         if(this.aCategories.length > 1)
         {
            _nCategoryOffsetY = Number(this.aCategories[0].title.height);
         }
         for(var j:uint = 0; j < this.aCategories.length; j++)
         {
            _oCat = this.aCategories[j];
            _oCat.title.mc.y = _nCategoryOffsetY;
            _oCat.title.mc.visible = true;
            for(i = 0; i < _oCat.radios.length; i++)
            {
               _nCol = i % this.nCols;
               _nLine = Math.floor(i / this.nCols);
               _nX = _nCol * this.nCellSize + this.nCellSize / 2;
               _nY = _nLine * _nCellHeight + _nCellHeight / 2 + _nCategoryOffsetY;
               _oRadio = _oCat.radios[i];
               _oRadio.updatePos(_nX,_nY,this.nCellSize,this.nItemHeightRatio,this.nOverRatio);
               _oRadio.mcContainer.visible = true;
            }
            _oCat.title.setBkgHeight(_nY - _nCategoryOffsetY + _nCellHeight / 2);
            if(j + 1 < this.aCategories.length)
            {
               _nCategoryOffsetY = _nY + SelectionCategoryStruct(this.aCategories[j + 1]).title.height + this.nCellSize / 2;
            }
         }
      }
      
      private function getCatByID(_sID:String) : SelectionCategoryStruct
      {
         var _oReturn:SelectionCategoryStruct = null;
         var _oCat:SelectionCategoryStruct = null;
         for each(_oCat in this.aCategories)
         {
            if(_oCat.sID == _sID)
            {
               _oReturn = _oCat;
            }
         }
         if(_oReturn == null)
         {
            _oReturn = new SelectionCategoryStruct(_sID);
            this.aCategories.push(_oReturn);
            this.mcContainer.addChildAt(_oReturn.title.mc,0);
         }
         return _oReturn;
      }
      
      private function onInvalidate(_e:Event) : void
      {
         this.oEventManager.removeEventListener(sEVENT_MANAGER_ID,UpdateManager.instance,UpdateEvent.UPDATE,this.onInvalidate);
         this.bInvalidate = false;
         this.updateCellSize();
         this.render();
      }
      
      private function onRollOver(_e:Event, _oRadio:Radio) : void
      {
         this.mcContainer.removeChild(_oRadio.mcContainer);
         this.mcContainer.addChild(_oRadio.mcContainer);
      }
      
      private function onChange(_e:UIEvent) : void
      {
         dispatchEvent(_e);
      }
      
      public function get selectedValue() : *
      {
         if(Boolean(this.oRadioGroup.selected))
         {
            return this.oRadioGroup.selected.value;
         }
         return null;
      }
      
      public function set selectedValue(_oValue:*) : void
      {
         var _oCategory:SelectionCategoryStruct = null;
         var _oRadio:SelectionGridRadio = null;
         var _bFound:Boolean = false;
         for each(_oCategory in this.aCategories)
         {
            for each(_oRadio in _oCategory.radios)
            {
               if(_oRadio.value == _oValue)
               {
                  this.oRadioGroup.selected = _oRadio;
                  _bFound = true;
                  break;
               }
            }
            if(_bFound)
            {
               break;
            }
         }
      }
   }
}

class SelectionCategoryStruct
{
   
   public var sID:String;
   
   private var aRadios:Array;
   
   private var oTitle:SelectionGridTitle;
   
   public function SelectionCategoryStruct(_sLocale:String)
   {
      super();
      this.aRadios = new Array();
      this.sID = _sLocale;
      this.oTitle = new SelectionGridTitle(_sLocale);
   }
   
   public function destroy() : void
   {
      var _oRadio:SelectionGridRadio = null;
      for each(_oRadio in this.aRadios)
      {
         _oRadio.destroy();
      }
   }
   
   public function addRadio(_oRadio:SelectionGridRadio) : void
   {
      this.aRadios.push(_oRadio);
   }
   
   public function getCatHeight(_nCols:uint) : Number
   {
      return Math.ceil(this.aRadios.length / _nCols);
   }
   
   public function get radios() : Array
   {
      return this.aRadios;
   }
   
   public function get title() : SelectionGridTitle
   {
      return this.oTitle;
   }
}
