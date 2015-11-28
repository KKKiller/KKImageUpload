//
//  HFUploadPhotoCollectionViewCell.h
//  HotFitness
//
//  Created by 周吾昆 on 15/8/20.
//  Copyright (c) 2015年 HeGuangTongChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HFButton.h"

@interface KKUploadPhotoCollectionViewCell : UICollectionViewCell


@property(nonatomic, strong) UIButton *imageViewBtn;
@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, strong) HFButton *cancleBtn;
@property(nonatomic, strong) UIImage *image;

@end
