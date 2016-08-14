module Entity.Ball;
static import AOD;
static import Game_Manager;
import Data;
import std.math;

class Ball : AOD.PolyEntity {
  float speed;
  float default_size;
  int speed_timer, size_timer;
  static immutable(float) Default_speed = 5.0f;
public:
  AOD.Vector direction = AOD.Vector(0.0f, 0.0f);

  void Set_Ball_Speed(float _speed, int _speed_timer) {
    speed = _speed;
    speed_timer = _speed_timer;
  }

  void Set_Ball_Size(float _size, int _size_timer) {
    Set_Size(AOD.Vector(_size, _size));
    size_timer = _size_timer;
  }

  this(float size) {
    layer = Layer_Data.Ball;
    default_size = size;
    Set_Size(AOD.Vector(size, size));

    Set_Sprite(Image_Data.ball);

    Set_Vertices([
      AOD.Vector(-size / 2.0f, -size / 2.0f),
      AOD.Vector( size / 2.0f, -size / 2.0f),
      AOD.Vector( size / 2.0f,  size / 2.0f),
      AOD.Vector(-size / 2.0f,  size / 2.0f),
    ]);

    Set_Size(AOD.Vector(size, size), true);
    speed = Default_speed;
  }

  float R_Default_Speed() { return Default_speed; }
  float R_Default_Size()  { return default_size;  }
  float R_Speed()         { return speed;         }

  override void Update() {
    // -- upgrade management --
    if ( speed_timer > 0 && --speed_timer == 0 ) {
      speed = Default_speed;
    }
    if ( size_timer  > 0 && --size_timer  == 0 ) {
      Set_Size(AOD.Vector(default_size, default_size));
    }

    // -- velocity/collision --
    direction.Normalize();

    velocity = direction * speed;

    if ( position.x - size.x / 2.0f + velocity.x < 0 ||
         position.x + size.x / 2.0f + velocity.x > AOD.R_Window_Width() ) {
      direction.x = -direction.x;
    }

    if ( position.y - size.x / 2.0f + velocity.y < 0 ) {
      direction.y = -direction.y;
    }

    static int coll_timer = 0;

    if ( coll_timer == 0 ) {
      auto col = Collision(Game_Manager.paddle, velocity);
      if ( col.will_collide ) {
        Add_Position(col.translation);
        direction.x = (position.x - Game_Manager.paddle.R_Position.x)
                      / Game_Manager.paddle.R_Width();
        direction.y = -sqrt(1-direction.x*direction.x);
        coll_timer = 16;
      }
      foreach ( asteroid; Game_Manager.asteroids ) {
        col = Collision(asteroid, velocity);
        if ( col.will_collide ) {
          direction *= -1;
          Game_Manager.Remove(asteroid);
          coll_timer = 16;
          break;
        }
      }
    } else -- coll_timer;
  }
}
