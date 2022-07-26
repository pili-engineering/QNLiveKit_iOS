//
//  UIImage+QNImage.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/31.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (QNImage)

+ (UIImage *)getImageFromURL:(NSURL *)imageUrl;

+ (UIImage *)imageFromBundle:(NSString *)imageName;

@end

NS_ASSUME_NONNULL_END
