using Fuse.Elements;
using Uno.UX;
using Uno;

namespace Fuse.Controls
{
	public class Abox : Node
	{
	
		static int UID_POOL = 0;
		internal int uid = UID_POOL++;

	

		public float _x;

		public float x{
			get
			{
				return _x;
			}
			set
			{
				_x = value;
				//Draw();
			}
		}

		public  float _y;

		public float y{
			get
			{
				return _y;
			}
			set
			{
				_y = value;
				//Draw();
			}
		}

		public  float _z;

		public float z{
			get
			{
				return _z;
			}
			set
			{
				_z = value;
				//Draw();
			}
		}

		public  string _type = "box";


		float _width;

		public float width{
			get
			{
				return _width;
			}
			set
			{
				_width = value;
				//base.Draw();
			}
		}

		float _height;

		public float height{
			get
			{
				return _height;
			}
			set
			{
				_height = value;
				//base.Draw();
			}
		}

		float _length;

		public float length{
			get
			{
				return _length;
			}
			set
			{
				_length = value;
				 //base.Draw();
			}
		}

/*
		public class BoxConfig : NodeConfig {
			float _width;
			float _height;
			float _length;
			public BoxConfig (int uid, float x,float y,float z,float width,float height,float length) : base(uid, x, y, z)
			{
				this._width = width;
				this._height = height;
				this._length = length;
			}
		}

			public Object getObject(String type) 
		{
		   
		    return new BoxConfig(uid, this._x, this._y, this._z, this._width, this._height, this._length);
		  
		}
*/		
		


	



	}


}
