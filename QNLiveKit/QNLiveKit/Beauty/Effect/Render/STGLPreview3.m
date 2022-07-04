//
//  STGLPreview.m
//
//  Created by sluin on 2017/1/11.
//  Copyright © 2017年 SenseTime. All rights reserved.
//

#import "STGLPreview3.h"
#import "STVFShader.h"
#import "STColorConversion.h"
#import "STGLShader.h"
#import <AVFoundation/AVFoundation.h>

// Attribute index.
enum {
    ATTRIB_VERTEX,
    ATTRIB_TEXTUREPOSITON,
    NUM_ATTRIBUTES
};

@interface STGLPreview3 ()
{
    /* The pixel dimensions of the backbuffer */
    GLint backingWidth, backingHeight;
    
    /* OpenGL names for the renderbuffer and framebuffers used to render to this view */
    GLuint viewRenderbuffer, viewFramebuffer;

    GLuint positionRenderTexture;
    GLuint positionRenderbuffer, positionFramebuffer;
    
    GLuint stDisplayProgram;
    
    int uniformLocation;

    //shader
    GLuint position;
    GLuint textureCoordinate;
    GLuint luminanctTexture;
    GLuint chrominanceTexture;
    
    //framebuffer
    GLuint rgbTexture;
    CVOpenGLESTextureRef rgbCVTexture;
    CVPixelBufferRef rgbPixelBuffer;
    GLuint rgbFrameBuffer;
    
    GLuint imageBufferWidth;
    GLuint imageBufferHeight;
    
    CVOpenGLESTextureCacheRef textureCache;
    
    const GLfloat *preferredConversion;
    
    BOOL supportFastTextureUpload;
    
    GLfloat imageVertices[8];
    
    GLuint yTextrure;
    GLuint uvTexture;
}

@property (nonatomic, strong) STGLShader *yuv2rgbShader;
@property (nonatomic, strong) STGLShader *yuv2rgbShader1;
@end

@implementation STGLPreview3

// Override the class method to return the OpenGL layer, as opposed to the normal CALayer
+ (Class) layerClass
{
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame context:(EAGLContext *)context
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        // Set scaling to account for Retina display
        if ([self respondsToSelector:@selector(setContentScaleFactor:)])
        {
            self.contentScaleFactor = [[UIScreen mainScreen] scale];
        }
        
        // Do OpenGL Core Animation layer setup
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        
        _glContext = context;
        
        if (!_glContext) {
            
            return nil;
        }
        
        if ([EAGLContext currentContext] != _glContext) {
            
            if (![EAGLContext setCurrentContext:_glContext]) {
                
                return nil;
            }
        }
        
        CVReturn ret = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, _glContext, NULL, &textureCache);
        if (ret) {
            NSLog(@"CVOpenGLESTextureCacheCreate error");
        }
        
        supportFastTextureUpload = YES;
        
        if (![self createFramebuffers]) {
            
            return nil;
        }
        
        [self loadVertexShader:@"STDisplayShader"
                fragmentShader:@"STDisplayShader"
                    forProgram:&stDisplayProgram];
        
        _yuv2rgbShader = [self createYUV2RGBShader:kSTYUVFullRangeConversionForLAFragmentShaderString];
        _yuv2rgbShader1 = [self createYUV2RGBShader:kSTYUVFullRangeConversionForLAFragmentShaderString1];
       
    }
    return self;
}


- (STGLShader *)createYUV2RGBShader:(NSString *)fragShader
{
    [EAGLContext setCurrentContext:self.glContext];
    STGLShader *shader = [[STGLShader alloc] initWithVertexShader:KSTVertexShaderString fragmentShader:fragShader];
    
    [shader addAttribute:@"position"];
    [shader addAttribute:@"inputTextureCoordinate"];
    
    position = [shader attributeIndex:@"position"];
    textureCoordinate = [shader attributeIndex:@"inputTextureCoordinate"];
    
    glEnableVertexAttribArray(position);
    glEnableVertexAttribArray(textureCoordinate);
    
    CGSize currentViewSize = self.bounds.size;
    
    //    CGFloat imageAspectRatio = inputImageSize.width / inputImageSize.height;
    //    CGFloat viewAspectRatio = currentViewSize.width / currentViewSize.height;
    
    CGRect insetRect = AVMakeRectWithAspectRatioInsideRect(CGSizeMake(720, 1280), self.bounds);
    
    CGFloat heightScaling, widthScaling;
    widthScaling = currentViewSize.height / insetRect.size.height;
    heightScaling = currentViewSize.width / insetRect.size.width;
    
    imageVertices[0] = -widthScaling;
           imageVertices[1] = -heightScaling;
           imageVertices[2] = widthScaling;
           imageVertices[3] = -heightScaling;
           imageVertices[4] = -widthScaling;
           imageVertices[5] = heightScaling;
           imageVertices[6] = widthScaling;
           imageVertices[7] = heightScaling;
    return shader;
}

- (void)createYUV2RGBFrameBuffer:(CGSize)size
{
    [EAGLContext setCurrentContext:self.glContext];
    //create framebuffer
    glGenFramebuffers(1, &rgbFrameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, rgbFrameBuffer);
    CFDictionaryRef empty;
    CFMutableDictionaryRef attrs;
    empty = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    attrs = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionarySetValue(attrs, kCVPixelBufferIOSurfacePropertiesKey, empty);
    CVReturn err = CVPixelBufferCreate(kCFAllocatorDefault, size.width, size.height, kCVPixelFormatType_32BGRA, attrs, &rgbPixelBuffer);
    if (err) {
        NSLog(@"CVPixelBuffer create error");
    }
    
    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, rgbPixelBuffer, NULL, GL_TEXTURE_2D, GL_RGBA, size.width, size.height, GL_BGRA, GL_UNSIGNED_BYTE, 0, &rgbCVTexture);
    if (err)
    {
        NSAssert(NO, @"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
    }
    
    CFRelease(attrs);
    CFRelease(empty);
    
    glBindTexture(CVOpenGLESTextureGetTarget(rgbCVTexture), CVOpenGLESTextureGetName(rgbCVTexture));
    rgbTexture = CVOpenGLESTextureGetName(rgbCVTexture);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, CVOpenGLESTextureGetName(rgbCVTexture), 0);
    glBindTexture(GL_TEXTURE_2D, 0);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

- (void)dealloc
{
    [self destroyFramebuffer];
}

- (BOOL)createFramebuffers
{
    [EAGLContext setCurrentContext:self.glContext];
    
//    glEnable(GL_TEXTURE_2D);
//    glDisable(GL_DEPTH_TEST);
    
    // Onscreen framebuffer object
    glGenFramebuffers(1, &viewFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, viewFramebuffer);
    
    glGenRenderbuffers(1, &viewRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
    
    [_glContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, viewRenderbuffer);
    
    if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        
        NSLog(@"STGLPreview : failure with framebuffer generation");
        
        return NO;
    }
    
    return YES;
}

- (void)resetRGBFrameBuffer
{
    if (rgbFrameBuffer) {
       glDeleteFramebuffers(1, &rgbFrameBuffer);
       rgbFrameBuffer = 0;
    }

    if (rgbPixelBuffer) {
       CVPixelBufferRelease(rgbPixelBuffer);
       rgbPixelBuffer = NULL;
    }

    if (rgbCVTexture) {
       CFRelease(rgbCVTexture);
       rgbCVTexture = NULL;
    }
    
    if (yTextrure) {
        glDeleteTextures(1, &yTextrure);
        yTextrure = 0;
    }
    
    if (uvTexture) {
        glDeleteTextures(1, &uvTexture);
        uvTexture = 0;
    }
}

- (void)destroyFramebuffer;
{
    
    [EAGLContext setCurrentContext:self.glContext];
    
    if (viewFramebuffer) {
        
        glDeleteFramebuffers(1, &viewFramebuffer);
        viewFramebuffer = 0;
    }
    
    if (viewRenderbuffer) {
        
        glDeleteRenderbuffers(1, &viewRenderbuffer);
        viewRenderbuffer = 0;
    }
    
    if (textureCache) {
        CFRelease(textureCache);
        textureCache = NULL;
    }
    
    [self resetRGBFrameBuffer];
}


- (BOOL)loadVertexShader:(NSString *)vertexShaderName
          fragmentShader:(NSString *)fragmentShaderName
              forProgram:(GLuint *)programPointer;
{
    GLuint vertexShader, fragShader;
        
    // Create shader program.
    *programPointer = glCreateProgram();
    
    // Create and compile vertex shader.
    if (![self compileShader:&vertexShader type:GL_VERTEX_SHADER shaderString:vsh]) {
        
        NSLog(@"STGLPreview : failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER shaderString:fsh]) {
        
        NSLog(@"STGLPreview : failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(*programPointer, vertexShader);
    
    // Attach fragment shader to program.
    glAttachShader(*programPointer, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(*programPointer, ATTRIB_VERTEX, "position");
    glBindAttribLocation(*programPointer, ATTRIB_TEXTUREPOSITON, "inputTextureCoordinate");
    
    // Link program.
    if (![self linkProgram:*programPointer]) {
        
        NSLog(@"STGLPreview : failed to link program: %d", *programPointer);
        
        if (vertexShader) {
            
            glDeleteShader(vertexShader);
            vertexShader = 0;
        }
        if (fragShader) {
            
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (*programPointer) {
            
            glDeleteProgram(*programPointer);
            *programPointer = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    uniformLocation = glGetUniformLocation(*programPointer, "videoFrame");
    
    // Release vertex and fragment shaders.
    if (vertexShader) {
     
        glDeleteShader(vertexShader);
    }
    if (fragShader) {
        
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type shaderString:(const char *)str
{
    GLint status;
    const GLchar *source;

    source = (GLchar *)str;
    if (!source) {
        
        NSLog(@"STGLPreview : failed to load vertex shader");
        
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        
        glDeleteShader(*shader);
        
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    
    glLinkProgram(prog);
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    
    if (0 == status) {
        
        return NO;
    }else{
        
        return YES;
    }
}

- (void)renderTexture:(GLuint)texture
{
    if ([EAGLContext setCurrentContext:self.glContext]) {
        
        [self drawFrameWithTexture:texture];
    }
}

- (BOOL)drawFrameWithTexture:(GLuint)texture
{
    static const GLfloat squareVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    
    const GLfloat textureVertices[] = {
        0.0 + self.scale, 1.0 - self.scale,
        1.0 - self.scale, 1.0 - self.scale,
        0.0 + self.scale,  0.0 + self.scale,
        1.0 - self.scale,  0.0 + self.scale,
    };
    
    // Use shader program.
    if (!viewFramebuffer) {
        
        [self createFramebuffers];
    }
    
    glUseProgram(stDisplayProgram);
    
    glBindFramebuffer(GL_FRAMEBUFFER, viewFramebuffer);
    glViewport(0, 0, backingWidth, backingHeight);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture);
    
    // Update uniform values
    glUniform1i(uniformLocation, 0);
    
    // Update attribute values.
    glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, 0, 0, imageVertices);
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    glVertexAttribPointer(ATTRIB_TEXTUREPOSITON, 2, GL_FLOAT, 0, 0, textureVertices);
    glEnableVertexAttribArray(ATTRIB_TEXTUREPOSITON);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    BOOL isSuccess = NO;
    
    if (_glContext) {
        
        glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
        isSuccess = [_glContext presentRenderbuffer:GL_RENDERBUFFER];
    }
    
    return isSuccess;
}

- (GLuint)convertYUV2RGB:(CVPixelBufferRef)cameraFrame
{
    [EAGLContext setCurrentContext:self.glContext];
    
    if (!cameraFrame) {
        return 0;
    }
    CVPixelBufferLockBaseAddress(cameraFrame, 0);
    int frameWidth = (int)CVPixelBufferGetWidthOfPlane(cameraFrame, 0);
    int frameHeight = (int)CVPixelBufferGetHeightOfPlane(cameraFrame, 0);
    
    CFTypeRef colorAttachments = CVBufferGetAttachment(cameraFrame, kCVImageBufferYCbCrMatrixKey, NULL);
    if (colorAttachments != NULL) {
        if (CFStringCompare(colorAttachments, kCVImageBufferYCbCrMatrix_ITU_R_601_4, 0) == kCFCompareEqualTo) {
            preferredConversion = kColorConversion601FullRange;
        }
        else
        {
            preferredConversion = kColorConversion709;
        }
    }
    else
    {
        preferredConversion = kColorConversion601;
    }
    
    //这里有两种创建纹理的方法
    //1.CVOpenGLESTextureCacheCreateTextureFromImage
    CVOpenGLESTextureRef luminanceTextureRef = NULL;
    CVOpenGLESTextureRef chroinanceTextureRef = NULL;
    
    int plane = (int)CVPixelBufferGetPlaneCount(cameraFrame);
    
    if (plane > 0) {
        if (imageBufferWidth != frameWidth && imageBufferHeight != frameHeight) {
            imageBufferWidth = frameWidth;
            imageBufferHeight = frameHeight;
            [self resetRGBFrameBuffer];
            [self createYUV2RGBFrameBuffer:CGSizeMake(frameWidth, frameHeight)];
        }
        CVReturn err;
        glActiveTexture(GL_TEXTURE5);
        err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, cameraFrame, NULL, GL_TEXTURE_2D, GL_LUMINANCE, frameWidth, frameHeight, GL_LUMINANCE, GL_UNSIGNED_BYTE, 0, &luminanceTextureRef);
        luminanctTexture = CVOpenGLESTextureGetName(luminanceTextureRef);
        glBindTexture(GL_TEXTURE_2D, luminanctTexture);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        glActiveTexture(GL_TEXTURE6);
        err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, cameraFrame, NULL, GL_TEXTURE_2D, GL_LUMINANCE_ALPHA, frameWidth/2, frameHeight/2, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, 1, &chroinanceTextureRef);
        chrominanceTexture = CVOpenGLESTextureGetName(chroinanceTextureRef);
        glBindTexture(GL_TEXTURE_2D, chrominanceTexture);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        [self convert:CGSizeMake(frameWidth, frameHeight) shader:_yuv2rgbShader];
        CFRelease(luminanceTextureRef);
        CFRelease(chroinanceTextureRef);
    }
    CVPixelBufferUnlockBaseAddress(cameraFrame, 0);
    return rgbTexture;
}


- (GLuint)convertYUV2RGB:(unsigned char *)yData
                  uvData:(unsigned char *)uvData
                       w:(int)w h:(int)h{
    if (imageBufferWidth != w && imageBufferHeight != h) {
        imageBufferWidth = w;
        imageBufferHeight = h;
        [self resetRGBFrameBuffer];
        [self createYUV2RGBFrameBuffer:CGSizeMake(w, h)];
    }
    if (yTextrure == 0) {
        glGenTextures(1, &yTextrure);
        glBindTexture(GL_TEXTURE_2D, yTextrure);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, w, h, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, NULL);
    }
    if (uvTexture == 0) {
        glGenTextures(1, &uvTexture);
        glBindTexture(GL_TEXTURE_2D, uvTexture);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE_ALPHA, w/2, h/2, 0, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, NULL);
    }
    if (yData && uvData) {
        glBindTexture(GL_TEXTURE_2D, yTextrure);
        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, w, h, GL_LUMINANCE, GL_UNSIGNED_BYTE, yData);
        glBindTexture(GL_TEXTURE_2D, uvTexture);
        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, w/2, h/2, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, uvData);
    }else{
        return 0;
    }
    preferredConversion = kColorConversion601;
    [self convert:CGSizeMake(w, h) shader:_yuv2rgbShader1];
    return rgbTexture;
}

- (void)convert:(CGSize)size shader:(STGLShader *)shader
{
    [EAGLContext setCurrentContext:self.glContext];
    
    glBindFramebuffer(GL_FRAMEBUFFER, rgbFrameBuffer);
    glViewport(0, 0, size.width, size.height);
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self.yuv2rgbShader use];
    
    //model
//    GLKMatrix4 model = GLKMatrix4Identity;
    //projection
    GLKMatrix4 projection = GLKMatrix4MakeOrtho(0.5, 1.0, 0.5, 0.0, -0.5, 0.5);
    
    static const GLfloat squareVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    
    static const GLfloat textureVertices[] = {
        0.0f, 1.0f,
        1.0f, 1.0f,
        0.0f,  0.0f,
        1.0f,  0.0f,
    };
    
    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, (shader == _yuv2rgbShader1) ? yTextrure : luminanctTexture);
    [_yuv2rgbShader setIntWithName:@"luminanceTexture" value:5];
    
    glActiveTexture(GL_TEXTURE6);
    glBindTexture(GL_TEXTURE_2D, (shader == _yuv2rgbShader1) ? uvTexture : chrominanceTexture);
    [_yuv2rgbShader setIntWithName:@"chrominanceTexture" value:6];
    
    GLKMatrix3 matrix = GLKMatrix3Make(preferredConversion[0],
                                       preferredConversion[1],
                                       preferredConversion[2],
                                       preferredConversion[3],
                                       preferredConversion[4],
                                       preferredConversion[5],
                                       preferredConversion[6],
                                       preferredConversion[7],
                                       preferredConversion[8]);
    [_yuv2rgbShader setMat3WithName:@"colorConversionMatrix" value:matrix];
//    [_yuv2rgbShader setMat4WithName:@"model" value:model];
    [_yuv2rgbShader setMat4WithName:@"projection" value:projection];
    
    glVertexAttribPointer(position, 2, GL_FLOAT, GL_FALSE, 0, squareVertices);
    glVertexAttribPointer(textureCoordinate, 2, GL_FLOAT, GL_FALSE, 0, textureVertices);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

@end
