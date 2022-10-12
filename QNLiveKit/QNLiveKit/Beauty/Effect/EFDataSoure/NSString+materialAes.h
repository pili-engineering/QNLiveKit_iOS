//
//  NSString+aes.h
//  Effects890Resource
//
//  Created by 马浩萌 on 2022/4/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (materialAes)

-(NSString *)aes_encryptStringBy:(NSString *)key andIv:(NSString *)iv;
-(NSString *)aes_decryptStringBy:(NSString *)key andIv:(NSString *)iv;
-(NSData *)aes_encryptDataBy:(NSString *)key andIv:(NSString *)iv;
-(NSData *)aes_decryptDataBy:(NSString *)key andIv:(NSString *)iv;

@end

NS_ASSUME_NONNULL_END
