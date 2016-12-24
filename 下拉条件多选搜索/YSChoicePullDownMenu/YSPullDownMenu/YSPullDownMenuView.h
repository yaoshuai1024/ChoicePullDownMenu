#import <UIKit/UIKit.h>

@class YSPullDownMenuView;

@protocol YSPullDownMenuViewDelegate <NSObject>

- (void)pullDownMenuView:(YSPullDownMenuView *)menu didSelectedIndexPaths:(NSArray<NSIndexPath *> *)indexPathArray;

@end

@interface YSPullDownMenuView : UIView

@property (weak, nonatomic) id<YSPullDownMenuViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame andSearchTitleArray:(NSArray *)searchTitleArray andSelectedColor:(UIColor *)selectedColor;

@end
