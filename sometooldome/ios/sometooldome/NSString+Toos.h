//
//  NSString+Toos.h
//  sometooldome
//
//  Created by 黎峰麟 on 2019/5/21.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Toos)

+(NSString *)imagePathByDateTime;
+(NSString *)videoPathBySuffixName:(NSString *)suffixName;

//通过源文件名称创建新的储存路径
-(NSString *)filePathBySuffixName:(NSString *)suffixName;

//删除file: 文件路径的头
-(NSString *)removeFilePathHeader;


//获取视频信息
+ (NSDictionary *)assetVideoInfo:(NSString *)source;

@end

NS_ASSUME_NONNULL_END
