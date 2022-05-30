//
//  QNHomeListViewModel.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/14.
//

#import "QNHomeListViewModel.h"
#import "QNSolutionListModel.h"
#import <AFNetworking/AFNetworking.h>
#import <MJExtension/MJExtension.h>
#import "QNNetworkUtil.h"

@implementation QNHomeListViewModel

+ (void)requestListModel:(void (^)(QNSolutionListModel *list))success {

    [QNNetworkUtil getRequestWithAction:@"solution" params:nil success:^(NSDictionary *responseData) {
        
        QNSolutionListModel *listModel = [QNSolutionListModel mj_objectWithKeyValues:responseData];
        
        if (listModel != nil) {
            listModel.list = [QNSolutionItemModel mj_objectArrayWithKeyValuesArray:responseData[@"list"]];
            [listModel.list enumerateObjectsUsingBlock:^(QNSolutionItemModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.type isEqualToString:@"interview"]) {
                    obj.itemSelectorNameStr = @"interviewClicked";
                    
                } else if ([obj.type isEqualToString:@"repair"]) {
                    obj.itemSelectorNameStr = @"repairClicked";
                } else if ([obj.type isEqualToString:@"show"]){
                    obj.itemSelectorNameStr = @"showLiveClicked";
                } else if ([obj.type isEqualToString:@"movie"]){
                    obj.itemSelectorNameStr = @"movieClicked";
                } else if ([obj.type isEqualToString:@"voiceChatRoom"]){
                    obj.itemSelectorNameStr = @"voiceChatRoomClicked";
                }  else {
                    obj.itemSelectorNameStr = @"others";
                }
            }];
        }
        success(listModel ?: nil);
        } failure:^(NSError *error) {
            
    }];
}


@end
