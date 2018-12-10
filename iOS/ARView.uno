using Uno;
using Uno.UX;
using Uno.Platform;
using Uno.IO;
using Uno.Collections;
using Fuse;
using Fuse.Elements;
using Uno.Compiler.ExportTargetInterop;
using Fuse.Controls;
using Fuse.Controls.Native.iOS;
using Fuse.Triggers;
using Fuse.Triggers.iOS;
using Fuse.Input;
using Fuse.Gestures;
using Fuse.Animations;
using Fuse.Elements;

using Fuse.Controls;
//using Fuse.Maps;

using Fuse.AR.iOS;


namespace Fuse.Controls
{



	internal interface IARView
	{
		//ObservableList<ARNodes> ARNodes { get; }
		ObservableList<ARNodes> ARNodes { get; }
		ObservableList<Abox> Aboxs { get; }

		bool ShowPlane { get; set; }
		bool ShowStatistics { get; set; }
		bool Debug { get; set; }
		FileSource PlaneFile { get; set; }
		//string File { get; set; }
		//void ApplyTo(bool showPlane, bool showStatistics, bool debug, string file);
		void ApplyTo(bool showPlane, bool showStatistics, bool debug, byte[] PlaneFile);
		//void SetAR(bool showPlane, bool showStatistics, bool debug, string file);
		void SetAR(bool showPlane, bool showStatistics, bool debug, FileSource PlaneFile);
		Action OnReady { get; set; }
		void UpdateNodes();
	}



	/****  AR configure                          ****/
	internal class ARConfig
	{
		public bool ShowPlane { get; set; }
		public bool ShowStatistics { get; set; }
		public bool Debug { get; set; }
		public FileSource PlaneFile { get; set; }
		//public string File { get; set; }

		public ARConfig(){
			ShowPlane = false;
			ShowStatistics = true;
			Debug = false;
			//File = "file";
			//PlaneFile="";
		}

		public void CopyFrom(IARView av)
		{
			ShowPlane = av.ShowPlane;
			ShowStatistics = av.ShowStatistics;
			Debug = av.Debug;
			PlaneFile = av.PlaneFile;
			//File = av.File;
		}

		public void Apply(IARView av){
			av.ShowPlane = ShowPlane;
			av.ShowStatistics = ShowStatistics;
			av.Debug = Debug;
			av.PlaneFile = PlaneFile;
			//av.File = File;
		}

	


	}

	

	public partial class ARView : Panel
	{

		ARConfig _arConfig;

		public ARView()
		{
			if defined(!MOBILE)
			{
				Background = new Fuse.Drawing.SolidColor(float4(0.6f,0.6f,0.6f,1.0f));
				var t = new Fuse.Controls.Text();
				t.Alignment = Alignment.Center;
				t.SetValue("ARView requires a mobile target.", this);
				t.TextAlignment = TextAlignment.Center;
				Children.Add(t);
			}

			_arConfig = new ARConfig();
		}

		protected override Fuse.Controls.Native.IView CreateNativeView()
		{
			if defined(Android){

				return base.CreateNativeView();

			}
			else if defined(iOS){

				return Fuse.AR.iOS.ARView.Create(this);
			}
			else{

				return base.CreateNativeView();

			}
		}


		IARView _arViewClient;
		internal IARView ARViewClient
		{
			get { return _arViewClient; }
			set
			{
				_arViewClient = value;
				if(_arViewClient == null)
				{
					_arReady = false;
					return;
				}

				ARViewClient.OnReady = OnARReady;

				_arConfig.Apply(ARViewClient);

			}
		}

		internal ObservableList<Abox> _aboxs;
		public ObservableList<Abox> Aboxs
		{
			get
			{
				if(_aboxs==null) _aboxs = new ObservableList<Abox>(OnAboxsAdded, OnAboxsRemoved);
				return _aboxs;
			}
		}

		internal ObservableList<ARNodes> _arnodes;
		public ObservableList<ARNodes> ARNodes
		{
			get
			{
				if(_arnodes==null) _arnodes = new ObservableList<ARNodes>(OnNodesAdded, OnNodesRemoved);
				return _arnodes;
			}
		}

		internal void AddNodes(ARNodes a)
		{
			if(ARNodes.Contains(a)) return;
			ARNodes.Add(a);
		}

		internal void RemoveNodes(ARNodes a)
		{
			ARNodes.Remove(a);
		}

		void OnAboxsAdded(Abox abox)
		{
			UpdateNodesNextFrame();
		}

		void OnAboxsRemoved(Abox abox)
		{
			UpdateNodesNextFrame();
		}

		void OnNodesAdded(ARNodes marker)
		{
			UpdateNodesNextFrame();
		}

		void OnNodesRemoved(ARNodes marker)
		{
			UpdateNodesNextFrame();
		}

		bool _willUpdateNodesNextFrame;
		void UpdateNodesNextFrame(){
			if(!ARIsReady || _willUpdateNodesNextFrame) return;
			UpdateManager.PerformNextFrame(DeferredNodesUpdate, UpdateStage.Primary);
			_willUpdateNodesNextFrame = true;
		}


		void DeferredNodesUpdate()
		{
			_willUpdateNodesNextFrame = false;
			UpdateNodes();
		}

		void UpdateNodes(){
			if(ARIsReady){
				ARViewClient.UpdateNodes();
			}
		}


		bool _arReady = false;
		void OnARReady()
		{
			if(ARViewClient == null) return;
			_arReady = true;
			ARViewClient.OnReady = null;
			ApplyARState();
		}

		//public void SetAR(bool showPlane, bool showStatistics, bool debug, string file)
		public void SetAR(bool showPlane, bool showStatistics, bool debug)
		{
			ShowPlane = showPlane;
			ShowStatistics = showStatistics;
			Debug = debug;
			//File = file;
		}


		bool ARIsReady
		{
			get {
				return _arReady;
			}
		}

		public bool ShowPlane {
			get { return _arConfig.ShowPlane; }
			set {
				_arConfig.ShowPlane = value;
				
			}
		}

		public bool ShowStatistics {
			get { return _arConfig.ShowStatistics; }
			set {
				_arConfig.ShowStatistics = value;
			}
		}

		public bool Debug {
			get { return _arConfig.Debug; }
			set {
				_arConfig.Debug = value;
			}
		}

	    public FileSource PlaneFile
	    {
	        get { return _arConfig.PlaneFile; }
	        set { 
	            _arConfig.PlaneFile = value; 
	            //if(_arConfig.PlaneFile!=null) _arConfig.OnImageFileSet();
	        }
	    }



/*
		public string File {
			get { return _arConfig.File; }
			set {
				_arConfig.File = value;
			}
		}
*/

		bool _willUpdateARNextFrame;
		internal void UpdateCameraNextFrame()
		{
			if(!ARIsReady || _willUpdateARNextFrame) return;
			UpdateManager.PerformNextFrame(ApplyARState, UpdateStage.Primary);
			_willUpdateARNextFrame = true;
		}

		void ApplyARState()
		{
			_willUpdateARNextFrame = false;
			if(ARIsReady){
				 //ObjC.Object planePtr = FileSourceToUIImageIOS(PlaneFile.ReadAllBytes());
				ARViewClient.ApplyTo(ShowPlane, ShowStatistics, Debug, PlaneFile.ReadAllBytes());

			}
				//ARViewClient.ApplyTo(ShowPlane, ShowStatistics, Debug, File);
		}





		Selector _showPlaneName = "Plane";

		[UXOriginSetter("SetPlane")]
		public bool Plane
		{
			get { return _arConfig.ShowPlane; }
			set { SetPlane(value, this);	}
		}

		public void SetPlane(bool value, IPropertyListener origin)
		{
			_arConfig.ShowPlane = value;
			UpdateCameraNextFrame();
			OnPropertyChanged(_showPlaneName, origin);
		}


		Selector _showStatisticsName = "Statistics";

		[UXOriginSetter("SetStatistics")]
		/** The longitude coordinate. */
		public bool Statistics
		{
			get { return _arConfig.ShowStatistics; }
			set { SetStatistics(value, this);	}
		}

		public void SetStatistics(bool value, IPropertyListener origin)
		{
			_arConfig.ShowStatistics = value;
			UpdateCameraNextFrame();
			OnPropertyChanged(_showStatisticsName, origin);
		}
/* SETTER 테스트 

		Selector _bearingName = "Bearing";

		[UXOriginSetter("SetTilt")]
		public string test
		{
			get { return _bearingName; }
			set { SetTilt(value, this);	}
		}

		public void SetTilt(string value, IPropertyListener origin)
		{
			OnPropertyChanged(_bearingName, origin);
		}

		internal void UpdateRestState()
		{
			
			OnPropertyChanged(_bearingName, this);
			
		}
*/

	}
}
