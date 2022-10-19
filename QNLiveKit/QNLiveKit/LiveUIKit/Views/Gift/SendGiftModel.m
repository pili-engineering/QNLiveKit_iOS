//
//  SendGiftModel.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/1/5.
//

#import "SendGiftModel.h"

@implementation SendGiftModel

- (NSString *)giftKey {
    return [NSString stringWithFormat:@"%@%@",self.giftName,self.giftId];
}

@end
