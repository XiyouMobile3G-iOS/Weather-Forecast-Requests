//
//  ViewController.m
//  天气预报
//
//  Created by yyyyy on 2025/7/29.
//

#import "ViewController.h"
#import "SearchViewController.h"
#import "WeatherCell.h"
#import "ScrollViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.weather = [[UILabel alloc] init];
    self.weather.frame = CGRectMake(20, 40, 200, 120);
    self.weather.text = @"天气";
    self.weather.font = [UIFont systemFontOfSize:33];
    [self.view addSubview: self.weather];
    
    self.imageBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    [self.imageBtn setImage: [UIImage imageNamed: @"添加.png"] forState: UIControlStateNormal];
    self.imageBtn.frame = CGRectMake(self.view.frame.size.width - 60, 80, 40, 40);
    [self.imageBtn addTarget: self action: @selector(addButtonTapped) forControlEvents: UIControlEventTouchUpInside];
    [self.view addSubview: self.imageBtn];
    
    self.tableView.bounces = NO;
    self.weatherAry = [NSMutableArray array];
    CGFloat tableViewY = 150;
    CGFloat tableViewHeight = self.view.bounds.size.height - tableViewY;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, tableViewY, self.view.bounds.size.width - 20, tableViewHeight) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview: self.tableView];
    [self.tableView registerClass: [WeatherCell class] forCellReuseIdentifier: @"weatherCell"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWeatherNotification:) name:@"addWeather" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleDeleteWeather:) name: @"deleteWeather" object: nil];
}

//显示删除按钮
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
//删除操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.weatherAry removeObjectAtIndex:indexPath.section];
        [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section]
                 withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)addButtonTapped {
    SearchViewController *searchvc = [[SearchViewController alloc] init];
    [self.navigationController pushViewController:searchvc animated:YES];
}

- (void)handleWeatherNotification:(NSNotification *)notification {
    NSDictionary *weatherInfo = notification.userInfo;
    NSString *locationID = weatherInfo[@"locationID"];
    for (NSDictionary *info in self.weatherAry) {
        if ([info[@"locationID"] isEqualToString:locationID]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"该城市已存在！" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
    }
    [self.weatherAry addObject:weatherInfo];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"添加成功！" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
    [self.tableView reloadData];
}

- (void)handleDeleteWeather:(NSNotification *)notification {
    NSString *locationID = notification.userInfo[@"locationID"];
    NSMutableArray *toRemove = [NSMutableArray array];
    for (NSDictionary *info in self.weatherAry) {
        if ([info[@"locationID"] isEqualToString:locationID]) {
            [toRemove addObject:info];
        }
    }
    [self.weatherAry removeObjectsInArray:toRemove];
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 140;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.weatherAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WeatherCell *cell = [tableView dequeueReusableCellWithIdentifier:@"weatherCell" forIndexPath:indexPath];
    
    cell.layer.cornerRadius = 23;
    cell.layer.masksToBounds = YES;
    cell.backgroundColor = [UIColor clearColor]; 
    
    NSDictionary *info = self.weatherAry[indexPath.section];
    cell.cityLabel.text = info[@"cityName"];
    cell.detailLabel.text = [NSString stringWithFormat:@"%@°C ", info[@"temperature"]];
    
    NSString *iconURLString = info[@"iconURL"];
    if (iconURLString.length > 0) {
        NSURL *url = [NSURL URLWithString:iconURLString];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSData *data = [NSData dataWithContentsOfURL:url];
            if (data) {
                UIImage *image = [UIImage imageWithData:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.iconimgView.image = image;
                });
            }
        });
    } else {
        cell.iconimgView.image = nil;
    }
  
    NSString *code = info[@"code"];
    NSString *imageName = nil;
    if ([code integerValue] == 1000) {
        imageName = @"home1.jpg";
    } else if ([code integerValue] >= 1003 && [code integerValue] <= 1006) {
        imageName = @"home4.jpg";
    } else if ([code integerValue] >= 1009 && [code integerValue] <= 1030) {
        imageName = @"home3.jpg";
    } else if ([code integerValue] >= 1063 && [code integerValue] <= 1195) {
        imageName = @"home2.jpg";
    } else if ([code integerValue] == 1210) {
        imageName = @"home6.jpg";
    } else if ([code integerValue] == 1273) {
        imageName = @"home5.jpg";
    } else {
        imageName = @"home1.jpg";
    }
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    cell.backgroundView.layer.cornerRadius = 16;
    cell.backgroundView.layer.masksToBounds = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ScrollViewController *scrollVC = [[ScrollViewController alloc] init];
    scrollVC.cityIDArray = self.weatherAry;
    scrollVC.nowPage = indexPath.section;

    scrollVC.modalPresentationStyle = UIModalPresentationFullScreen;
    //[self presentViewController:scrollVC animated:YES completion:nil];
    [self.navigationController pushViewController:scrollVC animated:nil];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *spacer = [[UIView alloc] init];
    spacer.backgroundColor = [UIColor clearColor];
    return spacer;
}

@end
