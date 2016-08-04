module AOD.realm;

import derelict.opengl3.gl3;
import derelict.opengl3.gl;
import derelict.sdl2.sdl;
import derelict.devil.il;
import derelict.devil.ilu;
import derelict.devil.ilut;
import derelict.freetype.ft;
import AOD.AOD;
import AOD.entity;
import AOD.text;
import AOD.console;
import AOD.sound;
import Camera = AOD.camera;

class Realm {
  Entity[][] objects;
  Text[] text;

  Entity[] objs_to_rem;

  GLfloat bg_red, bg_blue, bg_green;
public:
  this(int window_width, int window_height,
       immutable(char)* window_name, immutable(char)* icon = "") {
    Debug_Output("Initializing SDL");
    DerelictGL3.load();
    DerelictSDL2.load(SharedLibVersion(2, 0, 2));
    DerelictIL.load();
    DerelictILU.load();
    DerelictILUT.load();
    DerelictFT.load();

    SDL_Init ( SDL_INIT_EVERYTHING );

    Engine.screen = SDL_CreateWindow(window_name, SDL_WINDOWPOS_UNDEFINED,
                                                  SDL_WINDOWPOS_UNDEFINED,
                                                  window_width, window_height,
                                                  SDL_WINDOW_OPENGL |
                                                  SDL_WINDOW_SHOWN);
    DerelictGL3.reload();
    import std.conv : to;
		if ( SDL_GL_SetAttribute( SDL_GL_CONTEXT_MAJOR_VERSION, 2 ) == -1 )
			Output("Error CONTEXT_MAJOR: " ~ to!string(SDL_GetError()));
		if ( SDL_GL_SetAttribute( SDL_GL_CONTEXT_MINOR_VERSION, 1 ) == -1 )
			Output("Error CONTEXT_MINOR: " ~ to!string(SDL_GetError()));
		if ( SDL_GL_CreateContext( Engine.screen ) is null ) {
			Output("Error window context: " ~ to!string(SDL_GetError()));
		}
		if ( SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1) == -1 )
			Output("Error DOUBLEBUFFER: " ~ to!string(SDL_GetError()));
		if ( SDL_GL_SetAttribute(SDL_GL_ALPHA_SIZE, 8) == -1 )
			Output("Error ALPHA_SIZE: " ~ to!string(SDL_GetError()));
		//glShadeModel(GL_SMOOTH);
		glEnable(GL_TEXTURE_2D);
		glEnable(GL_BLEND);
		if ( icon != "" ) {
			SDL_Surface* ico = SDL_LoadBMP(icon);
			SDL_SetWindowIcon(Engine.screen, ico);
		}

		glClearDepth(1.0f);
		glPolygonMode(GL_FRONT, GL_FILL);
		/* glShadeModel(GL_FLAT); */
		/* glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST); */
		glDepthFunc(GL_LEQUAL);
		glEnable(GL_DEPTH_TEST);
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

		/* glMatrixMode(GL_PROJECTION); */
		glEnable(GL_ALPHA);

		/* glLoadIdentity(); */
		
		/* glOrtho(0, window_width, window_height, 0, 0, 1); */

		//glMatrixMode(GL_MODELVIEW);
		glDisable(GL_DEPTH_TEST);
		/* glMatrixMode(GL_MODELVIEW); */
    { // others
      Debug_Output("Initializing Sounds Core");
      SoundEng.Set_Up();
      Debug_Output("Initializing Font Core");
      TextEng.Font.Init();
      objs_to_rem = [];
      bg_red	 = 0;
      bg_blue	= 0;
      bg_green = 0;
    }
	}

  void __Add(Entity o) {
    int l = o.R_Layer();
    if ( objects.length <= l ) objects.length = l+1;
    objects[l] ~= o;
  }
  void __Add(Text t) {
    text ~= t;
  }

  void __Remove(Entity o) {
    objs_to_rem ~= o;
  }
  void __Remove(Text t) {
    foreach ( i; 0 .. text.length ) {
      if ( text[i] == t ) {
        text = text[0 .. i] ~ text[i+1 .. $];
        return;
      }
    }
  }

  void Set_BG_Colours(GLfloat r, GLfloat g, GLfloat b) {
    bg_red = r;
    bg_green = g;
    bg_blue = g;
  }


  void Update() {
    // update objects
    foreach ( l ; objects )
    foreach ( a ; l )
      a.Update();

    // remove objects
    foreach ( rem_it; 0 .. objs_to_rem.length ) {
      int layer_it = objs_to_rem[rem_it].R_Layer();
      foreach ( obj_it; 0 .. objects[layer_it].length ) {
        if ( objects[layer_it][obj_it] is objs_to_rem[rem_it] ) {
          objects[layer_it][obj_it] = null;
          objects[layer_it] = objects[layer_it][0 .. obj_it] ~
                              objects[layer_it][obj_it+1 .. $];
          break;
        }
      }
    }
    objs_to_rem = [];
  }

  void Render() {
    glClear(GL_COLOR_BUFFER_BIT| GL_DEPTH_BUFFER_BIT);
    glClearColor(bg_red,bg_green,bg_blue,0);
    
    /* glEnableClientState(GL_VERTEX_ARRAY); */
    /* glEnableClientState(GL_TEXTURE_COORD_ARRAY); */
    glEnable(GL_TEXTURE_2D);

    float off_x = Camera.R_Origin_Offset().x,
          off_y = Camera.R_Origin_Offset().y;

    static GLubyte[6] index = [ 0,1,2, 1,2,3 ];

    // --- objects

    foreach ( az ; objects )
    foreach ( lz ; az ) {
      if ( !lz.R_Is_Visible() ) continue;
      auto position = lz.R_Position(),
           size		  = lz.R_Size();
      if ( !lz.R_Is_Static_Pos() ) {
        position.x -= off_x;
        position.y -= off_y;
      }
      if ((position.x + size.x/2 < 0 ||
           position.x - size.x/2 > Camera.R_Size().x ) ||
          (position.y + size.y/2 < 0 ||
           position.y - size.y/2 > Camera.R_Size().y) )
        continue;

      glPushMatrix();
      glPushAttrib(GL_CURRENT_BIT);
        if ( lz.R_Is_Coloured() )
          glColor4f(lz.R_Red(), lz.R_Green(), lz.R_Blue(), lz.R_Alpha());
        glBindTexture(GL_TEXTURE_2D, lz.R_Sprite_Texture());
        auto origin = lz.R_Origin();
        int fx = lz.R_Flipped_X() ? - 1 :  1 ,
            fy = lz.R_Flipped_Y() ?   1 :- 1 ;
        glTranslatef(position.x + origin.x*fx,
                     position.y + origin.y*fy, 0);
        glRotatef((lz.R_Rotation()*180.0)/3.14159f, 0, 0, 1);
        glTranslatef(-origin.x*fx,
                     -origin.y*fy, 0);
        glScalef (lz.R_Img_Size().x, lz.R_Img_Size().y, 1);

        import std.conv : to;
        glVertexPointer	 (2, GL_FLOAT, 0, Entity.Vertices);
        glTexCoordPointer(2, GL_FLOAT, 0, lz.R_UV_Array());
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_BYTE, index);
        glLoadIdentity();
      glPopAttrib();
      glPopMatrix();
    }
  }
}
