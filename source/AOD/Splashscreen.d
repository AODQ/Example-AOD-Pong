module AODCore.Splashscreen;

static import AOD;


class Splash : AOD.Entity {
  int timer;
  AOD.Entity bg;
  AOD.SheetContainer img_fg;
public:
  this() {
    super();
    img_fg = AOD.SheetContainer("assets\\Images\\AOD\\splash_fg.png");
    Set_Sprite(img_fg);
    bg = new AOD.Entity();
    Set_Position(AOD.R_Window_Width/2, AOD.R_Window_Height/2);
    bg.Set_Position(AOD.R_Window_Width/2, AOD.R_Window_Height/2);
    bg.Set_Image_Size(AOD.Vector(AOD.R_Window_Width, AOD.R_Window_Height));
    bg.Set_Colour(.0, .0, .0);
    AOD.Add(bg);
    timer = cast(int)AOD.R_MS()*10;
  }

  /* override void Update() { */
  /*   if ( -- timer <= 0 ) { */
  /*     AOD.Remove(bg); */
  /*     AOD.Remove(this); */
  /*     return; */
  /*   } */
  /* } */
}
