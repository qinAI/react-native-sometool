//
//  KmaCropImageController.m
//  gdmap
//
//  Created by 黎峰麟 on 2019/4/30.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "KmaCropImageController.h"
#import "JPImageresizerView.h"

#import "PhotoFrameFilterViewController.h"

@interface KmaCropImageController ()
@property (weak, nonatomic) UIImageView *imageView;
@property (nonatomic, weak) JPImageresizerView *imageresizerView;
@end

@implementation KmaCropImageController



-(void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
  
  if (self.imageresizerView) {
    [self.imageresizerView recovery];
    self.imageView.hidden = YES;
    self.imageresizerView.hidden = NO;
  }
  
}


- (void)viewDidLoad {
  [super viewDidLoad];
  
  
  self.titleName = @"裁剪";
  self.rightTitleName = @"完成";
  
  
  CGSize size = self.contentView.bounds.size;
  CGFloat magin = 10;
  CGRect frame = CGRectMake(magin, magin, size.width - (2 * magin), size.height - (2 * magin));
  
  

  UIImageView *imageView = [UIImageView new];
  imageView.contentMode = UIViewContentModeScaleAspectFit;
  imageView.frame = frame;
  imageView.hidden = YES;
  [self.contentView addSubview:imageView];
  self.imageView = imageView;
  

  
  

  
  
  
  //  __weak typeof(self) weakSelf = self;
  JPImageresizerView *imageresizerView = [[JPImageresizerView alloc]
                                          initWithFrame:frame
                                          frameType:JPClassicFrameType
                                          resizeImage:self.cropImage
                                          strokeColor:[UIColor whiteColor]
                                          bgColor:KCFPCONTENTCOLOR
                                          maskAlpha:0.75
                                          verBaseMargin:10
                                          horBaseMargin:10
                                          resizeWHScale:0
                                          imageresizerIsCanRecovery:^(BOOL isCanRecovery) {  //重置
                                            //    __strong typeof(weakSelf) strongSelf = weakSelf;
                                            //    if (!strongSelf) return;
                                            //    strongSelf.recoveryBtn.enabled = isCanRecovery;
                                          }];
  [self.contentView addSubview:imageresizerView];
  self.imageresizerView = imageresizerView;
  

}


#pragma mark - 导航栏的按钮点击添加方法
-(void)back:(UIButton *)btn{
  __weak typeof(self) weakSelf = self;
  [self dismissViewControllerAnimated:YES completion:^{
    if (weakSelf.cancel) weakSelf.cancel(0);
  }];
}

-(void)rightBtnClick:(UIButton *)btn{
  __weak typeof(self) weakSelf = self;
  [self.imageresizerView imageresizerWithComplete:^(UIImage *resizeImage) {
    __strong typeof(weakSelf) strongSelf = weakSelf;
    if (!strongSelf) return;
    
    strongSelf.imageresizerView.hidden = YES;
    strongSelf.imageView.image = resizeImage;
    strongSelf.imageView.hidden = NO;
    
    [strongSelf dismissViewControllerAnimated:YES completion:^{
      if (strongSelf.done) {
        NSString *path = [NSString stringWithFormat:@"%@_iosCrop.%@",strongSelf.imagePath.stringByDeletingPathExtension,strongSelf.imagePath.pathExtension];
        NSData *imageData = UIImageJPEGRepresentation(resizeImage, 1);
        [imageData writeToFile:path atomically:YES];
        weakSelf.done(resizeImage,@{@"width":@(resizeImage.size.width),@"height":@(resizeImage.size.height),@"path":[NSString stringWithFormat:@"file://%@",path]});
      }
    }];
    
//    PhotoFrameFilterViewController *vc = [PhotoFrameFilterViewController new];
//    vc.cropImage = resizeImage;
//    vc.isFilter = YES;  //是否是添加滤镜界面
//    [strongSelf presentViewController:vc animated:YES completion:nil];
    
  }];
  
  

}



@end
