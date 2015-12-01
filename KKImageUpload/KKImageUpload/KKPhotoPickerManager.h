//
//  HFPhotoPickerManager.h
//  HotFitness
//
//  Created by 周吾昆 on 15/10/31.
//  Copyright © 2015年 HeGuangTongChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface KKPhotoPickerManager : NSObject

+ (instancetype)shareInstace;

typedef void (^CompelitionBlock)(NSMutableArray *imageArray);

- (void)showActionSheetInView:(UIView *)inView
               fromController:(UIViewController *)fromController
              completionBlock:(CompelitionBlock)completionBlock;
@end
