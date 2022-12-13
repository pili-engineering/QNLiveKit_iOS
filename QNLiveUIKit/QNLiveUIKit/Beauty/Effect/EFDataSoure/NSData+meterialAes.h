//
//  NSData+meterialAes.h
//  SenseMeEffects
//
//  Created by 马浩萌 on 2022/5/13.
//  Copyright © 2022 SenseTime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (meterialAes)

-(NSData *)aesProcessBy:(NSString *)key iv:(NSString *)iv andOperation:(CCOperation)operation;

@end

NS_ASSUME_NONNULL_END
