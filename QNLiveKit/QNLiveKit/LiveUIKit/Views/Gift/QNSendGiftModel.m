//
//  SendGiftModel.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/1/5.
//

#import "QNSendGiftModel.h"

@implementation QNSendGiftModel

- (NSString *)giftKey {
    return [NSString stringWithFormat:@"%@%@",self.name,self.gift_id];
}

@end
