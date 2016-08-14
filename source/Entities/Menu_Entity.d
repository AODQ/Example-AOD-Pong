module Entity.Menu;
static import AOD;
import AODCore.text;
import std.string;

class MenuEntity : AOD.Entity {
public:
	AOD.Text msg;
	
	this( AOD.Vector pos, int x, int y, string text, void function() click ) {
		Set_Size(x,y);
		Set_Position(pos);
		msg = new AOD.Text(cast(int)(pos.x-x+4), cast(int)(pos.y-y+4), text);
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