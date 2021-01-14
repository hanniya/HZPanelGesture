//
//  HZPanelGestureRecognizer.m
//  HZPanelGesture
//
//  Created by Yihan Zhang on 2021/1/14.
//

#import "HZPanelGestureRecognizer.h"

static const CGFloat kValidMovedDistance = 5; ///< 有效下滑距离, 防止细微抖动

@interface HZPanelGestureRecognizer ()

@property (nonatomic, assign) CGFloat originFrameY; ///< 手势开始时的View y
@property (nonatomic, assign) HZPanelState originState; ///< 手势开始时的state
@property (nonatomic, assign) CGFloat minY;
@property (nonatomic, assign) CGFloat normalY;

@property (nonatomic, assign) BOOL isCanPullDown; ///< 判断当前手势是否响应
@property (nonatomic, assign) BOOL isAfterDragDown; ///< 视图是否下滑过
@property (nonatomic, assign) BOOL isAfterDragUp; ///< 视图是否上滑过

@end

@implementation HZPanelGestureRecognizer

- (instancetype)init {
    self = [super init];
    if (self) {
        self.maximumNumberOfTouches = 1; //防止多指触碰导致错误显示
        self.panelState = HZPanelStateNormal;
        self.minHeight = 0;
        self.isCanPullDown = YES;
    }
    return self;
}

#pragma mark - Gesture Methods
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self p_initIfNeeded];
    CGPoint originPoint = [[touches anyObject] locationInView:self.view];
    self.originState = self.panelState;
    if (self.canRespondToGesture) {
        self.isCanPullDown = self.canRespondToGesture(originPoint, self.view);
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.isCanPullDown) {
        return;
    }
    CGFloat transY = [self translationInView:self.view.superview].y;
    BOOL isDragDown = (transY > kValidMovedDistance) ? YES : NO;
    BOOL isDragUp = (transY < kValidMovedDistance) ? YES : NO;
    BOOL isFirstAction = !self.isAfterDragUp && !self.isAfterDragDown;
    
    if (isDragDown) {
        if (isFirstAction) {
            self.isAfterDragDown = YES;
            self.originFrameY = self.movedView.frame.origin.y;
        }
        // 无论什么状态、是否上下滑过，都响应下滑
        [self p_setMovedViewY:(self.originFrameY + transY)];
        
    } else if (isDragUp) {
        if (self.originState == HZPanelStateMin) {
            if (isFirstAction) {
                self.isAfterDragUp = YES;
                self.originFrameY = self.movedView.frame.origin.y;
            }
            // 初始Min态均响应上滑手势，不小于normalY
            CGFloat distance = MIN(fabs(transY), fabs(self.normalY - self.minY));
            [self p_setMovedViewY:(self.originFrameY - distance)];
            
        } else if (self.originState == HZPanelStateNormal && self.isAfterDragDown) {
            // 初始Normal态下滑后才响应上滑手势，不超过原有高度
            [self p_setMovedViewY:MAX(self.originFrameY + transY, self.originFrameY)];
        }
    }
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self finishGesture];
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self finishGesture];
    [super touchesCancelled:touches withEvent:event];
}

- (void)finishGesture {
    if (!self.isAfterDragUp && !self.isAfterDragDown) { ///< 没触发上下滑
        return;
    }
    CGFloat transY = [self translationInView:self.view.superview].y;
    CGFloat viewHeight = (self.originState == HZPanelStateMin) ? self.minHeight : self.normalHeight;
    
    BOOL isDragDown = (transY > 0) ? YES : NO;
    BOOL isDragUp = (transY < 0) ? YES : NO;
    
    ///> 初始min态，被上滑后
    if ((self.originState == HZPanelStateMin) && isDragUp) {
        if (fabs(transY) < fabs(self.normalHeight - self.minHeight) * 0.2) {
            //上滑但未超过差值*20%，复原
            [UIView animateWithDuration:0.1 animations:^{
                [self p_setMovedViewY:self.originFrameY];
            }];
        } else {
            //上滑并超过差值*20%，变为normal态
            [UIView animateWithDuration:0.1 animations:^{
                [self p_setMovedViewY:(self.originFrameY - fabs(self.normalHeight - self.minHeight))];
            }];
            self.panelState = HZPanelStateNormal;
        }
    }
    
    ///> 任何态都处理下滑情况
    if (isDragDown && (transY < viewHeight * 0.2)) {
        //下滑且未超过「视图高度」*20%，复原
        [UIView animateWithDuration:0.1 animations:^{
            [self p_setMovedViewY:self.originFrameY];
        }];
    } else if (transY > viewHeight * 0.2) {
        //下滑且超过「视图高度」*20%，收起面板
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [self p_setMovedViewY:[UIScreen mainScreen].bounds.size.height];
            !self.closeBlock ? : self.closeBlock();
        } completion:nil];
    }
    self.isAfterDragDown = NO;
    self.isAfterDragUp = NO;
}

#pragma mark - Private
- (void)p_initIfNeeded {
    if (!self.movedView) {
        self.movedView = self.view;
    }
    if (!self.normalHeight) {
        self.normalHeight = self.normalHeight = self.view.frame.size.height;
    }
}

- (void)p_setMovedViewY:(CGFloat)y {
    CGRect frame = self.movedView.frame;
    frame.origin.y = y;
    self.movedView.frame = frame;
}

- (CGFloat)minY {
    return [UIScreen mainScreen].bounds.size.height - self.minHeight;
}

- (CGFloat)normalY {
    return [UIScreen mainScreen].bounds.size.height - self.normalHeight;
}

@end
