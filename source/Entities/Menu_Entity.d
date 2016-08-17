module Entity.Menu;
static import AOD;
import Data;
import std.string;

class MenuEntity : AOD.Entity {
public:
	AOD.Text msg;
	
	this( AOD.Vector pos, int x, int y, string text, void function() click ) {
    Set_Sprite (Image_Data.meteor_large);
    Set_Size(AOD.Vector(x, y), true);
    Set_Position(pos);
    Set_Visible(1);
		msg = new AOD.Text((cast(int)(pos.x-x/2.0f+8)),
                       (cast(int)(pos.y-y/2.0f+8)), text);
		on_click = click;
	}
	
	override void Update() {
    if (Clicked()) {
			on_click();
		}
	}
	
private:
	void function() on_click;
}