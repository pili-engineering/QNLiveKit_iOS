//
//  SendGiftModel.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/1/5.
//  发送的礼物的Model

#import <Foundation/Foundation.h>

@interface SendGiftModel : NSObject

/** usericon */
@property(nonatomic,copy)NSString *userIcon;
/** username */
@property(nonatomic,copy)NSString *userName;
/** userId */
@property(nonatomic,copy)NSString *userId;
/** giftname */
@property(nonatomic,copy)NSString *giftName;
/** giftimage */
@property(nonatomic,copy)NSString *giftImage;
/** gift gifimage */
@property(nonatomic,copy)NSString *giftGifImage;
/** gift price */
@property(nonatomic,copy)NSString *giftPrice;
/** count */
@property(nonatomic,assign) NSInteger defaultCount; //0
/** 发送的数 */
@property(nonatomic,assign) NSInteger sendCount;
/** 礼物ID */
@property(nonatomic,copy)NSString *giftId;
/** 礼物操作的唯一Key */
@property(nonatomic,copy)NSString *giftKey;
/** 是否选中 */
@property(nonatomic,assign)BOOL isSelected;

@end
