//
//  ImageButtonComponent.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/31.
//

#import <QNLiveKit/QNLiveKit.h>

NS_ASSUME_NONNULL_BEGIN

//带图片的button槽位
@interface ImageButtonComponent : QLiveComponent

@property (nonatomic, assign) BOOL selected;

- (void)normalImage:(NSString *)normalImage selectImage:(NSString *)selectImage;

@end

NS_ASSUME_NONNULL_END
