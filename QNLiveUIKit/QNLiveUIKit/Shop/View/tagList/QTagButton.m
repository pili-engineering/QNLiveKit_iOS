//
//  QTagButton.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/7/13.
//

#import "QTagButton.h"
extern CGFloat const imageViewWH;
@implementation QTagButton

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.imageView.frame.size.width <= 0) return;
    
    CGFloat btnW = self.bounds.size.width;
    CGFloat btnH = self.bounds.size.height;

    self.titleLabel.frame = CGRectMake(_margin, self.titleLabel.frame.origin.y, self.titleLabel.frame.size.width, self.titleLabel.frame.size.height);
    
    CGFloat imageX = btnW - self.imageView.frame.size.width -  _margin;
    self.imageView.frame = CGRectMake(imageX, (btnH - imageViewWH) * 0.5, imageViewWH, imageViewWH);
//    NSLog(@"%@",NSStringFromCGRect(self.frame));
//    NSLog(@"%@",NSStringFromCGRect(self.imageView.frame));
}

- (void)setHighlighted:(BOOL)highlighted {}

@end
