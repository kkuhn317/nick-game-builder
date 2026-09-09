package com.sarbakan.sbdk.errors
{
   public class ErrorMessages
   {
      
      public static const sID_EXISTS:String = "ID already exists: \'%ID%\'";
      
      public static const sID_UNKNOWN:String = "Cannot find ID: \'%ID%\'";
      
      public static const sKEYCODE_DUPLICATE:String = "Key code already added: \'%keyCode%\'";
      
      public static const sKEYCODE_UNKNOWN:String = "Cannot find key code: \'%keyCode%\'";
      
      public static const sKEYCODE_CASE_SENSITIVE_EXCEPTIONS:String = "Cannot add SHIFT and CAPS LOCK key in a case-sensitive sequence.";
      
      public static const sKEYCODE_CASE_SENSITIVE_DISABLED:String = "Cannot set uppercase mode in a non case-sensitive sequence.";
      
      public static const sSEQUENCE_LOCKED:String = "Cannot modify sequence once added to the manager";
      
      public static const sSEQUENCE_MAX_SIZE:String = "More element than allowed by sequence size. Please increase _nMaxsSize value in constructor.";
      
      public static const sSEQUENCE_DUPLICATE:String = "Sequence instance already added to manager under ID: \'%ID%\'";
      
      public static const sSEQUENCE_PERSISTENCE_UNENDED:String = "Persistence of key must be ended before that key can be added again: \'%keyCode%\'";
      
      public static const sSEQUENCE_PERSISTENCE_NOT:String = "Key is not persistent: \'%keyCode\'";
      
      public static const sSEQUENCE_PERSISTENCE_INVALID_KEY:String = "Sequence is invalid. All persistent keys must be ended and at least one element must be added to the sequence.";
      
      public static const sSEQUENCE_PERSISTENCE_INVALID_MOUSE:String = "Sequence is invalid. At least one element must be added to the sequence.";
      
      public static const sBANDWIDTH_LOADER_LOCKED:String = "Cannot set a custom loader to a BandwidthMonitor with source type BandwithMonitorSource.PRELOAD_MANAGER";
      
      public static const sDEBUG_GRAPHIC_MANAGER_LOCK:String = "Cannot modify graphic debug settings once added to the manager";
      
      public static const sSTATE_LOCATION_LOCKED:String = "Animation location cannot be modified once state have been added to the state machine.";
      
      public static const sSTATE_LOCATION_TIMELINE:String = "Cannot addStateFromAsset() on a AnimStateMachine with AnimStateLocation.TIMELINE";
      
      public static const sSTATE_LOCATION_ASSET:String = "Cannot addState() on a AnimStateMachine with AnimStateLocation.ASSET_MANAGER";
      
      public static const sSTATE_LABEL_UNKNOWN:String = "Cannot not find label: \'%label%\'";
      
      public static const sSTATE_REMOVE_CURRENT:String = "Cannot remove a state while it is the current state and state machine is running: \'%ID\'";
      
      public static const sSTATE_STOPPED_PAUSE:String = "Cannot pause a stopped state";
      
      public static const sSTATE_STOPPED_RESUME:String = "Cannot resume a stopped state";
      
      public static const sSTATE_STATEMC_RENAME:String = "Cannot modify stateMcName while state machine is running";
      
      public static const sSTATE_ALREADY_IS:String = "Statemachine is already is this state: \'%ID%\'";
      
      public static const sSTATE_IS_NOT_SET:String = "No state exist at the moment.";
      
      public static const sSTATE_DOESNT_EXIST:String = "State doesn\'t exist: \'%ID%\'";
      
      public static const sSTATE_ASSET_ALREADY_SET:String = "Cannot set cached asset when state are already set.";
      
      public static const sSTATE_CACHE_CANT_BE_SET:String = "Cannot set cache because asset location is set to timeline state.";
      
      public static const sSTATE_DOES_NOT_EXIST:String = "Target state does not exist. \'%mcButton%\'";
      
      public static const sSINGLETON:String = "This class is a singleton. It must be accessed through Class.instance";
      
      public static const sSINGLETON_STAGE:String = "This class is a singleton. It must be accessed through Class.instance(<stage reference>)";
      
      public static const sENUM_CONSTRUCTION:String = "Cannot instantiate an Enumeration class outside of its own class.";
      
      public static const sINVALID_STRING_PARAM:String = "Invalid string parameter: \'%string%\'";
      
      public static const sABSTRACT_CLASS_ERROR:String = "Abstract class must be extended";
      
      public static const sABSTRACT_METHOD_NOT_IMPLEMENTED:String = "Abstract method not implemented by concrete class: \'%method%\'";
      
      public static const sSINGLETON_ERROR:String = "Singleton can only be accessed through Class.instance";
      
      public static const sASSET_ALREADY_EXIST:String = "Asset allready exist: \'%ID%\'";
      
      public static const sASSET_DOESNT_EXIST:String = "Asset doesn\'t exist: \'%ID%\'";
      
      public static const sLOADER_ALREADY_LOADING:String = "Already loading: \'%filename%\'";
      
      public static const sLOADER_GROUPLOADER_ERROR:String = "Can\'t add a GroupLoader in a GroupLoader: \'%GROUP_ID%\'";
      
      public static const sLOADER_DOESNT_EXIST:String = "Loader does not exist: \'%ID%\'";
      
      public static const sLOADER_ALREADY_EXIST:String = "Loader already exist: \'%ID%\'";
      
      public static const sLOADER_QUEUE_FULL:String = "Loading queue is full";
      
      public static const sLOADER_MAXSIZE_ERROR:String = "Cannot set maxSize after instance exist";
      
      public static const sABSOLUTE_PATH:String = "You should not use absolute path: ";
      
      public static const sVIEW_DOESNT_EXIST:String = "View doesn\'t exist: \'%ID%\'";
      
      public static const sVIEW_IS_NOT_DISPLAYED:String = "View is not displayed: \'%ID%\'";
      
      public static const sVIEW_ASSET_LOCATION_NOT_SET:String = "Asset location is not set";
      
      public static const sVIEW_TRANSITION_ALREADY_PLAYING:String = "View is already playing a transition: \'%ID%\'";
      
      public static const sVIEW_ALREADY_DISPLAYED:String = "view already displayed: \'%ID%\'";
      
      public static const sTRANSTION_ASSET_DOESNT_EXIST:String = "Transition asset doesnt exist: \'%ID%\'";
      
      public static const sTRANSTION_ASSET_ALREADY_EXIST:String = "Transition asset already exist: \'%ID%\'";
      
      public static const sDISPLAY_OBJECT_IS_NULL:String = "DisplayObject is null";
      
      public static const sEMPTY_VIEW:String = "Cannot use effect transition with an empty view.";
      
      public static const sVO_DOESNT_EXIST:String = "Voice over doesn\'t exist: \'%ID%\'";
      
      public static const sVO_QUEUE_IS_CURRENTLY_PLAYING:String = "One queue is already playing. One queue at the time.";
      
      public static const sVO_QUEUE_PRIORITY_DOESNT_EXIST:String = "The priority of a queue must start at zero.";
      
      public static const sVO_QUEUE_DOESNT_EXIST:String = "Target queue doesn\'t exist: \'%ID%\'";
      
      public static const sVO_CHAR_ALREADY_EXIST:String = "Character already exist: \'%ID%\'";
      
      public static const sVO_CHAR_DOESNT_EXIST:String = "Character doesn\'t exist: \'%ID%\'";
      
      public static const sVO_SINGLE_ALREADY_EXIST:String = "Single voice over already exist: \'%ID%\'";
      
      public static const sLOCALIZATION_STRING_FILE_EXISTS:String = "String file already loaded: %fileName%";
      
      public static const sLOG_CONNECTION_ERROR:String = "External pusblisher cannot connect with console.";
      
      public static const sLOG_CONSOLE_SHAREOBJECT:String = "Problem connecting with local ShareObject.";
      
      public static const sSOUND_FADE_VALUE_TOO_SMALL:String = "Fade value is too small. Must be higher than 100: \'%ID%\'";
      
      public static const sDISPLAY_CONTAINER_NOT_SET:String = "Display container was not set";
      
      public static const sSTAGE_NULL:String = "Stage is null.";
      
      public static const sLIST_ARE_NOT_EQUAL_LENGTH:String = "List of asset class must be the same length as the duplicate frame list.";
      
      public static const sNOT_A_MOVIECLIP:String = "The DisplayObject is not a MovieClip.";
      
      public static const sBITMAP_TO_BIG:String = "The target bitmap is bigger then 2880 X 2880";
      
      public static const sROTATION_GREATER_THEN_360:String = "The target rotation angle is greater then 360 degree.";
      
      public static const sCONTAINER_NOT_VALID:String = "This IBitmappedAnimation is not part of a valid BitmapppedAnimContainer.";
      
      public static const sLAYER_NOT_FOUND:String = "Target layer: \'%ID%\' doesnt exist.";
      
      public static const sCOLLECTION_NOT_FOUND:String = "Target collection does not exist \'%ID%\'.";
      
      public static const sCOORDINATE_OUT_OF_BOUND:String = "X/Y coordinates are out of bound. x: \'%X%\' y: \'%Y%\'";
      
      public static const sNON_SEQUENTIAL_DEPTH:String = "The target depth is non sequential. Layer: \'%LAYER%\' Depth: \'%DEPTH%\'";
      
      public static const sNOT_ADDED_TO_CONTAINER:String = "IBitmappedAnimation is not added to container.";
      
      public static const sFLIPPED_FRAME_DONT_EXIST:String = "Flipped frame of the target collection doesn\'t exist.";
      
      public static const sTEXTFIELD_NOT_SET:String = "TextField was not initially set.";
      
      public static const sALREADY_EXISTING_IN_OTHER_CONTAINER:String = "Bitmapped animation already exist in other container: \'%ID%\'";
      
      public static const sSOUND_ASSET_DOESNT_EXIST:String = "Sound asset doesnt exist. ";
      
      public static const sCOLLIDERS_NOT_EXISTANT:String = "No colliders are availables in this animation: \'%ID%\'";
      
      public function ErrorMessages()
      {
         super();
      }
   }
}

