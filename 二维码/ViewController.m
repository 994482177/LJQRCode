//
//  ViewController.m
//  二维码
//
//  Created by LiJie on 15/6/25.
//  Copyright (c) 2015年 LiJie. All rights reserved.
//

#import "ViewController.h"
#import "QRView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    __block QRView* view=nil;
    view=[QRView getQRViewWithFrame:self.view.bounds result:^(id result)
    {
        NSLog(@"%@", result);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2*NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                       {
                           [view startScan];
                       });
    }];
    
    //两个可选属性：
    view.QRScanSize=CGSizeMake(200, 200);
    view.QRBackgroundColor=[[UIColor orangeColor]colorWithAlphaComponent:0.8];
    
    [view startScan];
    [self.view addSubview:view];
}



@end
