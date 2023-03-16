//
//  QInvitationModel.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/12/8.
//

#import "QInvitationModel.h"
#import "LinkInvitation.h"

@implementation QInvitationModel

@end

@implementation QInvitationInfo
@synthesize linkInvitation = _linkInvitation;
@synthesize msg = _msg;

+ (NSArray *)mj_ignoredPropertyNames {
    return @[@"linkInvitation"];
}

- (void)setLinkInvitation:(LinkInvitation *)linkInvitation {
    _linkInvitation = linkInvitation;
    
    NSError *error = nil;
    NSData *data = [linkInvitation mj_JSONData];
    if (!error) {
        _msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
}

- (LinkInvitation *)linkInvitation {
    if (_linkInvitation) {
        return _linkInvitation;
    }
    
    if (!_msg) {
        return nil;
    }
    
    NSData *data = [_msg dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    _linkInvitation = [LinkInvitation mj_objectWithKeyValues:dic];
    return _linkInvitation;
}
@end

@implementation QExtension

@end

