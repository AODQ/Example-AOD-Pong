import derelict.opengl3.gl3;
import derelict.sdl2.sdl;
import std.stdio;

void Render_Screen(SDL_Window* win) {
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  glClearColor(0, 0, 0, 0);

  SDL_GL_SwapWindow(win);
}

void Init () {
  static import AOD.console;
  writeln("app.d@Init Setting up console");
  AOD.console.console_open = false;
  AOD.console.Set_Console_Output_Type(AOD.console.TYPE_DEBUG_IN);
  static import AOD.clientvars;
  AOD.clientvars.screen_width  = 640;
  AOD.clientvars.screen_height = 480;
  static import AOD.AOD;
  writeln("app.d@Init initializing AOD");
  AOD.AOD.Initialize(17, "CYBER BUTCHER");
  static import AOD.camera;
  import AOD.vector;
  writeln("app.d@Setting up camera");
  AOD.camera.Set_Size(Vector(AOD.clientvars.screen_width,
                             AOD.clientvars.screen_height));
  AOD.camera.Set_Position(AOD.clientvars.screen_width,
                          AOD.clientvars.screen_height);
  static import AOD.text;
  writeln("app.d@Setting up text");
  /* AOD.text.Text.Set_Default_Font("DejaVuSansMono.ttf", 8); */
  /* AOD.AOD.Initialize_Console(1, SDL_SCANCODE_GRAVE, ""); */
  /* AOD.AOD.Set_BG_Colour(.08, .08, .095); */

  /* AOD.console.ConsEg.cursor.Set_Sprite */
}

int main () {
  Init();
  static import AOD.AOD;
  AOD.AOD.Run();
  writeln("Ending program");
  readln();
  return 0;
}
