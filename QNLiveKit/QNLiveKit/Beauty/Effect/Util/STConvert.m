//
//  STConvert.m
//  SenseMeEffects
//
//  Created by dongshuaijun on 2020/11/16.
//  Copyright © 2020 SenseTime. All rights reserved.
//

#import "STConvert.h"

@implementation STConvert

+ (int)floatToInt:(float)f {
    int i = 0;
    if (f > 0) {
        i = (f * 10 + 5) / 10;
    }else if (f < 0) {
        i = (f * 10 - 5) / 10;
    }else {
        i = 0;
    }
    return  i;
}

@end
