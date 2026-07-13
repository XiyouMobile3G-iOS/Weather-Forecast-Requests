//
//  ViewController.h
//  天气预报
//
//  Created by yyyyy on 2025/7/29.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UILabel *weather;
@property (nonatomic, strong) UIButton *imageBtn;

@property (nonatomic, strong) NSMutableArray *weatherAry;
@property (nonatomic, strong) UITableView *tableView;

@end

