//
//  QNIMLocationAttachment.h
//  QNIMSDK
//
//  Created by 郭茜 on 2021/7/1.
//

#import <Foundation/Foundation.h>
#import "QNIMMessageAttachment.h"

NS_ASSUME_NONNULL_BEGIN

@interface QNIMLocationAttachment : QNIMMessageAttachment

/*
 *  \~chinese
 *  纬度
 *
 *  \~english
 *  Location latitude
 */
@property (nonatomic) double latitude;

/*
 *  \~chinese
 *  经度
 *
 *  \~english
 *  Loctaion longitude
 */
@property (nonatomic) double longitude;

/**
 地址
 */
@property (nonatomic,copy) NSString *address;


/**
 初始化QNIMLocationAttachment

 @param aLatitude 纬度
 @param aLongitude 经度
 @param aAddress 地址
 @return QNIMLocationAttachment
 */
- (instancetype)initWithLatitude:(double)aLatitude
                       longitude:(double)aLongitude
                         address:(NSString *)aAddress;



@end

NS_ASSUME_NONNULL_END
