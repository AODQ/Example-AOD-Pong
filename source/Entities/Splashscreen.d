module Entity.Splashscreen;

static import AOD;


class Splash : AOD.Entity {
  float timer, timer_start, pop, time;
  enum IType {
    Fade, Pixel1, Pixel2, Pixel3
  };
  AOD.SheetContainer[][] img;
  uint[IType.max+1] img_start;
  AOD.SheetContainer reg;
  uint music;
  AOD.Entity add_after_done;
  uint ind = 0;
public:
  this(AOD.Entity _add_after_done) {
    add_after_done = _add_after_done;
    super();
    img = [
       [ AOD.SheetContainer("assets/menu/anim1/frame1.png"  ) ,
         AOD.SheetContainer("assets/menu/anim1/frame2.png"  ) ,
         AOD.SheetContainer("assets/menu/anim1/frame3.png"  ) ,
         AOD.SheetContainer("assets/menu/anim1/frame4.png"  ) ],
       [ AOD.SheetContainer("assets/menu/anim5/frame1.png"  ) ,
         AOD.SheetContainer("assets/menu/anim5/frame2.png"  ) ,
         AOD.SheetContainer("assets/menu/anim5/frame3.png"  ) ,
         AOD.SheetContainer("assets/menu/anim5/frame4.png"  ) ],
       [ AOD.SheetContainer("assets/menu/anim4/frame1.png"  ) ,
         AOD.SheetContainer("assets/menu/anim4/frame2.png"  ) ,
         AOD.SheetContainer("assets/menu/anim4/frame3.png"  ) ,
         AOD.SheetContainer("assets/menu/anim4/frame4.png"  ) ],
       [ AOD.SheetContainer("assets/menu/anim2/frame1.png"  ) ,
         AOD.SheetContainer("assets/menu/anim2/frame2.png"  ) ,
         AOD.SheetContainer("assets/menu/anim2/frame3.png"  ) ,
         AOD.SheetContainer("assets/menu/anim2/frame4.png"  ) ,
         AOD.SheetContainer("assets/menu/anim2/frame5.png"  ) ,
         AOD.SheetContainer("assets/menu/anim2/frame6.png"  ) ,
         AOD.SheetContainer("assets/menu/anim2/frame7.png"  ) ,
         AOD.SheetContainer("assets/menu/anim2/frame8.png"  ) ,
         AOD.SheetContainer("assets/menu/anim2/frame9.png"  ) ,
         AOD.SheetContainer("assets/menu/anim2/frame10.png" ) ,
         AOD.SheetContainer("assets/menu/anim2/frame11.png" ) ,
         AOD.SheetContainer("assets/menu/anim2/frame12.png" ) ,
         AOD.SheetContainer("assets/menu/anim2/frame13.png" ) ]
    ];
    img_start = [
      cast(uint)(1400.0f/AOD.R_MS()),
      cast(uint)(2700.0f/AOD.R_MS()),
      cast(uint)(2900.0f/AOD.R_MS()),
      cast(uint)(4000.0f/AOD.R_MS())
    ];
    Set_Sprite(img[1][1]);
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

  uint stage = 0, stage_it = 0, img_stage, img_ind;
  bool fadeblack = false;
  override void Update() {
    if ( fadeblack ) {
      float dt = 0.01;
      time += dt;
      if ( time >= 1.00f ) {
        AOD.Set_BG_Colour(.08, .08, .095);
        AOD.Stop_Sound(music);
        AOD.Remove(this);
        AOD.Set_FPS_Display(new AOD.Text(20, 460, ""));
        if ( add_after_done !is null )
          AOD.Add(add_after_done);
      } else {
        AOD.Set_BG_Colour(1 - 0.92*time, 1 - 0.92*time, 1 - 0.905*time);
      }
      return;
    }
    import std.math;
    import std.conv;
    import std.stdio;
    // -- frames --
    ++ time;
    Set_Visible(true);
    if ( ++ pop <= 1400.0/AOD.R_MS() )
      Set_Visible(false);
    if ( img_ind == -1 )
      Set_Sprite(img[0][3]);
    else
      Set_Sprite(img[img_stage][img_ind]);
    if ( R_Visible ) {
      if ( stage < img_start.length && time >= img_start[stage] ) {
        if ( ++ stage_it >= 50.0f/AOD.R_MS() ) {
          stage_it = 0;
          if ( ++ ind >= img[stage].length ) {
            img_ind = -1;
            ind = 0;
            // -- DEBUG START
            import std.stdio : writeln;
            import std.conv : to;
            writeln("STAGE: " ~ to!string(stage));
            // -- DEBUG END
            ++ stage;
            img_stage = stage;
          } else
            img_ind = ind;
        }
      } else {
        if ( stage == img_start.length ) {
          if ( time >= 4570/AOD.R_MS() ) {
            if ( ++ stage_it >= 50.0f/AOD.R_MS() ) {
              stage_it = 0;
              do {
                img_stage = cast(uint)AOD.Util.R_Rand(0, img.length);
                img_ind =   cast(uint)AOD.Util.R_Rand(0, img[img_stage].length);
              } while ( (img_stage == 0 && img_ind ==  3) ||
                        (img_stage == 1 && img_ind ==  0) ||
                        (img_stage == 1 && img_ind == 12) );
              // -- DEBUG START
              import std.stdio : writeln;
              import std.conv : to;
              writeln("POLL: " ~ to!string(ind));
              // -- DEBUG END
              if ( ++ ind >= 3 ) {
                ind = 0;
                // -- DEBUG START
                import std.stdio : writeln;
                import std.conv : to;
                writeln("STAGE: " ~ to!string(stage));
                // -- DEBUG END
                ++ stage;
                img_ind = -1;
              }
            }
          }
        } else if ( stage == img_start.length+1 ) {
          if ( time >= 6100/AOD.R_MS() ) {
            if ( ++ stage_it >= 50.0f/AOD.R_MS() ) {
              stage_it = 0;
              do {
                img_stage = cast(uint)AOD.Util.R_Rand(0, img.length);
                img_ind =   cast(uint)AOD.Util.R_Rand(0, img[img_stage].length);
              } while ( (img_stage == 0 && img_ind ==  3) ||
                        (img_stage == 1 && img_ind ==  0) ||
                        (img_stage == 1 && img_ind == 12) );
              writeln("POLL");
              if ( ++ ind >= 5 ) {
                // -- DEBUG START
                import std.stdio : writeln;
                import std.conv : to;
                writeln("STAGE: " ~ to!string(stage));
                // -- DEBUG END
                ++ stage;
                img_ind = -1;
              }
            }
          }
        }
      }
    }
    // -- fade --
    timer = pow(timer, 1.0020f);
    Set_Colour(1, 1, 1, 1 - timer/timer_start);
    import derelict.sdl2.sdl;
    if ( timer >= timer_start*0.2f ) {
      import std.math;
      float t = abs(((timer_start*0.2f) - timer)/((timer_start*0.2f)))*2;
      // -- DEBUG START
      import std.stdio : writeln;
      import std.conv : to;
      writeln("T: " ~ to!string(t));
      // -- DEBUG END
      if ( t <= 5.0f ) {
        img_stage = 0;
        img_ind = cast(uint)(4 - t);
        if ( img_ind > 3 ) img_ind = 3;
        if ( img_ind < 0 ) img_ind = 0;
      }
    }
    if ( timer >= timer_start*1.5f || AOD.Input.R_LMB()||
         AOD.Input.keystate[SDL_SCANCODE_SPACE]) {
      fadeblack = true;
      time = 0;
      return;
    }
  }
}
