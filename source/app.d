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
    Set_Is_Static_Pos(true);
    Set_Visible(true);
  }

  override void Update() {
    import AOD.vector, AOD.input;
    Set_Position(R_Mouse_X(0), R_Mouse_Y(0));
    import AOD.utility;
    if ( R_Rand(0.0f, 100.0f) > 75.0f ) {
      import AOD.AOD;
      auto f = new Flykick();
      f.Set_Position(R_Position());
      AOD.AOD.Add(f);
    }
  }
}

static import AOD.image;

AOD.image.SheetContainer flykick_img;

class Flykick : AOD.entity.Entity {
public:
  this() {
    super();
    static bool loaded = false;
    if ( !loaded ) {
      loaded = true;
      flykick_img = AOD.image.Load_Image("assets/flyside.png");
      flykick_img.width  = 64;
      flykick_img.height = 64;
    }
    Set_Size(64, 64, true);
    Set_Sprite(flykick_img);
    Set_Is_Static_Pos(true);
    import AOD.utility;
    fx = R_Rand(-15.0f, 15.0f);
    fy = R_Rand(-15.0f, 15.0f);
  }

  float fx, fy;

  override void Update() {
    fx *= 0.91f;
    fy *= 0.898f;
    Add_Position(fx, fy);
    if ( fx <= 1f && fy <= 1f ) {
      static import AOD.AOD;
      AOD.AOD.Remove(this);
    }
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
  AOD.AOD.Initialize(16, "CYBER BUTCHER"); // 16 approx = 60 frames (1000/16)
  static import AOD.camera;
  import AOD.vector;
  writeln("app.d@Setting up camera");
  AOD.camera.Set_Size(Vector(AOD.clientvars.screen_width,
                             AOD.clientvars.screen_height));
  AOD.camera.Set_Position(AOD.clientvars.screen_width/2, 
                          AOD.clientvars.screen_height/2);
  static import AOD.text;
  writeln("app.d@Setting up text");
  AOD.text.Text.Set_Default_Font("assets/DejaVuSansMono.ttf", 13);
  AOD.AOD.Initialize_Console(1, SDL_SCANCODE_GRAVE, "");
  AOD.AOD.Set_BG_Colour(.08, .08, .095);
  writeln("Setting up test object");
  auto test_obj = new Test_Object();
  AOD.AOD.Add(test_obj);
  AOD.AOD.Engine.fps_display = new AOD.text.Text(20, 20, "");
  AOD.AOD.Add(AOD.AOD.Engine.fps_display);
  static import AOD.sound;
  AOD.sound.Sounds.Play_Song("assets/test-song.ogg");
}

int main () {
  Init();
  static import AOD.AOD;
  AOD.AOD.Run();
  writeln("Ending program");
  return 0;
}
