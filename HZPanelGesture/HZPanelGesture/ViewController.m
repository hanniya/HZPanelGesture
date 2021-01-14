//
//  ViewController.m
//  HZPanelGesture
//
//  Created by Yihan Zhang on 2021/1/13.
//

#import "ViewController.h"
#import "HZPanelGestureRecognizer.h"

@interface ViewController ()

@property (nonatomic, strong) UIView *panelView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat minHeight = 200;
    CGFloat norHeight = 500;
    
    self.panelView = [UIView new];
    self.panelView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - minHeight, [UIScreen mainScreen].bounds.size.width, norHeight);
    self.panelView.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.panelView];
    
    HZPanelGestureRecognizer *gesture = [HZPanelGestureRecognizer new];
    gesture.normalHeight = norHeight;
    gesture.minHeight = minHeight;
    gesture.panelState = HZPanelStateMin;
    gesture.closeBlock = ^{
        NSLog(@"关闭回调");
    };
    [self.panelView addGestureRecognizer:gesture];
}

@end
