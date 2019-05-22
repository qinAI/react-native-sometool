//
//  BaseCFPViewController.h
//  gdmap
//
//  Created by 黎峰麟 on 2019/5/7.
//  Copyright © 2019 Facebook. All rights reserved.
//

#define KCFPNAVCOLOR [UIColor blackColor]
#define KCFPCONTENTCOLOR [UIColor colorWithWhite:0.2 alpha:1]


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseCFPViewController : UIViewController

@property (nonatomic,weak) UIView *contentView;
@property (nonatomic,weak) UIView *navView;

@property (nonatomic,copy) NSString *titleName;
@property (nonatomic,copy) NSString *rightTitleName;

-(void)back:(UIButton *)btn;
-(void)rightBtnClick:(UIButton *)btn;


//需要处理的l路径
@property (copy, nonatomic) NSString *imagePath;

@property (nonatomic,strong) UIImage *cropImage;


@property (nonatomic,copy) void (^done)(UIImage *image,NSDictionary *dic);
@property (nonatomic,copy) void (^cancel)(int type);
@end

NS_ASSUME_NONNULL_END
