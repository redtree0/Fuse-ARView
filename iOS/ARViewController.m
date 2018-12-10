//
//  ViewController.m
//  arkit-by-example
//
//  Created by md on 6/8/17.
//  Copyright © 2017 ruanestudios. All rights reserved.
//

#import "ARViewController.h"


@interface ARViewController () <ARSCNViewDelegate>

@property (nonatomic, strong) SCNNode *cubeNode;
// @property (nonatomic, strong) IBOutlet ARSCNView *sceneView;
// @property (nonatomic, strong) IBOutlet ARSCNView *sceneView;
//@property (nonatomic, strong) id _view;

@end

    
@implementation ARViewController
{
  id _view;
  BOOL isAvailable;
  // ARSCNView *sceneView;
}


-(id)initWithView:(id)view onAppeared:(Action)appearedHandler onResize:(Action)resizeHandler onDisappeared:(Action)disAppearedHandler {
  self = [super init];
  _view = view;
  NSLog(@"%@", self.view);
  NSLog(@"initWithView");
  //sceneView = [[ARSCNView alloc] init];

  if (@available(iOS 11.0, *)) {
    isAvailable = YES;
  }else{
    isAvailable = NO;
  }
  self.onAppearedCallback = appearedHandler;
  self.onResizeCallback = resizeHandler;
  self.onDisappearedCallback = disAppearedHandler;
  //[self setupScene];

  return self;
}

-(void)loadView
{
  self.view = _view;
  NSLog(@"%@", self.view);
  NSLog(@"LOADVIEW");

}




- (void)viewDidLoad {
  [super viewDidLoad];

}


- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  // Create a session configuration
  //ARWorldTrackingConfiguration *configuration = [ARWorldTrackingConfiguration new];
    
  /// Run the view's session
  //[self._view.session runWithConfiguration:configuration];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  // NSLog(@"Disappear");
  // if(self.onDisappearedCallback!=nil){

  //   self.onDisappearedCallback();

  // }
  
  //[self._view.session pause];

  // Pause the view's session
  // [self.sceneView.session pause];
  //[self._view.session pause];
}

-(void)viewDidDisappear:(BOOL)animated {
   [super viewDidDisappear:animated];
  NSLog(@"Disappear");
  if(self.onDisappearedCallback!=nil){

    self.onDisappearedCallback();

  }
}


- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Release any cached data, images, etc that aren't in use.
}


-(void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  if(self.onAppearedCallback!=nil){

    self.onAppearedCallback();

  }
}


@end