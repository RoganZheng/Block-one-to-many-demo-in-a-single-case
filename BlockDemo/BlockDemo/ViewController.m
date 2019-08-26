//
//  ViewController.m
//  BlockDemo
//
//  Created by drogan Zheng on 2019/8/26.
//  Copyright © 2019 drogan Zheng. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 添加当前ViewController对象的block监听
    [[SingleInstance sharedInstance] addObserver:self callback:^{
        NSLog(@"running block in the ViewController!");
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 当需要去执行单例中的所有block块时
    [[SingleInstance sharedInstance] runBlockMethod];
}
@end
