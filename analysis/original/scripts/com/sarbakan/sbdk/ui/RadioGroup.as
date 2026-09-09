package com.sarbakan.sbdk.ui
{
   import com.sarbakan.sbdk.events.UIEvent;
   import com.sarbakan.sbdk.utils.EventManager;
   import de.polygonal.ds.Iterator;
   import de.polygonal.ds.Set;
   import flash.events.EventDispatcher;
   
   [Event(name="CHANGE",type="com.sarbakan.sbdk.events.UIEvent")]
   public class RadioGroup extends EventDispatcher
   {
      
      private static const sEVENT_MANAGER_ID:String = "radioGroup";
      
      private var lRadio:Set;
      
      private var oSelectedRadio:Radio;
      
      private var oEventManager:EventManager;
      
      private var bEnabled:Boolean;
      
      private var bAutoSelectFirstRadio:Boolean;
      
      public function RadioGroup(_bAutoSelectFirstRadio:Boolean = true)
      {
         super();
         this.bAutoSelectFirstRadio = _bAutoSelectFirstRadio;
         this.init();
      }
      
      public function destroy() : void
      {
         this.lRadio = null;
         this.oEventManager.destroy();
         this.oEventManager = null;
      }
      
      public function addRadio(_oRadio:Radio) : void
      {
         _oRadio.setGroup(this);
         this.lRadio.set(_oRadio);
         if(this.lRadio.size == 1 && this.bAutoSelectFirstRadio)
         {
            _oRadio.checked = true;
         }
         if(this.bEnabled == false)
         {
            _oRadio.enabled = false;
         }
         if(this.oSelectedRadio == null && this.bAutoSelectFirstRadio)
         {
            this.oSelectedRadio = _oRadio;
         }
         this.oEventManager.addEventListener(sEVENT_MANAGER_ID,_oRadio,UIEvent.CHANGE,this.onRadioChange);
      }
      
      public function removeRadio(_oRadio:Radio) : void
      {
         this.cleanRadio(_oRadio);
         this.lRadio.remove(_oRadio);
      }
      
      public function removeAllRadios(_bUnselectCurrent:Boolean = true) : void
      {
         var _oRadio:Radio = null;
         var _oContentIterator:Iterator = this.lRadio.getIterator();
         while(_oContentIterator.hasNext())
         {
            _oRadio = _oContentIterator.next();
            if(_bUnselectCurrent)
            {
               _oRadio.checked = false;
            }
            this.cleanRadio(_oRadio);
         }
         this.lRadio.clear();
      }
      
      public function selectNone() : void
      {
         var _oNextRadio:Radio = null;
         var _oIterator:Iterator = this.lRadio.getIterator();
         while(_oIterator.hasNext())
         {
            _oNextRadio = _oIterator.next();
            _oNextRadio.checked = false;
         }
         this.oSelectedRadio = null;
      }
      
      override public function toString() : String
      {
         return "[RadioGroup: Selected = " + this.oSelectedRadio + ", Enabled = " + this.bEnabled + ", Radios Contained = " + this.lRadio.toString() + "]";
      }
      
      private function cleanRadio(_oRadio:Radio) : void
      {
         _oRadio.setGroup(null);
         this.oEventManager.removeEventListener(sEVENT_MANAGER_ID,_oRadio,UIEvent.CHANGE,this.onRadioChange);
      }
      
      private function init() : void
      {
         this.oEventManager = new EventManager();
         this.lRadio = new Set();
         this.bEnabled = true;
      }
      
      private function onRadioChange(_e:UIEvent) : void
      {
         var _oIterator:Iterator = null;
         var _oNextRadio:Radio = null;
         var _oRadio:Radio = _e.target as Radio;
         if(_oRadio.checked)
         {
            this.oSelectedRadio = _oRadio;
            _oIterator = this.lRadio.getIterator();
            while(_oIterator.hasNext())
            {
               _oNextRadio = _oIterator.next();
               if(_oNextRadio != _oRadio)
               {
                  _oNextRadio.checked = false;
               }
            }
            dispatchEvent(new UIEvent(UIEvent.CHANGE));
         }
      }
      
      public function get selected() : Radio
      {
         return this.oSelectedRadio;
      }
      
      public function set selected(_oTargetRadio:Radio) : void
      {
         var _bOwnRadio:Boolean = this.lRadio.contains(_oTargetRadio);
         if(_bOwnRadio)
         {
            _oTargetRadio.checked = true;
         }
      }
      
      public function get enabled() : Boolean
      {
         return this.bEnabled;
      }
      
      public function set enabled(_bEnabled:Boolean) : void
      {
         var _oIterator:Iterator = null;
         var _oRadio:Radio = null;
         if(_bEnabled != this.bEnabled)
         {
            this.bEnabled = _bEnabled;
            _oIterator = this.lRadio.getIterator();
            while(_oIterator.hasNext())
            {
               _oRadio = _oIterator.next();
               _oRadio.enabled = this.bEnabled;
            }
         }
      }
   }
}

