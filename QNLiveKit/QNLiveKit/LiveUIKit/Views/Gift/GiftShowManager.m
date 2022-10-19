//
//  GiftShowManager.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/1/5.
//

#import "GiftShowManager.h"
#import "GiftShowView.h"
#import "GiftOperation.h"
#import "SendGiftModel.h"

//获取屏幕 宽度、高度
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

// 判断是否是iPhone X
#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
// 状态栏高度
#define STATUS_BAR_HEIGHT (iPhoneX ? 44.f : 20.f)
// 导航栏高度
#define Nav_Bar_HEIGHT (iPhoneX ? 88.f : 64.f)
// 导航+状态
#define Nav_Status_Height (STATUS_BAR_HEIGHT+Nav_Bar_HEIGHT)
// tabBar高度
#define TAB_BAR_HEIGHT (iPhoneX ? (49.f+34.f) : 49.f)
// home indicator
#define HOME_INDICATOR_HEIGHT (iPhoneX ? 34.f : 0.f)
//距离底部的间距
#define Bottom_Margin(margin) ((margin)+HOME_INDICATOR_HEIGHT)


static const NSInteger giftMaxNum = 99;

@interface GiftShowManager()

/** 队列 */
@property(nonatomic,strong) NSOperationQueue *giftQueue1;
@property(nonatomic,strong) NSOperationQueue *giftQueue2;
/** showgift */
@property(nonatomic,strong) GiftShowView *giftShowView1;
@property(nonatomic,strong) GiftShowView *giftShowView2;
/** 操作缓存 */
@property (nonatomic,strong) NSCache *operationCache;

@property(nonatomic,copy) completeBlock finishedBlock;
/** 当前礼物的keys */
@property(nonatomic,strong) NSMutableArray *curentGiftKeys;

@property(nonatomic,strong) UIImageView *gifImageView;


@end

@implementation GiftShowManager

- (NSOperationQueue *)giftQueue1{
    
    if (!_giftQueue1) {
        
        _giftQueue1 = [[NSOperationQueue alloc] init];
        _giftQueue1.maxConcurrentOperationCount = 1;
    }
    return _giftQueue1;
}

- (NSOperationQueue *)giftQueue2{
    
    if (!_giftQueue2) {
        
        _giftQueue2 = [[NSOperationQueue alloc] init];
        _giftQueue2.maxConcurrentOperationCount = 1;
    }
    return _giftQueue2;
}

- (NSMutableArray *)curentGiftKeys{
    
    if (!_curentGiftKeys) {
        
        _curentGiftKeys = [NSMutableArray array];
    }
    return _curentGiftKeys;
}

- (GiftShowView *)giftShowView1{
    
    if (!_giftShowView1) {
        CGFloat itemW = SCREEN_WIDTH/4.0;
        CGFloat itemH = itemW*105/93.8;
        
        __weak typeof(self) weakSelf = self;
        CGFloat showViewW = 10+showGiftView_UserIcon_LT+showGiftView_UserIcon_WH+showGiftView_UserName_L+showGiftView_UserName_W+showGiftView_GiftIcon_W+showGiftView_XNum_L+showGiftView_XNum_W;
        CGFloat showViewY = SCREEN_HEIGHT-Bottom_Margin(44)-2*itemH-showGiftView_GiftIcon_H-10-15;
        _giftShowView1 = [[GiftShowView alloc] initWithFrame:CGRectMake(-showViewW, showViewY, showViewW, showGiftView_GiftIcon_H)];
        [_giftShowView1 setShowViewKeyBlock:^(SendGiftModel *giftModel) {
            [weakSelf.curentGiftKeys addObject:giftModel.giftKey];
        }];
    }
    return _giftShowView1;
}

- (GiftShowView *)giftShowView2 {
    
    if (!_giftShowView2) {
        CGFloat itemW = SCREEN_WIDTH/4.0;
        CGFloat itemH = itemW*105/93.8;
        
        __weak typeof(self) weakSelf = self;
        CGFloat showViewW = 10+showGiftView_UserIcon_LT+showGiftView_UserIcon_WH+showGiftView_UserName_L+showGiftView_UserName_W+showGiftView_GiftIcon_W+showGiftView_XNum_L+showGiftView_XNum_W;
        CGFloat showViewY = SCREEN_HEIGHT-Bottom_Margin(44)-2*itemH-showGiftView_GiftIcon_H*2-2*10-15;
        _giftShowView2 = [[GiftShowView alloc] initWithFrame:CGRectMake(-showViewW, showViewY, showViewW, showGiftView_GiftIcon_H)];
        [_giftShowView2 setShowViewKeyBlock:^(SendGiftModel *giftModel) {
            [weakSelf.curentGiftKeys addObject:giftModel.giftKey];
            
        }];
    }
    return _giftShowView2;
}


- (NSCache *)operationCache
{
    if (_operationCache==nil) {
        _operationCache = [[NSCache alloc] init];
    }
    return _operationCache;
}

+ (instancetype)sharedManager {
    
    static GiftShowManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[GiftShowManager alloc] init];
    });
    return manager;
}

- (void)showGiftViewWithBackView:(UIView *)backView info:(SendGiftModel *)giftModel completeBlock:(completeBlock)completeBlock {
    
    //展示gifimage
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:self.gifImageView];
        //展示本地gif
        NSString * path = [[NSBundle mainBundle] pathForResource:giftModel.giftGifImage ofType:@"gif"];
        NSData * data = [NSData dataWithContentsOfFile:path];
        self.gifImageView.image = [UIImage sd_imageWithGIFData:data];
        //展示网络gif
//        [self.gifImageView sd_setImageWithURL:[NSURL URLWithString:giftModel.giftGifImage]];
        self.gifImageView.hidden = NO;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.gifImageView.hidden = YES;
            [self.gifImageView sd_setImageWithURL:[NSURL URLWithString:@""]];
            [self.gifImageView removeFromSuperview];
        });
    });
        
    if (self.curentGiftKeys.count && [self.curentGiftKeys containsObject:giftModel.giftKey]) {
        //有当前的礼物信息
        if ([self.operationCache objectForKey:giftModel.giftKey]) {
            
            //当前存在操作
            GiftOperation *op = [self.operationCache objectForKey:giftModel.giftKey];
            //限制一次礼物的连击最大值
            if (op.giftShowView.currentGiftCount >= giftMaxNum) {
                //移除操作
                [self.operationCache removeObjectForKey:giftModel.giftKey];
                //清空唯一key
                [self.curentGiftKeys removeObject:giftModel.giftKey];
            }else {
                //赋值当前礼物数
                op.giftShowView.giftCount = giftModel.sendCount;
            }

        }else {
            
            NSOperationQueue *queue;
            GiftShowView *showView;
            if (self.giftQueue1.operations.count <= self.giftQueue2.operations.count) {
                queue = self.giftQueue1;
                showView = self.giftShowView1;
            }else {
                queue = self.giftQueue2;
                showView = self.giftShowView2;
            }

            //当前操作已结束 重新创建
            GiftOperation *operation = [GiftOperation addOperationWithView:showView OnView:backView Info:giftModel completeBlock:^(BOOL finished,NSString *giftKey) {
                if (self.finishedBlock) {
                    self.finishedBlock(finished);
                }
                //移除操作
                [self.operationCache removeObjectForKey:giftKey];
                //清空唯一key
                [self.curentGiftKeys removeObject:giftKey];
            }];
            operation.model.defaultCount += giftModel.sendCount;
            //存储操作信息
            [self.operationCache setObject:operation forKey:giftModel.giftKey];
            //操作加入队列
            [queue addOperation:operation];
        }

    }else {
        //没有礼物的信息
        if ([self.operationCache objectForKey:giftModel.giftKey]) {
            
            //当前存在操作
            GiftOperation *op = [self.operationCache objectForKey:giftModel.giftKey];
            //限制一次礼物的连击最大值
            if (op.model.defaultCount >= giftMaxNum) {
                //移除操作
                [self.operationCache removeObjectForKey:giftModel.giftKey];
                //清空唯一key
                [self.curentGiftKeys removeObject:giftModel.giftKey];
            }else {
                //赋值当前礼物数
                op.model.defaultCount += giftModel.sendCount;
            }

        }else {
            
            NSOperationQueue *queue;
            GiftShowView *showView;
            if (self.giftQueue1.operations.count <= self.giftQueue2.operations.count) {
                queue = self.giftQueue1;
                showView = self.giftShowView1;
            }else {
                queue = self.giftQueue2;
                showView = self.giftShowView2;
            }

            GiftOperation *operation = [GiftOperation addOperationWithView:showView OnView:backView Info:giftModel completeBlock:^(BOOL finished,NSString *giftKey) {
                if (self.finishedBlock) {
                    self.finishedBlock(finished);
                }
                if ([self.giftShowView1.finishModel.giftKey isEqualToString:self.giftShowView2.finishModel.giftKey]) {
                    return ;
                }
                //移除操作
                [self.operationCache removeObjectForKey:giftKey];
                //清空唯一key
                [self.curentGiftKeys removeObject:giftKey];
            }];
            operation.model.defaultCount += giftModel.sendCount;
            //存储操作信息
            [self.operationCache setObject:operation forKey:giftModel.giftKey];
            //操作加入队列
            [queue addOperation:operation];
        }
    }
}

- (UIImageView *)gifImageView{
    
    if (!_gifImageView) {
        _gifImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 60, kScreenWidth, 225)];
        _gifImageView.hidden = YES;
    }
    return _gifImageView;
}

@end
