//
//  QNConfigurationUI.h
//  QNLiveUIKit
//
//  Created by sunmu on 2023/3/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface QNConfigurationUI : NSObject

+ (QNConfigurationUI *)shardManager ;

-(BOOL)getHiddenWithName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
