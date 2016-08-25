module Entity.Splashscreen;

static import AOD;


class Splash : AOD.Entity {
  float timer, timer_start, pop, time;
  AOD.SheetContainer[] img_fade,
                       img_pixl;
  AOD.SheetContainer reg;
  uint music;
  AOD.Entity add_after_done;
  uint ind = 0;
public:
  this(AOD.Entity _add_after_done) {
    add_after_done = _add_after_done;
    super();
    img_fade = [ AOD.SheetContainer("assets/menu/anim1/frame1.png"),
                 AOD.SheetContainer("assets/menu/anim1/frame2.png"),
                 AOD.SheetContainer("assets/menu/anim1/frame3.png"),
                 AOD.SheetContainer("assets/menu/anim1/frame4.png") ];
    img_pixl = [ AOD.SheetContainer("assets/menu/anim2/frame1.png"),
                 AOD.SheetContainer("assets/menu/anim2/frame2.png"),
                 AOD.SheetContainer("assets/menu/anim2/frame3.png"),
                 AOD.SheetContainer("assets/menu/anim2/frame4.png"),
                 AOD.SheetContainer("assets/menu/anim2/frame5.png"),
                 AOD.SheetContainer("assets/menu/anim2/frame6.png"),
                 AOD.SheetContainer("assets/menu/anim2/frame7.png"),
                 AOD.SheetContainer("assets/menu/anim2/frame8.png"),
                 AOD.SheetContainer("assets/menu/anim2/frame9.png"),
                 AOD.SheetContainer("assets/menu/anim2/frame10.png"),
                 AOD.SheetContainer("assets/menu/anim2/frame11.png"),
                 AOD.SheetContainer("assets/menu/anim2/frame12.png"),
                 AOD.SheetContainer("assets/menu/anim2/frame13.png") ];
    Set_Sprite(img_fade[0]);
    Set_Position(AOD.R_Window_Width/2, AOD.R_Window_Height/2);
    Set_Colour(1, 1, 1, 1.0);
    timer_start = (12500.0f/AOD.R_MS());
    timer = 8.5f;
    time = 0.0f;
    pop = 0.0f;
    ind = 0;
    uint tid = AOD.Load_Sound("assets/menu/Smilecythe- BulkherPlatoon.ogg");
    music = AOD.Play_Sound(tid);
    Set_Visible(false);
  }

  uint stage = 0, stage_it = 0;
  override void Update() {
    import std.math;
    import std.conv;
    import std.stdio;
    // -- frames --
    ++ time;
    Set_Visible(true);
    if ( ++ pop <= 1550.0/AOD.R_MS() )
      Set_Visible(false);
    if ( ind < img_fade.length )
      Set_Sprite(img_fade[ind]);
    else
      Set_Sprite(img_pixl[ind-img_fade.length]);
    if ( R_Visible ) {
      if ( stage == 0 ) {
        if ( ++ stage_it >= (50.0f/AOD.R_MS) ) {
          stage_it = 0;
          /// ----- debug ----
          import std.stdio : writeln;
          import std.conv : to;
          writeln("inc: " ~ to!string(ind));
          /// ----- debug ----
          if ( ++ ind >= img_fade.length ) {
            stage = 1;
            ind = cast(uint)img_fade.length - 1;
          }
        }
      } else if ( stage == 1 ) {
        /// ----- debug ----
        import std.stdio : writeln;
        import std.conv : to;
        /// ----- debug ----
        if ( time >= 4100.0/AOD.R_MS() ) {
          stage = 2;
          stage_it = 0;
          ind = 4;
        }
      } else if ( stage == 2 ) {
        if ( ++ stage_it >= (50.0f/AOD.R_MS()) ) {
          stage_it = 0;
          if ( ++ ind - cast(uint)img_fade.length >= img_pixl.length ) {
            ind = cast(uint)img_fade.length - 1;
            stage = 3;
          }
        }
      } else if ( stage == 3 ) {
        if ( time >= 5800.0/AOD.R_MS() ) {
          stage = 4;
          stage_it = 0;
          ind = cast(uint)AOD.Util.R_Rand(0, cast(int)img_pixl.length) +
                                   cast(uint)img_fade.length;
          time = 0;
        }
      } else if ( stage == 4 ) {
        if ( ++ stage_it >= (50.0f/AOD.R_MS) ) {
          if ( ++time >= 8 ) {
            stage = 5;
            /// ----- debug ----
            import std.stdio : writeln;
            import std.conv : to;
            writeln("ASDFASDF");
            /// ----- debug ----
            ind = cast(uint)img_fade.length - 1;
          } else {
            stage_it = 0;
            ind = cast(uint)AOD.Util.R_Rand(0, cast(int)img_pixl.length) +
                                     cast(uint)img_fade.length;
          }
        }
      }
    }
    // -- fade --
    timer = pow(timer, 1.0020f);
    Set_Colour(1, 1, 1, 1 - timer/timer_start);
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
