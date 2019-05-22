//
//  UIImage+Toos.m
//  sometooldome
//
//  Created by 黎峰麟 on 2019/5/21.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "UIImage+Toos.h"

@implementation UIImage (Toos)


-(UIImage *)imageByResizeToSize:(CGSize)size waterImage:(UIImage *)waterImage waterImageRect:(CGRect)waterImageRect text:(NSString *)text textRect:(CGRect)textRect{
  
  if (size.width <= 0 || size.height <= 0) return nil;
  
  
  UIGraphicsBeginImageContextWithOptions(size, NO, self.scale);
  [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
  
  if (waterImage) {
    [waterImage drawInRect:waterImageRect];
  }
  if (text.length) {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentCenter;
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:15],
                                 NSParagraphStyleAttributeName:style,
                                 NSForegroundColorAttributeName:[UIColor whiteColor]};
    [text drawInRect:textRect withAttributes:attributes];
  }
  
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return image;
}



-(UIImage *)imageAddWaterImage:(UIImage *)waterImage{
  
  if (self.size.width <= 0 || self.size.height <= 0 || waterImage == nil) return nil;
  
  
  UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
  [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
  
  CGFloat width = self.size.width;
  CGFloat height = self.size.height;
  CGFloat waterWidth = waterImage.size.width;
  CGFloat waterHeight = waterImage.size.height;
  
  CGFloat w = width * 0.2;
  CGFloat h = waterHeight * w / waterWidth;
  CGFloat bottomM = 10;
  
  CGRect rect = rect = CGRectMake((width - w) * 0.5, height - h - bottomM, w, h);
  
  [waterImage drawInRect:rect];
  
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return image;
}


- (UIImage *)imageByResizeToSize:(CGSize)size {
  if (size.width <= 0 || size.height <= 0) return nil;
  UIGraphicsBeginImageContextWithOptions(size, NO, self.scale);
  [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return image;
}

-(UIImage *)imageByResizeToMaxValue:(CGFloat)maxWH{
  
  if (maxWH <= 0) return nil;
  
  double width = self.size.width;
  double height = self.size.height;
  
  
  double newWidth = 0;
  double newHeight = 0;
  
  if (width > height) {
    newWidth = (double)maxWH;
    newHeight = (height * maxWH / width);
  }else{
    newWidth = (width * maxWH / height);
    newHeight = (double)maxWH;
  }
  
  
  return [self imageByResizeToSize:CGSizeMake(newWidth, newHeight)];
}




- (UIImage *)fixOrientation {
  
  // No-op if the orientation is already correct
  if (self.imageOrientation == UIImageOrientationUp) return self;
  
  // We need to calculate the proper transformation to make the image upright.
  // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
  CGAffineTransform transform = CGAffineTransformIdentity;
  
  //  UIImageOrientationUp,            // default orientation
  //  UIImageOrientationDown,          // 180 deg rotation
  //  UIImageOrientationLeft,          // 90 deg CCW
  //  UIImageOrientationRight,         // 90 deg CW
  //  UIImageOrientationUpMirrored,    // as above but image mirrored along other axis. horizontal flip
  //  UIImageOrientationDownMirrored,  // horizontal flip
  //  UIImageOrientationLeftMirrored,  // vertical flip
  //  UIImageOrientationRightMirrored, // vertical flip
  
  switch (self.imageOrientation) {
    case UIImageOrientationDown:
    case UIImageOrientationDownMirrored:
      transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
      transform = CGAffineTransformRotate(transform, M_PI);
      break;
      
    case UIImageOrientationLeft:
    case UIImageOrientationLeftMirrored:
      transform = CGAffineTransformTranslate(transform, self.size.width, 0);
      transform = CGAffineTransformRotate(transform, M_PI_2);
      break;
      
    case UIImageOrientationRight:
    case UIImageOrientationRightMirrored:
      transform = CGAffineTransformTranslate(transform, 0, self.size.height);
      transform = CGAffineTransformRotate(transform, -M_PI_2);
      break;
  }
  
  switch (self.imageOrientation) {
    case UIImageOrientationUpMirrored:
    case UIImageOrientationDownMirrored:
      transform = CGAffineTransformTranslate(transform, self.size.width, 0);
      transform = CGAffineTransformScale(transform, -1, 1);
      break;
      
    case UIImageOrientationLeftMirrored:
    case UIImageOrientationRightMirrored:
      transform = CGAffineTransformTranslate(transform, self.size.height, 0);
      transform = CGAffineTransformScale(transform, -1, 1);
      break;
  }
  
  // Now we draw the underlying CGImage into a new context, applying the transform
  // calculated above.
  CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                           CGImageGetBitsPerComponent(self.CGImage), 0,
                                           CGImageGetColorSpace(self.CGImage),
                                           CGImageGetBitmapInfo(self.CGImage));
  CGContextConcatCTM(ctx, transform);
  switch (self.imageOrientation) {
    case UIImageOrientationLeft:
    case UIImageOrientationLeftMirrored:
    case UIImageOrientationRight:
    case UIImageOrientationRightMirrored:
      // Grr...
      CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
      break;
      
    default:
      CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
      break;
  }
  
  // And now we just create a new UIImage from the drawing context
  CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
  UIImage *img = [UIImage imageWithCGImage:cgimg];
  CGContextRelease(ctx);
  CGImageRelease(cgimg);
  return img;
}





+ (void)fileFromePHAsset:(PHAsset * )asset complete:(ResultPath)result{
  
  
  NSArray *assetResources = [PHAssetResource assetResourcesForAsset:asset];
  
  
  if (asset.mediaType == PHAssetMediaTypeImage) {
    
    __block NSData * data;
    PHAssetResource *resource = [assetResources firstObject];
    PHImageRequestOptions * options = [[PHImageRequestOptions alloc] init];
    options.version = PHImageRequestOptionsVersionCurrent;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = YES;
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options: options
                                                resultHandler: ^(NSData * imageData, NSString * dataUTI, UIImageOrientation orientation, NSDictionary * info) {
                                                  data = [NSData dataWithData:imageData];
                                                }];
    
    if (result) {
      if (data.length <= 0) {
        result(@{});
      } else {
        result(@{@"image":data,@"name":resource.originalFilename});
      }
    }
  }else{
    
    PHAssetResource *resource;
    for (PHAssetResource *assetRes in assetResources) {
      if (assetRes.type == PHAssetResourceTypePairedVideo || assetRes.type == PHAssetResourceTypeVideo) {resource = assetRes;}
    }
    NSString *fileName = @"TempAssetVideo.mov";
    if (resource.originalFilename) {
      fileName = resource.originalFilename;
    }
    if (asset.mediaType == PHAssetMediaTypeVideo || asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
      PHVideoRequestOptions * options = [[PHVideoRequestOptions alloc] init];
      options.version = PHImageRequestOptionsVersionCurrent;
      options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
      NSString *PATH_MOVIE_FILE = [NSTemporaryDirectory() stringByAppendingPathComponent: fileName];
      [[NSFileManager defaultManager] removeItemAtPath:PATH_MOVIE_FILE error: nil];
      [[PHAssetResourceManager defaultManager] writeDataForAssetResource: resource toFile: [NSURL fileURLWithPath: PATH_MOVIE_FILE] options: nil completionHandler: ^(NSError * _Nullable error) {
        if (error) {
          result(@{});
        } else {
          NSData *data = [NSData dataWithContentsOfURL: [NSURL fileURLWithPath:PATH_MOVIE_FILE]];
          result(@{@"url":PATH_MOVIE_FILE,@"data":data});
        }
        //[[NSFileManager defaultManager] removeItemAtPath: PATH_MOVIE_FILE error: nil];
      }];
    } else {
      result(@{});
    }
  }
}

@end
