import derelict.opengl3.gl3;
import derelict.sdl2.sdl;
import std.stdio;

void Render_Screen(SDL_Window* win) {
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  glClearColor(0, 0, 0, 0);

  SDL_GL_SwapWindow(win);
}
static import AOD.entity;

class Test_Object : AOD.entity.Entity {
  
public:
  this() {
    super();
    Set_Size(32, 32);
    static import AOD.image;
    Set_Sprite(AOD.image.Load_Image("assets/AOD.png"));
  }

  override void Update() {
    import AOD.vector;
    Set_Position(Vector(300, 250));
    writeln("Updating position to " ~ cast(string)R_Position());
    writeln("Updating position to " ~ cast(string)R_Position());
  }
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
  AOD.text.Text.Set_Default_Font("assets/DejaVuSansMono.ttf", 8);
  AOD.AOD.Initialize_Console(1, SDL_SCANCODE_GRAVE, "");
  AOD.AOD.Set_BG_Colour(.08, .08, .095);
  auto test_text = new AOD.text.Text(20, 20, "asdf");
  AOD.AOD.Add(test_text);
  writeln("Setting up test object");
  auto text_obj = new Test_Object();
  AOD.AOD.Add(text_obj);
}

int main () {
  Init();
  static import AOD.AOD;
  AOD.AOD.Run();
  writeln("Ending program");
  return 0;
}
