
#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif

#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface RNSometool : NSObject <RCTBridgeModule>
@property (strong, nonatomic) NSURL *videoURL;
@property (nonatomic, strong) AVPlayerViewController *playerViewController;
@end
  
