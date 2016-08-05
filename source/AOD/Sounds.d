module AOD.sound;
import derelict.openal.al;
import derelict.vorbis.vorbis;
import derelict.vorbis.file;

import AOD.console : Output, Debug_Output;
import std.string;
import std.conv : to;

class SoundEng {
static:
  ALCdevice* al_device;
  immutable(int) Buffer_size     = 32768; // 32 KB buffer

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

    writeln("Setting listener");
    alListenerfv(AL_POSITION, listener_position.ptr);
    alListenerfv(AL_VELOCITY, listener_velocity.ptr);
    alListenerfv(AL_ORIENTATION, listener_orientation.ptr);
    writeln("Finished with setting up AL");
  }

  void LoadOGG(string file_name, ref long[] buffer, ref ALenum format,
                                                    ref ALsizei freq) {
    int endian = 0;
    int bit_stream;
    long bytes;
    byte[Buffer_size] array;
    import std.stdio;
    File f = File(file_name, "rb");
    vorbis_info* p_info;
    OggVorbis_File ogg_file;
    writeln("Loading song " ~ file_name);
    if ( ov_open(f.getFP(), &ogg_file, null, 0) != 0 ) {
      throw new Exception("OGG file not found: " ~ file_name);
    }
    p_info = ov_info(&ogg_file, -1);
    if ( p_info is null ) {
      throw new Exception("Could not generate info for OGG file");
    }

    format = p_info.channels == 1 ? AL_FORMAT_MONO16 : AL_FORMAT_STEREO16;
    freq = p_info.rate;
    
    writeln("Loading song buffer");
    do {
      bytes = ov_read(&ogg_file, array.ptr, Buffer_size,
                             endian, 2, 1, &bit_stream);
      buffer ~= bytes;
    } while ( bytes > 0 );
    ov_clear(&ogg_file);
    writeln("OGG Song loaded");
  }

  class Song {
    ALint state;
    uint buffer_id, source_id;
    ALsizei size, freq;
    ALenum format;
    long[] data;
    string filename;
    bool playing;
  };

  Song[] songs;
}


class Sounds {
static:
  int Load_Song(string file_name) {
    import std.stdio : writeln;
    SoundEng.Song s = new SoundEng.Song();
    alGenBuffers(1, &s.buffer_id);
    alGenSources(1, &s.source_id);
    writeln("Loading OGG");
    SoundEng.LoadOGG(file_name, s.data, s.format, s.freq);
    writeln("Creating buffer data");
    alBufferData(s.buffer_id, s.format, s.data.ptr,
                cast(ALsizei)s.data.length,  s.freq);
    writeln("Creating source index");
    alSourcei(s.source_id, AL_BUFFER, s.buffer_id);
    SoundEng.songs ~= s;
    writeln("Song prepared");
    return SoundEng.songs.length-1;
  }

  void Play_Song(int index) in {
    assert(index >= 0 && index < SoundEng.songs.length); 
  } body {
    import std.stdio : writeln;
    writeln("Playing song");
    SoundEng.Song s = SoundEng.songs[index];
    writeln("PLAYING SONG");
    do {
      alGetSourcei(s.source_id, AL_SOURCE_STATE, &s.state);
    } while ( s.state != AL_STOPPED );
    writeln("PLAYED SONG");
  }

  void Clean_Up() {
    foreach ( s; SoundEng.songs ) {
      alDeleteBuffers(1, &s.buffer_id);
      alDeleteSources(1, &s.source_id);
    }
    SoundEng.songs = [];
  }
}
