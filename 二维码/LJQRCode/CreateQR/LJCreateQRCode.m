//
//  LJCreateQRCode.m
//  二维码
//
//  Created by LiJie on 2017/1/12.
//  Copyright © 2017年 celink. All rights reserved.
//

#import "LJCreateQRCode.h"

@implementation LJCreateQRCode

/**  生成一张普通的二维码， 正方形的， 自定义宽度 */
+(UIImage*)createGenerateQRImageFromString:(NSString*)dataStr imageWidth:(CGFloat)width{
    
    // 1、创建滤镜对象
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    // 恢复滤镜的默认属性
    [filter setDefaults];
    
    // 2、设置数据
    NSString *info = dataStr;
    // 将字符串转换成
    NSData *infoData = [info dataUsingEncoding:NSUTF8StringEncoding];
    
    // 通过KVC设置滤镜inputMessage数据
    [filter setValue:infoData forKeyPath:@"inputMessage"];
    
    // 3、获得滤镜输出的图像
    CIImage *outputImage = [filter outputImage];
    
    //放大图片 到像素点的三倍
    outputImage = [outputImage imageByApplyingTransform:CGAffineTransformMakeScale(width/23*3, width/23*3)];
    
    return [UIImage imageWithCIImage:outputImage];
}

/**  生成一张 中间 带有logo的 二维码*/
+(UIImage*)createLogoQRImageFromString:(NSString*)dataStr logoImage:(UIImage*)logoImage imageWidth:(CGFloat)width{
    // 1、创建滤镜对象
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    // 恢复滤镜的默认属性
    [filter setDefaults];
    
    // 2、设置数据
    NSString *string_data = dataStr;
    // 将字符串转换成 NSdata (虽然二维码本质上是字符串, 但是这里需要转换, 不转换就崩溃)
    NSData *qrImageData = [string_data dataUsingEncoding:NSUTF8StringEncoding];
    
    // 设置过滤器的输入值, KVC赋值
    [filter setValue:qrImageData forKey:@"inputMessage"];
    
    // 3、获得滤镜输出的图像
    CIImage *outputImage = [filter outputImage];
    
    // 图片小于(27,27),我们需要放大
    outputImage = [outputImage imageByApplyingTransform:CGAffineTransformMakeScale(width/23*3, width/23*3)];
    
    // 4、将CIImage类型转成UIImage类型
    UIImage *start_image = [UIImage imageWithCIImage:outputImage];
    
    
    // - - - - - - - - - - - - - - - - 添加中间小图标 - - - - - - - - - - - - - - - -
    // 5、开启绘图, 获取图形上下文 (上下文的大小, 就是二维码的大小)
    UIGraphicsBeginImageContext(start_image.size);
    
    // 把二维码图片画上去 (这里是以图形上下文, 左上角为(0,0)点
    [start_image drawInRect:CGRectMake(0, 0, start_image.size.width, start_image.size.height)];
    
    // 再把小图片画上去
    UIImage *icon_image = logoImage;
    CGFloat icon_imageW = start_image.size.width * 0.2;
    CGFloat icon_imageH = start_image.size.height * 0.2;
    CGFloat icon_imageX = (start_image.size.width - icon_imageW) * 0.5;
    CGFloat icon_imageY = (start_image.size.height - icon_imageH) * 0.5;
    
    [icon_image drawInRect:CGRectMake(icon_imageX, icon_imageY, icon_imageW, icon_imageH)];
    
    // 6、获取当前画得的这张图片
    UIImage *final_image = UIGraphicsGetImageFromCurrentImageContext();
    
    // 7、关闭图形上下文
    UIGraphicsEndImageContext();
    
    return final_image;
}

/**  生成一张 彩色的二维码 */
+(UIImage*)createColorQRImageFromString:(NSString*)dataStr bgColor:(UIColor*)bgColor QRColor:(UIColor *)QRColor imageWidth:(CGFloat)width{
    
    // 1、创建滤镜对象
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    // 恢复滤镜的默认属性
    [filter setDefaults];
    
    // 2、设置数据
    NSString *string_data = dataStr;
    // 将字符串转换成 NSdata (虽然二维码本质上是字符串, 但是这里需要转换, 不转换就崩溃)
    NSData *qrImageData = [string_data dataUsingEncoding:NSUTF8StringEncoding];
    
    // 设置过滤器的输入值, KVC赋值
    [filter setValue:qrImageData forKey:@"inputMessage"];
    
    // 3、获得滤镜输出的图像
    CIImage *outputImage = [filter outputImage];
    
    // 图片我们需要放大, 默认只有 23*23，
    outputImage = [outputImage imageByApplyingTransform:CGAffineTransformMakeScale(width/23*3, width/23*3)];
    
    
    // 4、创建彩色过滤器(彩色的用的不多)
    CIFilter * color_filter = [CIFilter filterWithName:@"CIFalseColor"];
    
    // 设置默认值
    [color_filter setDefaults];
    
    // 5、KVC 给私有属性赋值
    [color_filter setValue:outputImage forKey:@"inputImage"];
    
    // 6、需要使用 CIColor
    CGColorRef cgBgColor = bgColor.CGColor;
    CGColorSpaceRef  space= CGColorGetColorSpace(cgBgColor);
    const CGFloat* components=CGColorGetComponents(cgBgColor);
    cgBgColor =CGColorCreate(space, components);
    //kCIInputAngleKey
    [color_filter setValue:[CIColor colorWithCGColor:QRColor.CGColor] forKey:@"inputColor0"];
    [color_filter setValue:[CIColor colorWithCGColor:cgBgColor] forKey:@"inputColor1"];
    
    // 7、设置输出
    CIImage *colorImage = [color_filter outputImage];
    UIImage *resultIamge = [UIImage imageWithCIImage:colorImage];
    return resultIamge;
}

/**  生成一张 带有logo的彩色 二维码 */
+(UIImage*)createLogoAndColorQRImageFromString:(NSString*)dataStr logoImage:(UIImage*)logoImage bgColor:(UIColor*)bgColor QRColor:(UIColor *)QRColor imageWidth:(CGFloat)width{
    
    
    // 1、创建滤镜对象
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    // 恢复滤镜的默认属性
    [filter setDefaults];
    
    // 2、设置数据
    NSString *string_data = dataStr;
    // 将字符串转换成 NSdata (虽然二维码本质上是字符串, 但是这里需要转换, 不转换就崩溃)
    NSData *qrImageData = [string_data dataUsingEncoding:NSUTF8StringEncoding];
    
    // 设置过滤器的输入值, KVC赋值
    [filter setValue:qrImageData forKey:@"inputMessage"];
    
    // 3、获得滤镜输出的图像
    CIImage *outputImage = [filter outputImage];
    
    // 图片我们需要放大, 默认只有 23*23，
    outputImage = [outputImage imageByApplyingTransform:CGAffineTransformMakeScale(width/23*3, width/23*3)];
    
    
    // 4、创建彩色过滤器(彩色的用的不多)
    CIFilter * color_filter = [CIFilter filterWithName:@"CIFalseColor"];
    
    // 设置默认值
    [color_filter setDefaults];
    
    // 5、KVC 给私有属性赋值
    [color_filter setValue:outputImage forKey:@"inputImage"];
    
    // 6、需要使用 CIColor
    [color_filter setValue:[CIColor colorWithCGColor:QRColor.CGColor] forKey:@"inputColor0"];
    [color_filter setValue:[CIColor colorWithCGColor:bgColor.CGColor] forKey:@"inputColor1"];
    
    // 7、设置输出
    CIImage *colorImage = [color_filter outputImage];
    UIImage *start_image = [UIImage imageWithCIImage:colorImage];
    
    // - - - - - - - - - - - - - - - - 添加中间小图标 - - - - - - - - - - - - - - - -
    // 5、开启绘图, 获取图形上下文 (上下文的大小, 就是二维码的大小)
    UIGraphicsBeginImageContext(start_image.size);
    
    // 把二维码图片画上去 (这里是以图形上下文, 左上角为(0,0)点
    [start_image drawInRect:CGRectMake(0, 0, start_image.size.width, start_image.size.height)];
    
    // 再把小图片画上去
    UIImage *icon_image = logoImage;
    CGFloat icon_imageW = start_image.size.width * 0.2;
    CGFloat icon_imageH = start_image.size.height * 0.2;
    CGFloat icon_imageX = (start_image.size.width - icon_imageW) * 0.5;
    CGFloat icon_imageY = (start_image.size.height - icon_imageH) * 0.5;
    
    [icon_image drawInRect:CGRectMake(icon_imageX, icon_imageY, icon_imageW, icon_imageH)];
    
    // 6、获取当前画得的这张图片
    UIImage *final_image = UIGraphicsGetImageFromCurrentImageContext();
    
    // 7、关闭图形上下文
    UIGraphicsEndImageContext();
    
    return final_image;
}


#pragma mark - ================ private 不需要的方法了。 ==================
/** 根据CIImage生成指定大小的UIImage */
+ (UIImage *)createUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

@end
