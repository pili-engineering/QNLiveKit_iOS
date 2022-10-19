//
//  ImageButtonView.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/5/31.
//

#import <QNLiveKit/QNLiveKit.h>

NS_ASSUME_NONNULL_BEGIN

//带图片的button槽位
@interface ImageButtonView : QLiveView

@property (nonatomic, assign) BOOL selected;
//从bundle中读取
- (void)bundleNormalImage:(NSString *)normalImage selectImage:(NSString *)selectImage;
//从自己项目中读取
- (void)normalImage:(NSString *)normalImage selectImage:(NSString *)selectImage;
@end

NS_ASSUME_NONNULL_END
