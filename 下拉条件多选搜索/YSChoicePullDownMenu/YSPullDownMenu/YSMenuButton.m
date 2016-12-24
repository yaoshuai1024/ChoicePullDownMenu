#import "YSMenuButton.h"

@implementation YSMenuButton

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGRect frame = self.frame;
    CGRect imageVFrame = self.imageView.frame;
    CGRect labelFrame = self.titleLabel.frame;
    
    labelFrame.origin.x = (frame.size.width - labelFrame.size.width - imageVFrame.size.width) / 2;
    labelFrame.origin.y = (frame.size.height - labelFrame.size.height) / 2;
    
    imageVFrame.size = CGSizeMake(7, 7);
    imageVFrame.origin.x = CGRectGetMaxX(labelFrame) + 5;
    imageVFrame.origin.y = labelFrame.origin.y + (labelFrame.size.height - imageVFrame.size.height) / 2;
    
    self.imageView.frame = imageVFrame;
    self.titleLabel.frame = labelFrame;
}

@end
