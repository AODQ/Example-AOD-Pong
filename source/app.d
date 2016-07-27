import derelict.opengl3.gl3;
import derelict.sdl2.sdl;

import render;

void main () {
  SDL_Window* window;
  SDL_GLContext gl_context;

  DerelictGL3.load();
  DerelictSDL2.load(SharedLibVersion(2, 0, 2));

  if ( SDL_Init( SDL_INIT_EVERYTHING ) == -1 )
    throw new Exception("SDL Init failed");
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
  SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3);

  window = SDL_CreateWindow("SDL2 OpenGL", 20, 20, 640, 480, SDL_WINDOW_OPENGL);
  gl_context = SDL_GL_CreateContext(window);

  DerelictGL3.reload();

  bool running = true;

  while ( running ) {
    SDL_Event event;
    while ( SDL_PollEvent(&event) ) {
      if ( event.type == SDL_QUIT ) running = false;
    }
    SDL_PumpEvents();

    Render_Screen(window);
  }

  SDL_DestroyWindow(window);
  SDL_Quit();
}
