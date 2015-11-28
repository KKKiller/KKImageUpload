//
//  HFPhotoPickerManager.m
//  HotFitness
//
//  Created by 周吾昆 on 15/10/31.
//  Copyright © 2015年 HeGuangTongChen. All rights reserved.
//

#import "HFPhotoPickerManager.h"
#import "DNImagePickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "DNAsset.h"
@interface HFPhotoPickerManager()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,DNImagePickerControllerDelegate>

@property (nonatomic, weak) UIViewController *fromController;
@property (nonatomic, copy) CompelitionBlock completionBlcok;
@property(nonatomic, strong) NSMutableArray *imageArray; //拍照或者相册获取图片
@property(nonatomic, strong) NSArray *imageAsset;

@end
@implementation HFPhotoPickerManager
+ (instancetype)shareInstace {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once (&once, ^{
        sharedInstance = [[HFPhotoPickerManager alloc] init];
        [[NSNotificationCenter defaultCenter]addObserver:sharedInstance selector:@selector(callBackImageData:) name:@"finishedInvertImage" object:nil];
    });
    return sharedInstance;
}
- (void)callBackImageData:(NSNotification *)noti{
    NSDictionary *dict = noti.userInfo;
    NSInteger num = [[dict valueForKey:@"number"] integerValue];
    if (num == self.imageAsset.count - 1) {
        self.completionBlcok(self.imageArray);
    }
}

- (void)showActionSheetInView:(UIView *)inView
               fromController:(UIViewController *)fromController
                   completionBlock:(CompelitionBlock)completionBlock{
    self.completionBlcok = [completionBlock copy];
    self.fromController = fromController;

    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"选择照片" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册选取",@"拍照上传", nil];
    [actionSheet showInView:inView];
    return;
}


#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) { // 从相册选择
        if ([self isPhotoLibraryAvailable]) {
            DNImagePickerController *imagePicker = [[DNImagePickerController alloc] init];
            imagePicker.imagePickerDelegate = self;
            [self.fromController presentViewController:imagePicker animated:YES completion:nil];
        }
    } else if (buttonIndex == 1) { // 拍照
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self.fromController presentViewController:picker animated:YES completion:nil];
    }
    return;
}

#pragma mark - UIImagePickerControllerDelegate
// 拍照
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    __block UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    if (image && self.completionBlcok) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.imageArray removeAllObjects];
                [self.imageArray addObject:image];
                //照片回传
                self.completionBlcok(self.imageArray);
            });
        });
    }
    return;
}

// 取消
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

#pragma mark  ===== 选择照片 =====

#pragma mark - DNImagePickerControllerDelegate
//从相册读取照片,保存到本地数组
- (void)dnImagePickerController:(DNImagePickerController *)imagePickerController sendImages:(NSArray *)imageAssets isFullImage:(BOOL)fullImage
{
    [self loadImageWithImageAssets:imageAssets];
    self.imageAsset = imageAssets;

}

#pragma mark  加载相册图片
- (void)loadImageWithImageAssets:(NSArray *)imageAssets{
    //清除上次获取的图片
    [self.imageArray removeAllObjects];
    //转换图片格式
    for ( int i = 0; i<imageAssets.count; i++) {
        DNAsset *dnasset = imageAssets[i];
        ALAssetsLibrary *lib = [ALAssetsLibrary new];
        __weak typeof(self) weakSelf = self;
        [lib assetForURL:dnasset.url resultBlock:^(ALAsset *asset){
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (asset) {
                [strongSelf setImageViewWithasset:asset index:i];
            } else {
                [lib enumerateGroupsWithTypes:ALAssetsGroupPhotoStream
                                   usingBlock:^(ALAssetsGroup *group, BOOL *stop)
                 {
                     [group enumerateAssetsWithOptions:NSEnumerationReverse
                                            usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                                
                                                if([[result valueForProperty:ALAssetPropertyAssetURL] isEqual:dnasset.url])
                                                {
                                                    [strongSelf setImageViewWithasset:result index:i];
                                                    *stop = YES;
                                                }
                                            }];
                 }
                                 failureBlock:^(NSError *error)
                 {
                     [strongSelf setImageViewWithasset:nil index:i];
                 }];
            }
            
            NSDictionary *dict = @{@"number":[NSString stringWithFormat:@"%zd",i]};
            [[NSNotificationCenter defaultCenter]postNotificationName:@"finishedInvertImage" object:nil userInfo:dict];
        } failureBlock:^(NSError *error){
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf setImageViewWithasset:nil index:i];
        }];
    }
}

//设置图片
- (void)setImageViewWithasset:(ALAsset *)asset index:(int)index{
    if (!asset) {
        return;
    }
    UIImage *image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
    [self.imageArray addObject:image];
}
//取消选择照片
- (void)dnImagePickerControllerDidCancel:(DNImagePickerController *)imagePicker
{
    [imagePicker dismissViewControllerAnimated:YES completion:^{
    }];
}




#pragma mark  ===== 判断手机是否有各种权限 =====

- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}
- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
//- (BOOL)canTakePhoto {
//
//    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
//}
- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

#pragma mark  ===== 懒加载 =====
- (NSMutableArray *)imageArray {
    if (_imageArray == nil) {
        _imageArray = [NSMutableArray array];
    }
    return _imageArray;
}
- (NSArray *)imageAsset {
    if (_imageAsset == nil) {
        _imageAsset = [[NSArray alloc]init];
    }
    return _imageAsset;
}
@end
