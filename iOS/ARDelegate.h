//
//  AppDelegate.h
//  arkit-by-example
//
//  Created by md on 6/8/17.
//  Copyright © 2017 ruanestudios. All rights reserved.
//

#import <ARkit/ARkit.h>
#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>
#import <UIKit/UIKit.h>
#import <ModelIO/ModelIO.h>
#import <SceneKit/ModelIO.h>

#import <Vision/Vision.h>

#import "Plane.h"
#import "NodeConfig.h"



@interface ARDelegate : NSObject <ARSCNViewDelegate, UIGestureRecognizerDelegate, SCNPhysicsContactDelegate>

	-showPlane:(bool)plane;
	-showsStatistics:(bool)stat;
	//- (int)addNodes:(NSString*)type width:(float)width height:(float)height length:(float)length x:(float)x y:(float)y z:(float)z nodeID:(int)uid;
	//- (int)addNodesTest:(NSString*)type config:(id)config nodeID:(int)uid;
	- (void)removeNodes:(int)identifier;
	- (void)setAsDelegate:(ARSCNView*)sceneView;
	- (void)setupRecognizers;
	- (void)clearNodes;
	- (void)test;
	- (void)renderer:(id<SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor;

	//- (void)applyTo:(bool)showPlane ShowsStatistics:(bool)stat Debug:(bool)Debug File:(NSString*)File;
	- (void)applyTo:(bool)showPlane ShowsStatistics:(bool)stat Debug:(bool)Debug PlaneFile:(NSData*)imageData;
	
	- (void)insertGeometry:(ARHitTestResult *)hitResult;
	- (void)explode:(ARHitTestResult *)hitResult;
	- (void)handleTapFrom: (UITapGestureRecognizer *)recognizer;
	- (void)handleHoldFrom: (UILongPressGestureRecognizer *)recognizer;
	- (void)handleHidePlaneFrom: (UILongPressGestureRecognizer *)recognizer;


	-(int)createBox:(float)width height:(float)height length:(float)length x:(float)x y:(float)y z:(float)z nodeID:(int)uid;

	-(int)createSphere:(float)radius x:(float)x y:(float)y z:(float)z nodeID:(int)uid;
	- (SCNNode *)renderer:(id<SCNSceneRenderer>)renderer nodeForAnchor:(ARAnchor *)anchor;    

@end