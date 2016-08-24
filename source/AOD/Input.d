/**
  Describes the input of the current state of the Engine
*/
/**
Macros:
  PARAM = <u>$1</u>

  PARAMDESC = <t style="padding-left:3em">$1</t>
*/
module AODCore.input;
import derelict.sdl2.sdl;
import Camera = AODCore.camera;

// These represent SDL_ScanCodes. These are prefereable
// to just calling R_LMB() or w/e b/c these are bindeable
// from INI file
/**
  These represent SDL_ScanCodes. These are preferable to just calling
  mouse functions because these are bindeable from the config INI
*/
enum Mouse_Bind
     { Left = 300, Right = 301, Middle = 302,
       Wheelup  = 303, Wheeldown = 304,
       /** (also known as "mouse4") */
       X1   = 305,
       /** (also known as "mouse5") */
       X2    = 306
     };

/**
  The current state of the keyboard (and mouse). Use either Mouse_Bind or
  <a href="https://wiki.libsdl.org/SDL_Scancode">SDL_SCANCODE</a> for index.
Example:
---
  if ( keystate [ SDL_SCANCODE_A ] ) Output("A pressed");
---
*/
ubyte* keystate;

class MouseEngine {
static: private:
  uint mouse, last_frame_mouse;
  int mouse_x, mouse_y;
static: public:
  void Refresh_Input() {
    last_frame_mouse = mouse;
    keystate = cast(ubyte*)(SDL_GetKeyboardState(null));
    mouse = SDL_GetMouseState(&mouse_x, &mouse_y);
    keystate[ Mouse_Bind.Left   ] = R_LMB();
    keystate[ Mouse_Bind.Right  ] = R_RMB();
    keystate[ Mouse_Bind.Middle ] = R_MMB();
    keystate[ Mouse_Bind.X1     ] = R_MX1();
    keystate[ Mouse_Bind.X2     ] = R_MX2();
    // Let AODCore.D handle mouse wheel
  }
}

private alias MEngine = MouseEngine;

private uint  MLEFT   = SDL_BUTTON(SDL_BUTTON_LEFT),
              MRIGHT  = SDL_BUTTON(SDL_BUTTON_RIGHT),
              MMIDDLE = SDL_BUTTON(SDL_BUTTON_MIDDLE),
              MX1     = SDL_BUTTON(SDL_BUTTON_X1),
              MX2     = SDL_BUTTON(SDL_BUTTON_X2);

/** Returns: if the Left Mouse button is pressed */
bool R_LMB() { return cast(bool)MEngine.mouse&MLEFT  ; }
/** Returns: if the Right Mouse button is pressed */
bool R_RMB() { return cast(bool)MEngine.mouse&MRIGHT ; }
/** Returns: if the Middle Mouse button is pressed */
bool R_MMB() { return cast(bool)MEngine.mouse&MMIDDLE; }
/** Returns: if MouseX1 (mouse4) button is pressed */
bool R_MX1() { return cast(bool)MEngine.mouse&MX1    ; }
/** Returns: if MouseX2 (mouse5) button is pressed */
bool R_MX2() { return cast(bool)MEngine.mouse&MX2    ; }

/** Returns: if the Left Mouse button was clicked on this frame */
bool R_On_LMB() { return cast(bool)MEngine.mouse            &MLEFT &&
                        !cast(bool)MEngine.last_frame_mouse&MLEFT; }
/** Returns: if the Right Mouse button was clicked on this frame */
bool R_On_RMB() { return cast(bool)MEngine.mouse           &MRIGHT &&
                        !cast(bool)MEngine.last_frame_mouse&MRIGHT; }
/** Returns: if the Middle Mouse button was clicked on this frame */
bool R_On_MMB() { return cast(bool)MEngine.mouse           &MMIDDLE &&
                        !cast(bool)MEngine.last_frame_mouse&MMIDDLE; }
/** Returns: if MouseX1 (mouse4) button was clicked on this frame */
bool R_On_MX1() { return cast(bool)MEngine.mouse           &MX1 &&
                        !cast(bool)MEngine.last_frame_mouse&MX1; }
/** Returns: if MouseX2 (mouse5) button was clicked on this frame */
bool R_On_MX2() { return cast(bool)MEngine.mouse           &MX2 &&
                        !cast(bool)MEngine.last_frame_mouse&MX2; }


/** 
Params:
  camoffset = $(PARAMDESC Whether to offset the position of
                the mouse with the camera)
Returns:
  The position of the mouse on the x-axis
*/
float R_Mouse_X(bool camoffset) {
  return MouseEngine.mouse_x + (camoffset ?
          Camera.R_Position().x - Camera.R_Size().x/2 : 0);
}
/** 
Params:
  camoffset = $(PARAMDESC Whether to offset the position of
                the mouse with the camera)
Returns:
  The position of the mouse on the y-axis
*/
float R_Mouse_Y(bool camoffset) {
  return MouseEngine.mouse_y + (camoffset ?
          Camera.R_Position().y - Camera.R_Size().y/2 : 0);
}
