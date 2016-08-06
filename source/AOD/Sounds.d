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

    writeln("spawning thread");
    import std.concurrency;
    thread_id = spawn(&Main_Sound_Loop);

    writeln("Finished with setting up AL");
  }
  
  import std.concurrency : Tid;

  private Tid thread_id;

  Song LoadOGG(immutable(string) file_name) {
    Song s = Song();

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
    Check_AL_Errors() ;
    writeln("OGG Song loaded");

    return s;
  }

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

  // returns TRUE if file has finished loading
  bool Stream_Buffer( ALuint id, ALenum format, ref OggVorbis_File ogg_file,
                      ref int ogg_bitstream_section, int frq ) {
    // load buffer 
    byte[Buffer_size] buffer;
    uint bytes = ov_read(&ogg_file, buffer.ptr,
                         SoundEng.Buffer_size, 0, 2, 1,
                         &ogg_bitstream_section);
    import std.conv : to;
    import std.stdio : writeln;
    writeln("Read in " ~ to!string(bytes) ~ " bytes");

    // set to OpenAL
    alBufferData ( id, format, buffer.ptr, bytes, frq );
    SoundEng.Check_AL_Errors();
    return true;
  }

  struct Song {
    ALint state;
    ALuint[Buffer_amt] buffer_id;
    ALuint source_id;
    OggVorbis_File ogg_file;
    int ogg_bitstream_section;
    ALenum format;
    ALint freq;
    string file_name;
  };

}

private enum ThreadMsg {
  PlaySong, PauseSong, StopSong,
  PlaySound, StopSound,
  StopAllSounds
}

private void Main_Sound_Loop() {
  SoundEng.Song current_song;
  bool playing_song;

  void Play_Song() {
    auto s = current_song;
    playing_song = true;
    foreach ( i; 0 .. SoundEng.Buffer_amt ) // buffer 
      SoundEng.Stream_Buffer(s.buffer_id[i], s.format, s.ogg_file,
                             s.ogg_bitstream_section, s.freq);
    
    alSourceQueueBuffers(s.source_id, 3, s.buffer_id.ptr);
    SoundEng.Check_AL_Errors();
    alSourcei(s.source_id, AL_LOOPING, AL_FALSE);
    alSourcePlay(s.source_id);
    SoundEng.Check_AL_Errors();
  }

  while ( true ) {
    // check for messages
    import std.concurrency;
    import std.stdio : writeln;
    import core.time;
    receiveTimeout(dur!"msecs"(1), /* no hanging */
      (ThreadMsg msg, immutable(string)[] params) {
        switch ( msg ) {
          default: break;
          case ThreadMsg.PlaySong:
            current_song = SoundEng.LoadOGG(params[0]);
            Play_Song();
          break;
        }
      }
    );


    if ( playing_song ) { // refresh song
      auto s = current_song;
      ALint processed;
      alGetSourcei ( s.source_id, AL_BUFFERS_PROCESSED, &processed);
      SoundEng.Check_AL_Errors();
      import std.conv : to;

      foreach ( p ; 0 .. processed ) {
        ALuint buf_id;
        alSourceUnqueueBuffers ( s.source_id, 1, &buf_id );
        SoundEng.Check_AL_Errors();
        import std.stdio : write;
        write("Queueing buffer: ");
        SoundEng.Stream_Buffer(buf_id, s.format, s.ogg_file,
                               s.ogg_bitstream_section, s.freq);
        SoundEng.Check_AL_Errors();
        alSourceQueueBuffers ( s.source_id, 1, &buf_id );
        SoundEng.Check_AL_Errors();
      }
    }

    // refresh sounds

    import core.thread;
    Thread.sleep(dur!("msecs")(10));
  }

}


class Sounds {
static:
  void Play_Song(immutable(string) file_name) in {
    import File = std.file;
    assert(File.exists(file_name));
  } body {
    import std.stdio : writeln;
    writeln("Playing song " ~ file_name);
    import std.concurrency;
    send(SoundEng.thread_id, ThreadMsg.PlaySong,[ file_name ]);
  }

  void Clean_Up() {
    import std.concurrency;
    /* send(SoundEng.thread_id, ThreadMsg.StopSound,     []); */
    /* send(SoundEng.thread_id, ThreadMsg,StopAllSounds, []); */
  }
}
