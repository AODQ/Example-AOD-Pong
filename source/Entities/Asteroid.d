module Entity.Asteroid;
static import AOD;
import Data;
import std.random;
enum ast_size { ast_tiny, ast_small, ast_medium, ast_large}
enum ast_dims {dim_tiny=8, dim_small=16, dim_medium=32, dim_large=64}

AOD.Vector[][] ast_vertices =
	[[AOD.Vector(0,0), AOD.Vector(0,8),AOD.Vector(8,0), AOD.Vector(8,8)],
    [AOD.Vector(0,0), AOD.Vector(0,16),AOD.Vector(16,0), AOD.Vector(16,16)],
	[AOD.Vector(0,0), AOD.Vector(0,32),AOD.Vector(32,0), AOD.Vector(32,32)],
	[AOD.Vector(0,0), AOD.Vector(0,64),AOD.Vector(64,0), AOD.Vector(64,64)]];

class Asteroid : AOD.PolyEntity {
public:
	this(ast_size sz) {
		size=sz;
		super(ast_vertices[sz]);
		switch (sz) {
		case ast_size.ast_tiny:
			Set_Sprite(Image_Data.meteor_tiny[std.random.uniform(0,8)]);
			Set_Size(ast_dims.dim_tiny, ast_dims.dim_tiny);
			break;
		case ast_size.ast_small:
			Set_Sprite(Image_Data.meteor_small[std.random.uniform(0,4)]);
			Set_Size(ast_dims.dim_small, ast_dims.dim_small);
			break;
		case ast_size.ast_medium:
			Set_Sprite(Image_Data.meteor_medium[std.random.uniform(0,2)]);
			Set_Size(ast_dims.dim_medium, ast_dims.dim_medium);
			break;
		case ast_size.ast_large:
			Set_Sprite(Image_Data.meteor_large);
			Set_Size(ast_dims.dim_large, ast_dims.dim_large);
			break;
		default:
		}
		Set_Position(320, 240);
	}
	
	this(ast_size sz, AOD.Vector pos, AOD.Vector vel) {
		switch (sz) {
		case ast_size.ast_tiny:
			Set_Sprite(Image_Data.meteor_tiny[std.random.uniform(0,8)]);
			Set_Size(ast_dims.dim_tiny, ast_dims.dim_tiny);
			break;
		case ast_size.ast_small:
			Set_Sprite(Image_Data.meteor_small[std.random.uniform(0,4)]);
			Set_Size(ast_dims.dim_small, ast_dims.dim_small);
			break;
		case ast_size.ast_medium:
			Set_Sprite(Image_Data.meteor_medium[std.random.uniform(0,2)]);
			Set_Size(ast_dims.dim_medium, ast_dims.dim_medium);
			break;
		case ast_size.ast_large:
			Set_Sprite(Image_Data.meteor_large);
			Set_Size(ast_dims.dim_large, ast_dims.dim_large);
			break;
		default:
		}
		Set_Velocity(vel);
		Set_Position(pos);
	}
	
	~this() {
		ast_size temp= cast(ast_size) (size-1);
		if(temp>=ast_size.ast_tiny){
			AOD.Vector vel;
			vel.Right_Normal(R_Velocity());
			auto a1 = new Asteroid(temp, R_Position(), vel);
			vel.Left_Normal(R_Velocity());
			auto a2 = new Asteroid(temp, R_Position(), vel);
			AOD.Add(a1);
			AOD.Add(a2);
		}
	}
	
private:
	ast_size size;
}