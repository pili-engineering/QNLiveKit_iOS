//
//  QNSolutionListModel.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QNSolutionItemModel;
//场景列表Model
@interface QNSolutionListModel : NSObject

@property (nonatomic, strong) NSArray<QNSolutionItemModel *> *list;

@property (nonatomic, copy) NSString *nextId;

@property (nonatomic, assign) CGFloat total;

@property (nonatomic, assign) CGFloat cnt;

@end

@interface QNSolutionItemModel : NSObject

@property (nonatomic, copy) NSString *ID;
//中文标题
@property (nonatomic, copy) NSString *title;
//图标
@property (nonatomic, copy) NSString *icon;
//跳转连接
@property (nonatomic, copy) NSString *url;
//中文描述备用
@property (nonatomic, copy) NSString *desc;

@property (nonatomic, copy) NSString *type;
//点击事件
@property (nonatomic, copy) NSString *itemSelectorNameStr;

@end


NS_ASSUME_NONNULL_END
