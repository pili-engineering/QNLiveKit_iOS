//
//  EFDataSourcing.h
//  SenseMeEffects
//
//  Created by 马浩萌 on 2021/6/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EFDataSourcing <NSObject>

@required
@property (nonatomic, readonly, copy) NSString * efName;
@property (nonatomic, readonly, copy) NSString * efThumbnailDefault;
@property (nonatomic, readonly, copy) NSString * efThumbnailHighlight;
@property (nonatomic, copy) NSString *efMaterialPath;
@property (nonatomic, copy) NSString *strMaterialURL;
@property (nonatomic, readonly, assign) NSUInteger efType;
@property (nonatomic, readonly, strong) NSArray <EFDataSourcing> * efSubDataSources;
@property (nonatomic, readonly, assign) NSUInteger efRoute;
@property (nonatomic, readwrite, assign) BOOL efIsMulti;
@property (nonatomic, copy) NSString *strID;
@property (nonatomic, readwrite, assign) BOOL efFromBundle;
@property (nonatomic, readwrite, assign) BOOL efIsLocal;

@end

NS_ASSUME_NONNULL_END
