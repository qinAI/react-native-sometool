//
//  PhotoFrameFilterViewController.m
//  gdmap
//
//  Created by 黎峰麟 on 2019/5/7.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "PhotoFrameFilterViewController.h"
#import "OurViewCell.h"

#import "UIImage+Toos.h"

#import "GPUImage.h"

@interface PhotoFrameFilterViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (weak, nonatomic) UIImageView *imageView;
@property (nonatomic,weak) UICollectionView *collectionView;

@property (nonatomic,strong) NSArray *collectionViewDataSource;

@end

@implementation PhotoFrameFilterViewController


- (void)viewDidLoad {
    [super viewDidLoad];
  
  
  if (_isFilter) {
    
    _collectionViewDataSource = @[];
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
      NSArray *datas = @[[self filterImage:self.cropImage index:0],
                         [self filterImage:self.cropImage index:1],
                         [self filterImage:self.cropImage index:2],
                         [self filterImage:self.cropImage index:3],
                         [self filterImage:self.cropImage index:4],
                         [self filterImage:self.cropImage index:5],
                         [self filterImage:self.cropImage index:6],
                         [self filterImage:self.cropImage index:7],
                         [self filterImage:self.cropImage index:8],
                         [self filterImage:self.cropImage index:9],
                         [self filterImage:self.cropImage index:10]];
      weakSelf.collectionViewDataSource = datas;
      dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.collectionView reloadData];
      });
    });
    
  }else{
    _collectionViewDataSource = @[@{@"image":[UIImage imageNamed:@"相框"],@"title":@"相框"}];
  }
  
  
  self.titleName = _isFilter ? @"滤镜" : @"相框";
  self.rightTitleName = @"完成";
  
  
  CGSize size = self.contentView.bounds.size;
  CGFloat magin = 10;
  CGFloat itmeSize = 100;
  
  CGFloat imageViewW = size.width - (2 * magin);
  CGFloat imageViewH = size.height - (2 * magin) - itmeSize;
  
  
  
  CGRect frame = CGRectMake(magin, magin, imageViewW, imageViewH);
  
  
  UIImageView *imageView = [UIImageView new];
  imageView.frame = frame;
  imageView.image = self.cropImage;
  imageView.contentMode = UIViewContentModeScaleAspectFit;
  imageView.backgroundColor = [UIColor clearColor];
  [self.contentView addSubview:imageView];
  self.imageView = imageView;
  
  
  
  //底部广告位
  UICollectionViewFlowLayout* layout=[[UICollectionViewFlowLayout alloc]init];
  layout.minimumLineSpacing = 10.0f;
  layout.minimumInteritemSpacing = 0.0f;
  layout.itemSize = CGSizeMake(100, 100);
  layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

  
  UICollectionView *collectionView=[[UICollectionView alloc]initWithFrame:CGRectMake(magin, imageViewH + 2 * magin, imageViewW, itmeSize) collectionViewLayout:layout];
  collectionView.backgroundColor = [UIColor clearColor];
  collectionView.showsVerticalScrollIndicator = NO;
  collectionView.pagingEnabled  = YES;
  collectionView.dataSource=self;
  collectionView.delegate=self;
  collectionView.showsHorizontalScrollIndicator = NO;
  
//  [collectionView registerNib:[UINib nibWithNibName:@"OurViewCell" bundle:nil] forCellWithReuseIdentifier:@"OurViewCell"];
  [collectionView registerClass:[OurViewCell class] forCellWithReuseIdentifier:@"OurViewCell"];
  [self.contentView addSubview:collectionView];
  _collectionView = collectionView;
  
}






#pragma mark - 导航栏的按钮点击添加方法
-(void)back:(UIButton *)btn{
  
  __weak typeof(self) weakSelf = self;
  [self dismissViewControllerAnimated:YES completion:^{
    if (weakSelf.cancel) weakSelf.cancel(weakSelf.isFilter ? 1 : 2);
  }];
}


//// 从路径中获得完整的文件名（带后缀）
//exestr = [filePath lastPathComponent];
//NSLog(@"%@",exestr);
//// 获得文件名（不带后缀）
//exestr = [exestr stringByDeletingPathExtension];
//NSLog(@"%@",exestr);
//
//// 获得文件的后缀名（不带'.'）
//exestr = [filePath pathExtension];
//NSLog(@"%@",exestr);


-(void)rightBtnClick:(UIButton *)btn{
  
  __weak typeof(self) weakSelf = self;
  
  [self dismissViewControllerAnimated:YES completion:^{
    UIImage *resImage = weakSelf.imageView.image;  //结果图片
    NSString *name = weakSelf.isFilter ? @"_iosFilter" :@"_iosPhotoFrame";
    if (weakSelf.done) {
      
      NSString *path = [NSString stringWithFormat:@"%@%@.%@",self.imagePath.stringByDeletingPathExtension,name,self.imagePath.pathExtension];
      NSData *imageData = UIImageJPEGRepresentation(resImage, 1);
      [imageData writeToFile:path atomically:YES];
      
      weakSelf.done(resImage,@{@"width":@(resImage.size.width),@"height":@(resImage.size.height),@"path":[NSString stringWithFormat:@"file://%@",path]});
      
    }
  }];
}



#pragma mark － UICollectionViewCell的 代理和数据源

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
  return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
  
  return _collectionViewDataSource.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  
  OurViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"OurViewCell" forIndexPath:indexPath];
  NSDictionary *dic = _collectionViewDataSource[indexPath.item];
  cell.imageView.image = dic[@"image"];
  cell.titleLable.text = dic[@"title"];
  return cell;
  
}



-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
  
  [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
  
  NSDictionary *dic = _collectionViewDataSource[indexPath.item];
  UIImage *image = dic[@"image"];
  
  if (_isFilter) {
    _imageView.image  = image;
  }else{
    //左边不拉伸区域  右边不拉伸区域
//    image = [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
    //端盖 image resizableImageWithCapInsets:<#(UIEdgeInsets)#> resizingMode:<#(UIImageResizingMode)#>
    
    
//    CGFloat bili = 0.8; //分段平铺 边框
//    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * bili, image.size.width * bili, image.size.height * bili, image.size.width * bili)
//                                  resizingMode:UIImageResizingModeStretch];
    
    //缩放限定一下宽高
    UIImage *srcImage = [self.cropImage imageByResizeToMaxValue:self.maxWH];
//    UIImage *srcImage = self.cropImage;
    UIImage *resImage = [srcImage imageByResizeToSize:srcImage.size
                                           waterImage:image
                                       waterImageRect:CGRectMake(0, 0, srcImage.size.width, srcImage.size.height)
                                                 text:nil textRect:CGRectZero];
    _imageView.image  = resImage;
    
  }
  
}













#pragma mark - 添加滤镜效果  1~10
-(NSDictionary *)filterImage:(UIImage *)inputImage index:(NSInteger)index{
  
  NSString *title = nil;
  UIImage *image = nil;
  
  if (index == 1) {  //怀旧
    title = @"怀旧";
    GPUImageSepiaFilter *filter = [[GPUImageSepiaFilter alloc] init];
    image = [filter imageByFilteringImage:inputImage];
  }else if (index == 2){ //中间突出 四周暗
    title = @"视窗";
    GPUImageVignetteFilter *filter = [[GPUImageVignetteFilter alloc] init];
    image = [filter imageByFilteringImage:inputImage];
  }else  if (index == 3){   //朦胧加暗
    title = @"朦胧";
    GPUImageHazeFilter *filter = [[GPUImageHazeFilter alloc] init];
    image = [filter imageByFilteringImage:inputImage];
  }else  if (index == 4){   //饱和
    title = @"饱和度";
    GPUImageSaturationFilter *filter = [[GPUImageSaturationFilter alloc] init];
    filter.saturation = 1.5;
    image = [filter imageByFilteringImage:inputImage];
  }else  if (index == 5){   //亮度
    title = @"亮度";
    GPUImageBrightnessFilter *filter = [[GPUImageBrightnessFilter alloc] init];
    filter.brightness = 0.2;
    image = [filter imageByFilteringImage:inputImage];
  }else  if (index == 6){   //曝光度
    title = @"曝光度";
    GPUImageExposureFilter *filter = [[GPUImageExposureFilter alloc] init];
    filter.exposure = 0.2;
    image = [filter imageByFilteringImage:inputImage];
  }else  if (index == 7){   //素描
    title = @"素描";
    GPUImageSketchFilter *filter = [[GPUImageSketchFilter alloc] init];
    image = [filter imageByFilteringImage:inputImage];
  }else  if (index == 8){   //卡通
    title = @"卡通";
    GPUImageSmoothToonFilter *filter = [[GPUImageSmoothToonFilter alloc] init];
//    filter.blurRadiusInPixels = 0.5;
    image = [filter imageByFilteringImage:inputImage];
  }else if (index == 9){
    title = @"RGB蓝";
    GPUImageRGBFilter *filter = [[GPUImageRGBFilter alloc] init];
    //蓝
    filter.red = 0.8;
    filter.green = 0.8;
    filter.blue = 0.9;
    image = [filter imageByFilteringImage:inputImage];
  }else if (index == 10){
    title = @"RGB绿";
    GPUImageRGBFilter *filter = [[GPUImageRGBFilter alloc] init];
    //绿
    filter.red = 0.8;
    filter.green = 0.9;
    filter.blue = 0.8;
    image = [filter imageByFilteringImage:inputImage];
  }else if (index == 11){
    title = @"RGB红";
    GPUImageRGBFilter *filter = [[GPUImageRGBFilter alloc] init];
    //红
    filter.red = 0.9;
    filter.green = 0.8;
    filter.blue = 0.8;
    image = [filter imageByFilteringImage:inputImage];
  }else{
    title = @"经典";
    image = inputImage;
  }
  
  return @{@"image":image,@"title":title};
}


@end
