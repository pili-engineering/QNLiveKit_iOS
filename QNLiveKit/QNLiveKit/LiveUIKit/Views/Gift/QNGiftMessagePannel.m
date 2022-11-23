//
//  QNGiftMessagePannel.m
//  QNLiveKit
//
//  Created by sheng wang on 2022/11/23.
//

#import "QNGiftMessagePannel.h"
#import "QNGiftMessageView.h"
#import "QNIMSDK/QNIMSDK.h"
#import "QNGiftOperation.h"

#define QUEUE_COUNT 3
#define CELL_WIDTH  170
#define CELL_HEIGHT 50

@interface QNGiftMessagePannel ()

@property (nonatomic, strong) NSArray<NSOperationQueue *> *msgQueues;
@property (nonatomic, strong) NSArray<QNGiftMessageView *> *msgViews;

@end

@implementation QNGiftMessagePannel

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createMsgQueues];
        [self createMsgViews];
    }
    return self;
}

- (void)createMsgQueues {
    NSMutableArray<NSOperationQueue *> *queues;
    for (int i = 0; i < QUEUE_COUNT; i++) {
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        queue.maxConcurrentOperationCount = 1;
        [queues addObject:queue];
    }
    
    _msgQueues = [queues copy];
}

- (void)createMsgViews {
    NSMutableArray<QNGiftMessageView *> *views;
    for (int i = 0; i < QUEUE_COUNT; i++) {
        QNGiftMessageView *view = [[QNGiftMessageView alloc] initWithFrame:CGRectMake(0, (QUEUE_COUNT - 1 - i) * CELL_HEIGHT, CELL_WIDTH, CELL_HEIGHT)];
        [self addSubview:view];
        
        [views addObject:view];
    }
    _msgViews = views;
}

- (void)showGiftMessage:(QNIMMessageObject *)message {
    NSOperationQueue *queue = [self.msgQueues objectAtIndex:0];
    QNGiftMessageView *showView = [self.msgViews objectAtIndex:0];
    for (int i = 1; i < QUEUE_COUNT; i++) {
        NSOperationQueue *curQueue = [self.msgQueues objectAtIndex:i];
        if (curQueue.operationCount < queue.operationCount) {
            queue = curQueue;
            showView = [self.msgViews objectAtIndex:i];
        }
    }
    
    QNGiftOperation *operation = [[QNGiftOperation alloc] initWithMessage:message view:showView];
    [queue addOperation:operation];
}

@end
