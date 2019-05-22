//
//  OurViewCell.m
//  圣诞树
//
//  Created by 黎峰麟 on 15/12/23.
//  Copyright © 2015年 黎峰麟. All rights reserved.
//

#import "OurViewCell.h"

@interface OurViewCell()



@end



@implementation OurViewCell


- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  
  self.backgroundColor = [UIColor clearColor];
  
  self.imageView.layer.cornerRadius = 5.0f;
  self.imageView.layer.masksToBounds = YES;
  
  self.titleLable.font = [UIFont systemFontOfSize:12];
  self.titleLable.textColor = [UIColor whiteColor];
  self.titleLable.backgroundColor = [UIColor clearColor];
  self.titleLable.textAlignment = NSTextAlignmentCenter;
  self.titleLable.numberOfLines = 4;
  
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  CGFloat width = self.bounds.size.width;
  CGFloat height = self.bounds.size.height;
  
  _imageView.frame = CGRectMake(0, 0, width, height - 20);
  _titleLable.frame = CGRectMake(0, height - 20, width, 20);
}


- (UIImageView *)imageView {
  if (_imageView == nil) {
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.clipsToBounds = YES;
    [self.contentView addSubview:imageView];
    _imageView = imageView;
  }
  return _imageView;
}


- (UILabel *)titleLable{
  if (_titleLable == nil) {
    UILabel *lable = [[UILabel alloc] init];
    [self.contentView addSubview:lable];
    _titleLable = lable;
  }
  return _titleLable;
}



@end
