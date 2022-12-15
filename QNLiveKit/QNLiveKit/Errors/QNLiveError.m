//
//  QNLiveError.m
//  QNLiveKit
//
//  Created by sheng wang on 2022/12/15.
//

#import "QNLiveError.h"


NSErrorDomain const _Nonnull QNLiveErrorDomain = @"QNLiveErrorDomain";


@implementation QNErrorUtil

+ (NSError *)errorWithCode:(NSInteger)code {
    return [NSError errorWithDomain:QNLiveErrorDomain code:code userInfo:nil];
}

+ (NSError *)errorWithCode:(NSInteger)code message:(NSString * )message {
    NSDictionary *userInfo = @{
        NSLocalizedDescriptionKey:message,
    };
    return [NSError errorWithDomain:QNLiveErrorDomain code:code userInfo:userInfo];
}


+ (NSError *)errorWithCode:(NSInteger)code message:(NSString * )message underlying:(id)error {
    NSDictionary *userInfo = @{
        NSLocalizedDescriptionKey:message,
        NSUnderlyingErrorKey: error,
    };
    return [NSError errorWithDomain:QNLiveErrorDomain code:code userInfo:userInfo];
}


+ (NSError *)errorWithCode:(NSInteger)code userInfo:(NSDictionary *)userInfo {
    return [NSError errorWithDomain:QNLiveErrorDomain code:code userInfo:userInfo];
}



@end
