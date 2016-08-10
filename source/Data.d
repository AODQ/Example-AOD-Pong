module Data;
static import AOD;

class Image_Data {
public: static:
  AOD.SheetContainer boss;

  void Initialize() {
    boss = AOD.SheetContainer("assets/debug-box.png");
  }
}
