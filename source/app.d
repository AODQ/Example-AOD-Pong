import derelict.opengl3.gl3;
import derelict.sdl2.sdl;
import std.stdio;

void Render_Screen(SDL_Window* win) {
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  glClearColor(0, 0, 0, 0);

  SDL_GL_SwapWindow(win);
}

int main () {
  import AOD = AOD.AOD;

  AOD.Initialize(640, 840, 60, "CYBER BUTCHER");

  writeln("Ending program");
  return 0;
}
