package com.sarbakan.sbdk.input
{
   public class CharCode
   {
      
      public static const A:String = "A";
      
      public static const B:String = "B";
      
      public static const C:String = "C";
      
      public static const D:String = "D";
      
      public static const E:String = "E";
      
      public static const F:String = "F";
      
      public static const G:String = "G";
      
      public static const H:String = "H";
      
      public static const I:String = "I";
      
      public static const J:String = "J";
      
      public static const K:String = "K";
      
      public static const L:String = "L";
      
      public static const M:String = "M";
      
      public static const N:String = "N";
      
      public static const O:String = "O";
      
      public static const P:String = "P";
      
      public static const Q:String = "Q";
      
      public static const R:String = "R";
      
      public static const S:String = "S";
      
      public static const T:String = "T";
      
      public static const U:String = "U";
      
      public static const V:String = "V";
      
      public static const W:String = "W";
      
      public static const X:String = "X";
      
      public static const Y:String = "Y";
      
      public static const Z:String = "Z";
      
      public static const NUMBER_0:String = "NUMBER_0";
      
      public static const NUMBER_1:String = "NUMBER_1";
      
      public static const NUMBER_2:String = "NUMBER_2";
      
      public static const NUMBER_3:String = "NUMBER_3";
      
      public static const NUMBER_4:String = "NUMBER_4";
      
      public static const NUMBER_5:String = "NUMBER_5";
      
      public static const NUMBER_6:String = "NUMBER_6";
      
      public static const NUMBER_7:String = "NUMBER_7";
      
      public static const NUMBER_8:String = "NUMBER_8";
      
      public static const NUMBER_9:String = "NUMBER_9";
      
      public static const NUMBER_0_NUMPAD:String = "NUMBER_0_NUMPAD";
      
      public static const NUMBER_1_NUMPAD:String = "NUMBER_1_NUMPAD";
      
      public static const NUMBER_2_NUMPAD:String = "NUMBER_2_NUMPAD";
      
      public static const NUMBER_3_NUMPAD:String = "NUMBER_3_NUMPAD";
      
      public static const NUMBER_4_NUMPAD:String = "NUMBER_4_NUMPAD";
      
      public static const NUMBER_5_NUMPAD:String = "NUMBER_5_NUMPAD";
      
      public static const NUMBER_6_NUMPAD:String = "NUMBER_6_NUMPAD";
      
      public static const NUMBER_7_NUMPAD:String = "NUMBER_7_NUMPAD";
      
      public static const NUMBER_8_NUMPAD:String = "NUMBER_8_NUMPAD";
      
      public static const NUMBER_9_NUMPAD:String = "NUMBER_9_NUMPAD";
      
      public static const F1:String = "F1";
      
      public static const F2:String = "F2";
      
      public static const F3:String = "F3";
      
      public static const F4:String = "F4";
      
      public static const F5:String = "F5";
      
      public static const F6:String = "F6";
      
      public static const F7:String = "F7";
      
      public static const F8:String = "F8";
      
      public static const F9:String = "F9";
      
      public static const F10:String = "F10";
      
      public static const F11:String = "F11";
      
      public static const F12:String = "F12";
      
      public static const UP:String = "UP";
      
      public static const DOWN:String = "DOWN";
      
      public static const LEFT:String = "LEFT";
      
      public static const RIGHT:String = "RIGHT";
      
      public static const SPACE:String = "SPACE";
      
      public static const HOME:String = "HOME";
      
      public static const END:String = "END";
      
      public static const DELETE:String = "DELETE";
      
      public static const PGUP:String = "PGUP";
      
      public static const PGDOWN:String = "PGDOWN";
      
      public static const INSERT:String = "INSERT";
      
      public static const PAUSE:String = "PAUSE";
      
      public static const PRINTSCREEN:String = "PRINTSCREEN";
      
      public static const ENTER:String = "ENTER";
      
      public static const TAB:String = "TAB";
      
      public static const SHIFT:String = "SHIFT";
      
      public static const CTRL:String = "CTRL";
      
      public static const ALT:String = "ALT";
      
      public static const CAPSLOCK:String = "CAPSLOCK";
      
      public static const NUMLOCK:String = "NUMLOCK";
      
      public static const SCROLLLOCK:String = "SCROLLLOCK";
      
      public function CharCode()
      {
         super();
      }
      
      public static function KeyCodeToCharCode(_nKeyCode:uint) : String
      {
         switch(_nKeyCode)
         {
            case 65:
               return A;
            case 66:
               return B;
            case 67:
               return C;
            case 68:
               return D;
            case 69:
               return E;
            case 70:
               return F;
            case 71:
               return G;
            case 72:
               return H;
            case 73:
               return I;
            case 74:
               return J;
            case 75:
               return K;
            case 76:
               return L;
            case 77:
               return M;
            case 78:
               return N;
            case 79:
               return O;
            case 80:
               return P;
            case 81:
               return Q;
            case 82:
               return R;
            case 83:
               return S;
            case 84:
               return T;
            case 85:
               return U;
            case 86:
               return V;
            case 87:
               return W;
            case 88:
               return X;
            case 89:
               return Y;
            case 90:
               return Z;
            case 48:
               return NUMBER_0;
            case 49:
               return NUMBER_1;
            case 50:
               return NUMBER_2;
            case 51:
               return NUMBER_3;
            case 52:
               return NUMBER_4;
            case 53:
               return NUMBER_5;
            case 54:
               return NUMBER_6;
            case 55:
               return NUMBER_7;
            case 56:
               return NUMBER_8;
            case 57:
               return NUMBER_9;
            case 96:
               return NUMBER_0_NUMPAD;
            case 97:
               return NUMBER_1_NUMPAD;
            case 98:
               return NUMBER_2_NUMPAD;
            case 99:
               return NUMBER_3_NUMPAD;
            case 100:
               return NUMBER_4_NUMPAD;
            case 101:
               return NUMBER_5_NUMPAD;
            case 102:
               return NUMBER_6_NUMPAD;
            case 103:
               return NUMBER_7_NUMPAD;
            case 104:
               return NUMBER_8_NUMPAD;
            case 105:
               return NUMBER_9_NUMPAD;
            case 112:
               return F1;
            case 113:
               return F2;
            case 114:
               return F3;
            case 115:
               return F4;
            case 116:
               return F5;
            case 117:
               return F6;
            case 118:
               return F7;
            case 119:
               return F8;
            case 120:
               return F9;
            case 121:
               return F10;
            case 122:
               return F11;
            case 123:
               return F12;
            case 37:
               return LEFT;
            case 38:
               return UP;
            case 39:
               return RIGHT;
            case 40:
               return DOWN;
            case 32:
               return SPACE;
            case 36:
               return HOME;
            case 35:
               return END;
            case 46:
               return DELETE;
            case 33:
               return PGUP;
            case 34:
               return PGDOWN;
            case 45:
               return INSERT;
            case 19:
               return PAUSE;
            case 44:
               return PRINTSCREEN;
            case 13:
               return ENTER;
            case 9:
               return TAB;
            case 16:
               return SHIFT;
            case 17:
               return CTRL;
            case 18:
               return ALT;
            case 20:
               return CAPSLOCK;
            case 144:
               return NUMLOCK;
            case 145:
               return SCROLLLOCK;
            default:
               return null;
         }
      }
   }
}

