# LJQRCode
一个非常简单的二维码扫描。

     QRView* view=[QRView getQRViewWithFrame:self.view.bounds result:^(NSString* result)
    {
        NSLog(@"%@", result);
    }];
    [view startScan];
    [self.view addSubview:view];
    
    添加如上代码即可实现 二维码扫描了。
    ![image](https://github.com/GooseJie/Images/raw/master/QR.png)
