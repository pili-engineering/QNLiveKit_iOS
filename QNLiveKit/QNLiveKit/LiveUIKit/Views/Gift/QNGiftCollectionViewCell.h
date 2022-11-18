//
//  GiftCollectionViewCell.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/1/5.
//  展示礼物cell

#import <UIKit/UIKit.h>

@class QNSendGiftModel;
@interface QNGiftCollectionViewCell : UICollectionViewCell

/** model */
@property(nonatomic,strong) QNSendGiftModel *model;

@end
