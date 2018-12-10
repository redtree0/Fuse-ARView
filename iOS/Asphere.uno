using Fuse.Elements;
using Uno.UX;
using Uno;

namespace Fuse.Controls
{
	public class Asphere : ARNodes
	{
		new string _type = "sphere";

		float _radius;
		
		public float radius{
				get
				{
					return _radius;
				}
				set
				{
					_radius = value;
					base.Draw();
				}
		}

	
/*

	public Asphere (int uid, float x,float y,float z, float radius): base(uid, x, y, z){

		}


		public class SphereConfig : NodeConfig {
			float _radius;
			public SphereConfig (int uid, float x,float y,float z, float radius) : base(uid, x, y, z)
			{
				this._radius = radius;
			}
		}
*/

		

/*
		public Object getObject(String type) 
		{
		   
		    	return new SphereConfig(uid, this._x, this._y, this._z, this._radius);
		  
		}
*/

	}
}
