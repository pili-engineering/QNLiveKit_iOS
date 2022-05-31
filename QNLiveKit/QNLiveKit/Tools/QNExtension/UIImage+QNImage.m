//
//  UIImage+QNImage.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/31.
//

#import "UIImage+QNImage.h"

@implementation UIImage (QNImage)

+ (UIImage *)getImageFromURL:(NSURL *)imageUrl {
    NSData *data = [NSData dataWithContentsOfURL:imageUrl];
    UIImage *image = [UIImage imageWithData:data];
    return image;
}

@end
