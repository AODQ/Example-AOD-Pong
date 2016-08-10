import derelict.opengl3.gl3;
import derelict.sdl2.sdl;
import std.stdio;
static import AOD;

// This is the "standard" way to initialize the engine. My thought process is
// to immediately set up the console so we can receive errors as we initialize
// the AOD engine. Then afterwards we adjust the camera to center of screen
// and load the font & assign console key so we can start reading from the
// console. Everything else after is usually control configuration or debug
void Init () {
  writeln("app.d@Init Setting up console");
  AOD.Console.console_open = false;
  AOD.Console.Set_Console_Output_Type(AOD.Console.Type.Debug_In);
  AOD.Initialize(16, "CYBER BUTCHER", 640, 480);
  AOD.Camera.Set_Size(AOD.Vector(AOD.R_Window_Width(), AOD.R_Window_Height()));
  AOD.Camera.Set_Position(AOD.Vector(AOD.R_Window_Width() /2,
                                     AOD.R_Window_Height()/2));
  AOD.Text.Set_Default_Font("assets/DejaVuSansMono.ttf", 13);
  AOD.Console.Initialize(AOD.Console.Type.Debug_In);
  AOD.Set_BG_Colour(.08, .08, .095);
  // --- debug ---
  AOD.Set_FPS_Display(new AOD.Text(20, 20, ""));
  AOD.ClientVars.Load_Config();
}


void Game_Init () {
  static import Data;
  Data.Image_Data.Initialize();
  import Entity.Boss;
  auto pl = new Boss();
  AOD.Add(pl);
}

int main () {
  Init();
  Game_Init();
  AOD.Run();
  writeln("Ending program");
  return 0;
}
