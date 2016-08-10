module Data;
static import AOD;

class Image_Data {
public: static:
  AOD.SheetContainer paddle;
  AOD.SheetContainer meteor_large; // 64x64
  AOD.SheetContainer[2] meteor_medium; // 32x32
  AOD.SheetContainer[4] meteor_small; // 16x16
  AOD.SheetContainer[8] meteor_tiny; // 8x8

  void Initialize() {
    // .. todo ..
  }
}
