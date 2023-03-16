//
//  QNLicenseModel.m
//  QNLiveUIKit
//
//  Created by 孙慕 on 2023/2/6.
//

#import "QNLicenseModel.h"

@implementation QNLicenseModel

-(BOOL)isEqualModle:(QNLicenseModel *)object{
    return [object.start isEqualToString:self.start] && [object.end isEqualToString:self.end];
}

@end
