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
    import std.conv : to; 
    import derelict.util.exception;
    import std.stdio;
    writeln("AOD@Realm.d@Initialize Initializing Art of Dwarficorn engine");
    writeln("AOD@Realm.d@Initialize Loading external libraries");
    try {
      DerelictGL3.load();
    } catch ( DerelictException de ) {
      writeln("\n----------------------------------------------------------\n");
      writeln("Failed to load DerelictGL3: "  ~ to!string(de));
      writeln("\n----------------------------------------------------------\n");
    }
    try {
      DerelictGL.load();
    } catch ( DerelictException de ) {
      writeln("\n----------------------------------------------------------\n");
      writeln("Failed to load DerelictGL: "  ~ to!string(de));
      writeln("\n----------------------------------------------------------\n");
    }
    try {
      DerelictSDL2.load("SDL2.dll", SharedLibVersion(2, 0, 2));
    } catch ( DerelictException de ) {
      writeln("\n----------------------------------------------------------\n");
      writeln("Failed to load DerelictSDL2: " ~ to!string(de));
      writeln("\n----------------------------------------------------------\n");
    }
    try {
      DerelictIL.load("DevIL.dll");
    } catch ( DerelictException de ) {
      writeln("\n----------------------------------------------------------\n");
      writeln("Failed to load DerelictIL: "   ~ to!string(de));
      writeln("\n----------------------------------------------------------\n");
    }
    try {
      DerelictILU.load("ILU.dll");
    } catch ( DerelictException de ) {
      writeln("\n----------------------------------------------------------\n");
      writeln("Failed to load DerelictILU: "  ~ to!string(de));
      writeln("\n----------------------------------------------------------\n");
    }
    try {
      DerelictILUT.load("ILUT.dll");
    } catch ( DerelictException de ) {
      writeln("\n----------------------------------------------------------\n");
      writeln("Failed to load DerelictILUT: " ~ to!string(de));
      writeln("\n----------------------------------------------------------\n");
    }
    try {
      DerelictFT.load("freetype265.dll");
    } catch ( DerelictException de ) {
      writeln("\n---------------------------------------------------\n");
      writeln("Failed to load DerelictFT: "   ~ to!string(de));
      writeln("\n---------------------------------------------------\n");
    }
    try {
      import derelict.openal.al;
      DerelictAL.load();
    } catch ( DerelictException de ) {
      writeln("--------------------------------------------------------------");
      writeln("Error initializing derelict-OpenAL library: " ~ to!string(de));
      writeln("--------------------------------------------------------------");
    }
    try {
      import derelict.vorbis.vorbis;
      DerelictVorbis.load("libvorbis-0.dll");
    } catch ( DerelictException de ) {
      writeln("--------------------------------------------------------------");
      writeln("Error initializing DerelictVorbis library: " ~ to!string(de));
      writeln("--------------------------------------------------------------");
    }

    try {
      import derelict.vorbis.file;
      DerelictVorbisFile.load("libvorbisfile-3.dll");
    } catch ( DerelictException de ) {
      writeln("--------------------------------------------------------------");
      writeln("Error initializing DerelictVorbisFil library: " ~ to!string(de));
      writeln("--------------------------------------------------------------");
    }

    writeln("AOD@Realm.d@Initialize Initializing SDL");
    SDL_Init ( SDL_INIT_EVERYTHING );

    writeln("Creating OpenGL Context");
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 2);
    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
    SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE,  24);

    writeln("AOD@Realm.d@Initialize Creating SDL Window");
    Engine.screen = SDL_CreateWindow(window_name, SDL_WINDOWPOS_UNDEFINED,
                                                  SDL_WINDOWPOS_UNDEFINED,
                                                  window_width, window_height,
                                                  SDL_WINDOW_OPENGL );
    import std.conv : to;
    if ( Engine.screen is null ) {
      throw new Exception("Error SDL_CreateWindow: "
                          ~ to!string(SDL_GetError()));
    }

    if ( SDL_GL_CreateContext(Engine.screen) is null ) {
      throw new Exception("Error SDL_GL_CreateContext: "
                          ~ to!string(SDL_GetError()));
    }

    try {
      DerelictGL3.reload();
      DerelictGL.reload();
    } catch ( DerelictException de ) {
      writeln("\n----------------------------------------------------------\n");
      writeln("Failed to reload DerelictGL3: " ~ to!string(de));
      writeln("\n----------------------------------------------------------\n");
    }

    writeln("AOD@Realm.d@Initialize Reloading GL3");

    writeln("Setting glShadeModel");
    glShadeModel(GL_SMOOTH);
    writeln("Enabling GL_TEXTURE2D and GL_BLEND");
    glEnable(GL_TEXTURE_2D);
    glEnable(GL_BLEND);
    if ( icon != "" ) {
      writeln("Loading window icon");
      SDL_Surface* ico = SDL_LoadBMP(icon);
      SDL_SetWindowIcon(Engine.screen, ico);
    }

    writeln("glClearDepth");
    glClearDepth(1.0f);
    writeln("glPolygonMode");
    glPolygonMode(GL_FRONT, GL_FILL);
    writeln("glShadeModel");
    glShadeModel(GL_FLAT);
    writeln("glHint");
    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST);
    writeln("glDepthFunc");
    glDepthFunc(GL_LEQUAL);
    writeln("glEnable");
    glEnable(GL_DEPTH_TEST);
    writeln("glEnable");
    glEnable(GL_BLEND);
    writeln("glBlendFunc");
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    writeln("glMatrixMode");
    glMatrixMode(GL_PROJECTION);
    writeln("glEnable");
    glEnable(GL_ALPHA);

    writeln("glLoadIdentity");
    glLoadIdentity();
    
    writeln("glOrtho");
    glOrtho(0, window_width, window_height, 0, 0, 1);

    glMatrixMode(GL_MODELVIEW);
    writeln("glDisable");
    glDisable(GL_DEPTH_TEST);
    writeln("glMatrixMode");
    glMatrixMode(GL_MODELVIEW);
    { // others
      writeln("Initializing sounds core");
      Debug_Output("Initializing Sounds Core");
      SoundEng.Set_Up();

      Sounds.Play_Song( Sounds.Load_Song("assets/test-song.ogg") );
      Sounds.Clean_Up();

      Debug_Output("Initializing Font Core");
      TextEng.Font.Init();
      /* objs_to_rem = []; */
      /* bg_red   = 0; */
      /* bg_blue  = 0; */
      /* bg_green = 0; */
    }
    writeln("AOD@Realm.d@Initialize Finalized initializing AOD main core");
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
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnable(GL_TEXTURE_2D);

    float off_x = Camera.R_Origin_Offset().x,
          off_y = Camera.R_Origin_Offset().y;

    static GLubyte[6] index = [ 0,1,2, 1,2,3 ];

    // --- objects

    foreach ( az ; objects )
    foreach ( lz ; az ) {
      if ( !lz.R_Is_Visible() ) continue;
      auto position = lz.R_Position(),
           size      = lz.R_Size();
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
        glVertexPointer   (2, GL_FLOAT, 0, Entity.Vertices.ptr);
        glTexCoordPointer(2, GL_FLOAT, 0, lz.R_UV_Array().ptr);
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_BYTE, index.ptr);
        glLoadIdentity();
      glPopAttrib();
      glPopMatrix();
    }


    // ---- texts
    foreach ( i; 0 .. text.length ) {
      auto tz = text[i];
      if ( !tz.R_Visible() ) continue;
      if ( !tz.R_FT_Font() ) {
        Debug_Output("Font face uninitialized for " ~ tz.R_Font());
      }
    
      string t_str = tz.R_Str();
      import std.stdio : writeln;
      /* writeln("Rendering " ~ t_str ~ " @ " ~ cast(string)tz.R_Position()); */

      glPushMatrix();
        glTranslatef(tz.R_Position().x, tz.R_Position().y, 0);
        glListBase(tz.R_FT_Font().R_Character_List());
        glCallLists(t_str.length, GL_UNSIGNED_BYTE, t_str.ptr);
      glPopMatrix();
    }


    // ---- console
    static import AOD.console;
    if ( AOD.console.console_open ) {
      foreach ( tz; AOD.console.ConsEng.console_text ) {
        string t_str = tz.R_Str();

        glPushMatrix();
          glTranslatef(tz.R_Position().x, tz.R_Position().y, 0);
          glListBase(tz.R_FT_Font().R_Character_List());
          glCallLists(t_str.length, GL_UNSIGNED_BYTE, t_str.ptr);
        glPopMatrix();
      }
    }


    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisableClientState(GL_TEXTURE_2D);


    SDL_GL_SwapWindow(Engine.screen);
  }
}
