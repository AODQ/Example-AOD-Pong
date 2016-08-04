module AOD.camera;

import AOD.AOD;
import AOD.vector;

private Vector position;
private Vector size;

void Set_Position(const ref Vector pos) {
  position = pos;
}

void Set_Position(float x, float y) {
  position = new Vector(x, y);
}

void Set_Size(const ref Vector siz) {
  if ( siz.x <= 0 || siz.y <= 0 ) return;
  size = siz;
}

void Set_Size(float x, float y) {
  if ( x <= 0 || y <= 0 ) return;
  Camera.size = new AODUtil.Vector(x, y);
}

Vector R_Size()     { return size;     }
Vector R_Position() { return position; }
