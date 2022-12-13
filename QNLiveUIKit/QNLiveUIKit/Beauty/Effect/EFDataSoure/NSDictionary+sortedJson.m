//
//  NSDictionary+sortedJson.m
//  Effects890Resource
//
//  Created by 马浩萌 on 2022/4/25.
//

#import "NSDictionary+sortedJson.h"

@implementation NSDictionary (sortedJson)

-(NSString *)sortedJsonString {
    NSArray *arrAllKeys = [self allKeys];
    
    arrAllKeys = [arrAllKeys sortedArrayUsingSelector:@selector(compare:)];
    
    NSMutableArray *arrStrKeyPair = [NSMutableArray array];
    
    for (NSString *strKey in arrAllKeys) {
        
        id obj = [self objectForKey:strKey];
        
        if ([obj isKindOfClass:[NSString class]]) {
            
            NSString *strValue = [obj description];
            
//            if (needEncode) {
//
//                strValue = [self encodeToPercentEscapeString:strValue];
//            }
            
            [arrStrKeyPair addObject:[NSString stringWithFormat:@"%@=%@" , strKey , strValue]];
        }
        
        if ([obj isKindOfClass:[NSDictionary class]] || [obj isKindOfClass:[NSArray class]]) {
            
            NSString *strValue = [self getJsonStringObj:obj];
            
//            if (needEncode) {
//                
//                strValue = [self encodeToPercentEscapeString:strValue];
//            }
            
            [arrStrKeyPair addObject:[NSString stringWithFormat:@"%@=%@" , strKey , strValue]];
        }
        
        if ([obj isKindOfClass:[NSNumber class]]) {
            [arrStrKeyPair addObject:[NSString stringWithFormat:@"%@=%@" , strKey , [obj description]]];
        }
    }
    
    NSString *strLinked = [arrStrKeyPair componentsJoinedByString:@"&"];
    
    strLinked = strLinked ? strLinked : @"";
    
    return strLinked;
}

-(NSString *)getJsonStringObj:(id)jsonObj
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObj options:0 error:&error];
    
    if (!jsonData || error) {
        
        return nil;
    }
    
    NSString *strJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return strJson;
}

@end
