//
//  QNBeautyManager.m
//  QNLiveUIKit
//
//  Created by 孙慕 on 2023/2/17.
//

#import "QNBeautyManager.h"
#import "LicenseUtil.h"


@interface QNBeautyManager ()

@property (nonatomic, strong) PLSTEffectManager *effectManager;
@property (nonatomic, strong) PLSTDetector *detector;

@property (nonatomic, strong) dispatch_semaphore_t sem;
@property (nonatomic, strong) SuccessBlock block;
@end



@implementation QNBeautyManager
+ (QNBeautyManager *)shardManager {
    static QNBeautyManager * single = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        single =[[QNBeautyManager alloc]init];
    }) ;
    return single;
}


- (instancetype)init{
    if (self == [super init]){
        // 鉴权

    }
    return  self;
}


- (void)initSuccess:(void (^)(BOOL state))success{
    [[LicenseUtil sharedInstance] checkLicense:^(BOOL status) {
        if(status){
            [self setupSenseAR];
            success(YES);
        }else{
            success(NO);
        }
    }];
}

-(void)setupSenseAR {
    if (self.effectManager) {
        return;
    }
    
    self.effectManager = [[PLSTEffectManager alloc] initWithContext:[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2] handleConfig:EFFECT_CONFIG_NONE];
    self.effectManager.effectOn = YES;
    
    _detector = [[PLSTDetector alloc] initWithConfig:ST_MOBILE_HUMAN_ACTION_DEFAULT_CONFIG_VIDEO];
    NSAssert(_detector, @"");

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [_detector setModelPath:[[NSBundle mainBundle] pathForResource:@"model" ofType:@"bundle"]];
        
        //猫脸检测
        NSString *catFaceModel = [[NSBundle mainBundle] pathForResource:@"M_SenseME_CatFace_p_3.2.0.1" ofType:@"model"];
        [_detector addAnimalModelModel:catFaceModel];

        //狗脸检测
        NSString *dogFaceModelPath = [[NSBundle mainBundle] pathForResource:@"M_SenseME_DogFace_p_2.0.0.1" ofType:@"model"];
        [_detector addAnimalModelModel:dogFaceModelPath];

    });

}


-(PLSTEffectManager *)getEffectManager{
    return _effectManager;
}

-(PLSTDetector *)getDetector{
    return _detector;
}



@end
