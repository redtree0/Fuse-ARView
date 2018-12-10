using Uno;
using Uno.UX;
using Uno.Platform;
using Uno.Collections;
using Fuse;
using Fuse.Elements;
using Uno.Compiler.ExportTargetInterop;
using Fuse.Controls;
using Fuse.Controls.Native.iOS;
using Fuse.Elements;
using Uno.IO;
using Uno.UX;
//using iOS;

namespace Fuse.AR.iOS
{



	[Require("Source.Include", "UIKit/UIKit.h")]
	[Require("Source.Include", "SceneKit/SceneKit.h")]
	[Require("Source.Include", "ARKit/ARKit.h")]
	extern (iOS) internal class FuseARView
	{
		public readonly ObjC.Object Handle;
		public readonly ObjC.Object Container;

		public FuseARView()
		{
			Container = CreateContainer();
			Handle = CreateAR(Container);
		}


		[Foreign(Language.ObjC)]
		ObjC.Object CreateContainer()
		@{
			 UIView* view = [[UIView alloc] init];

			//ARSCNView* view = [[ARSCNView alloc] init];
			return view;
		@}

		[Foreign(Language.ObjC)]
		ObjC.Object CreateAR(ObjC.Object container)
		@{

			  
			UIView* avc = container;
			//ARSCNView* sceneView = [[ARSCNView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
			//ARSCNView* sceneView = [[ARSCNView alloc] initWithFrame:CGRectMake(0, 0, 1000, 1000)];
			//ARSCNView* sceneView = [[ARSCNView alloc] initWithFrame:[UIScreen mainScreen].bounds];
			
			ARSCNView* sceneView = [[ARSCNView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 100 )];


			[avc addSubview:sceneView];

			 
			return sceneView;
		@}




		[Foreign(Language.ObjC)]
		public bool GetBoolValue(string key)
		@{
			id result = [@{FuseARView:Of(_this).Handle:Get()} valueForKey:key];
			return [result boolValue];
		@}

		[Foreign(Language.ObjC)]
		public string GetStringValue(string key)
		@{
			return [@{FuseARView:Of(_this).Handle:Get()} valueForKey:key];
		@}

		[Foreign(Language.ObjC)]
		public void SetBoolValue(string key, bool val)
		@{
			[@{FuseARView:Of(_this).Handle:Get()} setValue:[NSNumber numberWithBool:val] forKey:key];
		@}

		[Foreign(Language.ObjC)]
		public void SetIntValue(string key, int val)
		@{
			[@{FuseARView:Of(_this).Handle:Get()} setValue:[NSNumber numberWithInt:val] forKey:key];
		@}


		[Foreign(Language.ObjC)]
		public void SetStringValue(string key, string val)
		@{
			[@{FuseARView:Of(_this).Handle:Get()} setValue:[NSString stringWithString:val] forKey:key];
		@}
/*
		[Foreign(Language.ObjC)]
		public double GetPlane()
		@{
			ARSCNView * av = @{FuseMapView:Of(_this).Handle:Get()};
			return av.pitch;
		@}
*/


	}

	[Require("Source.Include", "ARViewController.h")]
	extern (iOS) internal class ARViewContainer
	{
		public Action OnReady;
		public Action OnResize;
		public Action OnPaused;

		public readonly FuseARView AR;
		public readonly ObjC.Object Handle;

		public ARViewContainer(FuseARView ar)
		{
			AR = ar;
			Handle = Create(AR.Container, viewDidAppear, viewDidResize, viewWillDisappear);
			//Handle = Create(AR.Container);
		}

		[Foreign(Language.ObjC)]
		ObjC.Object Create(ObjC.Object view , Action onReady, Action onResize, Action onPaused)
		@{
			return [[ARViewController alloc] initWithView:view onAppeared:onReady onResize:onResize onDisappeared:onPaused];
		@}

		//// obj c create
		[Foreign(Language.ObjC)]
		public ObjC.Object GetView()
		@{
			UIViewController* vc = @{ARViewContainer:Of(_this).Handle:Get()};

			return vc.view;
		@}

		void viewDidAppear()
		{
			if(OnReady!=null)
				OnReady();
		}
		
		void viewDidResize()
		{
			if(OnResize!=null)
				OnResize();
		}


		void viewWillDisappear(){
			if(OnPaused!=null){
				OnPaused();
			}
		}
	}


	////// 메인 /////
	[Require("Source.Include", "ARDelegate.h")]
	extern (iOS) public class ARView : LeafView, IARView
	{
		ARViewContainer _container;
		FuseARView _arView;
		ObjC.Object _arViewDelegate;

		Fuse.Controls.ARView _arViewHost;

		
		public static ARView Create(Fuse.Controls.ARView arViewHost) 
		{
			var v = new FuseARView();
			//debug_log("View");
			//debug_log v;

			var avc = new ARViewContainer(v);
			//debug_log("ViewContainer");
			//debug_log mvc;
			
			return new ARView(arViewHost, avc);
		}

		ARView(Fuse.Controls.ARView arViewHost, ARViewContainer avc) : base(avc.GetView())
		{
			_arViewHost = arViewHost;
			_container = avc;

			_container.OnReady= OnReadyInternal;
			_container.OnPaused= OnPausedInternal;
			_arView = _container.AR;
			//debug_log "ARVIEW - in FUSE";
			//debug_log _arView;
			//debug_log "AR Handle";
			//debug_log _arView.Handle;

			_arViewDelegate = Configure(_arView.Handle);
			
			_arViewHost.ARViewClient = this;
			
			// add nodes

			//UpdateNodes();
		}

		bool _isReady;
		public Action OnReady { get; set; }

		void OnReadyInternal()
		{
			_isReady = true;
			debug_log "ready";
			if(OnReady!=null) OnReady();
		}

		bool _isPaused;
		public Action OnPaused { get; set; }

		void OnPausedInternal()
		{
			_isPaused = true;
			debug_log "paused";
			if(OnPaused!=null) OnPaused();
		}

		

		[Require("Source.Include", "ARDelegate.h")]
		[Foreign(Language.ObjC)]
		ObjC.Object Configure(ObjC.Object ARView)
		@{
			ARSCNView* sceneView = ARView;
			//NSLog(@"CONFIGURE - IN FUSE");
			
			//NSLog(@"%@", sceneView);
			//NSLog(@"%@", sceneView.scene);
			ARDelegate* dg = [[ARDelegate alloc] init];

			//NSLog(@"%@", dg);
			[dg setAsDelegate:sceneView];
			//NSLog(@"%@", dg);
			
			return dg;
		@}

		[Foreign(Language.ObjC)]
		void ClearNodes()
		@{
			NSLog(@"@clearnodes");
			ARDelegate* dg = (ARDelegate*)@{ARView:Of(_this)._arViewDelegate:Get()};
			[dg clearNodes];
		@}

		public bool ShowPlane { get; set; }

		public bool ShowStatistics
		 { 
			get{ return _arView.GetBoolValue("ShowsStatistics");} 
			set{ _arView.SetBoolValue("ShowsStatistics", value); }
		}

		public bool Debug { get; set; }
		
		public FileSource PlaneFile { get; set; }
		//public string File { get; set; }

/*
		public string File
		 { 
			get{ return _arView.GetStringValue("File");} 
			set{ _arView.SetStringValue("File", value); }
		}
*/
		[Foreign(Language.ObjC)]
		//public void ApplyTo(bool ShowPlane, bool ShowsStatistics, bool Debug, string File)
		//extern (iOS) static void ApplyTo(bool ShowPlane, bool ShowsStatistics, bool Debug, FileSource PlaneFile)
		extern (iOS) public void ApplyTo(bool ShowPlane, bool ShowsStatistics, bool Debug, byte[] PlaneFile)
		@{
			ARDelegate* dg = (ARDelegate*)@{ARView:Of(_this)._arViewDelegate:Get()};

			if(PlaneFile){
				uArray* arr = [PlaneFile unoArray];
				NSData* imageData = [NSData dataWithBytes:arr->Ptr() length:[PlaneFile count]];
				[dg applyTo:ShowPlane ShowsStatistics:ShowsStatistics Debug:Debug PlaneFile:imageData];
			}
			//[dg applyTo:ShowPlane ShowsStatistics:ShowsStatistics Debug:Debug File:File];
		@}

		//public void SetAR(bool ShowPlane, bool ShowsStatistics, bool Debug, string File)
		public void SetAR(bool ShowPlane, bool ShowsStatistics, bool Debug, FileSource PlaneFile)
		{
			//ApplyTo(ShowPlane, ShowsStatistics, Debug, File);
			//ObjC.Object _PlaneFile = FileSourceToUIImageIOS(PlaneFile.ReadAllBytes());

			ApplyTo(ShowPlane, ShowsStatistics, Debug, PlaneFile.ReadAllBytes());
		}

		//public ObservableList<ARNodes> ARNodes {
		public ObservableList<ARNodes> ARNodes {
			get
			{
				return _arViewHost.ARNodes;
			}
		}
		public ObservableList<Abox> Aboxs {
			get
			{
				return _arViewHost.Aboxs;
			}
		}


/*
		[Foreign(Language.ObjC)]
		int addNodesTest(int uid, string type, object config)
		@{
			ARDelegate* dg = (ARDelegate*)@{ARView:Of(_this)._arViewDelegate:Get()};
			return [dg addNodesTest:type config:config nodeID:uid];
		@}

		[Foreign(Language.ObjC)]
		int AddNodes(int uid, string type, double width, double height, double length, double x, double y, double z)
		@{
			ARDelegate* dg = (ARDelegate*)@{ARView:Of(_this)._arViewDelegate:Get()};
			return [dg addNodes:type width:width height:height length:length x:x y:y z:z nodeID:uid];
		@}
*/

		[Foreign(Language.ObjC)]
		int CreateBox(int uid, float width, float height, float length, float x, float y, float z)
		@{
			ARDelegate* dg = (ARDelegate*)@{ARView:Of(_this)._arViewDelegate:Get()};
			return [dg createBox:width height:height length:length x:x y:y z:z nodeID:uid];
		@}

/*
		[Foreign(Language.ObjC)]
		int CreateSphere(int uid, float radius, float x, float y, float z)
		@{
			ARDelegate* dg = (ARDelegate*)@{ARView:Of(_this)._arViewDelegate:Get()};
			return [dg createSphere:radius x:x y:y z:z nodeID:uid];
		@}
*/
		[Foreign(Language.ObjC)]
		void RemoveNodes(int identifier)
		@{
			ARDelegate* dg = (ARDelegate*)@{ARView:Of(_this)._arViewDelegate:Get()};
			[dg removeNodes:identifier];
		@}


		public void UpdateNodes()
		{
			ClearNodes();
			debug_log "update Nodes";
			//debug_log ARNodes;
			debug_log Aboxs;
			foreach(Abox a in Aboxs){
				CreateBox(a.uid, a.width, a.height, a.length, a.x, a.y, a.z);
			}
				//debug_log a;
				//debug_log "forEach";
				//debug_log a.type;
				//if(a.type == "box"){
					//AddNodes(a.uid, a.type, a.width, a.height, a.length, a.x, a.y, a.z);
					//addNodesTest(a.uid, a.type, a.getObject(a.type));
					//debug_log a.getObject(a.type);
			//		debug_log "working box";
					//debug_log Abox;
			//		Abox abox = (Abox)a;
			//		debug_log abox;
			//		debug_log "box";
			//		debug_log abox.width;
			//		CreateBox(abox.uid, abox.width, abox.height, abox.length, abox.x, abox.y, abox.z);

				//}else if(a.type == "sphere"){

				//	Asphere asphere = (Asphere)a;

					//CreateSphere(asphere.uid, asphere.radius, asphere.x, asphere.y, asphere.z);
				//}
				/// add Nodes args 수정
			

		
			
		}



	}


}
