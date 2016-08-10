module Data;
static import AOD;

enum Layer_Data {
  Asteroid = 49,
  Paddle   = 50,
  Ball     = 51
}

class Image_Data {
public: static:
  AOD.SheetContainer paddle, ball;
  AOD.SheetRect    meteor_large; // 64x64
  AOD.SheetRect[2] meteor_medium; // 32x32
  AOD.SheetRect[4] meteor_small; // 16x16
  AOD.SheetRect[8] meteor_tiny; // 8x8
  AOD.SheetRect[4] upgrades;

  void Initialize() {
    paddle       = AOD.SheetContainer("assets/paddle.png"   ) ;
    ball         = AOD.SheetContainer("assets/ball.png"     ) ;
    auto meteor  = AOD.SheetContainer("assets/meteor.png"   ) ;
    auto upgrade = AOD.SheetContainer("assets/upgrades.png" ) ;
    meteor_tiny = [
      AOD.SheetRect(meteor, AOD.Vector(0,  0), AOD.Vector(8,  8)),
      AOD.SheetRect(meteor, AOD.Vector(0,  8), AOD.Vector(8, 16)),
      AOD.SheetRect(meteor, AOD.Vector(0, 16), AOD.Vector(8, 24)),
      AOD.SheetRect(meteor, AOD.Vector(0, 24), AOD.Vector(8, 32)),
      AOD.SheetRect(meteor, AOD.Vector(0, 32), AOD.Vector(8, 40)),
      AOD.SheetRect(meteor, AOD.Vector(0, 40), AOD.Vector(8, 48)),
      AOD.SheetRect(meteor, AOD.Vector(0, 48), AOD.Vector(8, 56)),
      AOD.SheetRect(meteor, AOD.Vector(0, 56), AOD.Vector(8, 64))
    ];
    meteor_small = [
      AOD.SheetRect(meteor, AOD.Vector(8,  0) ,AOD.Vector(24, 16)),
      AOD.SheetRect(meteor, AOD.Vector(8, 16) ,AOD.Vector(24, 32)),
      AOD.SheetRect(meteor, AOD.Vector(8, 32) ,AOD.Vector(24, 48)),
      AOD.SheetRect(meteor, AOD.Vector(8, 48) ,AOD.Vector(24, 64))
    ];
    meteor_medium = [
      AOD.SheetRect(meteor, AOD.Vector(24,  0), AOD.Vector(56, 32)),
      AOD.SheetRect(meteor, AOD.Vector(24, 32), AOD.Vector(56, 64))
    ];
    meteor_large = AOD.SheetRect(meteor, AOD.Vector(56,   0),
                                         AOD.Vector(120, 64));
    upgrades = [
      AOD.SheetRect(upgrade, AOD.Vector( 0,  0), AOD.Vector( 32,  32)),
      AOD.SheetRect(upgrade, AOD.Vector( 0, 32), AOD.Vector( 32,  64)),
      AOD.SheetRect(upgrade, AOD.Vector( 0, 64), AOD.Vector( 32,  96)),
      AOD.SheetRect(upgrade, AOD.Vector( 0, 96), AOD.Vector( 32, 128))
    ];
  }
}
