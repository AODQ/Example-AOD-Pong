module Entity.Paddle;
static import AOD;
import Data;
import Entity.Ball;
alias Vector = AOD.Vector;

class Paddle : AOD.PolyEntity {
private:
  bool key_left, key_right, key_ball_left, key_ball_right, key_launch;
  float ball_offset = 0.0f;
  Ball stored_ball;
  float width;
  immutable(float) Default_speed = 2.5f;
  float speed;
  int speed_timer;
public:
  void Set_Speed(float _speed, int _speed_timer) {
    speed = _speed;
    speed_timer = _speed_timer;
  }
  
  float R_Default_Speed() { return Default_speed; }

  this(float _width, Ball _stored_ball) {
    super();
    layer = Layer_Data.Paddle;
    speed = Default_speed;
    stored_ball = _stored_ball;
    this.width = _width;
    Set_Sprite(Image_Data.paddle);

    Set_Vertices([
      Vector(-width / 2.0f, -10.0f),
      Vector(-width / 2.0f,  10.0f),
      Vector( width / 2.0f,  10.0f),
      Vector( width / 2.0f, -10.0f),
    ]);
    Set_Sprite(Image_Data.paddle);
    Set_Size(Vector(width, 20.0f), true);
    Set_Position(Vector(cast(float) AOD.R_Window_Width()  /  2.0f,
                        cast(float) AOD.R_Window_Height() - 50.0f));
    stored_ball.Set_Position(position - Vector(0.0f, 10.0f +
                             stored_ball.R_Size().x));
  }

  void Add_Ball(Ball new_ball) in { assert(stored_ball is null); }
  body {
    stored_ball = new_ball;
  }

  override void Update() {
    // -- upgrades --
    if ( speed_timer < 0 && --speed_timer == 0 ) {
      speed = Default_speed;
    }

    // -- key binds --
    key_left = key_right = key_ball_left = key_ball_right = key_launch = false;
    float ball_size = stored_ball is null ? 0 : stored_ball.R_Size().x;

    foreach ( k; AOD.ClientVars.keybinds ) {
      if ( AOD.Input.keystate[ k.key ] ) {
        switch ( k.command ) {
          default           : break;
          case "left"       : key_left       = true; break;
          case "right"      : key_right      = true; break;
          case "ball_left"  : key_ball_left  = true; break;
          case "ball_right" : key_ball_right = true; break;
          case "launch"     : key_launch     = true; break;
        }
      }
    }
    
    // positioning
    velocity.x *= 0.6;

    if ( key_left ) {
      Add_Velocity(Vector(-speed, 0.0f));
    }
    if ( key_right ) {
      Add_Velocity(Vector(speed, 0.0f));
    }
    if ( key_ball_left ) {
      ball_offset -= 3.0f;
    }
    if ( key_ball_right ) {
      ball_offset += 3.0f;
    }

    // stop paddle at edges
    if ( position.x - width / 2.0f + velocity.x < 0 ) {
      position.x = width / 2.0f;
      velocity.x = 0;
    }
    else if ( position.x + width / 2.0f + velocity.x > 640 ) {
      position.x = cast(float) AOD.R_Window_Width() - width / 2.0f;
      velocity.x = 0;
    }

    // ball
    if ( ball_offset < -width / 2.0f + ball_size / 2.0f ) {
      ball_offset = -width / 2.0f + ball_size / 2.0f;
    }
    else if ( ball_offset > width / 2.0f - ball_size / 2.0f ) {
      ball_offset = width / 2.0f - ball_size / 2.0f;
    }

    if ( stored_ball !is null ) {
      stored_ball.Set_Position(position - Vector(0.0f, 15.0f)
          + velocity + Vector(ball_offset, 0.0f));

      if ( key_launch ) {
        stored_ball.direction = (stored_ball.R_Position() - position);
        stored_ball = null;
      }
    }

    /* if ( Collision(ball).collision ) { */
    /*   AOD.Output("Ball collided with paddle"); */
    /* } */
  }
}
