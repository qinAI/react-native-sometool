//
//  PhotoFrameFilterViewController.h
//  gdmap
//
//  Created by 黎峰麟 on 2019/5/7.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "BaseCFPViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface PhotoFrameFilterViewController : BaseCFPViewController

@property (nonatomic,assign) BOOL isFilter;  //是否是滤镜界面
@property (nonatomic,assign) int maxWH;      //最大限定宽高
@end

NS_ASSUME_NONNULL_END
