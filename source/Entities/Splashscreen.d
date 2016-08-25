module Entity.Splashscreen;

static import AOD;


class Splash : AOD.Entity {
  float timer, timer_start, pop;
  AOD.SheetContainer[] img_fg;
  uint music;
  AOD.Entity add_after_done;
  uint ind = 0;
public:
  this(AOD.Entity _add_after_done) {
    add_after_done = _add_after_done;
    super();
    img_fg ~= AOD.SheetContainer("assets/menu/intro.png"),
              AOD.SheetContainer("assets/menu/intro.png"),
              AOD.SheetContainer("assets/menu/intro.png"),
              AOD.SheetContainer("assets/menu/intro.png");
    Set_Sprite(img_fg[0]);
    Set_Position(AOD.R_Window_Width/2, AOD.R_Window_Height/2);
    Set_Colour(1, 1, 1, 1.0);
    timer_start = (12500.0f/AOD.R_MS());
    timer = 8.5f;
    pop = 0.0f;
    ind = 0;
    uint tid = AOD.Load_Sound("assets/menu/Smilecythe- BulkherPlatoon.ogg");
    music = AOD.Play_Sound(tid);
    Set_Visible(false);
  }

  override void Update() {
    import std.math;
    import std.conv;
    import std.stdio;
    timer = pow(timer, 1.0020f);
    if ( ++ pop <= 1550.0/AOD.R_MS() )
      Set_Visible(false);
    Set_Colour(1, 1, 1, 1 - timer/timer_start);
    Set_Sprite(img_fg[ind]);
    if ( ++ ind >= img_fg.length ) ind = 0;
    import derelict.sdl2.sdl;
    if ( timer >= timer_start*1.5f || AOD.Input.R_LMB()||
         AOD.Input.keystate[SDL_SCANCODE_SPACE]) {
      AOD.Set_BG_Colour(.08, .08, .095);
      AOD.Stop_Sound(music);
      AOD.Remove(this);
      AOD.Set_FPS_Display(new AOD.Text(20, 460, ""));
      if ( add_after_done !is null )
        AOD.Add(add_after_done);
      return;
    }
  }
}
