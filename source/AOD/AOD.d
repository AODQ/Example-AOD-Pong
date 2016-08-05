module AOD.AOD;

import derelict.opengl3.gl3;
import derelict.opengl3.gl;
import derelict.sdl2.sdl;
import std.string;

import Camera = AOD.camera;
import Console = AOD.console;
import AOD.input;
import AOD.entity;
static import AOD.realm;
import AOD.sound;
import AOD.text;
import AOD.vector;
import AOD.utility;

class Engine {
static:
  SDL_Window* screen = null;
  GLuint[] images;

  AOD.realm.Realm realm = null;

  uint ms_dt = 0;

  bool started = 0;
  int start_ticks = 0;
  Text fps_display;
  float[20] fps = [ 0 ];
}

void Initialize(uint _fps, string window_name, string icon = "") {
  static import AOD.clientvars;
  if ( Engine.realm is null ) {
    if ( window_name == "" )
      window_name = "Art of Dwarficorn";
    Engine.realm = new AOD.realm.Realm(AOD.clientvars.screen_width,
                                       AOD.clientvars.screen_height,
                                       window_name.ptr, icon.ptr);
    Engine.ms_dt = _fps;
  }
  Camera.Set_Position(Vector(0, 0));
  Camera.Set_Size(Vector(cast(float)AOD.clientvars.screen_width,
                         cast(float)AOD.clientvars.screen_height));
}

void Initialize_Console(bool print_debug, SDL_Keycode key, string cons) {
  if ( print_debug )
    Console.ConsEng.console_type = Console.TYPE_DEBUG_IN;
  else
    Console.ConsEng.console_type = Console.TYPE_DEBUG_OUT;
  Console.Debug_Output("Created new console");
  Console.ConsEng.key = key;
  Console.ConsEng.Construct();
}

void Change_MSDT(Uint32 x) {
  if ( x > 0 )
    Engine.ms_dt = x;
  else
    Console.Debug_Output("Trying to change the MS DeltaTime to a value <= 0");
}

void Reset() {
  /* if ( Engine.realm !is null ) */
  /*   Engine.realm.Reset(); */
}
void End() {
  Engine.realm = null;
  SDL_DestroyWindow(Engine.screen);
  SDL_Quit();
}

Entity[int] obj_list;


int Add(Entity o) {
  static uint id_counter = 0;
  if ( Engine.realm !is null && o ) {
    Engine.realm.__Add(o);
    o.Set_ID(id_counter++);
    /* obj_list[o.Ret_ID(), o); */
    return o.Ret_ID();
  } else {
    if ( o is null )
      Console.Debug_Output("Error: Adding null text to realm");
    return -1;
  }
}

void Add(Text t) {
  if ( Engine.realm !is null && t !is null )
    Engine.realm.__Add(t);
  else {
    if ( t is null )
      Console.Debug_Output("Error: Adding null text to realm");
  }
}

void Remove(Entity o) {
  if ( Engine.realm !is null )
    Engine.realm.__Remove(o);
}

void Remove(Text t) {
  if ( Engine.realm !is null )
    Engine.realm.__Remove(t);
}

void Set_BG_Colour(GLfloat r, GLfloat g, GLfloat b) {
  if ( Engine.realm is null ) return;
  Engine.realm.Set_BG_Colours(r, g, b);
}

void Run() {
  if ( Engine.realm is null ) return;
  float prev_dt        = 0, // DT from previous frame
        curr_dt        = 0, // DT for beginning of current frame
        elapsed_dt     = 0, // DT elapsed between previous frame and this frame
        accumulated_dt = 0; // DT needing to be processed
  Engine.started = 1;
  Engine.start_ticks = SDL_GetTicks();
  SDL_Event _event;
  _event.user.code = 2;
  _event.user.data1 = null;
  _event.user.data2 = null;
  SDL_PushEvent(&_event);

  // so I can set up keys and not have to rely that update is ran first
  SDL_PumpEvents();
  MouseEngine.Refresh_Input();
  SDL_PumpEvents();
  MouseEngine.Refresh_Input();

  while ( SDL_PollEvent(&_event) ) {
    switch ( _event.type ) {
      case SDL_QUIT:
        return;
      default: break;
    }
  }
  prev_dt = cast(float)SDL_GetTicks();
  while ( true ) {
    // refresh time handlers
    curr_dt = cast(float)SDL_GetTicks();
    elapsed_dt = curr_dt - prev_dt;
    accumulated_dt += elapsed_dt;

    // refresh calculations
    while ( accumulated_dt >= Engine.ms_dt ) {
      // sdl
      SDL_PumpEvents();
      MouseEngine.Refresh_Input();

      // actual update
      accumulated_dt -= Engine.ms_dt;
      Engine.realm.Update();

      string tex;
      string to_handle;
      bool alnum;
      char* chptr = null;

      /* auto input = Console::input->R_Str(), */
      /*      input_after = Console::input_after->R_Str(); */

      while ( SDL_PollEvent(&_event) ) {
        switch ( _event.type ) {
          default: break;
/* case SDL_MOUSEWHEEL: */
/*   if ( _event.wheel.y > 0 ) // positive away from user */
/*     Input::keys[ MOUSEBIND::MWHEELUP ] = true; */
/*   else if ( _event.wheel.y < 0 ) */
/*     Input::keys[ MOUSEBIND::MWHEELDOWN ] = true; */
/* break; */
/* case SDL_KEYDOWN: */
/*   // check if backspace or copy/paste */
/*   if ( Console::console_open ) { */
/*     switch ( _event.key.keysym.sym ) { */
/*       case SDLK_BACKSPACE: */
/*         if ( Console::input->R_Str().length() > 0 ) { */
/*           Console::input.Set_S */
/*           Console::input.R_Str().pop_back(); */
/*           Update_Console_Input_Position(); */
/*         } */
/*       break; */
/*       case SDLK_DELETE: */
/*         if ( Console::input_after->R_Str().length() > 0 ) { */
/*           Console::input_after->R_Str().erase(0, 1); */
/*           Update_Console_Input_Position(); */
/*         } */
/*       break; */
/*       case SDLK_c: // copy */
/*         if ( SDL_GetModState() & KMOD_CTRL ) { */
/*           SDL_SetClipboardText( Console::input->R_Str().c_str() ); */
/*           Update_Console_Input_Position(); */
/*         } */
/*       break; */
/*       case SDLK_v: // paste */
/*         if ( SDL_GetModState() & KMOD_CTRL ) { */
/*           chptr = SDL_GetClipboardText(); */
/*           Console::input.Set_String( chptr ); */
/*           SDL_free(chptr); */
/*           Update_Console_Input_Position(); */
/*         } */
/*       break; */
/*       case SDLK_LEFT: // navigate cursor left */
/*         tex = Console::input->R_Str(); */
/*         if ( tex.length() > 0 ) { */
/*           tex = tex[tex.length()-1]; */
/*           Console::input->R_Str().pop_back(); */
/*           Console::input_after->R_Str().insert(0, tex); */

/*           // skip word */
/*           /1* if ( SDL_GetModState() & KMOD_CTRL ) { *1/ */
/*           /1*   alnum = isalnum(tex[0]); *1/ */
/*           /1*   while ( Console::input->R_Str().length() > 0 ) { *1/ */
/*           /1*     tex = Console::input->R_Str(); *1/ */
/*           /1*     tex = tex[tex.length()-1]; *1/ */
/*           /1*     if ( (bool)isalnum(tex[0]) == alnum ) { *1/ */
/*           /1*       Console::input->R_Str().pop_back(); *1/ */
/*           /1*       Console::input_after->R_Str().insert(0, tex); *1/ */
/*           /1*     } else break; *1/ */
/*           /1*   } *1/ */
/*           /1* } *1/ */

/*           Update_Console_Input_Position(); */
/*         } */
/*       break; */
/*       case SDLK_RIGHT: // navigate cursor right */
/*         tex = Console::input_after->R_Str(); */
/*         if ( tex.length() > 0 ) { */
/*           tex = tex[0]; */
/*           Console::input_after->R_Str().erase(0, 1); */
/*           Console::input->R_Str().push_back(tex[0]); */

/*           // skip word */
/*           /1* if ( SDL_GetModState() & KMOD_CTRL ) { *1/ */
/*           /1*   alnum = isalnum(tex[0]); *1/ */
/*           /1*   while ( Console::input_after->R_Str().length() > 0 ) { *1/ */
/*           /1*     tex = Console::input_after->R_Str(); *1/ */
/*           /1*     tex = tex[0]; *1/ */
/*           /1*     if ( (bool)isalnum(tex[0]) == alnum ) { *1/ */
/*           /1*       Console::input_after->R_Str().erase(0, 1); *1/ */
/*           /1*       Console::input->R_Str().push_back(tex[0]); *1/ */
/*           /1*     } else break; *1/ */
/*           /1*   } *1/ */
/*           /1* } *1/ */

/*           Update_Console_Input_Position(); */
/*         } */
/*       break; */
/*       case SDLK_RETURN: case SDLK_RETURN2: */
/*         to_handle = Console::input->R_Str() + */
/*                     Console::input_after->R_Str(); */
/*         if ( to_handle != "" ) { */
/*           Console::input->Set_String(""); */
/*           Console::input_after->Set_String(""); */
/*           Handle_Console_Input(to_handle); */
/*           Update_Console_Input_Position(); */
/*         } */
/*       break; */
/*       case SDLK_END: */
/*         Console::input->R_Str() += Console::input_after->R_Str(); */
/*         Console::input_after->R_Str().clear(); */
/*         Update_Console_Input_Position(); */
/*       break; */
/*       case SDLK_HOME: */
/*         // since appending is faster than prepending */
/*         Console::input->R_Str() += Console::input_after->R_Str(); */
/*         Console::input_after->R_Str() = Console::input->R_Str(); */
/*         Console::input->R_Str().clear(); */
/*         Update_Console_Input_Position(); */
/*       break; */
/*     } */
/*   } */
/* break; */
/* case SDL_TEXTINPUT: */
/*   if ( AOD::Console::console_open ) { */
/*     if ( (SDL_GetModState() & KMOD_CTRL) || */
/*           _event.text.text[0] == '~' || _event.text.text[0] == '`' ) */
/*       break; */
/*     Console::input->R_Str() += _event.text.text; */
/*     Update_Console_Input_Position(); */
/*   } */
/* break; */
          case SDL_QUIT:
            return;
        }
      }
    }

    { // refresh screen
      float _FPS = 0;
      for ( int i = 0; i != 19; ++ i ) {
        Engine.fps[i+1] = Engine.fps[i];
        _FPS += Engine.fps[i+1];
      }
      Engine.fps[0] = elapsed_dt;
      _FPS += Engine.fps[0];

      if ( Engine.fps_display !is null ) {
        /* engine.fps_display->Set_String( */
        /*                     std::to_string(int(20000/_FPS)) + " FPS"); */
      }

      /* Refresh(); */
      Engine.realm.Render(); // render the screen
    }

    { // sleep until temp dt reaches ms_dt
      float temp_dt = accumulated_dt;
      temp_dt = cast(float)(SDL_GetTicks()) - curr_dt;
      while ( temp_dt < Engine.ms_dt ) {
        SDL_PumpEvents();
        temp_dt = cast(float)(SDL_GetTicks()) - curr_dt;
      }
    }

    // set current frame timemark
    prev_dt = curr_dt;
  }
}

float R_MS()         { return cast(float)Engine.ms_dt; }
float To_MS(float x) { return (x*Engine.ms_dt)/1000;   }
