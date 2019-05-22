//
//  OpenVideoSelectorInformation.h
//  cropfilterimagevideo
//
//  Created by 黎峰麟 on 2019/3/26.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIImage;
typedef void (^OpenVideoInformationBlock) (NSDictionary *info);
typedef void (^OpenVideoFailurekBlock)(NSError *error);

typedef enum : NSUInteger {
  OpenSelectorImage,
  OpenSelectorCameraImage,
  OpenSelectorVideo,
  OpenSelectorCameraVideo,
} OpenSelector;

NS_ASSUME_NONNULL_BEGIN

@interface OpenVideoSelectorInformation : NSObject

+(instancetype)shared;

-(void)openType:(OpenSelector)type completion:(OpenVideoInformationBlock)completion failure:(OpenVideoFailurekBlock)failure;

- (void)analysisVideo:(NSURL *)videoURL complete:(void (^)(NSArray<UIImage *> *))complete;
@end

NS_ASSUME_NONNULL_END
