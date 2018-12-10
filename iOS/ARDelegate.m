//
//  AppDelegate.m
//  arkit-by-example
//
//  Created by md on 6/8/17.
//  Copyright © 2017 ruanestudios. All rights reserved.
//

#import "ARDelegate.h"



@interface FuseNodeSCNBox : SCNBox
	//@property(copy) NSString* icon;
	@property double boxWithWidth;
	@property double height;
	@property double length;
	@property int nodeID;
@end

@implementation FuseNodeSCNBox
@end


@interface ARDelegate ()

@end


typedef NS_OPTIONS(NSUInteger, CollisionCategory) {
  CollisionCategoryBottom  = 1 << 0,
  CollisionCategoryCube    = 1 << 1,
  //   CollisionCategoryBottom  = 1 << 0,
  // CollisionCategoryCube    = 1 << 1,
};

@implementation ARDelegate
{
	ARSCNView * _sceneView;
	NSMutableDictionary* _annotations;
  NSMutableDictionary * _nodes;
	NSMutableDictionary * _planes;
  NSMutableArray* _boxes;


  bool _processing;
  VNDetectBarcodesRequest * _barcodesReq;
  ARAnchor* _detectedDataAnchor;

  NSData* _PlaneFile;
	// CLLocationManager* _locationMgr;
	// int _touchCount;
}

static int _idPool = 0;

-(int)nextId
{
  return _idPool++;
}

-(id)init
{
	self = [super init];
	_annotations = [[NSMutableDictionary alloc] init];

	_planes = [NSMutableDictionary new];

	_boxes = [NSMutableArray new];
  
  _processing = false ;

  _PlaneFile = [[NSData alloc] init];


	return self;
}


-(void)setAsDelegate:(ARSCNView*)sceneView
{
	_sceneView = sceneView;

  _sceneView.delegate = self;
  _sceneView.autoenablesDefaultLighting = YES;


  [self test];
  [self setupSession];
  [self setupRecognizers];
  [self setupPhysics];

  
	
}


- (void)setupSession {
  // Create a session configuration
  ARWorldTrackingConfiguration *configuration = [ARWorldTrackingConfiguration new];
  
  // Horizontal 인식
  configuration.planeDetection = ARPlaneDetectionHorizontal;
  
  [_sceneView.session runWithConfiguration:configuration];
}


- (void)setupPhysics {
  
  // For our physics interactions, we place a large node a couple of meters below the world
  // origin, after an explosion, if the geometry we added has fallen onto this surface which
  // is place way below all of the surfaces we would have detected via ARKit then we consider
  // this geometry to have fallen out of the world and remove it
  SCNBox *bottomPlane = [SCNBox boxWithWidth:1000 height:0.5 length:1000 chamferRadius:0];
  SCNMaterial *bottomMaterial = [SCNMaterial new];
  
  // Make it transparent so you can't see it
  bottomMaterial.diffuse.contents = [UIColor colorWithWhite:1.0 alpha:0.0];
  bottomPlane.materials = @[bottomMaterial];
  SCNNode *bottomNode = [SCNNode nodeWithGeometry:bottomPlane];
  
  // Place it way below the world origin to catch all falling cubes
  bottomNode.position = SCNVector3Make(0, -10, 0);
  bottomNode.physicsBody = [SCNPhysicsBody
                            bodyWithType:SCNPhysicsBodyTypeKinematic
                            shape: nil];
  bottomNode.physicsBody.categoryBitMask = CollisionCategoryBottom;
  bottomNode.physicsBody.contactTestBitMask = CollisionCategoryCube;
  
  SCNScene *scene = _sceneView.scene;
  [scene.rootNode addChildNode:bottomNode];
  scene.physicsWorld.contactDelegate = self;
}


-(void)setupRecognizers
{
  // 터치 인식
  UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
  tapGestureRecognizer.numberOfTapsRequired = 1;
  [_sceneView addGestureRecognizer:tapGestureRecognizer];


  UILongPressGestureRecognizer *explosionGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleHoldFrom:)];
  explosionGestureRecognizer.minimumPressDuration = 0.5;
  [_sceneView addGestureRecognizer:explosionGestureRecognizer];

  UILongPressGestureRecognizer *hidePlanesGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleHidePlaneFrom:)];
  hidePlanesGestureRecognizer.minimumPressDuration = 1;
  hidePlanesGestureRecognizer.numberOfTouchesRequired = 2;
  [_sceneView addGestureRecognizer:hidePlanesGestureRecognizer];  

}


-(void)clearNodes
{
  [_nodes removeAllObjects];
  [_boxes removeAllObjects];
  [_planes removeAllObjects];
}

//-(void)applyTo:(bool)showPlane ShowsStatistics:(bool)stat Debug:(bool)Debug File:(NSString*)File
-(void)applyTo:(bool)showPlane ShowsStatistics:(bool)stat Debug:(bool)Debug PlaneFile:(NSData*)imageData
{
	_sceneView.showsStatistics = stat;
	// NSLog(@"applyTO");
	// NSLog(@"%@", _sceneView);
	// NSLog(_sceneView.showsStatistics ? @"YES" : @"NO");

  if(Debug){
    _sceneView.debugOptions =
      ARSCNDebugOptionShowWorldOrigin |
      ARSCNDebugOptionShowFeaturePoints;
  }

  if(imageData){
    _PlaneFile = imageData;
  }

}

/*
-(int)addNodes:(NSString*)type 
		width:(double)width 
		height:(double)height
		length:(double)length
		x:(double)x
		y:(double)y
		z:(double)z
    nodeID:(int)uid
{

//  SCNBox *box = [SCNBox boxWithWidth:width height:height length:length chamferRadius:0];
  SCNNode *node;
  if(type == @"box"){
    node = [self addNewBox:width height:height length:length x:x y:y z:z nodeID:uid];
  }else if(type = @"sphere"){
   // node = [self addNewSphere:radius x:x y:y z:z nodeID:uid];
  }else{
    return _idPool;
  }
  [self nextId];
  //[_boxes addObject:node];
  [_nodes setObject:node forKey:\@(_idPool)];
  return _idPool;
	// FuseNodeSCNBox* box = [[FuseNodeSCNBox alloc] init];
	// box.boxWithWidth = width;
	// box.height = height;
	// box.length = length;
	// box.chamferRadius = 0.0;


	// SCNNode *boxNode = [SCNNode nodeWithGeometry:box];
	// boxNode.position = SCNVector3Make(x,y,z);
	
	// [_sceneView.scene.rootNode addChildNode:boxNode];
	// [self nextId];
	// [_annotations setObject:a forKey:\@(_idPool)];
	// return _idPool;
}


-(int)addNodesTest:(NSString*)type 
    config:(id)config
    nodeID:(int)uid
{
  SCNNode *node;
  NSLog(@"%@", config);
  if(type == @"box"){
   // node = [self addNewBox:config.width height:config.height length:config.length x:config.x y:config.y z:config.z nodeID:uid];
  }else if(type = @"sphere"){
   // node = [self addNewSphere:config.radius x:config.x y:config.y z:config.z nodeID:config.uid];
  }else{
    return _idPool;
  }
  [self nextId];
  //[_boxes addObject:node];
  [_nodes setObject:node forKey:\@(_idPool)];
  return _idPool;
}
*/



#pragma mark - Ux Ar Node Create 

-(int)addGeometryNodes:(SCNNode*)node
{
  [_sceneView.scene.rootNode addChildNode:node];

  [self nextId];
  //[_boxes addObject:node];
  [_nodes setObject:node forKey:\@(_idPool)];
  return _idPool;
}

//-(SCNNode*)addNewBox:(float)width 
-(int)createBox:(float)width height:(float)height length:(float)length x:(float)x y:(float)y z:(float)z nodeID:(int)uid
{
  SCNBox *box = [SCNBox boxWithWidth:width height:height length:length chamferRadius:0];
  SCNNode *boxNode = [SCNNode nodeWithGeometry:box];
  boxNode.position = SCNVector3Make(x,y,z);
  NSLog(@"%s", "ADDNODE");

  return [self addGeometryNodes:boxNode];
}


//-(SCNNode*)addNewSphere:
-(int)createSphere:(float)radius
    x:(float)x
    y:(float)y
    z:(float)z
    nodeID:(int)uid
{
  SCNSphere *sphere = [SCNSphere sphereWithRadius:radius ];
  SCNNode *sphereNode = [SCNNode nodeWithGeometry:sphere];
  sphereNode.position = SCNVector3Make(x,y,z);
  NSLog(@"%s", "ADDNODE");

  return [self addGeometryNodes:sphereNode];
}


-(void)removeNodes:(int)identifier
{

	[_nodes removeObjectForKey:\@(identifier)];
}



- (void)explode:(ARHitTestResult *)hitResult {
  // For an explosion, we take the world position of the explosion and the position of each piece of geometry
  // in the world. We then take the distance between those two points, the closer to the explosion point the
  // geometry is the stronger the force of the explosion.
  
  // The hitResult will be a point on the plane, we move the explosion down a little bit below the
  // plane so that the goemetry fly upwards off the `
  float explosionYOffset = 0.1;
  
  SCNVector3 position = SCNVector3Make(
                                       hitResult.worldTransform.columns[3].x,
                                       hitResult.worldTransform.columns[3].y - explosionYOffset,
                                       hitResult.worldTransform.columns[3].z
                                       );
  
  // We need to find all of the geometry affected by the explosion, ideally we would have some
  // spatial data structure like an octree to efficiently find all geometry close to the explosion
  // but since we don't have many items, we can just loop through all of the current geoemtry
  for(SCNNode *cubeNode in _boxes) {
    // The distance between the explosion and the geometry
    SCNVector3 distance = SCNVector3Make(
                                          cubeNode.worldPosition.x - position.x,
                                          cubeNode.worldPosition.y - position.y,
                                          cubeNode.worldPosition.z - position.z
                                          );
    
    float len = sqrtf(distance.x * distance.x + distance.y * distance.y + distance.z * distance.z);
    
    // Set the maximum distance that the explosion will be felt, anything further than 2 meters from
    // the explosion will not be affected by any forces
    float maxDistance = 2;
    float scale = MAX(0, (maxDistance - len));
    
    // Scale the force of the explosion
    scale = scale * scale * 2;
    
    // Scale the distance vector to the appropriate scale
    distance.x = distance.x / len * scale;
    distance.y = distance.y / len * scale;
    distance.z = distance.z / len * scale;
    
    // Apply a force to the geometry. We apply the force at one of the corners of the cube
    // to make it spin more, vs just at the center
    [cubeNode.physicsBody applyForce:distance atPosition:SCNVector3Make(0.05, 0.05, 0.05) impulse:YES];
  }
}

- (void)insertGeometry:(ARHitTestResult *)hitResult {
  // Right now we just insert a simple cube, later we will improve these to be more
  // interesting and have better texture and shading
  
  float dimension = 0.1;
  SCNBox *cube = [SCNBox boxWithWidth:dimension height:dimension length:dimension chamferRadius:0];
  SCNNode *node = [SCNNode nodeWithGeometry:cube];
  
  // The physicsBody tells SceneKit this geometry should be manipulated by the physics engine
  node.physicsBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeDynamic shape:nil];
  node.physicsBody.mass = 2.0;
  node.physicsBody.categoryBitMask = CollisionCategoryCube;
  
  // We insert the geometry slightly above the point the user tapped, so that it drops onto the plane
  // using the physics engine
  float insertionYOffset = 0.5;
  node.position = SCNVector3Make(
                                 hitResult.worldTransform.columns[3].x,
                                 hitResult.worldTransform.columns[3].y + insertionYOffset,
                                 hitResult.worldTransform.columns[3].z
                                 );
  [_sceneView.scene.rootNode addChildNode:node];

  // [self test];
  [_boxes addObject:node];
}



#pragma mark - UIGestureRecognizerDelegate

- (void)handleTapFrom: (UITapGestureRecognizer *)recognizer {
  // Take the screen space tap coordinates and pass them to the hitTest method on the ARSCNView instance
  CGPoint tapPoint = [recognizer locationInView:_sceneView];
  NSArray<ARHitTestResult *> *result = [_sceneView hitTest:tapPoint types:ARHitTestResultTypeExistingPlaneUsingExtent];
  
  // If the intersection ray passes through any plane geometry they will be returned, with the planes
  // ordered by distance from the camera
  if (result.count == 0) {
    return;
  }
  
  // If there are multiple hits, just pick the closest plane
  ARHitTestResult * hitResult = [result firstObject];
  [self insertGeometry:hitResult];
}

- (void)handleHoldFrom: (UILongPressGestureRecognizer *)recognizer {
  if (recognizer.state != UIGestureRecognizerStateBegan) {
    return;
  }
  
  // Perform a hit test using the screen coordinates to see if the user pressed on
  // a plane.
  CGPoint holdPoint = [recognizer locationInView:_sceneView];
  NSArray<ARHitTestResult *> *result = [_sceneView hitTest:holdPoint types:ARHitTestResultTypeExistingPlaneUsingExtent];
  if (result.count == 0) {
    return;
  }
  
  ARHitTestResult * hitResult = [result firstObject];
  dispatch_async(dispatch_get_main_queue(), ^{
    [self explode:hitResult];
  });
}

- (void)handleHidePlaneFrom: (UILongPressGestureRecognizer *)recognizer {
  if (recognizer.state != UIGestureRecognizerStateBegan) {
    return;
  }
  
  // Hide all the planes
  for(NSUUID *planeId in _planes) {
    [_planes[planeId] hide];
  }
  
  // Stop detecting new planes or updating existing ones.
  ARWorldTrackingConfiguration *configuration = (ARWorldTrackingConfiguration *)_sceneView.session.configuration;
  configuration.planeDetection = ARPlaneDetectionNone;
  [_sceneView.session runWithConfiguration:configuration];
}




#pragma mark - SCNPhysicsContactDelegate


- (void)physicsWorld:(SCNPhysicsWorld *)world didBeginContact:(SCNPhysicsContact *)contact {
  // Here we detect a collision between pieces of geometry in the world, if one of the pieces
  // of geometry is the bottom plane it means the geometry has fallen out of the world. just remove it
  CollisionCategory contactMask = contact.nodeA.physicsBody.categoryBitMask | contact.nodeB.physicsBody.categoryBitMask;
  
  NSLog(@"%lu", (unsigned long)contactMask);

  if (contactMask == (CollisionCategoryBottom | CollisionCategoryCube)) {
    if (contact.nodeA.physicsBody.categoryBitMask == CollisionCategoryBottom) {
      [contact.nodeB removeFromParentNode];
       NSLog(@"A");
    } else {
      [contact.nodeA removeFromParentNode];
       NSLog(@"B");

    }
  }
}



#pragma mark - ARSCNViewDelegate

- (void)renderer:(id <SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
  if (![anchor isKindOfClass:[ARPlaneAnchor class]]) {
    return;
  }
  //NSLog(@"renderer");
  // When a new plane is detected we create a new SceneKit plane to visualize it in 3D
  Plane *plane = [[Plane alloc] initWithAnchor: (ARPlaneAnchor *)anchor isHidden: NO PlaneFile:_PlaneFile];
  [_planes setObject:plane forKey:anchor.identifier];
  [node addChildNode:plane];
}



- (void)renderer:(id <SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
  Plane *plane = [_planes objectForKey:anchor.identifier];
  if (plane == nil) {
    return;
  }
  
  // When an anchor is updated we need to also update our 3D geometry too. For example
  // the width and height of the plane detection may have changed so we need to update
  // our SceneKit geometry to match that
  [plane update:(ARPlaneAnchor *)anchor];
}



// - (SCNNode *)renderer:(id<SCNSceneRenderer>)renderer nodeForAnchor:(ARAnchor *)anchor
// {
//   if(_detectedDataAnchor.identifier == anchor.identifier){
//     SCNScene *scene = [SCNScene sceneNamed:@"ship.scn"];
//     //SCNNode *node = [SCNNode nodeWithMDLObject:model];
//     //sceneView.scene.rootNode.addChildNode(_detectedDataAnchor);
//        SCNNode *node = [SCNNode init];

//     for (SCNNode *child in scene.rootNode.childNodes) {
//         child.geometry.firstMaterial.lightingModelName = SCNLightingModelPhysicallyBased;
//         child.movabilityHint = SCNMovabilityHintMovable;
//     }

//     node.transform =SCNMatrix4FromMat4(anchor.transform);
//     return node;
//   }

//   return nil;
// }



// #pragma mark - ARSessionDelegate

// - (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame {

//       if (_processing) {
//           return;
//       };
    
//       _processing = true;
      
//       _barcodesReq = [[VNDetectBarcodesRequest alloc] initWithCompletionHandler:^(VNRequest *request, NSError *error){
        
//         if ([request.results isKindOfClass:[VNBarcodeObservation class]] == YES){

//                for(VNBarcodeObservation *result in request.results) {
//                    // VNBarcodeObservation * result = request.results;
//                   if(result){
//                       CGRect rect = result.boundingBox;
//                      rect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeScale(1.0, -1.0));
//                      rect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeTranslation(0.0, 1.0));

//                      CGPoint center;
//                       center.x = CGRectGetMidX(rect);
//                       center.y = CGRectGetMidY(rect);

//                      NSArray<ARHitTestResult *> *hitTestResults = [frame hitTest:center types:ARHitTestResultTypeFeaturePoint];

//                      //_sceneView.nodeForAnchor();
//                      for(ARHitTestResult *result in hitTestResults){
//                          //NSLog(@"%@", result.worldTransform);
//                          if(result){
//                             if(_detectedDataAnchor){
//                               SCNNode* node = [_sceneView nodeForAnchor:(_detectedDataAnchor)];
//                               node.transform = SCNMatrix4FromMat4(result.worldTransform);
//                               //SCNMatrix4
//                               //sceneView.scene.rootNode.addChildNode(_detectedDataAnchor);
//                             }else {
//                                 [_detectedDataAnchor initWithTransform: (matrix_float4x4)result.worldTransform];
//                                 //_detectedDataAnchor = ARAnchor(result.worldTransform);
//                                 //_sceneView.session.addAnchor(_detectedDataAnchor);
//                                 [_sceneView.session addAnchor:(ARAnchor *) _detectedDataAnchor];
//                             }
                        
//                          }
                       
//                       }
//                   }
             
//                 }

//                  _processing = true;
//                   // [rect CGRectApplyAffineTransform:[CGAffineTransform ]]
//                    //rect = [rect CGRectApplyAffineTransform:[CGAffineTransform init:]];
//         }else {
//             _processing = false;
//         }
        


//         dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//         dispatch_async(globalQueue, ^{ 
//             _barcodesReq.symbologies = VNBarcodeSymbologyQR;
//             // _barcodesReq = [[VNDetectBarcodesRequest alloc] initWithCompletionHandler:^(VNRequest *request, NSError *error){
//              VNImageRequestHandler* imageRequestHandler = [[VNImageRequestHandler alloc] initWithCVPixelBuffer:frame.capturedImage options: nil];
//             [imageRequestHandler performRequests:_barcodesReq error:nil];
//           });


//     }];


//  }




- (void)renderer:(id <SCNSceneRenderer>)renderer didRemoveNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
  // Nodes will be removed if planes multiple individual planes that are detected to all be
  // part of a larger plane are merged.
  [_planes removeObjectForKey:anchor.identifier];
}

/**
 Called when a node will be updated with data from the given anchor.
 
 @param renderer The renderer that will render the scene.
 @param node The node that will be updated.
 @param anchor The anchor that was updated.
 */
- (void)renderer:(id <SCNSceneRenderer>)renderer willUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
}





#pragma mark - TEST CODE

-(void)test
{

  SCNScene *scene = [SCNScene sceneNamed:@"./ship.scn"];
  SCNNode *node = [scene.rootNode clone];

 
  node.scale = SCNVector3Make(5, 5, 5);
  node.position = SCNVector3Make(0, 0, 0);
  
  NSLog(@"%@", node);

  [_sceneView.scene.rootNode addChildNode:node];
 


  /*
    
    글짜 출력 테스트

      UILabel *yourLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 20)];

      [yourLabel setTextColor:[UIColor blackColor]];
      [yourLabel setBackgroundColor:[UIColor clearColor]];
      [yourLabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: 14.0f]]; 
      [avc addSubview:yourLabel];
      NSString *someString = @"Sample String, Yarp!";
      yourLabel.text = someString;

        */  
    
}





#pragma mark - ARSession

- (void)session:(ARSession *)session didFailWithError:(NSError *)error {
    // Present an error message to the user
    
}

- (void)sessionWasInterrupted:(ARSession *)session {
    // Inform the user that the session has been interrupted, for example, by presenting an overlay
    
}

- (void)sessionInterruptionEnded:(ARSession *)session {
    // Reset tracking and/or remove existing anchors if consistent tracking is required
    
}


@end