//
//  QRView.m
//  二维码
//
//  Created by LiJie on 15/11/5.
//  Copyright © 2015年 LiJie. All rights reserved.
//

#import "QRView.h"
#import "QRCodeBackView.h"

#import <AVFoundation/AVFoundation.h>

@interface QRView ()<AVCaptureMetadataOutputObjectsDelegate>

@property(nonatomic, strong)QRBlock tempBlock;
@property(nonatomic, strong)AVCaptureSession* captureSession;//CaptureSession 这是个捕获会话，也就是说你可以用这个对象从输入设备捕获数据流
@property(nonatomic, strong)AVCaptureVideoPreviewLayer* videoPreviewLayer;//AVCaptureVideoPreviewLayer 可以通过输出设备展示被捕获的数据流。首先我们应该判断当前设备是否有捕获数据流的设备
@property(nonatomic, strong)AVCaptureMetadataOutput* captureOutput;
@property(nonatomic, strong)QRCodeBackView* backView;

@end

@implementation QRView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backView=[[QRCodeBackView alloc]initWithFrame:self.bounds];
        self.QRBackgroundColor=[[UIColor grayColor]colorWithAlphaComponent:0.8];
        self.QRScanSize=CGSizeMake(CGRectGetWidth(frame)/2.0, CGRectGetWidth(frame)/2.0);
    }
    return self;
}

+(instancetype)getQRViewWithFrame:(CGRect)frame result:(QRBlock)resultBlock
{
    QRView* tempSelf=[[QRView alloc]initWithFrame:frame];
    tempSelf.tempBlock=resultBlock;
    [tempSelf initScan];
    return tempSelf;
}
-(void)startScan
{
    [self.captureSession startRunning];
    [self.backView startRun];
}
-(void)stopScan
{
    [self.captureSession stopRunning];
    [self.backView stopRun];
}
-(void)setQRBackgroundColor:(UIColor *)QRBackgroundColor
{
    _QRBackgroundColor=QRBackgroundColor;
    self.backView.backgroundColor=_QRBackgroundColor;
}
-(void)setQRScanSize:(CGSize)QRScanSize
{
    _QRScanSize=QRScanSize;
    self.backView.scanSize=_QRScanSize;
    
    //设置扫描范围
    CGFloat width=_QRScanSize.width/CGRectGetWidth(self.frame);
    CGFloat height=_QRScanSize.height/CGRectGetHeight(self.frame);
    if (self.captureOutput!=nil)
    {
        [self.captureOutput setRectOfInterest:CGRectMake((1-height)/2, (1-width)/2, height, width)];
    }
}

//============   ++ ===================================

-(void)initScan
{
    AVCaptureDevice* captureDevice=[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError* error=nil;
    
    //判断是否有相机
    AVCaptureDeviceInput* deviceInput=[AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!deviceInput)
    {
        NSLog(@"出错啦：%@",error);
        return;
    }
    else
    {
        self.captureSession=[[AVCaptureSession alloc]init];
        [self.captureSession addInput:deviceInput];
        
        //输出
        self.captureOutput=[[AVCaptureMetadataOutput alloc]init];
        [self.captureSession addOutput:self.captureOutput];
        
        //设置默认扫描范围
        CGFloat width=self.QRScanSize.width/CGRectGetWidth(self.frame);
        CGFloat height=self.QRScanSize.height/CGRectGetHeight(self.frame);
        [self.captureOutput setRectOfInterest:CGRectMake((1-height)/2, (1-width)/2, height, width)];
        self.captureOutput.metadataObjectTypes=@[AVMetadataObjectTypeQRCode];
        
        //创建一个队列
        dispatch_queue_t dispatchQueue=dispatch_queue_create("myQueue", NULL);
        [self.captureOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
        [self.captureOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
        
        //显示相机捕获的场景
        self.videoPreviewLayer=[[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
        [self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        [self.videoPreviewLayer setFrame:self.layer.frame];
        [self.layer addSublayer:self.videoPreviewLayer];
        
        //设置背景
        [self addSubview:self.backView];
    }
    
}


#pragma mark 扫描代理
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    //判断是否有数据，是否是二维码
    if (metadataObjects!=nil && [metadataObjects count]>0)
    {
        AVMetadataMachineReadableCodeObject* metadataObject=[metadataObjects objectAtIndex:0];
        if ([[metadataObject type]isEqualToString:AVMetadataObjectTypeQRCode])
        {
            NSString* resultStr=metadataObject.stringValue;
            [self stopScan];
            if (self.tempBlock)
            {
                self.tempBlock(resultStr);
            }
        }
    }
}


@end
