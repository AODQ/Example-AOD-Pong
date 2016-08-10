module Entity.Ball;
static import AOD;
import Data;

class Ball : AOD.PolyEntity {
public:
  float size;
  float speed = 1.0f;
  AOD.Vector direction = AOD.Vector(0.0f, 0.0f);

  this(float size) {
    this.size = size;

    Set_Vertices([
      AOD.Vector(-size / 2.0f, -size / 2.0f),
      AOD.Vector(size / 2.0f, -size / 2.0f),
      AOD.Vector(size / 2.0f, size / 2.0f),
      AOD.Vector(-size / 2.0f, size / 2.0f),
    ]);

    Set_Size(AOD.Vector(size, size), true);
  }

  override void Update() {
    direction.Normalize();

    velocity = direction * speed;
  }
}
