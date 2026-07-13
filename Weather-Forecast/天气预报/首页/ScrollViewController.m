//
//  ScrollViewController.m
//  天气预报
//
//  Created by yyyyy on 2025/8/4.
//

#import "ScrollViewController.h"
#import "DetailViewController.h"

@interface ScrollViewController () <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation ScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    self.scrollView = [[UIScrollView alloc] initWithFrame:screenBounds];

    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
    //这里是之前版本的一个方法，在这里隐藏导航栏十分好用，我在这里对编译器发出的警告进行了屏蔽，正常来说还是用其他方法比较好
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        self.automaticallyAdjustsScrollViewInsets = NO;
#pragma clang diagnostic pop
    }

    self.view.backgroundColor = [UIColor blackColor];
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.extendedLayoutIncludesOpaqueBars = YES;

    self.scrollView.pagingEnabled = YES;
    self.scrollView.alwaysBounceVertical = NO;
    self.scrollView.alwaysBounceHorizontal = YES;

    self.scrollView.directionalLockEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.contentSize = CGSizeMake(screenBounds.size.width * self.cityIDArray.count, screenBounds.size.height);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];

    self.scrollView.clipsToBounds = YES;

    for (int i = 0; i < self.cityIDArray.count; i++) {
        NSDictionary *info = self.cityIDArray[i];
        NSString *cityName = info[@"cityName"];

        DetailViewController *vc = [[DetailViewController alloc] init];
        vc.cityName = cityName;
        vc.tempc = info[@"temperature"];
        vc.iconURL = info[@"iconURL"];
        vc.code = @([info[@"code"] integerValue]);

        [self addChildViewController:vc];
        vc.view.frame = CGRectMake(i * screenBounds.size.width, 0, screenBounds.size.width, screenBounds.size.height);
        //NSLog(@"vc.view frame for index %d: %@", i, NSStringFromCGRect(vc.view.frame));

        [self.scrollView addSubview:vc.view];
        [vc didMoveToParentViewController:self];
    }

    [self.scrollView setContentOffset:CGPointMake(screenBounds.size.width * self.nowPage, 0) animated:NO];
    self.scrollView.bounces = NO;
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    backButton.frame = CGRectMake(15, 50, 30, 30);
    [backButton setImage:[UIImage systemImageNamed:@"chevron.left"] forState:UIControlStateNormal];
    backButton.tintColor = [UIColor whiteColor];
    [backButton addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];

    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    deleteButton.frame = CGRectMake(screenBounds.size.width - 45, 50, 30, 30);
    [deleteButton setImage:[UIImage systemImageNamed:@"trash"] forState:UIControlStateNormal];
    deleteButton.tintColor = [UIColor whiteColor];
    [deleteButton addTarget:self action:@selector(deleteCurrentPage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deleteButton];

}

- (void)closeView {
    [self.navigationController popViewControllerAnimated:YES];
    //[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.bounds.size.width;
    NSInteger currentPage = (NSInteger)(scrollView.contentOffset.x / pageWidth + 0.5);
    self.nowPage = currentPage;
}
- (void)deleteCurrentPage {
    NSInteger index = self.nowPage;

    NSDictionary *info = self.cityIDArray[index];
    NSString *locationID = info[@"locationID"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteWeather" object:nil userInfo:@{@"locationID": locationID}];
    [self.navigationController popViewControllerAnimated:YES];
    //[self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
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
