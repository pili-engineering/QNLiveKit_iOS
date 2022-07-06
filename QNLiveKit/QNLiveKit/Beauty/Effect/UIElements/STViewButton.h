//
//  STViewButton.h
//  SenseMeEffects
//
//  Created by Sunshine on 15/08/2017.
//  Copyright © 2017 SenseTime. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^STTapBlock)(void);

@protocol STViewButtonDelegate <NSObject>

@optional
- (void)btnLongPressBegin;
- (void)btnLongPressEnd;
- (void)btnLongPressFailed;
- (void)btnLongPressCancelled;

@end


@interface STViewButton : UIView

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *titleLabel;

@property (nonatomic, readwrite, assign, getter=isHighlighted) BOOL highlighted;
@property (nonatomic, readwrite, copy) STTapBlock tapBlock;

@property (nonatomic, readwrite, weak) id<STViewButtonDelegate> delegate;

@end
