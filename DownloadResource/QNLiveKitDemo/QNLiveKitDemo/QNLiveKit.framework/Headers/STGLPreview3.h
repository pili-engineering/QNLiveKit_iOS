//
//  STGLPreview.h
//
//  Created by sluin on 2017/1/11.
//  Copyright © 2017年 SenseTime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/glext.h>
#import <AVFoundation/AVFoundation.h>

@interface STGLPreview3 : UIView

@property (nonatomic , strong) EAGLContext *glContext;
@property (nonatomic, assign) GLfloat scale;

- (instancetype)initWithFrame:(CGRect)frame context:(EAGLContext *)context;

- (void)renderTexture:(GLuint)texture;

- (GLuint)convertYUV2RGB:(CVPixelBufferRef)sampleBuffer;

- (GLuint)convertYUV2RGB:(unsigned char *)yData uvData:(unsigned char *)uvData w:(int)w h:(int)h;

@end
