//
//  QNIMAuthQuestion.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/7/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNIMAuthQuestion : NSObject

@property (nonatomic,copy) NSString *mQuestion;
@property (nonatomic,copy) NSString *mAnswer;

@end

NS_ASSUME_NONNULL_END
