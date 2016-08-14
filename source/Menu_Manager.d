module Menu_Manager;
static import AOD;
import Entity.Menu;

MenuEntity [][] menus;
int screen = 0;

void Create() {
	foreach (MenuEntity m; menus[screen]) {
		AOD.Add(m);
		AOD.Add(m.msg);
	}
}

void Destroy() {
	foreach (m; menus[screen]) {
		AOD.Remove(m);
		AOD.Remove(m.msg);
	}
}

//Initial menu
void play() {
  Destroy();
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
	Destroy();
	Create();
}

void quit() {
	
}

//all other menus
void back() {
	screen = 0;
}

//keys