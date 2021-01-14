//
//  HZPanelGestureRecognizer.h
//  HZPanelGesture
//
//  Created by Yihan Zhang on 2021/1/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, HZPanelState) {
    HZPanelStateNormal,
    HZPanelStateMin
};

@interface HZPanelGestureRecognizer : UIPanGestureRecognizer

/// 正常状态视图高度
/// 默认为添加手势的视图高度
@property (nonatomic, assign) CGFloat normalHeight;

/// 最小状态视图高度，建议<normalHeight
/// 默认为0, 无最小态
@property (nonatomic, assign) CGFloat minHeight;

/// 初始状态
/// 默认为HZPanelStateNormal
@property (nonatomic, assign) HZPanelState panelState;

/// 自定义条件手势拦截
/// return NO 时不响应该手势
@property (nonatomic, copy) BOOL (^canRespondToGesture)(CGPoint point, UIView *view);

/// 视图收起回调
@property (nonatomic, copy) dispatch_block_t closeBlock;

/// 移动的视图
/// 默认为添加手势的视图
@property (nonatomic, strong) UIView *movedView;

@end

NS_ASSUME_NONNULL_END
