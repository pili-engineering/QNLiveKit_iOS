//
//  QNGiftOperation.m
//  QNLiveKit
//
//  Created by sheng wang on 2022/11/23.
//

#import "QNGiftOperation.h"
#import "QNGiftMessageView.h"

@interface QNGiftOperation ()

@property (nonatomic, strong) QNIMMessageObject *message;
@property (nonatomic, strong) QNGiftMessageView *view;

@end

@implementation QNGiftOperation

@synthesize finished = _finished;
@synthesize executing = _executing;

- (instancetype)initWithMessage:(QNIMMessageObject *)message view:(QNGiftMessageView *)view {
    if (self = [super init]) {
        _executing = NO;
        _finished  = NO;
        
        _message = message;
        _view = view;
    }
    return self;
}

- (void)main {
    if ([self isCancelled]) {
        _finished = YES;
        return;
    }
    
    self.executing = YES;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.view showGiftWithMessage:self.message complete:^{
            self.executing = NO;
            self.finished = YES;
        }];
    }];
}


#pragma mark -  手动触发 KVO
- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

@end
