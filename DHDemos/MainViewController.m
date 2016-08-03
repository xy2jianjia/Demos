//
//  MainViewController.m
//  DHDemos
//
//  Created by xy2 on 16/8/3.
//  Copyright © 2016年 xy2. All rights reserved.
//

#import "MainViewController.h"
#import "SUNSlideSwitchView.h"

#import "ViewController.h"
#import "BViewController.h"
#import "AViewController.h"
@interface MainViewController ()<SUNSlideSwitchViewDelegate,UIScrollViewDelegate,UITableViewDelegate>

@property (nonatomic,strong) SUNSlideSwitchView *slideView;

@property (nonatomic,strong) UIScrollView *scrollV;
@property (nonatomic,strong) UIView *topView;

@property (nonatomic,strong) AViewController *vc1;
@property (nonatomic,strong) BViewController *vc2;
@property (nonatomic,assign) NSInteger scrollvlastPosition;
@property (nonatomic,assign) NSInteger tablevlastPosition;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"同仁堂";
    self.navigationController.navigationBar.alpha = 0;
    [self.view addSubview:self.scrollV];
    [_scrollV addSubview:self.slideView];
    
}
//只要滚动了就会触发
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ([scrollView isKindOfClass:[UITableView class]]) {
        int currentPostion = scrollView.contentOffset.y;
        if (currentPostion - _tablevlastPosition > 0) {
            _tablevlastPosition = currentPostion;
            // 向下滑动
            [UIView animateWithDuration:0.1 animations:^{
                [_scrollV setContentOffset:CGPointMake(0, 200-64)];
            }];
        }else if (_tablevlastPosition - currentPostion > 0){
            _tablevlastPosition = currentPostion;
            // 向下滑动
            [UIView animateWithDuration:0.1 animations:^{
                [_scrollV setContentOffset:CGPointMake(0, -20)];
            }];
        }
    }else{
        int currentPostion = scrollView.contentOffset.y;
        if (currentPostion - _scrollvlastPosition > 10) {
            _scrollvlastPosition = currentPostion;
            // 向上滑动
            self.navigationController.navigationBar.alpha = scrollView.contentOffset.y/100.0;
            if (scrollView.contentOffset.y >= 200-64) {
                CGRect temp = _slideView.frame;
                temp.origin.y = 64 + scrollView.contentOffset.y+10;
                _slideView.frame = temp;
            }else{
                _slideView.frame = CGRectMake(0, CGRectGetMaxY(_topView.frame)+10, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-64);
            }
        }else if (_scrollvlastPosition - currentPostion > 10){
            _scrollvlastPosition = currentPostion;
            // 向下滑动
            [UIView animateWithDuration:0.1 animations:^{
                [_scrollV setContentOffset:CGPointMake(0, -20)];
            }];
        }
    }
    
}
- (UIScrollView *)scrollV{
    if (!_scrollV) {
        _scrollV = [[UIScrollView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    _scrollV.delegate = self;
    _scrollV.tag = 2000;
    _scrollV.bounces = NO;
    _scrollV.contentSize = CGSizeMake(0, [[UIScreen mainScreen] bounds].size.height + 200);
    return _scrollV;
}


- (SUNSlideSwitchView *)slideView{
    
    _topView = [[UIView alloc]init];
    _topView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width , 200);
    _topView.backgroundColor = [UIColor yellowColor];
    [_scrollV addSubview:_topView];
    
    [_slideView removeFromSuperview];
    _slideView = nil;
    if (!_slideView) {
        _slideView = [[SUNSlideSwitchView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_topView.frame)+10, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-64)];
    }
    _slideView.slideSwitchViewDelegate = self;
    _slideView.tabItemNormalColor = kUIColorFromRGB(0x323232);
    _slideView.tabItemSelectedColor = kUIColorFromRGB(0x934de6);
//    _slideView.tabItemNormalBackgroundImage = [UIImage imageNamed:@"51.jpg"];
//    _slideView.tabItemSelectedBackgroundImage = [UIImage imageNamed:@"51.jpg"];
//    _slideView.shadowImage = [[UIImage imageNamed:@"w_message_line_sel"] stretchableImageWithLeftCapWidth:59.0f topCapHeight:0.0f];
    //    UIButton *rightSideButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [rightSideButton setImage:[UIImage imageNamed:@"icon_rightarrow.png"] forState:UIControlStateNormal];
    //    rightSideButton.frame = CGRectMake(0, 0, 20.0f, 44.0f);
    //    rightSideButton.userInteractionEnabled = YES;
    //    _slideView.rigthSideButton = rightSideButton;
    [_slideView buildUI];
    return _slideView;
}
/*!
 * @method 顶部tab个数
 * @abstract
 * @discussion
 * @param 本控件
 * @result tab个数
 */
- (NSUInteger)numberOfTab:(SUNSlideSwitchView *)view{
    return 2;
}

/*!
 * @method 每个tab所属的viewController
 * @abstract
 * @discussion
 * @param tab索引
 * @result viewController
 */
- (UIViewController *)slideSwitchView:(SUNSlideSwitchView *)view viewOfTab:(NSUInteger)number{
    
    switch (number) {
        case 0:{
            _vc1 = [[AViewController alloc] initWithStyle:(UITableViewStyleGrouped)];
            _vc1.tableView.tag = 1000;
            _vc1.tableView.delegate = self;
            _vc1.tableView.bounces = NO;
//            _vc1.tableView.scrollEnabled = NO;
            _vc1.title = @"交友信息";
            _vc1.navigationController = self.navigationController;
            _vc1.navigationItem = self.navigationItem;
            return _vc1;
        }
            
            break;
        case 1:{
            _vc2 = [[BViewController alloc] initWithStyle:(UITableViewStyleGrouped)];
            _vc2.tableView.tag = 1000;
            _vc2.tableView.delegate = self;
//            _vc2.tableView.scrollEnabled = NO;
            _vc2.tableView.bounces = NO;
            _vc2.title = @"自我介绍";
            _vc2.navigationController = self.navigationController;
            _vc2.navigationItem = self.navigationItem;
            return _vc2;
        }
            break;
            
        default:
            return nil;
            break;
    }
    
}


/*!
 * @method 滑动左边界时传递手势
 * @abstract
 * @discussion
 * @param   手势
 * @result
 */
- (void)slideSwitchView:(SUNSlideSwitchView *)view panLeftEdge:(UIPanGestureRecognizer*) panParam{
    
}

/*!
 * @method 滑动右边界时传递手势
 * @abstract
 * @discussion
 * @param   手势
 * @result
 */
- (void)slideSwitchView:(SUNSlideSwitchView *)view panRightEdge:(UIPanGestureRecognizer*) panParam{
    
}

/*!
 * @method 点击tab
 * @abstract
 * @discussion
 * @param tab索引
 * @result
 */
- (void)slideSwitchView:(SUNSlideSwitchView *)view didselectTab:(NSUInteger)number{
    //    if ([[self.sectionArr[number] name] isEqualToString:@"相册"]) {
    //        [[NSNotificationCenter defaultCenter] postNotificationName:@"loadAlbumList" object:[self.sectionArr[number] id]];
    //    }else{
    //        [[NSNotificationCenter defaultCenter] postNotificationName:@"loadInfoList" object:[self.sectionArr[number] id]];
    //    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
