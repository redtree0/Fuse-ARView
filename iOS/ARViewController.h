//
//  ViewController.h
//  arkit-by-example
//
//  Created by md on 6/8/17.
//  Copyright © 2017 ruanestudios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>

typedef void (^Action)(void);
@interface ARViewController : UIViewController
@property(copy) Action onAppearedCallback;
@property(copy) Action onResizeCallback;
@property(copy) Action onDisappearedCallback;
-(id)initWithView:(id)view onAppeared:(Action)appearedHandler onResize:(Action)resizeHandler onDisappeared:(Action)disAppearedHandler ;
@end