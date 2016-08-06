module AOD.sound;
import derelict.openal.al;
import derelict.vorbis.vorbis;
import derelict.vorbis.file;

import AOD.console : Output, Debug_Output;
import std.string;
import std.conv : to;

class SoundEng {
static:
  ALCdevice*  al_device;
  ALCcontext* al_context;
  immutable(int) Buffer_size = 22050,
                 Buffer_amt  =    3;

  ALfloat[] listener_position    = [0.0,0.0,4.0              ] ;
  ALfloat[] listener_velocity    = [0.0,0.0,0.0              ] ;
  ALfloat[] listener_orientation = [0.0,0.0,1.0, 0.0,1.0,0.0 ] ;

  void Set_Up() {
    import derelict.util.exception;
    import std.stdio;

    writeln("AOD@Sound@Set_Up setting up AL");

    try {
      DerelictAL.load();
    } catch ( DerelictException de ) {
      writeln("--------------------------------------------------------------");
      writeln("Error initializing derelict-OpenAL library: " ~ to!string(de));
      writeln("--------------------------------------------------------------");
    }

    try {
      DerelictVorbis.load();
    } catch ( DerelictException de ) {
      writeln("--------------------------------------------------------------");
      writeln("Error initializing DerelictVorbis library: " ~ to!string(de));
      writeln("--------------------------------------------------------------");
    }

    try {
      DerelictVorbisFile.load();
    } catch ( DerelictException de ) {
      writeln("--------------------------------------------------------------");
      writeln("Error initializing DerelictVorbisFil library: " ~ to!string(de));
      writeln("--------------------------------------------------------------");
    }
    Check_AL_Errors() ;

    al_device = alcOpenDevice(null);
    Check_AL_Errors() ;
    if ( al_device == null ) {
      throw new Exception("Failed to open ALC device");
    }
    al_context = alcCreateContext(al_device, null);
    Check_AL_Errors() ;
    alcMakeContextCurrent(al_context);
    Check_AL_Errors() ;

    writeln("Setting listener");
    alListenerfv(AL_POSITION, listener_position.ptr);
    Check_AL_Errors() ;
    alListenerfv(AL_VELOCITY, listener_velocity.ptr);
    Check_AL_Errors() ;
    alListenerfv(AL_ORIENTATION, listener_orientation.ptr);
    Check_AL_Errors() ;
    writeln("Finished with setting up AL");
  }

  Song LoadOGG(string file_name) {
    Song s =  new Song();

    alGenBuffers(Buffer_amt, s.buffer_id.ptr);
    Check_AL_Errors();
    alGenSources(1, &s.source_id);
    Check_AL_Errors();
    s.file_name = file_name;

    import std.stdio;
    import core.stdc.stdio : fopen;
    FILE* f = fopen(file_name.ptr, "rb".ptr);
    vorbis_info* p_info;
    OggVorbis_File ogg_file;
    writeln("Loading song " ~ file_name);
    if ( ov_open(f, &ogg_file, null, 0) != 0 ) {
      throw new Exception("OGG file not found: " ~ file_name);
    }
    Check_AL_Errors() ;
    p_info = ov_info(&ogg_file, -1);
    if ( p_info is null ) {
      throw new Exception("Could not generate info for OGG file");
    }
    Check_AL_Errors() ;

    s.format = p_info.channels == 1 ? AL_FORMAT_MONO16 : AL_FORMAT_STEREO16;
    s.freq = p_info.rate;
    
    s.ogg_file = ogg_file;
    s.endian = 0;

    Check_AL_Errors() ;
    writeln("OGG Song loaded");

    return s;
  }

  class Song {
    ALint state;
    ALuint[Buffer_amt] buffer_id;
    byte[Buffer_size] buffers;
    ALuint source_id;
    int endian;
    OggVorbis_File ogg_file;
    ALenum format;
    ALint freq;
    string file_name;
  };

  Song[] songs;

  void Check_AL_Errors() {
    import std.stdio;
    int error = alGetError();
    switch ( error ) {
      default: break;
      case AL_NO_ERROR: return;
    }
    write("OpenAL error: ");
    switch ( error ) {
      default: assert(0);
      case AL_INVALID_NAME:
        writeln("AL_INVALID_NAME");
      break;
      case AL_INVALID_ENUM:
        writeln("AL_INVALID_ENUM");
      break;
      case AL_INVALID_VALUE:
        writeln("AL_INVALID_VALUE");
      break;
      case AL_INVALID_OPERATION:
        writeln("AL_INVALID_OPERATION");
      break;
      case AL_OUT_OF_MEMORY:
        writeln("AL_OUT_OF_MEMORY");
      break;
    }
  }


  void Stream_Buffer( ALuint id, ALenum format, byte[] buffers, int frq ) {
    // load buffer 
    
    
    // set to OpenAL
    alBufferData ( id, format, buffers.ptr, buffers.length, frq );
  }
}


class Sounds {
static:
  int Load_Song(string file_name) {
    import std.stdio : writeln;
    SoundEng.songs ~= SoundEng.LoadOGG(file_name);
    return SoundEng.songs.length-1;
  }

  void Play_Song(int index) in {
    assert(index >= 0 && index < SoundEng.songs.length); 
  } body {
    import std.stdio : writeln;
    SoundEng.Song s = SoundEng.songs[index];
    writeln("Playing song " ~ s.file_name);

    foreach ( i; 0 .. SoundEng.Buffer_amt ) // buffer 
      SoundEng.Stream_Buffer(s.buffer_id[i], s.format, s.buffers, s.freq);
    
    alSourceQueueBuffers(s.source_id, 3, s.buffer_id.ptr);

    while ( true ) {
      ALint processed;
      alGetSourcei ( s.source_id, AL_BUFFERS_PROCESSED, &processed);

      while ( -- processed ) {
        ALuint buf_id;
        alSourceUnqueueBuffers ( s.source_id, 1, &buf_id );
        SoundEng.Stream_Buffer(buf_id, s.format, s.buffers, s.freq);
        alSourceQueueBuffers ( s.source_id, 1, &buf_id );
      }
    }
  }

  void Clean_Up() {
    foreach ( s; SoundEng.songs ) {
      alDeleteBuffers(1, s.buffer_id.ptr);
      alDeleteSources(1, &s.source_id);
    }
    SoundEng.songs = [];
  }
}
