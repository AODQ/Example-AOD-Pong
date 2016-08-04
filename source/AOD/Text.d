module AOD.text;

import AOD.AOD;
import AOD.utility;
import AOD.vector;
import AOD.console;

import derelict.opengl3.gl3;
import derelict.sdl2.sdl;
import derelict.freetype.ft;

import std.string;
import std.typecons : tuple;

static class TextEng {
  class Font {
    FT_Face face;
    GLuint[128] char_texture;
    GLuint char_lists;
    int width;
  public:
    static FT_Library FTLib;

    this(string file, int siz) {
      import File = std.file;
      import std.conv : to;
      if ( File.file.exists(file) ) {
        Debug_Output("font " ~ file ~ ": not found\n");
        return;
      }
      int comp = FT_New_Face(FTLib, file, 0, &face);
      if ( comp ) {
        Debug_Output("Could not load font " ~ file ~ ": " ~
          R_FT_Error_String(comp) ~ '\n');
        return;
      }
      if ( (comp = FT_Set_Pixel_Sizes(face, 0, siz)) ) {
        Debug_Output("Could not load font " ~ file + ": " ~
          R_FT_Error_String(comp));
      }

      glGenTextures( 128, char_texture );
      char_lists = glGenLists(128);

      for ( int i = 0; i != 128; ++ i ) {
        FT_UInt index = FT_Get_Char_Index(face, i);
        if ( FT_Load_Glyph(face, index, FT_LOAD_RENDER) ) {
          Debug_Output("Could not load char index "
                                   ~ to!string(i) ~ " for font " ~ file);
          continue;
        }
        if ( FT_Render_Glyph(face.glyph,
                            FT_Render_Mode_.FT_RENDER_MODE_NORMAL ) ) {
          Debug_Output("Failed to render char index "
                                    ~ to!string(i) ~ " for font " + file);
          continue;
        }

        FT_Glyph glyph;
        if ( FT_Get_Glyph ( face.glyph, &glyph ) ) {
          Debug_Output( "Get Glyph failed at index " ~
                                      to!string(i) ~ " for font " + file);
          continue;
        }
        if ( FT_Glyph_To_Bitmap( &glyph, ft_render_mode_normal, 0, 1) ) {
          Debug_Output( "Glyph to bitmap failed at char index " ~
                                    to!string(i) ~ " for font " ~ file);
          continue;
        }
        FT_BitmapGlyph bitmap_glyph = cast(FT_BitmapGlyph)glyph;

        FT_Bitmap map = bitmap_glyph.bitmap;

        //map.palette_mode = ILUT_PALETTE_MODE;

        int d = (face.glyph.metrics.height -
                 face.glyph.metrics.horiBearingY)>>6;

        int w = map.width*map.width,
            h = map.rows *map.rows;

        GLubyte[] data = new GLubyte[2 * w * h];

        for ( int x = 0; x != w; ++ x )
        for ( int y = 0; y != h; ++ y ) {
          data[2 * (x + y*w)    ] =
          data[2 * (x + y*w) + 1] =
            (x >= map.width || y >= map.rows ) ?
            0 : map.buffer[x + map.width*y];
        }

        glBindTexture(GL_TEXTURE_2D, char_texture[i]);
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glEnable(GL_BLEND);
        glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA, w, h, 0,
                      GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, data );

        data = [];
        glNewList(char_lists + i, GL_COMPILE );

          glBindTexture( GL_TEXTURE_2D, char_texture[i] );
          glPushMatrix();

            glTranslatef(face.glyph.bitmap_left, 0, 0);
            float x = cast(float)map.width/cast(float)w,
                  y = cast(float)map.rows /cast(float)h;
            int rows = -cast(int)map.rows;
            glBegin( GL_QUADS );
              glTexCoord2f( 0.f, y   ); glVertex2f( 0.f,       d );
              glTexCoord2f( x  , y   ); glVertex2f( map.width, d );
              glTexCoord2f( x  , 0.f ); glVertex2f( map.width, rows + d );
              glTexCoord2f( 0.f, 0.f ); glVertex2f( 0.f,       rows + d );
            glEnd();

          glPopMatrix();
          glTranslatef(face.glyph.advance.x>>6, 0, 0);

        glEndList();
      }

      FT_Done_Face(face);
    }
    ~this() {
      glDeleteTextures(128, char_texture); 
    }

    FT_Face R_Face()           { return face;            }
    GLuint R_Character(char c) { return char_texture[c]; }
    GLuint R_Character_List()  { return char_lists;      }
    int R_Width()              { return width;           }

    static void Init() {
      auto comp = FT_Init_FreeType(&FTLib);
      if ( comp ) {
        Debug_Output("Could not open FreeType Library: " ~
                                 R_FT_Error_String(comp));
        return;
      }
    }

    static Font Load_Font(string fil, int siz) {
      auto font_pair = Font_Type(fil, siz);
      if ( fonts.get(font_pair, null) == null ) {
        fonts[font_pair] = new Font(str, pt_size);
      }
      return fonts[font_pair];
    }
  }

  struct Font_Type {
    string name;
    int size;
  };

  Font[Font_Type] fonts;
}

class Text {
  Vector position;
  string msg, font_name;
  int pt_size;
  string font;
  TextEng.Font ft_font;

  bool uses_default_font;
  bool visible;

  static string default_font;
  static int default_pt_size;

  void Refresh_Message() {
    if ( uses_default_font ) {
      pt_size = default_pt_size;
      font    = default_font;
    }
    ft_font = TextEng.fonts[TextEng.Font_Type(font,pt_size)];
  }

  void Redefault(string str_) {
    msg = str_;
    font = "";
    ft_font = null;

    uses_default_font = 1;
    pt_size = 12;
    visible = 1;

    if ( default_font != "" )
        Refresh_Message();
  }
public:
  this(int pos_x, int pos_y, string str_) {
    position = new Vector(pos_x, pos_y);
    Redefault(str_);
  }

  this(Vector pos, string str_) {
    position = new Vector(pos);
    Redefault(str_);
  }

  void Set_Position(Vector v)          { position = v;                   }
  void Set_Position(float x, float y)  { position.x = x; position.y = y; }
  void Set_String(string str)          { string = str;                   }
  void Set_Colour(int r, int g, int b) {                                 }
  void Set_Visible(bool t)             { visible = t;                    }
  void Set_To_Default() {
    uses_default_font = 1;
    if ( default_font != "" )
      Refresh_Message();
  }

  void Set_Font(string str, int pt_siz) {
    TextEng.Load_Font(str, pt_size);
    font = str;
    pt_size = pt_siz;
    uses_default_font = 0;
    Refresh_Message();
  }

  Vector R_Position() { return position; }
  string R_Font()     {
    if ( ft_font == null ) return default_font;
    else                   return font;
  }
  ref TextEng.Font R_FT_Font() { return ft_font; }
  string R_Str() { return string; }
  bool R_Visible() { return visible; }

  string R_Default_Font() { return default_font; }

  static void Set_To_Default(string str, int pt_size) {
    TextEng.Load_Font(str, pt_size);
    default_font = str;
    default_pt_size = pt_size;
  }
  static string R_Default_Font() { return default_font; }
}


string R_FT_Error_String(int code) {
  switch ( code ) {
    case 0x00: return "no error";
    case 0x01: return "cannot open resource";
    case 0x02: return "unknown file format";
    case 0x03: return "broken file";
    case 0x04: return "invalid FreeType version";
    case 0x05: return "module version is too low";
    case 0x06: return "invalid argument";
    case 0x07: return "unimplemented feature";
    case 0x08: return "broken table";
    case 0x09: return "broken offset within table";
    case 0x0A: return "array allocation size too large";

  /* glyph/character errors */

    case 0x10: return "invalid glyph index";
    case 0x11: return "invalid character code";
    case 0x12: return "unsupported glyph image format";
    case 0x13: return "cannot render this glyph format";
    case 0x14: return "invalid outline";
    case 0x15: return "invalid composite glyph";
    case 0x16: return "too many hints";
    case 0x17: return "invalid pixel size";

  /* handle errors */

    case 0x20: return "invalid object handle";
    case 0x21: return "invalid library handle";
    case 0x22: return "invalid module handle";
    case 0x23: return "invalid face handle";
    case 0x24: return "invalid size handle";
    case 0x25: return "invalid glyph slot handle";
    case 0x26: return "invalid charmap handle";
    case 0x27: return "invalid cache manager handle";
    case 0x28: return "invalid stream handle";

  /* driver errors */

    case 0x30: return "too many modules";
    case 0x31: return "too many extensions";

  /* memory errors */

    case 0x40: return "out of memory";
    case 0x41: return "unlisted object";

  /* stream errors */

    case 0x51: return "cannot open stream";
    case 0x52: return "invalid stream seek";
    case 0x53: return "invalid stream skip";
    case 0x54: return "invalid stream read";
    case 0x55: return "invalid stream operation";
    case 0x56: return "invalid frame operation";
    case 0x57: return "nested frame access";
    case 0x58: return "invalid frame read";

  /* raster errors */

    case 0x60: return "raster uninitialized";
    case 0x61: return "raster corrupted";
    case 0x62: return "raster overflow";
    case 0x63: return "negative height while rastering";

  /* cache errors */

    case 0x70: return "too many registered caches";

  /* TrueType and SFNT errors */

    case 0x80: return "invalid opcode";
    case 0x81: return "too few arguments";
    case 0x82: return "stack overflow";
    case 0x83: return "code overflow";
    case 0x84: return "bad argument";
    case 0x85: return "division by zero";
    case 0x86: return "invalid reference";
    case 0x87: return "found debug opcode";
    case 0x88: return "found ENDF opcode in execution stream";
    case 0x89: return "nested DEFS";
    case 0x8A: return "invalid code range";
    case 0x8B: return "execution context too long";
    case 0x8C: return "too many function definitions";
    case 0x8D: return "too many instruction definitions";
    case 0x8E: return "SFNT font table missing";
    case 0x8F: return "horizontal header (hhea) table missing";
    case 0x90: return "locations (loca) table missing";
    case 0x91: return "name table missing";
    case 0x92: return "character map (cmap) table missing";
    case 0x93: return "horizontal metrics (hmtx) table missing";
    case 0x94: return "PostScript (post) table missing";
    case 0x95: return "invalid horizontal metrics";
    case 0x96: return "invalid character map (cmap) format";
    case 0x97: return "invalid ppem value";
    case 0x98: return "invalid vertical metrics";
    case 0x99: return "could not find context";
    case 0x9A: return "invalid PostScript (post) table format";
    case 0x9B: return "invalid PostScript (post) table";

  /* CFF, CID, and Type 1 errors */

    case 0xA0: return "opcode syntax error";
    case 0xA1: return "argument stack underflow";
    case 0xA2: return "ignore";
    case 0xA3: return "no Unicode glyph name found";


  /* BDF errors */

    case 0xB0: return "`STARTFONT' field missing";
    case 0xB1: return "`FONT' field missing";
    case 0xB2: return "`SIZE' field missing";
    case 0xB3: return "`FONTBOUNDINGBOX' field missing";
    case 0xB4: return "`CHARS' field missing";
    case 0xB5: return "`STARTCHAR' field missing";
    case 0xB6: return "`ENCODING' field missing";
    case 0xB7: return "`BBX' field missing";
    case 0xB8: return "`BBX' too big";
    case 0xB9: return "Font header corrupted or missing fields";
    case 0xBA: return "Font glyphs corrupted or missing fields";
  }
}
