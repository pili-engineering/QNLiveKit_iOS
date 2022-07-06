//
//  STViewButton.m
//  SenseMeEffects
//
//  Created by Sunshine on 15/08/2017.
//  Copyright © 2017 SenseTime. All rights reserved.
//

#import "STViewButton.h"

@interface STViewButton ()

@property (nonatomic, strong) dispatch_queue_t blockSerialQueue;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;

@end

@implementation STViewButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self imageView];
        [self titleLabel];
        [self setLongPressGesture];
    }
    return self;
}

- (void)setTapBlock:(STTapBlock)tapBlock {
    
    _tapBlock = tapBlock;
    
    if (_tapBlock) {
        
        self.userInteractionEnabled = YES;
        
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        
        [self addGestureRecognizer:self.tapGesture];
        
        [self.longPressGesture requireGestureRecognizerToFail:self.tapGesture];
    }
}

- (void)setLongPressGesture {
    
    self.userInteractionEnabled = YES;
    
    _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];

    [self addGestureRecognizer:_longPressGesture];
}

- (void)onTap:(UITapGestureRecognizer *)recognizer {
    
    _tapBlock();

}

- (void)onLongPress:(UILongPressGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        if ([self.delegate respondsToSelector:@selector(btnLongPressBegin)]) {
            [self.delegate btnLongPressBegin];
        }
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        if ([self.delegate respondsToSelector:@selector(btnLongPressEnd)]) {
            [self.delegate btnLongPressEnd];
        }
        
    } else if (recognizer.state == UIGestureRecognizerStateFailed) {
        
        if ([self.delegate respondsToSelector:@selector(btnLongPressFailed)]) {
            [self.delegate btnLongPressFailed];
        }
        
    } else if (recognizer.state == UIGestureRecognizerStateCancelled) {
        
        //todo
        
    } else if (recognizer.state == UIGestureRecognizerStateRecognized) {
        
        //todo
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        //todo
        
    } else if (recognizer.state == UIGestureRecognizerStatePossible) {
        
        //todo
        
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    _highlighted = highlighted;
    _imageView.highlighted = highlighted;
    _titleLabel.highlighted = highlighted;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        [self addSubview:_imageView];
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
            make.bottom.equalTo(self.mas_bottom).offset(-10);
        }];
    }
    return _imageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:11];
        [self addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self);
            make.top.equalTo(self.imageView.mas_bottom);
        }];
    }
    return _titleLabel;
}

@end
