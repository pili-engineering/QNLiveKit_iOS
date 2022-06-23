//
//  QNAppStartPlayerController.h
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2021/4/9.
//

#import <UIKit/UIKit.h>

@interface QNAppStartPlayerController : UIViewController

/**
 *  @param movieURL 网上url视频
 *  @param localMovieName 本地视频
 */
- (void)setMoviePlayerInIndexWithURL:(NSURL *)movieURL localMovieName:(NSString *)localMovieName;

/**
 *  @param imageURL 网上url图片
 *  @param localImageName 本地图片
 *  @param timeCount 倒计时时间
 */

- (void)setImageInIndexWithURL:(NSURL *)imageURL localImageName:(NSString *)localImageName timeCount:(int)timeCount;

@end
