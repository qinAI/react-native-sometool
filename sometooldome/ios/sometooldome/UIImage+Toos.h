//
//  UIImage+Toos.h
//  sometooldome
//
//  Created by 黎峰麟 on 2019/5/21.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ResultPath)(NSDictionary *infos);

@interface UIImage (Toos)


//处理图片旋转的问题
- (UIImage *)fixOrientation;


//给定宽高最大值  等比缩放按照图片宽高
- (UIImage *)imageByResizeToMaxValue:(CGFloat)maxWH;

//把图片绘制到h矩形内
- (UIImage *)imageByResizeToSize:(CGSize)size;



-(UIImage *)imageAddWaterImage:(UIImage *)waterImage;

+ (void)fileFromePHAsset:(PHAsset * )asset complete:(ResultPath)result;


-(UIImage *)imageByResizeToSize:(CGSize)size
                     waterImage:(UIImage *)waterImage
                 waterImageRect:(CGRect)waterImageRect
                           text:(NSString *)text
                       textRect:(CGRect)textRect;

@end

NS_ASSUME_NONNULL_END
