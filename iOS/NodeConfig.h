
@interface NodeConfig: NSObject

@property NSString* type;

@property float x;
@property float y;
@property float z;

@end

@interface BoxConfig: NodeConfig

@property float width; 
@property float height;
@property float length;

@end

@interface SphereConfig: NodeConfig

@property float radius; 

@end

@interface PyramidConfig: NodeConfig

@property float width; 
@property float height;
@property float length;

@end
