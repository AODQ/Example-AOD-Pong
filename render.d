module render;
import derelict.opengl3.gl3;
import derelict.sdl2.sdl;


void Render_Screen_Cec(SDL_Window* win) {
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  glClearColor(0, 0, 0, 0);

  SDL_GL_SwapWindow(win);
}
