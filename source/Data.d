module Data;
static import AOD;

class Image_Data {
public: static:
  AOD.SheetContainer paddle, ball;
  AOD.SheetRect meteor_large; // 64x64
  AOD.SheetRect[2] meteor_medium; // 32x32
  AOD.SheetRect[4] meteor_small; // 16x16
  AOD.SheetRect[8] meteor_tiny; // 8x8

  void Initialize() {
    paddle = AOD.SheetContainer("assets/paddle.png");
    ball   = AOD.SheetContainer("assets/ball.png");
    auto meteor = AOD.SheetContainer("assets/meteor.png");
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
      AOD.SheetRect(meteor, AOD.Vector(8,  0) ,AOD.Vector(8, 16)),
      AOD.SheetRect(meteor, AOD.Vector(8, 16) ,AOD.Vector(8, 32)),
      AOD.SheetRect(meteor, AOD.Vector(8, 32) ,AOD.Vector(8, 48)),
      AOD.SheetRect(meteor, AOD.Vector(8, 48) ,AOD.Vector(8, 64))
    ];
    meteor_medium = [
      AOD.SheetRect(meteor, AOD.Vector(24,  0), AOD.Vector(24, 32)),
      AOD.SheetRect(meteor, AOD.Vector(24, 32), AOD.Vector(24, 64))
    ];
    meteor_large = AOD.SheetRect(meteor, AOD.Vector(56, 0), AOD.Vector(56, 64));
  }
}
