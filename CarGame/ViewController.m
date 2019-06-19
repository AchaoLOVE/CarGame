//
//  ViewController.m
//  CarGame
//
//  Created by apple on 2019/6/19.
//  Copyright © 2019 apple.zfc. All rights reserved.
//

#import "ViewController.h"
#import "GridModel.h"

#define kWidth [UIScreen mainScreen].bounds.size.width  //屏幕宽度
#define kHeight [UIScreen mainScreen].bounds.size.height //屏幕高度

#define IS_iPHONE_5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
//判断iPhoneX
#define IS_iPHONE_X ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

#define IS_iPHONEX_Xs     (kWidth == 375.f && kHeight == 812.f ? YES : NO)
//iPhoneXR / iPhoneXSMax
#define IS_iPHONEXR_XsMax    (kWidth == 414.f && kHeight == 896.f ? YES : NO)
//异性全面屏
#define   isFullScreen    (IS_iPHONEX_Xs || IS_iPHONEXR_XsMax)

#define kScaleH    (kHeight/667.0)
#define kScaleW    (kWidth/375.0)

#define PW(x)  ceil((x)*kScaleW)
#define PH(y) ceil((y)*kScaleH)

#define SafeAreaTopHeight (isFullScreen ? 88 : 64)
#define NavHeight (isFullScreen ? 44 : 20)
#define NavFitHeight (isFullScreen ? 24 : 0)
#define SafeAreaBottomHeight (isFullScreen ? 34 : 0)
#define XFitHeight (isFullScreen ? 88 : 0)

typedef NS_ENUM(NSInteger, DirectionType) {
    DirectionTypeNone    = 0,
    DirectionTypeUp      = 1,
    DirectionTypeDown    = 2,
    DirectionTypeLeft    = 3,
    DirectionTypeRight   = 4
};

@interface ViewController ()
@property(nonatomic,strong) UIView * map;
@property(nonatomic,strong) UIImageView * car;
@property(nonatomic,assign) DirectionType  panDirection;

@property(nonatomic,assign) DirectionType  carDirection;

@property(nonatomic,strong) NSMutableArray <GridModel*>* gridArray;
@property(nonatomic,strong) GridModel * currentGrid;

@property(nonatomic,assign) BOOL  isMoving;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _panDirection = DirectionTypeNone;
    
    _carDirection = DirectionTypeUp;
    
    _gridArray = [NSMutableArray array];
    
    _isMoving = NO;
    
    [self drawContentView];
}

- (void)drawContentView
{
    if (isFullScreen) {
        self.view.layer.contents = (id)[UIImage imageNamed:@"game_maze_bgipx"].CGImage;
    }else{
        self.view.layer.contents = (id)[UIImage imageNamed:@"game_maze_bg"].CGImage;
    }
    
    UIView * map = [[UIView alloc]initWithFrame:CGRectMake(PW(19),XFitHeight+PW(176), PW(340), PW(464))];
    map.layer.contents = (id)[UIImage imageNamed:@"game_maze_path"].CGImage;
    [self.view addSubview:map];
    self.map = map;
    
    // 第1个参数:列数 x横坐标
    // 第2个参数:行数 y纵坐标
    // 第3个参数:是否是有效区域
    // 第4个参数:支持的方向  上:1 下:2 左:3 右:4
    
    NSArray <NSArray*>*array = @[
                                 @[@"1,1,1,24", @"1,2,1,34", @"1,3,1,34", @"1,4,1,34", @"1,5,1,34", @"1,6,1,34", @"1,7,1,34", @"1,8,1,23"],
                                 @[@"2,1,1,12", @"2,2,0,0", @"2,3,0,0", @"2,4,0,1", @"2,5,0,1", @"2,6,0,0", @"2,7,0,0", @"2,8,1,12"],
                                 @[@"3,1,1,14", @"3,2,1,23", @"3,3,0,0", @"3,4,0,1", @"3,5,0,1", @"3,6,0,1", @"3,7,2,4", @"3,8,1,123"],
                                 @[@"4,1,0,0", @"4,2,1,12", @"4,3,0,0", @"4,4,0,0", @"4,5,0,0", @"4,6,0,0", @"4,7,0,0", @"4,8,1,12"],
                                 @[@"5,1,1,24", @"5,2,1,134", @"5,3,2,3", @"5,4,0,0", @"5,5,0,0", @"5,6,0,0", @"5,7,0,0", @"5,8,1,12"],
                                 @[@"6,1,1,12", @"6,2,0,0", @"6,3,0,0", @"6,4,0,0", @"6,5,0,0", @"6,6,0,0", @"6,7,0,0", @"6,8,1,12"],
                                 @[@"7,1,1,14", @"7,2,1,34", @"7,3,1,34", @"7,4,1,34", @"7,5,1,234", @"7,6,1,34", @"7,7,1,34", @"7,8,1,13"],
                                 @[@"8,1,0,0", @"8,2,0,0", @"8,3,0,0", @"8,4,0,0", @"8,5,1,12", @"8,6,0,0", @"8,7,0,0", @"8,8,0,0"],
                                 @[@"9,1,1,24", @"9,2,1,34", @"9,3,1,23", @"9,4,0,0", @"9,5,1,124", @"9,6,2,3", @"9,7,0,0", @"9,8,0,0"],
                                 @[@"10,1,1,1", @"10,2,0,0", @"10,3,1,12", @"10,4,0,0", @"10,5,1,12", @"10,6,0,0", @"10,7,0,0", @"10,8,0,0"],
                                 @[@"11,1,1,1", @"11,2,0,0", @"11,3,1,14", @"11,4,1,34", @"11,5,1,13", @"11,6,0,0", @"11,7,0,0", @"11,8,0,0"]
                                 ];
    
    
    for (int i = 0; i< array.count; i++) {
        NSArray <NSString*>* hangArray = array[i];
        
        for (int j = 0; j < hangArray.count; j++) {
            
            NSString * str = [hangArray objectAtIndex:j];
            
            NSArray <NSString*>* strArr = [str componentsSeparatedByString:@","];
            
            UIView * gridView = [[UIView alloc]initWithFrame:CGRectMake(PW(11)+ j%8*PW(40),PW(10)+i%11*PW(40), PW(40), PW(40))];
            gridView.userInteractionEnabled = YES;
            [self.map addSubview:gridView];
            
            GridModel * grid = [[GridModel alloc]init];
            grid.x = strArr[1].integerValue;
            grid.y = strArr[0].integerValue;
            grid.flag = strArr[2].integerValue;
            grid.dires = strArr[3];
            
            if (grid.x == 1 && grid.y == 10) {
                _currentGrid = grid;
            }
            
            [_gridArray addObject:grid];
            
        }
    }
    
    _car = [[UIImageView alloc]initWithFrame:CGRectZero];
    _car.image = [UIImage imageNamed:@"maze_car_up"];
    _car.frame = CGRectMake(PW(11)+ (_currentGrid.x-1)%8*PW(40),PW(10)+(_currentGrid.y-1)%11*PW(40), PW(40), PW(40));
    [self.map addSubview:_car];
    
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleSwipe:)];
    [self.view addGestureRecognizer:recognizer];
    
    UIImageView * targetIV1 = [[UIImageView alloc]initWithFrame:CGRectMake(PW(188), PW(74), PW(81), PW(81))];
    targetIV1.image = [UIImage imageNamed:@"game_maze_button"];
    [self.map addSubview:targetIV1];
    
    UIImageView * target1 = [[UIImageView alloc]initWithFrame:CGRectMake(PW(22), PW(17), PW(40), PW(40))];
    target1.contentMode = UIViewContentModeScaleAspectFit;
    target1.tag = 100;
    [targetIV1 addSubview:target1];
    
    UIImageView * targetIV2 = [[UIImageView alloc]initWithFrame:CGRectMake(PW(108), PW(152), PW(81), PW(81))];
    targetIV2.image = [UIImage imageNamed:@"game_maze_button"];
    [self.map addSubview:targetIV2];
    
    UIImageView * target2 = [[UIImageView alloc]initWithFrame:CGRectMake(PW(22), PW(17), PW(40), PW(40))];
    target2.contentMode = UIViewContentModeScaleAspectFit;
    target2.tag = 101;
    [targetIV2 addSubview:target2];
    
    UIImageView * targetIV3 = [[UIImageView alloc]initWithFrame:CGRectMake(PW(228), PW(310), PW(81), PW(81))];
    targetIV3.image = [UIImage imageNamed:@"game_maze_button"];
    [self.map addSubview:targetIV3];
    
    UIImageView * target3 = [[UIImageView alloc]initWithFrame:CGRectMake(PW(22), PW(17), PW(40), PW(40))];
    target3.contentMode = UIViewContentModeScaleAspectFit;
    target3.tag = 102;
    [targetIV3 addSubview:target3];
    
}


- (void)handleSwipe:(UIPanGestureRecognizer *)swipe
{
    if (_isMoving == YES) return;
    
    float carX = self.car.frame.origin.x;
    float carY = self.car.frame.origin.y;
    
    if (swipe.state == UIGestureRecognizerStateBegan || swipe.state == UIGestureRecognizerStateChanged) {
        
        CGPoint currentPoint = [swipe translationInView:self.view];
//        NSLog(@"point (%f, %f) in View", currentPoint.x, currentPoint.y);
        
        CGFloat absX = fabs(currentPoint.x);
        CGFloat absY = fabs(currentPoint.y);
        
        // 设置滑动有效距离
        //        if (MAX(absX, absY) < 10)  return;
        
        if (absX > absY ) {
            
            //向左滑动
            if (currentPoint.x<0) {
                _panDirection = DirectionTypeLeft;
                
                if ([_currentGrid.dires containsString:@"3"]) {
                    if (_currentGrid.x<1) return;
                    
                    GridModel * grid = [_gridArray objectAtIndex:(_currentGrid.y-1)*8+(_currentGrid.x-1-1)];
                    _currentGrid = grid;
                    _isMoving = YES;
                    [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                        self.car.frame = CGRectMake(PW(11)+ (_currentGrid.x-1)%8*PW(40),PW(10)+(_currentGrid.y-1)%11*PW(40), PW(40), PW(40));
                        if (self.carDirection != DirectionTypeLeft) {
                            self.carDirection = DirectionTypeLeft;
                            self.car.image = [UIImage imageNamed:@"maze_car_left"];
                        }
                    } completion:^(BOOL finished) {
                        self.isMoving = NO;
                        [self handleAnswer];
                    }];
                }
                
            }
            //向右滑动
            else{
                _panDirection = DirectionTypeRight;
                
                if ([_currentGrid.dires containsString:@"4"]) {
                    if (_currentGrid.x>7) return;
                    GridModel * grid = [_gridArray objectAtIndex:(_currentGrid.y-1)*8+(_currentGrid.x-1+1)];
                    _currentGrid = grid;
                    _isMoving = YES;
                    [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                        self.car.frame = CGRectMake(PW(11)+ (_currentGrid.x-1)%8*PW(40),PW(10)+(_currentGrid.y-1)%11*PW(40), PW(40), PW(40));
                        if (self.carDirection != DirectionTypeRight) {
                            self.carDirection = DirectionTypeRight;
                            self.car.image = [UIImage imageNamed:@"maze_car_right"];
                        }
                    } completion:^(BOOL finished) {
                        self.isMoving = NO;
                        [self handleAnswer];
                    }];
                }
                
            }
            
        } else if (absY > absX) {
            //向上滑动
            if (currentPoint.y<0) {
                _panDirection = DirectionTypeUp;
                if ([_currentGrid.dires containsString:@"1"]) {
                    if (_currentGrid.y<1) return;
                    GridModel * grid = [_gridArray objectAtIndex:(_currentGrid.y-1-1)*8+(_currentGrid.x-1)];
                    _currentGrid = grid;
                    _isMoving = YES;
                    [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                        self.car.frame = CGRectMake(PW(11)+ (_currentGrid.x-1)%8*PW(40),PW(10)+(_currentGrid.y-1)%11*PW(40), PW(40), PW(40));
                        if (self.carDirection != DirectionTypeUp) {
                            self.car.image = [UIImage imageNamed:@"maze_car_up"];
                            self.carDirection = DirectionTypeUp;
                        }
                        
                    } completion:^(BOOL finished) {
                        self.isMoving = NO;
                        [self handleAnswer];
                    }];
                }
            }
            //向下滑动
            else{
                _panDirection = DirectionTypeDown;
                if ([_currentGrid.dires containsString:@"2"]) {
                    if (_currentGrid.y>10) return;
                    GridModel * grid = [_gridArray objectAtIndex:(_currentGrid.y-1+1)*8+(_currentGrid.x-1)];
                    _currentGrid = grid;
                    _isMoving = YES;
                    [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                        self.car.frame = CGRectMake(PW(11)+ (_currentGrid.x-1)%8*PW(40),PW(10)+(_currentGrid.y-1)%11*PW(40), PW(40), PW(40));
                        if (self.carDirection != DirectionTypeDown) {
                            self.car.image = [UIImage imageNamed:@"maze_car_down"];
                            self.carDirection = DirectionTypeDown;
                        }
                    } completion:^(BOOL finished) {
                        self.isMoving = NO;
                        [self handleAnswer];
                    }];
                }
            }
        }
    }
    
    if (swipe.state == UIGestureRecognizerStateEnded) {
        
    }
}

- (void)handleAnswer
{
    NSInteger index = _currentGrid.y*8+_currentGrid.x;
    NSInteger t = 2 ;//如果答案是2
    if (index == 31) {
        if (t == 1) {
            NSLog(@"回答正确");
        }else{
            NSLog(@"回答错误");
        }
    }else if (index == 43){
        if (t == 2) {
            NSLog(@"回答正确");
        }else{
            NSLog(@"回答错误");
        }
    }else if (index == 78){
        if (t == 3) {
            NSLog(@"回答正确");
        }else{
            NSLog(@"回答错误");
        }
    }
}

@end
