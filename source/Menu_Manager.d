module Menu_Manager;
static import AOD;
import Menu_Entity;

Menu_Entity [][] menus = [[new Menu_Entity(AOD.Vector(100, 100), 200, 50, "play", &play)]];
int screen = 0;

void render() {
	foreach (Menu_Entity m; menus[screen]) {
		AOD.Add(m);
		AOD.Add(m.msg);
	}
}

void clear() {
	foreach (m; menus[screen]) {
		AOD.Remove(m);
		AOD.Remove(m.msg);
	}
}

//Initial menu
void play() {
  clear();
  import Data;
  Image_Data.Initialize();
  static import Game_Manager;
  import Entity.Asteroid;
  Game_Manager.Add(new Asteroid(Asteroid.Size.large));

  import Entity.Ball;
  auto ball = new Ball(10);
  Game_Manager.Add(ball);

  import Entity.Paddle;
  Game_Manager.Add(new Paddle(100, ball));
}

void credits() {
	//Dumb intro-esque effects???
}

void keys() {
	screen = 1;
	clear();
	render();
}

void quit() {
	
}

//all other menus
void back() {
	screen = 0;
}

//keys