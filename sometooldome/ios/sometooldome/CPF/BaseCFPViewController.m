//
//  BaseCFPViewController.m
//  gdmap
//
//  Created by 黎峰麟 on 2019/5/7.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "BaseCFPViewController.h"

@interface BaseCFPViewController ()
@property (nonatomic,weak) UIButton *backBtn;
@property (nonatomic,weak) UIButton *titleBtn;
@property (nonatomic,weak) UIButton *rightBtn;
@end

@implementation BaseCFPViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = KCFPCONTENTCOLOR;
  
  CGFloat height = [UIApplication sharedApplication].statusBarFrame.size.height;   //44 刘海屏幕  普通 20
  CGSize size = [UIScreen mainScreen].bounds.size;
  
  //  CGFloat magin = 10;
  //  CGFloat top = 88;
  //  CGFloat bottom = 34;
  
  UIImage *image = [UIImage imageWithContentsOfFile:_imagePath];
  _cropImage = image;
  
  
  //添加导航栏
  CGFloat navH = height + 44;
  CGFloat btnW = 80;
  UIView *navView = [UIView new];
  navView.frame = CGRectMake(0, 0, size.width, navH);
  navView.backgroundColor = KCFPNAVCOLOR;
  [self.view addSubview:navView];
  self.navView = navView;
  
  
  UIButton *back = [UIButton new];
  back.frame = CGRectMake(0, height, btnW, 44);
  [back setImage:[UIImage imageNamed:@"arrow_pointing_left"] forState:UIControlStateNormal];
  back.imageEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 40);
  back.imageView.contentMode = UIViewContentModeScaleAspectFit;
  back.titleLabel.font = [UIFont systemFontOfSize:17];
  [back addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
  [navView addSubview:back];
  self.backBtn = back;
  
  UIButton *title = [UIButton new];
  title.frame = CGRectMake(0, 0, btnW, 44);
  title.center = CGPointMake(size.width * 0.5, height + 22);
  title.titleLabel.font = [UIFont systemFontOfSize:20];
  [title setTitle:@"" forState:0];
  [navView addSubview:title];
   self.titleBtn = title;
  
  UIButton *cropBtn = [UIButton new];
  cropBtn.frame = CGRectMake(size.width - btnW, height, btnW, 44);
  [cropBtn setTitle:@"裁剪" forState:0];
  cropBtn.titleLabel.font = [UIFont systemFontOfSize:15];
  [cropBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
  [navView addSubview:cropBtn];
   self.rightBtn = cropBtn;
  
  
  UIView *contentView = [UIView new];
  contentView.frame = CGRectMake(0, navH, size.width, size.height - navH - (height > 20 ? 34 : 0));
  contentView.backgroundColor = [UIColor clearColor];
  [self.view addSubview:contentView];
  self.contentView = contentView;
  
  
}


-(void)setTitleName:(NSString *)titleName{
  _titleName = titleName;
  [self.titleBtn setTitle:titleName forState:0];
}

-(void)setRightTitleName:(NSString *)rightTitleName{
  _rightTitleName = rightTitleName;
  [self.rightBtn setTitle:rightTitleName forState:0];
}



-(void)back:(UIButton *)btn{}
-(void)rightBtnClick:(UIButton *)btn{}


@end
