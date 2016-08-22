module Entity.Menu;
static import AOD;
import Data;
import std.string;
import derelict.sdl2.sdl;

class MenuEntity : AOD.Entity {
public:
	AOD.Text msg;
	
	this( AOD.Vector pos, int x, int y, string text, void function() click ) {
    Set_Sprite (Image_Data.meteor_large);
    Set_Size(AOD.Vector(x, y), true);
    Set_Position(pos);
    Set_Visible(1);
    Set_Colour(0.0, 0.0, 0.0);
    msg = new AOD.Text(cast(int)(pos.x - 15 ),
                       cast(int)(pos.y  ), text);
		on_click = click;
	}
	
	override void Update() {
    if (Clicked(0) || AOD.Input.keystate [ SDL_SCANCODE_SPACE ] ) {
			on_click();
      import Data;
      AOD.Play_Sound(Sound_Data.bg_music);
		}
	}
	
private:
	void function() on_click;
}
