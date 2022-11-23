//
//  LiveChatRoom.m
//  QNLiveKit
//
//  Created by 郭茜 on 2022/6/2.
//

#import "LiveChatRoom.h"
#import "QMessageBaseCell.h"
#import "QTextMessageCell.h"
#import "PubChatModel.h"
#import "CreateSignalHandler.h"
#import "QIMModel.h"
#import <QNIMSDK/QNIMSDK.h>
#import "QGradient.h"
#import "QNGiftMessageCell.h"

/**
 *  文本cell标示
 */
static NSString *const textCellIndentifier = @"textCellIndentifier";
static NSString *const startAndEndCellIndentifier = @"startAndEndCellIndentifier";
static NSString *const giftCellIndentifier = @"giftCellIndentifier";

static NSString * const banNotifyContent = @"您已被管理员禁言";

@interface LiveChatRoom ()<QInputBarControlDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate,QNIMChatServiceProtocol>
/*!
 聊天内容的消息Cell数据模型的数据源
 
 @discussion 数据源中存放的元素为消息Cell的数据模型，即RCDLiveMessageModel对象。
 */
@property(nonatomic, strong) NSMutableArray<QNIMMessageObject *> *conversationDataRepository;

/**
 *  是否需要滚动到底部
 */
@property(nonatomic, assign) BOOL isNeedScrollToButtom;

@property(nonatomic, assign) BOOL isPubchat;

@property(nonatomic, assign) BOOL isAllowToSend;//是否允许发送
/**
 *  滚动条不在底部的时候，接收到消息不滚动到底部，记录未读消息数
 */
@property (nonatomic, assign) NSInteger unreadNewMsgCount;

@end
@implementation LiveChatRoom

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        CGSize size = frame.size;
        CGFloat bottomExtraDistance  = 0;
        if (@available(iOS 11.0, *)) {
            bottomExtraDistance = [self getIPhonexExtraBottomHeight];
        }
        //  消息展示界面和输入框
        [self.messageContentView setFrame:CGRectMake(0, 0, size.width, size.height - 50)];
        [self addSubview:self.messageContentView];
        
        [self.messageContentView  addSubview:self.conversationMessageCollectionView];
        
        
        [self.conversationMessageCollectionView setFrame:CGRectMake(0, 0, size.width, self.messageContentView.frame.size.height)];
        UICollectionViewFlowLayout *customFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        customFlowLayout.minimumLineSpacing = 2;
        customFlowLayout.sectionInset = UIEdgeInsetsMake(10.0f, 0.0f,5.0f, 0.0f);
        customFlowLayout.estimatedItemSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, 44);
        customFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        [self.conversationMessageCollectionView setCollectionViewLayout:customFlowLayout animated:NO completion:nil];
        
        [self.messageContentView  addSubview:self.inputBar];
        [self.inputBar setBackgroundColor: [UIColor whiteColor]];
        [self.inputBar setFrame:CGRectMake(0, self.messageContentView.frame.size.height - 50, SCREEN_W , 50)];
        [self.inputBar setHidden:YES];
        
        //  底部按钮
        [self addSubview:self.bottomBtnContentView];
        [self.bottomBtnContentView setFrame:CGRectMake(0, size.height - 56, size.width, 50)];
        [self.bottomBtnContentView setBackgroundColor:[UIColor clearColor]];
        
        
        [self.commentBtn setFrame:CGRectMake(10, 10, 35, 35)];
        
        [self registerClass:[QTextMessageCell class]forCellWithReuseIdentifier:textCellIndentifier];
        [self registerClass:[QTextMessageCell class]forCellWithReuseIdentifier:startAndEndCellIndentifier];
        [self registerClass:[QNGiftMessageCell class]forCellWithReuseIdentifier:giftCellIndentifier];
        
        self.isAllowToSend = YES;
//        [[QNIMChatService sharedOption] addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
    }
    return self;
    
}



#pragma mark - views init
/**
 *  注册cell
 *
 *  @param cellClass  cell类型
 *  @param identifier cell标示
 */
- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier {
    [self.conversationMessageCollectionView registerClass:cellClass
                               forCellWithReuseIdentifier:identifier];
}


/**
 发言按钮事件
 */
- (void)commentBtnPressedWithPubchat:(BOOL)isPubchat {
    self.isPubchat = isPubchat;
        [self.inputBar setHidden:NO];
        [self.inputBar  setInputBarStatus:RCCRBottomBarStatusKeyboard];

}

/**
 *  将消息加入本地数组
 */
- (void)appendAndDisplayMessage:(QNIMMessageObject *)rcMessage {
    if ([self appendMessageModel:rcMessage]) {
        NSIndexPath *indexPath =
        [NSIndexPath indexPathForItem:self.conversationDataRepository.count - 1
                            inSection:0];
        if ([self.conversationMessageCollectionView numberOfItemsInSection:0] !=
            self.conversationDataRepository.count - 1) {
            return;
        }
        //  view刷新
        [self.conversationMessageCollectionView
         insertItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
        if ([self isAtTheBottomOfTableView] || self.isNeedScrollToButtom) {
            [self scrollToBottomAnimated:YES];
            self.isNeedScrollToButtom=NO;
        }
    }
    return;
}

/**
 *  消息滚动到底部
 *
 *  @param animated 是否开启动画效果
 */
- (void)scrollToBottomAnimated:(BOOL)animated {
    if ([self.conversationMessageCollectionView numberOfSections] == 0) {
        return;
    }
    NSUInteger finalRow = MAX(0, [self.conversationMessageCollectionView numberOfItemsInSection:0] - 1);
    if (0 == finalRow) {
        return;
    }
    NSIndexPath *finalIndexPath =
    [NSIndexPath indexPathForItem:finalRow inSection:0];
    [self.conversationMessageCollectionView scrollToItemAtIndexPath:finalIndexPath
                                                   atScrollPosition:UICollectionViewScrollPositionTop
                                                           animated:animated];
}


/**
 *  如果当前会话没有这个消息id，把消息加入本地数组
 */
- (BOOL)appendMessageModel:(QNIMMessageObject *)model {

    if (!model.content) {
        return NO;
    }
    //这里可以根据消息类型来决定是否显示，如果不希望显示直接return NO
    
    //数量不可能无限制的大，这里限制收到消息过多时，就对显示消息数量进行限制。
    //用户可以手动下拉更多消息，查看更多历史消息。
    if (self.conversationDataRepository.count>100) {
        //                NSRange range = NSMakeRange(0, 1);
        [self.conversationDataRepository removeObjectAtIndex:0];
        [self.conversationMessageCollectionView reloadData];
    }
    [self.conversationDataRepository addObject:model];
    return YES;
}


/**
 *  判断消息是否在collectionView的底部
 *
 *  @return 是否在底部
 */
- (BOOL)isAtTheBottomOfTableView {
    if (self.conversationMessageCollectionView.contentSize.height <= self.conversationMessageCollectionView.frame.size.height) {
        return YES;
    }
    if(self.conversationMessageCollectionView.contentOffset.y +200 >= (self.conversationMessageCollectionView.contentSize.height - self.conversationMessageCollectionView.frame.size.height)) {
        return YES;
    }else{
        return NO;
    }
}

/**
 *  更新底部新消息提示显示状态
 */
- (void)updateUnreadMsgCountLabel{
}



#pragma mark - QNInputBarControlDelegate
//  根据inputBar 回调来修改页面布局
- (void)onInputBarControlContentSizeChanged:(CGRect)frame withAnimationDuration:(CGFloat)duration andAnimationCurve:(UIViewAnimationCurve)curve ifKeyboardShow:(BOOL)ifKeyboardShow {
    CGRect originFrame = self.frame;
    __weak __typeof(&*self)weakSelf = self;
    [UIView animateWithDuration:duration animations:^{
        [UIView setAnimationCurve:curve];
        CGFloat bottomExtraDistance  = 0;
        if (@available(iOS 11.0, *)) {
            bottomExtraDistance = [self getIPhonexExtraBottomHeight];
        }
        if (ifKeyboardShow) {
            [weakSelf setFrame:CGRectMake(0, frame.origin.y - originFrame.size.height + 50 , originFrame.size.width, originFrame.size.height)];
        }else {
            [weakSelf setFrame:CGRectMake(0, frame.origin.y - originFrame.size.height - bottomExtraDistance , originFrame.size.width, originFrame.size.height)];
        }
        [UIView commitAnimations];
    }];
}

//  发送消息
- (void)onTouchSendButton:(NSString *)text {
    
    [self.inputBar clearInputView];
    self.inputBar.hidden = YES;
    [self.inputBar resignFirstResponder];
    
    if ([self.delegate respondsToSelector:@selector(didEndEditMessageContent:)]) {
        self.isAllowToSend = [self.delegate didEndEditMessageContent:text];
    }
    if (self.isAllowToSend) {
        [self touristSendMessage:text];
    }
}

- (void)touristSendMessage:(NSString *)text {
        
    if (text.length == 0) {
        return;
    }
    CreateSignalHandler *create = [[CreateSignalHandler alloc] initWithToId:self.groupId roomId:@""];
    if (self.isPubchat) {
        QNIMMessageObject *rcTextMessage = [create createChatMessage:text];
        [self sendMessage:rcTextMessage];
    } else {
        QNIMMessageObject *rcTextMessage = [create createDanmuMessage:text];
        [self sendMessage:rcTextMessage];
    }

}

#pragma mark sendMessage/showMessage
/**
 发送消息

 @param messageContent 消息
 */
- (void)sendMessage:(QNIMMessageObject *)messageContent{
           
    [[QNIMChatService sharedOption] sendMessage:messageContent];
    if ([self.delegate respondsToSelector:@selector(didSendMessageModel:)]) {
        [self.delegate didSendMessageModel:messageContent];
    }
    //是公聊消息才插入
    if (self.isPubchat) {
        [self appendAndDisplayMessage:messageContent];
    }
}

- (void)messageStatusChanged:(QNIMMessageObject *)message error:(QNIMError *)error {
    
}

#pragma mark <UIScrollViewDelegate,UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.conversationDataRepository.count;
}

- (void)showMessage:(QNIMMessageObject *)message {
    [self appendAndDisplayMessage:message];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    menu.menuVisible=NO;
    //如果消息不在最底部，收到消息之后不滚动到底部，加到列表中只记录未读数
    if (![self isAtTheBottomOfTableView]) {
        self.unreadNewMsgCount ++ ;
        [self updateUnreadMsgCountLabel];
    }
}

- (void)receivedMessages:(NSArray<QNIMMessageObject *> *)messages {

    [self appendAndDisplayMessage:messages.firstObject];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    menu.menuVisible=NO;
    //如果消息不在最底部，收到消息之后不滚动到底部，加到列表中只记录未读数
    if (![self isAtTheBottomOfTableView]) {
        self.unreadNewMsgCount ++ ;
        [self updateUnreadMsgCountLabel];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QNIMMessageObject *messageContent =
    [self.conversationDataRepository objectAtIndex:indexPath.row];
    NSString *indentifier = [self indentifierOfMessage:messageContent];
    
    QMessageBaseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:indentifier forIndexPath:indexPath];
    [cell setDataModel:messageContent];
    
    return cell;
}

- (NSString *)indentifierOfMessage:(QNIMMessageObject *)message {
    QIMModel *imModel = [QIMModel mj_objectWithKeyValues:message.content.mj_keyValues];
    if ([imModel.action isEqualToString:liveroom_pubchat]) {
        return textCellIndentifier;
    } else if ([imModel.action isEqualToString:liveroom_welcome]) {
        return startAndEndCellIndentifier;
    } else if ([imModel.action isEqualToString:liveroom_bye_bye]) {
        return startAndEndCellIndentifier;
    } else if ([imModel.action isEqualToString:liveroom_gift]) {
        return giftCellIndentifier;
    } else {
        return @"";
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    QNIMMessageObject *messageContent =
    [self.conversationDataRepository objectAtIndex:indexPath.row];
    
    return CGSizeMake(self.frame.size.width, 44);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 2.f;
}

#pragma mark - gesture and button action
- (void)resetBottomGesture:
(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self setDefaultBottomViewStatus];
    }
}

- (void)setDefaultBottomViewStatus {
    [self.inputBar setInputBarStatus:RCCRBottomBarStatusDefault];
    [self.inputBar setHidden:YES];
   
}

- (void)alertErrorWithTitle:(NSString *)title message:(NSString *)message ok:(NSString *)ok{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *action = [UIAlertAction actionWithTitle:ok style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:action];
    dispatch_async(dispatch_get_main_queue(), ^{
    });
    
}

#pragma mark - getter setter

- (UIView *)bottomBtnContentView {
    if (!_bottomBtnContentView) {
        _bottomBtnContentView = [[UIView alloc] init];
        [_bottomBtnContentView setBackgroundColor:[UIColor clearColor]];
    }
    return _bottomBtnContentView;
}

- (UIButton *)commentBtn {
    if (!_commentBtn) {
        _commentBtn = [[UIButton alloc] init];
        [_commentBtn addTarget:self
                        action:@selector(commentBtnPressedWithPubchat:)
              forControlEvents:UIControlEventTouchUpInside];
        [_commentBtn setImage:[UIImage imageNamed:@"feedback"] forState:UIControlStateNormal];
    }
    return _commentBtn;
}

- (UIView *)messageContentView {
    if (!_messageContentView) {
        _messageContentView = [[UIView alloc] init];
        [_messageContentView setBackgroundColor: [UIColor clearColor]];
    }
    return _messageContentView;
}

- (UICollectionView *)conversationMessageCollectionView {
    if (!_conversationMessageCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _conversationMessageCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_conversationMessageCollectionView setDelegate:self];
        [_conversationMessageCollectionView setDataSource:self];
        [_conversationMessageCollectionView setBackgroundColor: [UIColor clearColor]];
//        [_conversationMessageCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:ConversationMessageCollectionViewCell];
    }
    return _conversationMessageCollectionView;
}

- (QInputBarControl *)inputBar {
    if (!_inputBar) {
        _inputBar = [[QInputBarControl alloc] initWithStatus:RCCRBottomBarStatusDefault];
        [_inputBar setDelegate:self];
    }
    return _inputBar;
}

- (NSMutableArray *)conversationDataRepository {
    if (!_conversationDataRepository) {
           _conversationDataRepository = [[NSMutableArray alloc] init];
       }
       return _conversationDataRepository;
}

- (float)getIPhonexExtraBottomHeight {
    float height = 0;
    if (@available(iOS 11.0, *)) {
        height = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets].bottom;
    }
    return height;
}


@end
