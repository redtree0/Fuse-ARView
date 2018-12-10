using Fuse.Elements;
using Uno.UX;
using Uno;

namespace Fuse.Controls
{
	public class ARNodes : Node
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
				Draw();
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
				Draw();
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
				Draw();
			}
		}

		public  string _type;

		public string type{
			get
			{
				return _type;
			}
			set
			{
				_type = value;
				Draw();
			}
		}

		//class 
		public class NodeConfig{
			int _uid;
			float _x;
			float _y;
			float _z;
			public NodeConfig (int uid, float x, float y, float z){
				this._uid = uid;
				this._x = x;
				this._y = y;
				this._z = z;
			}
		}


		
		

		protected override void OnRooted()
		{
			base.OnRooted();
			ARView a = Parent as ARView;
			if(a != null) a.AddNodes(this);
		}

		protected override void OnUnrooted()
		{
			base.OnUnrooted();
			ARView a = Parent as ARView;
			if(a != null) a.RemoveNodes(this);
		}

		public void Draw()
		{
			//ARView a = Parent as ARView;
			//if(a != null) a.UpdateMarkersNextFrame();
		}
/*
		public Object getObject(String type) 
		{
		    if(type=="box"){
		    	return new BoxConfig(uid, this._x, this._y, this._z, this._width, this._height, this._length);
		    }else if(type=="sphere"){
		    	return new SphereConfig(uid, this._x, this._y, this._z, this._radius);
		    }
		    return null;
		}
*/
	}
}
