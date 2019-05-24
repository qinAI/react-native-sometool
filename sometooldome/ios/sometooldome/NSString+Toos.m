//
//  NSString+Toos.m
//  sometooldome
//
//  Created by 黎峰麟 on 2019/5/21.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "NSString+Toos.h"

#import <AVFoundation/AVFoundation.h>

@implementation NSString (Toos)

#pragma mark - 创建图片选择后的保存地址
+(NSString *)imagePathByDateTime{
  //判断文件夹存在
  NSString *dir = [NSString stringWithFormat:@"%@react-native-sometool",NSTemporaryDirectory()];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  BOOL isDir = NO;
  BOOL existed = [fileManager fileExistsAtPath:dir isDirectory:&isDir];
  if ( !(isDir == YES && existed == YES) ) {//如果文件夹不存在
    [fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
  }
  
  NSString *newpath = [NSString stringWithFormat:@"%@/%.0f.jpg",dir,[[NSDate date] timeIntervalSince1970] * 1000];
  return newpath;
}


+(NSString *)videoPathBySuffixName:(NSString *)suffixName{
  //判断文件夹存在
  NSString *dir = [NSString stringWithFormat:@"%@react-native-sometool",NSTemporaryDirectory()];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  BOOL isDir = NO;
  BOOL existed = [fileManager fileExistsAtPath:dir isDirectory:&isDir];
  if ( !(isDir == YES && existed == YES) ) {//如果文件夹不存在
    [fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
  }
  
  NSString *newpath = [NSString stringWithFormat:@"%@/compress_%@",dir,suffixName];
  return newpath;
}



#pragma mark - 图片通过了什么操作
-(NSString *)filePathBySuffixName:(NSString *)suffixName{
  //判断文件夹存在
  NSString *dir = [NSString stringWithFormat:@"%@react-native-sometool",NSTemporaryDirectory()];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  BOOL isDir = NO;
  BOOL existed = [fileManager fileExistsAtPath:dir isDirectory:&isDir];
  if ( !(isDir == YES && existed == YES) ) {//如果文件夹不存在
    [fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
  }
  
  NSString *lastPathComponent = self.lastPathComponent;
  NSString *name = [lastPathComponent componentsSeparatedByString:@"."].firstObject;
  
  NSString *path = [NSString stringWithFormat:@"%@/%@_%@.jpg",fileManager,suffixName,name];
  return path;
}








-(NSString *)removeFilePathHeader{
  
  NSString *pathS = self;
  
  if ([self hasPrefix:@"file:"]) {
    NSArray *rslt = [pathS componentsSeparatedByString:@"/"];
    NSMutableArray *pfi = [NSMutableArray arrayWithCapacity:2];
    for (int i = 0; i < rslt.count; i++) {
      NSString *value = rslt[i];
      if ([value isEqualToString:@"file:"] || value.length == 0) {
        [pfi addObject:value];
      }else{
        break;
      }
    }
    NSMutableArray *muta = [NSMutableArray arrayWithArray:rslt];
    [muta removeObjectsInArray:pfi];
    pathS = [NSString stringWithFormat:@"/%@",[muta componentsJoinedByString:@"/"]];
  }
  
  return pathS;
}






+ (NSDictionary *)assetVideoInfo:(NSString *)source{
  
  AVAsset *asset = [AVAsset assetWithURL:[NSURL URLWithString:source]];
  AVAssetTrack *track = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
  
  if (track) {
    
    CGSize naturalSize = track.naturalSize;
    CGAffineTransform t = track.preferredTransform;
    BOOL isPortrait = t.a == 0 && abs(t.b) == 1 && t.d == 0;
    
    
    
    NSDictionary *info = @{
                           @"duration":@(asset.duration.value/asset.duration.timescale),
                           @"width": @(isPortrait ? naturalSize.height : naturalSize.width),
                           @"height": @(isPortrait ? naturalSize.width : naturalSize.height),
                           @"frameRate":@(track.nominalFrameRate),
                           @"bitrate":@(track.estimatedDataRate)
                           };
    return info;
  }
  
  
  return nil;
}


@end
