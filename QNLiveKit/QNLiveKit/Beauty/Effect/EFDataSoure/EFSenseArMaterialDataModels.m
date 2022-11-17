//
//  EFSenseArMaterialDataModels.m
//  SenseMeEffects
//
//  Created by 马浩萌 on 2021/6/4.
//

#import "EFSenseArMaterialDataModels.h"
#import <objc/runtime.h>
#import "NSObject+dictionary.h"

static NSString * const efMaterialsArrayKey;

@interface EFDataSourceModel ()

//@property (nonatomic, readwrite, copy) NSString * efName;
//@property (nonatomic, readwrite, copy) NSString * efThumbnailDefault;
@property (nonatomic, readwrite, copy) NSString * efThumbnailHighlight;
//@property (nonatomic, readwrite, copy) NSString * efMaterialPath;
//@property (nonatomic, readwrite, assign) NSUInteger efType;
//@property (nonatomic, readwrite, assign) NSUInteger efRoute;

@end

@implementation EFDataSourceModel

+(NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{
        @"efName": @"name",
        @"efThumbnailDefault": @[@"imageName", @"thumbnail"],
        @"efThumbnailHighlight": @"highlightImageName",
        @"efType": @"type",
        @"efMaterialPath": @[@"path"],
        @"efRoute": @"route",
        @"efSubDataSources": @[@"subDataSources", @"all_categories"],
        @"strMaterialURL": @[@"pkgUrl"],
        @"strID": @"id"
    };
}

-(void)setEfMaterials:(NSArray<EFDataSourceModel *> *)efMaterials {
    for (NSInteger i = 0; i < efMaterials.count; i ++) {
        EFDataSourceModel *materialModel = efMaterials[i];
        /// ——/—/—/———
        /// type/path_flag/mode_flag/mode
        materialModel.efType = (3 << 5) | (1 << 4);
        //        materialModel.efMaterialPath = materialModel.strMaterialPath;
        materialModel.efRoute = (self.efRoute | (i + 1));
    }
    self.efSubDataSources = [efMaterials copy];
}

-(NSString *)efAlias {
    if (_efAlias) return _efAlias;
    return _efName;
}

+(NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
    return @{
        @"efSubDataSources": EFDataSourceModel.class
    };
}

-(NSString *)strID {
    if (!_strID) {
        return self.efName;
    }
    return _strID;
}

- (id)copyWithZone:(NSZone *)zone {
    return [self yy_modelCopy];
}

@end

#pragma mark - EFMaterialGroup implementation
@implementation EFMaterialGroup

@end
