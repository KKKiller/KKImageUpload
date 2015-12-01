//
//  ViewController.m
//  AlertViewTest
//
//  Created by 周吾昆 on 15/11/30.
//  Copyright © 2015年 zhang_rongwu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightTextColor];

}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"妈蛋" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDestructive handler:nil];
//    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
//        textField.borderStyle =  UITextBorderStyleRoundedRect;
//    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
