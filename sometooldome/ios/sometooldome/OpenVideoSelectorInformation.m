//
//  OpenVideoSelectorInformation.m
//  cropfilterimagevideo
//
//  Created by 黎峰麟 on 2019/3/26.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "OpenVideoSelectorInformation.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

static OpenVideoInformationBlock  _infoBlock;
static OpenVideoFailurekBlock _errorBlock;

@interface OpenVideoSelectorInformation()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@end

@implementation OpenVideoSelectorInformation

+ (instancetype)shared {
  static OpenVideoSelectorInformation *_shared = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _shared = [[super allocWithZone:NULL] init];
  });
  return _shared;
}
// 防止外部调用alloc 或者 new
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
  return [OpenVideoSelectorInformation shared];
}

//// 防止外部调用copy  没有遵循协议可以不写
//- (id)copyWithZone:(nullable NSZone *)zone {
//  return [OpenVideoSelectorInformation shared];
//}
//
//- (id)mutableCopyWithZone:(nullable NSZone *)zone {
//  return [OpenVideoSelectorInformation shared];
//}

-(void)openType:(OpenSelector)type completion:(OpenVideoInformationBlock)completion failure:(OpenVideoFailurekBlock)failure{
 
//  ///申请麦克风权限
//  [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
//  }];
//  ///申请拍照权限
//  [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
//  }];
//  ///申请相册权限
//  [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
//  }];
  
  // 1. 实例化照片选择控制器
  UIImagePickerController *picker = [[UIImagePickerController alloc]init];
  if (type == OpenSelectorImage) {
    [picker setMediaTypes:@[@"public.image"]];
  }else if (type == OpenSelectorVideo){
    [picker setMediaTypes:@[@"public.movie"]];
    [picker setAllowsEditing:YES];
  }else if (type == OpenSelectorCameraVideo){
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.videoMaximumDuration = 10;
    picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
    picker.videoQuality = UIImagePickerControllerQualityTypeIFrame1280x720;
    picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
    [picker setAllowsEditing:NO];
  }else if (type == OpenSelectorCameraImage){
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
  
    picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    
  }
  
  [picker setDelegate:self];
  [self setBarButtonItemAppearanceColor:[UIColor blackColor]];
//  iOS8以后拍照的页面跳转会卡顿几秒中，加入这个属性，卡顿消失，啦啦啦
//  picker.modalPresentationStyle=UIModalPresentationOverCurrentContext;
  [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:picker animated:YES completion:nil];
  
  
  _infoBlock = [completion copy];
  _errorBlock = [failure copy];
  
}




- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
  
  [self setBarButtonItemAppearanceColor:[UIColor blackColor]];
  [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
  
  
  [self setBarButtonItemAppearanceColor:[UIColor blackColor]];
  
  NSURL *fileURL = info[UIImagePickerControllerMediaURL];
  //  PHAsset *asset = info[UIImagePickerControllerPHAsset];
  //  NSURL *refUrl = [NSURL URLWithString:@""];
  //  if (!asset) refUrl= info[UIImagePickerControllerReferenceURL];
  
//  NSURL *url = info[UIImagePickerControllerMediaURL];
  
//  [self analysisVideo:url complete:^(NSArray<UIImage *> * arrImages) {
//    NSLog(@"---------%@",arrImages);
//  }];

  [picker dismissViewControllerAnimated:YES completion:^{
    if (_infoBlock) _infoBlock(info);
  }];
  NSLog(@"裁剪结束s上传文件------------%@",fileURL.class);
}




#pragma mark - 设置导航栏左右的按钮的颜色

-(void)setBarButtonItemAppearanceColor:(UIColor *)color{
  
  [[UINavigationBar appearance]setTintColor:[UIColor blackColor]];
  
  UIBarButtonItem *barItem = [UIBarButtonItem appearance];
  NSShadow *shadow = [[NSShadow alloc] init];
  shadow.shadowOffset = CGSizeZero;
  NSDictionary *barItemTextAttr = @{
                                    NSForegroundColorAttributeName : color,
                                    NSShadowAttributeName : shadow,
                                    NSFontAttributeName : [UIFont systemFontOfSize:15]
                                    };
  
  [barItem setTitleTextAttributes:barItemTextAttr forState:UIControlStateNormal];
  [barItem setTitleTextAttributes:barItemTextAttr forState:UIControlStateHighlighted];
}




#pragma mark - 解析视频每秒第一帧的图像
- (void)analysisVideo:(NSURL *)videoURL complete:(void (^)(NSArray<UIImage *> *))complete{
  
  //  NSMutableArray * returnArr = [NSMutableArray array];
  
  AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil] ;  //或者直接使用相册的AVAsset
  long duration = round(asset.duration.value) / asset.duration.timescale;
  
  
  AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
  gen.appliesPreferredTrackTransform = YES;
  gen.requestedTimeToleranceBefore = kCMTimeZero;
  gen.requestedTimeToleranceAfter = kCMTimeZero;
  
  //每秒的第一帧
  NSMutableArray *arr = [NSMutableArray array];
  for (float i = 0; i < duration; i += 1) {
    /*
     CMTimeMake(a,b) a当前第几帧, b每秒钟多少帧
     */
    //这里加上0.35 是为了避免解析0s图片必定失败的问题
    CMTime time = CMTimeMake((i+0.35) * asset.duration.timescale, asset.duration.timescale);
    NSValue *value = [NSValue valueWithCMTime:time];
    [arr addObject:value];
  }
  
  NSMutableArray *arrImages = [NSMutableArray array];
  
  __block long count = 0;
  [gen generateCGImagesAsynchronouslyForTimes:arr
                            completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * error) {
    switch (result) {
      case AVAssetImageGeneratorSucceeded:
        [arrImages addObject:[UIImage imageWithCGImage:image]];
        break;
      case AVAssetImageGeneratorFailed:
        NSLog(@"第%ld秒图片解析失败", count);
        break;
      case AVAssetImageGeneratorCancelled:
        NSLog(@"取消解析视频图片");
        break;
    }
    
    count++;
    
    if (count == arr.count && complete) {
      dispatch_async(dispatch_get_main_queue(), ^{
        complete(arrImages);
      });
    }
  }];
  
}
@end
