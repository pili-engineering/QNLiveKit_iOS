//
//  HorizontalLayout.m
//  QiNiu_Solution_iOS
//
//  Created by 郭茜 on 2022/1/5.
//

#import "QNHorizontalLayout.h"

@interface QNHorizontalLayout()
/** 存放cell全部布局属性 */
@property(nonatomic,strong) NSMutableArray *cellAttributesArray;

@property (nonatomic, assign) CGFloat itemHeight ;
@property (nonatomic, assign) CGFloat itemWidth;

@end

@implementation QNHorizontalLayout

- (instancetype)init {
    if (self = [super init]) {
        self.itemWidth = 80;
        self.itemHeight = 100;
    }
    return self;
}

- (NSMutableArray *)cellAttributesArray{
    if (!_cellAttributesArray) {
        _cellAttributesArray = [NSMutableArray array];
    }
    return _cellAttributesArray;
}


- (void)prepareLayout {
    [super prepareLayout];
    
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
    [self setSectionInset:UIEdgeInsetsMake(0, 8, 0, 8)];
    
    self.itemSize = CGSizeMake(self.itemWidth, self.itemHeight);
    self.minimumLineSpacing = 0;
    self.minimumInteritemSpacing = 13;
    
    self.itemSize = CGSizeMake(self.itemWidth, self.itemHeight);
    
    //刷新后清除所有已布局的属性 重新获取
    [self.cellAttributesArray removeAllObjects];
    
    NSInteger cellCount = [self.collectionView numberOfItemsInSection:0];
    for (NSInteger i = 0; i < cellCount; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UICollectionViewLayoutAttributes *attibute = [self layoutAttributesForItemAtIndexPath:indexPath];
        
        [self.cellAttributesArray addObject:attibute];
    }
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    return self.cellAttributesArray;
}

- (CGSize)collectionViewContentSize {
    NSInteger cellCount = [self.collectionView numberOfItemsInSection:0];
    NSInteger lineCount = (cellCount > 0) ? (cellCount - 1) / 4 + 1 : 0;
    
    return CGSizeMake(SCREEN_W, self.itemHeight * lineCount);
}


@end
