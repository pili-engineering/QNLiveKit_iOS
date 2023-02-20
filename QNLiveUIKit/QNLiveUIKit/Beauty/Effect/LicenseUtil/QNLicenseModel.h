//
//  QNLicenseModel.h
//  QNLiveUIKit
//
//  Created by 孙慕 on 2023/2/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QNLicenseModel : NSObject

/** start */
@property(nonatomic, copy)NSString *start;

/** end */
@property(nonatomic,copy)NSString *end;

/** url */
@property(nonatomic,copy)NSString *url;

/** localPath */
@property(nonatomic,copy)NSString *localPath;

-(BOOL)isEqualModle:(QNLicenseModel *)object;


@end

NS_ASSUME_NONNULL_END
