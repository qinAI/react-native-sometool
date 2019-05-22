
#import "RNSometool.h"

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


#import "UIImage+Toos.h"
#import "NSString+Toos.h"

#import "ZLPhotoBrowser.h"
#import "TZImagePickerController.h"
#import "OpenVideoSelectorInformation.h"

#import "BaseCFPViewController.h"
#import "KmaCropImageController.h"
#import "PhotoFrameFilterViewController.h"

@implementation RNSometool

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()


#pragma mark - 跳转设置
RCT_EXPORT_METHOD(goToSetting:(NSString *)type)
{
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}




#pragma mark - 缩放图片大小按照宽高比   限制最大宽高  文件必须file:开头
RCT_EXPORT_METHOD(zoomImagePath:(NSString *)path maxWH:(int)maxWH callback:(RCTResponseSenderBlock)completion)
{
  
  NSString *imagePath = [path removeFilePathHeader];
  
  UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
  if (image) {
    image = [image fixOrientation];
    image = [image imageByResizeToMaxValue:maxWH];
    
    NSString *newPath = [path filePathBySuffixName:@"zoomImage"];
    
    NSData *data = UIImageJPEGRepresentation(image, 1);
    [data writeToFile:path atomically:YES];
    
    NSDictionary *events = @{@"path":[NSString stringWithFormat:@"file://%@",newPath],
                             @"width":@(image.size.width),
                             @"height":@(image.size.height),
                             @"size":@(data.length)};
    completion(@[@(200),events]);
  }else{
    completion(@[@(202),@{@"msg":@"图片不存在"}]);
  }
  
}


RCT_EXPORT_METHOD(imageWatermarkSrc:(NSString *)path watermark:(NSString *)waterpath callback:(RCTResponseSenderBlock)completion)
{
  
  UIImage *image = [UIImage imageWithContentsOfFile:[path removeFilePathHeader]];
  if (image == nil) completion(@[@(202),@{@"msg":@"图片不存在"}]);
  
  
  UIImage *water = [UIImage imageWithContentsOfFile:[waterpath removeFilePathHeader]];
  //如果为nil就用app图标
  if (water == nil) {
    NSString *key = @"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles";
    NSArray *icons = [[[NSBundle mainBundle] infoDictionary] valueForKeyPath:key];
    NSString *icon = [icons lastObject];
    water = [UIImage imageNamed:icon];
  }
  if (water == nil) completion(@[@(202),@{@"msg":@"水印图片不存在"}]);
  
  
  image = [image fixOrientation];
  UIImage *result = [image imageAddWaterImage:water];
  
  NSString *newPath = [path filePathBySuffixName:@"waterMarkImage"];
  
  NSData *data = UIImageJPEGRepresentation(result, 1);
  [data writeToFile:path atomically:YES];

  NSDictionary *events = @{@"path":[NSString stringWithFormat:@"file://%@",newPath],
                           @"width":@(image.size.width),
                           @"height":@(image.size.height),
                           @"size":@(data.length)};
  completion(@[@(200),events]);
}





RCT_EXPORT_METHOD(showSingleCrop:(RCTResponseSenderBlock)completion){
  [UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
  });
  
  TZImagePickerController *vc = [TZImagePickerController new];
  vc.allowPickingVideo = NO;           //运行选择视频
  vc.allowPickingGif = NO;
  vc.allowPickingOriginalPhoto = NO;   //不选择原图
  
  vc.maxImagesCount = 1;
  vc.showSelectBtn = NO;
  vc.allowCrop = YES;
  vc.needCircleCrop = NO;
  // 设置竖屏下的裁剪尺寸
  
  CGFloat width = [UIScreen mainScreen].bounds.size.width;
  CGFloat height = [UIScreen mainScreen].bounds.size.height;
  
  NSInteger left = 30;
  NSInteger widthHeight = width - 2 * left;
  NSInteger top = (height - widthHeight) / 2;
  vc.cropRect = CGRectMake(left, top, widthHeight, widthHeight);
  
  [vc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
    
    if (photos.count) {
      NSMutableArray *imageArr = [NSMutableArray arrayWithCapacity:photos.count];
      
      for (UIImage *image in photos) {
        
        NSString *fileURL = [NSString imagePathByDateTime];
        NSData *imageData = UIImageJPEGRepresentation(image, 1);
        [imageData writeToFile:fileURL atomically:YES];
        [imageArr addObject:@{@"cutPath":[NSString stringWithFormat:@"file://%@",fileURL],
                              @"width":@(image.size.width),
                              @"height":@(image.size.height),
                              @"size":@(imageData.length)}];
      }
      dispatch_async(dispatch_get_main_queue(), ^{
        completion(@[@200,imageArr]);
      });
    }else{
      completion(@[@202,@[]]);
    }
  }];
  
  
  [vc setImagePickerControllerDidCancelHandle:^{completion(@[@202,@[]]);}];
  [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:vc animated:YES completion:nil];
}



RCT_EXPORT_METHOD(showPictureSelector:(RCTResponseSenderBlock)completion)
{
  [UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
  });
  
  TZImagePickerController *vc = [TZImagePickerController new];
  vc.allowPickingVideo = NO;           //运行选择视频
  vc.allowPickingGif = NO;
  vc.allowPickingOriginalPhoto = NO;   //不选择原图
  vc.allowTakePicture = NO;
  vc.maxImagesCount = 9;
  
  [vc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
    NSLog(@"选择完成---%@",photos);
    
    if (photos.count) {
      NSMutableArray *imageArr = [NSMutableArray arrayWithCapacity:photos.count];
      
//      PHAsset *asset = assets[0];
//      NSString *fileName = [asset valueForKey:@"_filename"];
      
      for (UIImage *image in photos) {
        
        NSString *fileURL = [NSString imagePathByDateTime];
        NSData *imageData = UIImageJPEGRepresentation(image, 1);
        [imageData writeToFile:fileURL atomically:YES];
        [imageArr addObject:@{@"path":[NSString stringWithFormat:@"file://%@",fileURL],
                              @"width":@(image.size.width),
                              @"height":@(image.size.height),
                              @"size":@(imageData.length)}];
      }
      dispatch_async(dispatch_get_main_queue(), ^{
        completion(@[@200,imageArr]);
      });
    }else{
      completion(@[@202,@[]]);
    }
    
  }];
  
  [vc setImagePickerControllerDidCancelHandle:^{completion(@[@202,@[]]);}];
  [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:vc animated:YES completion:nil];
  
  
  
  
//  ZLPhotoActionSheet *ac = [[ZLPhotoActionSheet alloc] init];
//  ac.sender = [UIApplication sharedApplication].keyWindow.rootViewController;
//
//  //  //颜色，状态栏样式
//  ac.configuration.selectedMaskColor = [UIColor blackColor];
//  ac.configuration.navBarColor = [UIColor blackColor];
//  ac.configuration.navTitleColor = [UIColor whiteColor];
//  ac.configuration.bottomBtnsNormalTitleColor = [UIColor blackColor];
//  ac.configuration.bottomBtnsDisableBgColor = [UIColor blackColor];
//  ac.configuration.bottomViewBgColor = [UIColor whiteColor];
//  ac.configuration.statusBarStyle = UIStatusBarStyleLightContent;
//
//  ac.configuration.allowEditImage = NO;
//  ac.configuration.allowSelectVideo = NO;
//  ac.configuration.allowSelectOriginal = NO;
//  ac.configuration.allowTakePhotoInLibrary = NO;  //拍照按钮
//
//
//  //选择回调
//  __weak typeof(self) weakSelf = self;
//  [ac setSelectImageBlock:^(NSArray<UIImage *> * _Nonnull images, NSArray<PHAsset *> * _Nonnull assets, BOOL isOriginal) {
//    NSLog(@"选择完成---%@",images);
//
//    NSMutableArray *imageArr = [NSMutableArray arrayWithCapacity:images.count];
//
//    for (UIImage *image in images) {
//      NSString *fileURL = [weakSelf getZLPhotoBrowserImagePath:image];
//      NSData *imageData = UIImageJPEGRepresentation(image, 1);
//      [imageData writeToFile:fileURL atomically:YES];
//      [imageArr addObject:@{@"path":[NSString stringWithFormat:@"file://%@",fileURL],
//                            @"width":@(image.size.width),
//                            @"height":@(image.size.height),
//                            @"size":@(imageData.length)}];
//    }
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//      completion(@[@200,imageArr]);
//    });
//
//  }];
//  [ac setCancleBlock:^{
//    completion(@[@202,@[]]);
//  }];
//  [ac showPhotoLibrary];
}


#pragma mark - 相机拍照
RCT_EXPORT_METHOD(showCameraTakePicture:(RCTResponseSenderBlock)completion)
{
  [UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
  });
  
  
  [[OpenVideoSelectorInformation shared] openType:OpenSelectorCameraImage completion:^(NSDictionary *info) {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    NSString *fileURL = [NSString imagePathByDateTime];
    
    NSData *imageData = UIImageJPEGRepresentation([image fixOrientation], 1);
    [imageData writeToFile:fileURL atomically:YES];
    NSDictionary *res = @{@"path":[NSString stringWithFormat:@"file://%@",fileURL],
                          @"width":@(image.size.width),
                          @"height":@(image.size.height),
                          @"size":@(imageData.length)};
    dispatch_async(dispatch_get_main_queue(), ^{
      completion(@[@200,@[res]]);
    });
  } failure:^(NSError *error) {
    completion(@[@202,@[]]);
  }];
}


#pragma mark - 相机录像
RCT_EXPORT_METHOD(showCameraTakeVideo:(RCTResponseSenderBlock)completion)
{
  [UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
  });
  
  
  [[OpenVideoSelectorInformation shared] openType:OpenSelectorCameraVideo completion:^(NSDictionary *info) {
    
    NSURL *videoUrl = info[UIImagePickerControllerMediaURL];
    NSDictionary *res = @{@"path":videoUrl.absoluteString,
                          @"width":@(720),
                          @"height":@(1280),
                          @"size":@(-1)};
    dispatch_async(dispatch_get_main_queue(), ^{
      completion(@[@200,@[res]]);
    });
  } failure:^(NSError *error) {
    completion(@[@202,@[]]);
  }];
}


#pragma mark - 多选视频
RCT_EXPORT_METHOD(showVideosSelectorType:(BOOL)isSingle callback:(RCTResponseSenderBlock)completion)
{
  [UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
  });
  
  
  TZImagePickerController *vc = [TZImagePickerController new];
  
//  vc.iconThemeColor = [UIColor blackColor];
//  vc.showSelectedIndex = YES;
//  vc.oKButtonTitleColorNormal = [UIColor blackColor];
//  vc.oKButtonTitleColorDisabled = [UIColor darkGrayColor];
//  vc.naviBgColor = [UIColor blueColor];
//  vc.barItemTextColor = [UIColor yellowColor];
  
  vc.allowPickingImage = NO;
  vc.allowPickingGif = NO;
  vc.allowTakeVideo = NO;
  vc.allowPickingOriginalPhoto = NO;   //不选择原图
  vc.maxImagesCount = 9;
  
  if (!isSingle) {
    vc.allowPickingMultipleVideo = YES;
    [vc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
      
      if (assets.count) {
        //创建信号量
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        __block NSMutableArray *arr = [NSMutableArray arrayWithCapacity:assets.count];
        
        for (PHAsset *asset in assets) {
          
          dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            [UIImage fileFromePHAsset:asset complete:^(NSDictionary *infos) {
              NSString *url = infos[@"url"];
              NSData *data = infos[@"data"];
              NSDictionary *res = @{@"path":[NSString stringWithFormat:@"file://%@",url],
                                    @"width":@(asset.pixelWidth),
                                    @"height":@(asset.pixelHeight),
                                    @"size":@(data.length)};
              [arr addObject:res];
              
              //释放信号量
              dispatch_semaphore_signal(sem);
              
              if (arr.count == assets.count) {
                dispatch_async(dispatch_get_main_queue(), ^{
                  completion(@[@200,arr]);
                });
              }
            }];
            
          });
          
          //等待信号量
          dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        }
      }else{
        completion(@[@202,@[]]);
      }
    }];
    
  }else{
    [vc setDidFinishPickingVideoHandle:^(UIImage *coverImage, PHAsset *asset) {
      [UIImage fileFromePHAsset:asset complete:^(NSDictionary *infos) {
        NSString *url = infos[@"url"];
        NSData *data = infos[@"data"];
        NSDictionary *res = @{@"path":[NSString stringWithFormat:@"file://%@",url],
                              @"width":@(asset.pixelWidth),
                              @"height":@(asset.pixelHeight),
                              @"size":@(data.length)};
          dispatch_async(dispatch_get_main_queue(), ^{
            completion(@[@200,@[res]]);
          });
      }];
    }];
  }
  
  
  [vc setImagePickerControllerDidCancelHandle:^{completion(@[@202,@[]]);}];
  [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:vc animated:YES completion:nil];
  
  
  
  
//  ZLPhotoActionSheet *ac = [[ZLPhotoActionSheet alloc] init];
//  ac.sender = [UIApplication sharedApplication].keyWindow.rootViewController;
//
//  //  //颜色，状态栏样式
//  ac.configuration.selectedMaskColor = [UIColor blackColor];
//  ac.configuration.navBarColor = [UIColor blackColor];
//  ac.configuration.navTitleColor = [UIColor whiteColor];
//  ac.configuration.bottomBtnsNormalTitleColor = [UIColor blackColor];
//  ac.configuration.bottomBtnsDisableBgColor = [UIColor blackColor];
//  ac.configuration.bottomViewBgColor = [UIColor whiteColor];
//  ac.configuration.statusBarStyle = UIStatusBarStyleLightContent;
//
//  ac.configuration.allowSelectImage = NO;
//  ac.configuration.allowEditImage = NO;
//  ac.configuration.allowSelectOriginal = NO;
//  ac.configuration.allowTakePhotoInLibrary = NO;  //拍照按钮
//  ac.configuration.allowEditVideo = NO;
//  ac.configuration.allowSelectVideo = YES;
//  ac.configuration.maxSelectCount = 9;
//
//  //选择回调
//  [ac setSelectImageBlock:^(NSArray<UIImage *> * images, NSArray<PHAsset *> * assets, BOOL isOriginal) {
//
//    if (assets.count) {
//
//      //创建信号量
//      dispatch_semaphore_t sem = dispatch_semaphore_create(0);
//
//      __block NSMutableArray *arr = [NSMutableArray arrayWithCapacity:assets.count];
//
//      for (PHAsset *asset in assets) {
//
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//
//          NSLog(@"%@--- %@",[NSThread currentThread],asset.burstIdentifier);
//
//          [UIImage fileFromePHAsset:asset complete:^(NSDictionary *infos) {
//            NSString *url = infos[@"url"];
//            NSData *data = infos[@"data"];
//            NSDictionary *res = @{@"path":[NSString stringWithFormat:@"file://%@",url],
//                                  @"width":@(asset.pixelWidth),
//                                  @"height":@(asset.pixelHeight),
//                                  @"size":@(data.length)};
//            [arr addObject:res];
//
//            //释放信号量
//            dispatch_semaphore_signal(sem);
//
//            if (arr.count == assets.count) {
//              dispatch_async(dispatch_get_main_queue(), ^{
//                completion(@[@200,arr]);
//              });
//            }
//          }];
//
//        });
//
//        //等待信号量
//        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
//      }
//    }else{
//      completion(@[@202,@[]]);
//    }
//
//  }];
//  [ac setCancleBlock:^{
//    completion(@[@202,@[]]);
//  }];
//  [ac showPhotoLibrary];
}





RCT_EXPORT_METHOD(showPhotoFrameImageVc:(NSString *)imagePath maxWH:(int)maxWH callback:(RCTResponseSenderBlock)completion){
  
  [UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
  });
  
  NSString *pathS = [imagePath removeFilePathHeader];
  
  BaseCFPViewController *vc = nil;
  
  PhotoFrameFilterViewController *vcp = [PhotoFrameFilterViewController new];
  vcp.isFilter = NO;
  vcp.maxWH = maxWH;
  vc = vcp;
  vc.imagePath = pathS;
  vc.done = ^(UIImage *image, NSDictionary *dic) {
    dispatch_async(dispatch_get_main_queue(), ^{
      completion(@[@200,dic]);
    });
  };
  vc.cancel = ^(int type) {
    dispatch_async(dispatch_get_main_queue(), ^{
      completion(@[@202,@"取消"]);
    });
  };
  [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:vc animated:YES completion:nil];
}

RCT_EXPORT_METHOD(showCropFilterImageVc:(NSString *)imagePath type:(int)type callback:(RCTResponseSenderBlock)completion)
{
  
  [UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
  });
  
  NSString *pathS = [imagePath removeFilePathHeader];
  
  
  BaseCFPViewController *vc = nil;
  
  if (type == 0) {
    vc = [KmaCropImageController new];
  }else if (type == 1){
    PhotoFrameFilterViewController *vcp = [PhotoFrameFilterViewController new];
    vcp.isFilter = YES;
    vc = vcp;
  }else if (type == 2){
    
  }
  
  vc.imagePath = pathS;
  vc.done = ^(UIImage *image, NSDictionary *dic) {
    dispatch_async(dispatch_get_main_queue(), ^{
      completion(@[@200,dic]);
    });
  };
  vc.cancel = ^(int type) {
    dispatch_async(dispatch_get_main_queue(), ^{
      completion(@[@202,@"取消"]);
    });
  };
  [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:vc animated:YES completion:nil];
  
}



@end
  
