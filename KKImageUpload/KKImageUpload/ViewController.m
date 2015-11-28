//
//  ViewController.m
//  KKImageUpload
//
//  Created by 周吾昆 on 15/11/28.
//  Copyright © 2015年 zhang_rongwu. All rights reserved.
//

#import "ViewController.h"
#import "KKUploadPhotoCollectionViewCell.h"
#import "HFPhotoPickerManager.h"

static NSString *collectionViewCellId = @"collectionViewCellId";
static CGFloat imageSize = 80;

@interface ViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property(nonatomic, strong) UICollectionView *collectionView; //添加图片,每个cell内有一个imageView
@property(nonatomic, strong) NSMutableArray *imageArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setCollectionView];
    self.view.backgroundColor = [UIColor purpleColor];
    self.imageArray = [NSMutableArray array];
}

#pragma mark  UICollectionView数据源方法
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 4;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    KKUploadPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionViewCellId forIndexPath:indexPath];
    //添加子控件,设置布局与控件图片
    [self addAndSetSubViews:cell indexPath:indexPath];
    return cell;
}

- (void)addAndSetSubViews:(KKUploadPhotoCollectionViewCell *)cell indexPath:(NSIndexPath *)indexPath{
    //清空子控件,解决重用问题
    NSArray *subviews = [[NSArray alloc] initWithArray:cell.contentView.subviews];
    for (UIView *subview in subviews) {
        [subview removeFromSuperview];
    }
    UIImageView *imageView = [[UIImageView alloc]init];
    [cell.contentView addSubview:imageView];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.layer.masksToBounds = YES;
    cell.tag = 11; //根据tag值设定是否可点击
    cell.imageView = imageView;
    cell.backgroundColor = [UIColor whiteColor];
    imageView.image = [UIImage imageNamed:@"add"];
    
    HFButton *cancleBtn = [[HFButton alloc]init];
    cell.cancleBtn = cancleBtn;
    [cell.contentView addSubview: cancleBtn];
    [cancleBtn setImage:[UIImage imageNamed:@"remove"] forState:UIControlStateNormal];
    cancleBtn.hidden = YES;
    
    cell.imageView.frame = CGRectMake(0, 0, imageSize, imageSize);
    cell.cancleBtn.frame = CGRectMake(0, 0, 20, 20);
    
    if (self.imageArray.count > indexPath.row) {
        if ([self.imageArray[indexPath.row] isKindOfClass:[UIImage class]]) {
            cell.imageView.image = nil;
            cell.imageView.image = self.imageArray[indexPath.row];
            cell.cancleBtn.hidden = NO;
            cell.tag = 10;
        }
    }
    cell.cancleBtn.indexPath = indexPath;
    [cell.cancleBtn addTarget:self action:@selector(cancleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
}
#pragma mark  collectionView代理方法,添加照片
//点击collectionView跳转到相册
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([collectionView cellForItemAtIndexPath:indexPath].tag == 11) {
        [[HFPhotoPickerManager shareInstace] showActionSheetInView:self.view fromController:self completionBlock:^(NSMutableArray *imageArray) {
            [self.collectionView reloadData];
            for (int i = 0; i<imageArray.count; i++) {
                if (self.imageArray.count < 4) {
                    UIImage *image = imageArray[i];
                    [self.imageArray addObject:image]; //上传图片保存到数组
                }
            }
        }];
    }
}

#pragma mark  删除图片
- (void)cancleBtnClick:(HFButton *)sender{
    if (sender.indexPath.row < self.imageArray.count) {
        if (self.imageArray[sender.indexPath.row] != nil) {
            [self.imageArray removeObjectAtIndex:sender.indexPath.row];
            sender.hidden = YES;
            [self.collectionView cellForItemAtIndexPath:sender.indexPath].tag = 11;
            [self.collectionView reloadData];
        }
    }
}

#pragma mark  设置CollectionView
- (void)setCollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake(imageSize, imageSize);
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 0;
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake((self.view.frame.size.width - imageSize * 4 - 30) * 0.5, 250, imageSize * 4 + 30, imageSize) collectionViewLayout:layout];
    self.collectionView = collectionView;
    [self.view addSubview:collectionView];
    
    [self.collectionView registerClass:[KKUploadPhotoCollectionViewCell class] forCellWithReuseIdentifier:collectionViewCellId];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor lightTextColor];

}



@end
