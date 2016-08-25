module Entity.Splashscreen;

static import AOD;


class Splash : AOD.Entity {
  float timer, timer_start, pop, time;
  enum IType {
    Fade, Pixel1, Pixel2, Pixel3
  };
  AOD.SheetContainer[][] img;
  uint[IType.max+1] img_start, img_stages;
  AOD.SheetContainer reg;
  uint music;
  AOD.Entity add_after_done;
  uint ind = 0;
public:
  this(AOD.Entity _add_after_done) {
    add_after_done = _add_after_done;
    super();
    auto commands = AOD.ClientVars.commands;
    img = [
       [ AOD.SheetContainer("assets/menu/anim1/frame1.png"  ) ,
         AOD.SheetContainer("assets/menu/anim1/frame2.png"  ) ,
         AOD.SheetContainer("assets/menu/anim1/frame3.png"  ) ,
         AOD.SheetContainer("assets/menu/anim1/frame4.png"  ) ],
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
         AOD.SheetContainer("assets/menu/anim2/frame13.png" ) ],
       [ AOD.SheetContainer("assets/menu/anim4/frame1.png"  ) ,
         AOD.SheetContainer("assets/menu/anim4/frame2.png"  ) ,
         AOD.SheetContainer("assets/menu/anim4/frame3.png"  ) ,
         AOD.SheetContainer("assets/menu/anim4/frame4.png"  ) ],
       [ AOD.SheetContainer("assets/menu/anim5/frame1.png"  ) ,
         AOD.SheetContainer("assets/menu/anim5/frame2.png"  ) ,
         AOD.SheetContainer("assets/menu/anim5/frame3.png"  ) ,
         AOD.SheetContainer("assets/menu/anim5/frame4.png"  ) ]
    ];
    img_start = [ 0, 0, 0, 0 ];
    img_stages = [ 0, 0, 0, 0 ];
    uint cnt = 0;
    foreach ( c; commands ) {
      import std.conv : to;
      import std.stdio;
      img_start[c.key[4] - '1'] = cast(uint)(to!float(c.value)/AOD.R_MS());
      img_stages[c.key[4] - '1'] = cnt;
      writeln("VAL: " ~ c.value ~ ", key: " ~ to!string(c.key[4] - '1'));
      ++ cnt;
    }
    foreach ( s; img_start ) {
      /// ----- debug ----
      import std.stdio : writeln;
      import std.conv : to;
      writeln("TIMES: " ~ to!string(s));
      /// ----- debug ----
    }
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
    if ( img_ind == -1 )
      Set_Sprite(img[0][3]);
    else
      Set_Sprite(img[img_stage][img_ind]);
    Set_Visible(false);
    if ( stage > 0 || (stage == 0 && time >= img_start[0]) ) {
      Set_Visible(true);
      if ( stage < img_start.length && time >= img_start[stage] ) {
        writeln(" ( " ~ to!string(img_ind) ~ " ) ");
        if ( ++ stage_it >= 100.0f/AOD.R_MS() ) {
          stage_it = 0;
          if ( ++ ind >= img[stage].length + 1 ) {
            img_ind = -1;
            ind = 0;
            // -- DEBUG START
            import std.stdio : writeln;
            import std.conv : to;
            writeln("STAGE: " ~ to!string(stage));
            // -- DEBUG END
            ++ stage;
            img_stage = img_stages[stage];
          } else
            img_ind = ind-1;
          writeln(" ( " ~ to!string(img_ind) ~ " ) ");
        }
      } else {
        img_ind = -1;
      }
    }
    // -- fade --
    timer = pow(timer, 1.0020f);
    Set_Colour(1, 1, 1, 1 - timer/timer_start);
    import derelict.sdl2.sdl;
    if ( timer >= timer_start*0.2f ) {
      import std.math;
      float t = abs(((timer_start*0.2f) - timer)/((timer_start*0.2f)))*2;
      if ( t <= 5.0f ) {
        img_stage = 0;
        img_ind = cast(uint)(4 - t);
        if ( img_ind > 3 ) img_ind = 3;
        if ( img_ind < 0 ) img_ind = 3;
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
