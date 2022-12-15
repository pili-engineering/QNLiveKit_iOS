//
//  ApiDemoViewController.h
//  QNLiveKitDemo
//
//  Created by sheng wang on 2022/12/15.
//

#import <UIKit/UIKit.h>
#import "QNApiDemo.h"

NS_ASSUME_NONNULL_BEGIN


@interface QNApiDemoEntry : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, strong) id<QNApiDemo> demo;

- (instancetype)initWithTitle:(NSString *)title desc:(NSString *)desc demo:(id<QNApiDemo>)demo;

@end

@interface ApiDemoViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
