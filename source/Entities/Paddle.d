module Entity.Paddle;
static import AOD;
import Data;

class Paddle : AOD.PolyEntity {
private:
  bool key_left, key_right, key_ball_left, key_ball_right, key_launch;
  Entity.Ball.Ball ball;
  bool launched = false;
  float ball_offset = 0.0f;

public:
  float width;
  float speed = 2.5f;

  this(float width, Entity.Ball.Ball ball) {
    super();

    this.ball = ball;
    this.width = width;

    Set_Vertices([
      AOD.Vector(-width / 2.0f, -20.0f),
      AOD.Vector(width / 2.0f, -20.0f),
      AOD.Vector(width / 2.0f, 20.0f),
      AOD.Vector(-width / 2.0f, 20.0f),
    ]);
    Set_Sprite(Image_Data.paddle);
    Set_Size(AOD.Vector(width, 20.0f), true);
    Set_Position(AOD.Vector(cast(float) AOD.R_Window_Width() / 2.0f, cast(float) AOD.R_Window_Height() - 50.0f));
    this.ball.Set_Position(this.position - AOD.Vector(0.0f, 10.0f + this.ball.size));
  }

  override void Update() {
    key_left = key_right = key_ball_left = key_ball_right = key_launch = false;

    // key binds
    foreach ( k; AOD.ClientVars.keybinds ) {
      if ( AOD.Input.keystate[ k.key ] ) {
        switch ( k.command ) {
          default: break;
          case "left":  key_left  = true; break;
          case "right": key_right = true; break;
          case "ball_left": key_ball_left = true; break;
          case "ball_right": key_ball_right = true; break;
          case "launch": key_launch = true; break;
        }
      }
    }

    // positioning
    velocity.x *= 0.6;

    if ( key_left ) {
      Add_Velocity(AOD.Vector(-speed, 0.0f));
    }
    if ( key_right ) {
      Add_Velocity(AOD.Vector(speed, 0.0f));
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
    if ( ball_offset < -width / 2.0f + ball.size / 2.0f ) {
      ball_offset = -width / 2.0f + ball.size / 2.0f;
    }
    else if ( ball_offset > width / 2.0f - ball.size / 2.0f ) {
      ball_offset = width / 2.0f - ball.size / 2.0f;
    }

    if ( !launched ) {
      ball.Set_Position(position - AOD.Vector(0.0f, 10.0f + ball.size) + velocity + AOD.Vector(ball_offset, 0.0f));

      if ( key_launch ) {
        launched = true;
        ball.direction = (ball.R_Position() - position);
      }
    }

    if ( Collision(ball).collision ) {
      //ball.direction = ball.R_Position() - position;

      AOD.Output("Ball collided with paddle");
    }

    if ( ball.R_Position().y + ball.size / 2.0f > AOD.R_Window_Height() ) {
      launched = false;
      ball_offset = 0.0f;
    }
  }
}