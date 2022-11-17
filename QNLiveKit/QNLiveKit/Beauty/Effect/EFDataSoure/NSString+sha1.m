//
//  NSString+sha1.m
//  Effects890Resource
//
//  Created by 马浩萌 on 2022/4/25.
//

#import "NSString+sha1.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (sha1)

-(NSString *)sha1String {
    NSData *dataSign = [self dataUsingEncoding:NSUTF8StringEncoding];

    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(dataSign.bytes, (unsigned int)dataSign.length, digest);
    
    NSMutableString *strSHA1 = [NSMutableString string];
    
    for (int i = 0 ; i < CC_SHA1_DIGEST_LENGTH ; i ++) {
        
        [strSHA1 appendFormat:@"%02x" , digest[i]];
    }
    
    return strSHA1;
}

@end
