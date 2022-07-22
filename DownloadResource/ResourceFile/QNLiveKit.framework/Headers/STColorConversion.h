//
//  STColorConversion.h
//  SenseMeEffects
//
//  Created by sunjian on 2019/10/31.
//  Copyright © 2019 SenseTime. All rights reserved.
//

#ifndef STColorConversion_h
#define STColorConversion_h
#include <GLKit/GLKit.h>

extern GLfloat *kColorConversion601;
extern GLfloat *kColorConversion601FullRange;
extern GLfloat *kColorConversion709;
extern NSString * const KSTVertexShaderString;
extern NSString * const kSTYUVVideoRangeConversionForRGFragmentShaderString;
extern NSString * const kSTYUVFullRangeConversionForLAFragmentShaderString;
extern NSString * const kSTYUVVideoRangeConversionForLAFragmentShaderString;
extern NSString * const kSTYUVFullRangeConversionForLAFragmentShaderString1;

#endif /* STColorConversion_h */
