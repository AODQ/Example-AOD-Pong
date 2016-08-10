module Game_Manager;
static import AOD;
import Entity.Asteroid;
import Entity.Ball;
import Entity.Paddle;
import Entity.Upgrade;
import std.string;

Paddle      paddle;
Ball     [] balls;
Asteroid [] asteroids;
Upgrade  [] upgrades;

void Add(T)(T x) {
  static if ( is(T == Ball    )) { balls     ~= x; }
  static if ( is(T == Asteroid)) { asteroids ~= x; }
  static if ( is(T == Upgrade )) { upgrades  ~= x; }
  static if ( is(T == Paddle  )) { paddle     = x; }
  AOD.Add(x);
}

void Remove(T)(T x) {
  import std.algorithm : remove;
  template Rem(string container) { const char[] Rem =
    "for ( int i = 0; i != " ~ container ~ ".length; ++ i )" ~
      "if ( " ~ container ~ "[i] is x ) {" ~
        container ~ " = remove("~container~", i);"~
        "break;" ~
      "}";
  }
  static if ( is(T == Ball    )) { mixin(Rem!("balls"    )); }
  static if ( is(T == Asteroid)) { mixin(Rem!("asteroids")); }
  static if ( is(T == Upgrade )) { mixin(Rem!("upgrades" )); }
  static if ( is(T == Paddle  )) { paddle = x;               }
  AOD.Remove(x);
}
