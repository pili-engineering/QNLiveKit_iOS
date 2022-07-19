//
//  LinkOptionModel.h
//  QNLiveKit
//
//  Created by 郭茜 on 2022/6/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LinkOptionModel : NSObject

@property (nonatomic, copy)NSString *uid;

@property (nonatomic, copy)NSString *msg;

@property (nonatomic, assign)BOOL mute;

@property (nonatomic, assign)BOOL forbidden;


@end

NS_ASSUME_NONNULL_END
