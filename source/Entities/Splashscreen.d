module Entity.Splashscreen;

static import AOD;


class Splash : AOD.Entity {
  float timer, timer_start;
  AOD.SheetContainer img_fg;
  uint music;
  AOD.Entity add_after_done;
public:
  this(AOD.Entity _add_after_done) {
    add_after_done = _add_after_done;
    super();
    img_fg = AOD.SheetContainer("assets/menu/intro.png");
    Set_Sprite(img_fg);
    Set_Position(AOD.R_Window_Width/2, AOD.R_Window_Height/2);
    Set_Colour(1, 1, 1, 1.0);
    timer_start = (12500.0f/AOD.R_MS());
    timer = 8.5f;
    uint tid = AOD.Load_Sound("assets/menu/Smilecythe- BulkherPlatoon.ogg");
    music = AOD.Play_Sound(tid);
  }

  override void Update() {
    import std.math;
    timer = pow(timer, 1.0020f);
    Set_Colour(1, 1, 1, 1 - timer/timer_start);
    import derelict.sdl2.sdl;
    if ( timer >= timer_start*1.5f || AOD.Input.R_LMB()||
         AOD.Input.keystate[SDL_SCANCODE_SPACE]) {
      AOD.Set_BG_Colour(.08, .08, .095);
      AOD.Stop_Sound(music);
      AOD.Remove(this);
      if ( add_after_done !is null )
        AOD.Add(add_after_done);
      return;
    }
  }
}
