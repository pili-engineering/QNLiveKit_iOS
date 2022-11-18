//
//  GiftOperation.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/1/5.
//

#import "QNGiftOperation.h"
#import "QNGiftShowView.h"
#import "QNSendGiftModel.h"


@implementation QNGiftOperation

@synthesize finished = _finished;
@synthesize executing = _executing;

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _executing = NO;
        _finished  = NO;
    }
    return self;
}

+ (instancetype)addOperationWithView:(QNGiftShowView *)giftShowView OnView:(UIView *)backView Info:(QNSendGiftModel *)model completeBlock:(completeOpBlock)completeBlock {
    
    QNGiftOperation *op = [[QNGiftOperation alloc] init];
    op.giftShowView = giftShowView;
    op.model = model;
    op.backView = backView;
    op.opFinishedBlock = completeBlock;
    return op;
}

- (void)start {
    
    if ([self isCancelled]) {
        _finished = YES;
        return;
    }
    
    _executing = YES;
    NSLog(@"当前队列-- %@",self.model.name);
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        [self.backView addSubview:self.giftShowView];
        [self.giftShowView showGiftShowViewWithModel:self.model completeBlock:^(BOOL finished,NSString *giftKey) {
            self.finished = finished;
            if (self.opFinishedBlock) {
                self.opFinishedBlock(finished,giftKey);
            }
        }];
    }];
    
}

#pragma mark -  手动触发 KVO
- (void)setExecuting:(BOOL)executing
{
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)setFinished:(BOOL)finished
{
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}


@end
