//
//  SendGiftModel.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/1/5.
//  发送的礼物的Model

#import <Foundation/Foundation.h>

@interface QNGiftModel : NSObject

/** 礼物ID */
@property(nonatomic, assign) NSInteger gift_id;

/** 礼物类型 */
@property(nonatomic, assign) NSInteger type;

/** giftname */
@property(nonatomic, copy)NSString *name;

/** gift price */
@property(nonatomic, assign) NSInteger amount;

/** giftimage */
@property(nonatomic,copy)NSString *img;

/** gift gifimage */
@property(nonatomic,copy)NSString *animation_img;

/** gift 排序 */
@property(nonatomic,assign) NSInteger order;


/** 是否选中 */
@property(nonatomic,assign)BOOL isSelected;

@end
