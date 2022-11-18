//
//  NSData+meterialAes.m
//  SenseMeEffects
//
//  Created by 马浩萌 on 2022/5/13.
//  Copyright © 2022 SenseTime. All rights reserved.
//

#import "NSData+meterialAes.h"

@implementation NSData (meterialAes)

-(NSData *)aesProcessBy:(NSString *)key iv:(NSString *)iv andOperation:(CCOperation)operation {
    NSString * ivKey = [iv ?: key copy]; //16位偏移，CBC模式才有
    NSData *initVector = [ivKey dataUsingEncoding:NSUTF8StringEncoding];
    //公钥
    char keyPtr[kCCBlockSizeAES128+1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    //数据长度
    NSUInteger dataLength = self.length;
    //加密输出缓冲区大小
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    //加密输出缓冲区
    void *buffer = malloc(bufferSize);
    //实际输出大小
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(operation,
                                          kCCAlgorithmAES,//加密算法
                                          kCCOptionPKCS7Padding,//CBC -> PKCS7Padding，ECB -> kCCOptionPKCS7Padding|kCCOptionECBMode
                                          keyPtr,
                                          kCCBlockSizeAES128,//密钥长度128
                                          initVector.bytes,//偏移字符串, ECB模式传NULL
                                          self.bytes,//编码内容
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *aesData = [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
        return aesData;
    }
    free(buffer);
    return nil;
}

@end
