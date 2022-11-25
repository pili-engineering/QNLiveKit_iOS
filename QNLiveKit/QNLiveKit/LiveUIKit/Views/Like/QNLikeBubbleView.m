//
//  QNLikeBubbleView.m
//  QNLiveKit
//
//  Created by sheng wang on 2022/11/24.
//

#import "QNLikeBubbleView.h"

@interface QNLikeBubbleView ()

@property (nonatomic, strong) NSArray<NSString *> *bubbleImages;
@property (nonatomic, strong) UIImageView *bubbleImageView;

@end

@implementation QNLikeBubbleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.bubbleImages = [NSArray arrayWithObjects:@"like_bubble_01",
                             @"like_bubble_02",
                             @"like_bubble_03",
                             @"like_bubble_04",
                             @"like_bubble_05",
                             nil];
        
        [self addSubview:self.bubbleImageView];
    }
    return self;
}

- (void)layoutSubviews {
    [self.bubbleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self);
    }];
}

- (UIImageView *)bubbleImageView {
    if (!_bubbleImageView) {
        uint32_t idx = arc4random() % self.bubbleImages.count;
        NSString *imageName = [self.bubbleImages objectAtIndex:idx];
        
        _bubbleImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_bubbleImageView setImage:[UIImage imageNamed:imageName]];
    }
    return _bubbleImageView;
}




- (void)bubbleWithMode:(NSInteger)mode {
    [self easeOutWithComplete:^(BOOL finished) {
        switch (mode) {
            case 1:
                [self disappearWithDuration:2.6 delay:0.12];
                [self moveWithDuration:2.6];
                [self bounceWithDuration:2.6 offset:24];
                break;
                
            case 2:
                [self disappearWithDuration:1.6 delay:0.12];
                [self moveWithDuration:1.6];
                [self bounceWithDuration:1.6 offset:-24];
                break;
                
            default:
                [self disappearWithDuration:2.3 delay:0.12];
                [self moveWithDuration:2.3];
                [self bounceWithDuration:2.3 offset:30];
                break;
        }
    }];
}



- (void)easeOutWithComplete:(void (^ __nullable)(BOOL finished))complete {
    self.transform = CGAffineTransformMakeScale(0.0, 0.0);
    [UIView animateWithDuration:0.2 //动画时长 单位为秒
                          delay:0   //动画延时， 不需要延时，设0
                        options:UIViewAnimationOptionCurveEaseInOut //执行的动画选项
                     animations:^{ //动画的内容
                         self.transform = CGAffineTransformMakeScale(1.0, 1.0);
                     } completion:^(BOOL finished) {
                         complete(finished);
                     }];
}

- (void)disappearWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay {
    [UIView animateWithDuration:duration
                          delay:delay
                        options:UIViewAnimationOptionCurveEaseInOut //执行的动画选项
                     animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)bounceWithDuration:(NSTimeInterval)duration offset:(CGFloat)offset{
        [UIView animateWithDuration:0.5
                              delay:0
             usingSpringWithDamping:1
              initialSpringVelocity:1
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
            self.transform = CGAffineTransformMakeTranslation(offset, 0);
                         }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                self.transform = CGAffineTransformMakeTranslation(0, 0);
            }];
        }];

}

- (void)moveWithDuration:(NSTimeInterval)duration {
    CGPoint beginPoint = self.frame.origin;
    CGPoint controlPoint1 = CGPointMake(beginPoint.x - 50, beginPoint.y - 100);
    CGPoint controlPoint2 = CGPointMake(beginPoint.x + 100, beginPoint.y - 200);
    
    CGPoint endPoint = CGPointMake(beginPoint.x, beginPoint.y - 330);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:beginPoint];
    [path addCurveToPoint:endPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"position";
    animation.duration = duration;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    
    animation.path = path.CGPath;
    [self.layer addAnimation:animation forKey:nil];
}

@end
