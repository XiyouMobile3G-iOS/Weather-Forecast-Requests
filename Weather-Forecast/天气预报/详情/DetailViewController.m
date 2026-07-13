//
//  DetailViewController.m
//  天气预报
//
//  Created by yyyyy on 2025/7/30.
//

#import "DetailViewController.h"
#import <UIKit/UIKit.h>


@interface DetailViewController ()

@property (nonatomic, strong) NSString *sunrise;
@property (nonatomic, strong) NSString *sunset;
@property (nonatomic, strong) NSString *pressure;
@property (nonatomic, strong) NSString *visibility;
@property (nonatomic, strong) NSString *ulray;
@property (nonatomic, strong) NSString *humidity;


@property (nonatomic, strong) NSString *weatherText;


@property (nonatomic, strong) UIButton *addBtn;
@property (nonatomic, strong) UIImageView *backImageView;
@property (nonatomic, strong) UILabel *citycalling;
@property (nonatomic, strong) UILabel *curtemperature;
@property (nonatomic, strong) UILabel *curweather;
@property (nonatomic, strong) UILabel *curtemround;

@property (nonatomic, strong) NSString *imageName;

@property (nonatomic, strong) NSArray *hourlyData;
@property (nonatomic, strong) UICollectionView *hourlyCollectionView;

@property (nonatomic, strong) UILabel *sevenDays;
@property (nonatomic, strong) UITableView *sevenDayWeather;
@property (nonatomic, strong) NSArray *sevenDayData;

@property (nonatomic, strong) NSNumber *lat;
@property (nonatomic, strong) NSNumber *lon;

@property (nonatomic, strong) UITableView *bottomView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableData *responseData;
@end

@implementation DetailViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //self.navigationController.navigationBarHidden = NO;
    
    self.backImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.backImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.backImageView.alpha = 0.88;
    [self.view addSubview:self.backImageView];
    [self.view sendSubviewToBack:self.backImageView];
    
    UIBarButtonItem *addBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addBtnTapped)];
    self.navigationItem.rightBarButtonItem = addBtn;
    self.view.clipsToBounds = YES;
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1000)];
    contentView.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:contentView];
    self.scrollView.contentSize = contentView.frame.size;
    
    self.citycalling = [[UILabel alloc] initWithFrame: CGRectMake(115, 15, 170, 50)];
    self.citycalling.text = self.cityName;
    self.citycalling.textAlignment = NSTextAlignmentCenter;
    self.citycalling.textColor = [UIColor whiteColor];
    self.citycalling.font = [UIFont systemFontOfSize: 29];
    [contentView addSubview: self.citycalling];
    
    self.curtemperature = [[UILabel alloc] initWithFrame: CGRectMake(90, 35, 220, 150)];
    self.curtemperature.textAlignment = NSTextAlignmentCenter;
    self.curtemperature.font = [UIFont boldSystemFontOfSize: 63];
    self.curtemperature.textColor = [UIColor whiteColor];
    [contentView addSubview: self.curtemperature];
    
    self.curweather = [[UILabel alloc] initWithFrame: CGRectMake(126, 125, 150, 65)];
    self.curweather.textAlignment = NSTextAlignmentCenter;
    self.curweather.font = [UIFont systemFontOfSize: 23];
    self.curweather.textColor = [UIColor whiteColor];
    [contentView addSubview: self.curweather];
    
    self.curtemround = [[UILabel alloc] initWithFrame: CGRectMake(134, 157, 140, 70)];
    self.curtemround.textAlignment = NSTextAlignmentCenter;
    self.curtemround.font = [UIFont systemFontOfSize: 23];
    self.curtemround.textColor = [UIColor whiteColor];
    [contentView addSubview: self.curtemround];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(80, 90);
    layout.minimumLineSpacing = 10;
    
    self.hourlyCollectionView = [[UICollectionView alloc] initWithFrame: CGRectMake(0, 240, self.view.bounds.size.width, 120) collectionViewLayout: layout];
    self.hourlyCollectionView.backgroundColor = [UIColor clearColor];
    self.hourlyCollectionView.showsHorizontalScrollIndicator = NO;
    [self.hourlyCollectionView registerClass: [UICollectionViewCell class] forCellWithReuseIdentifier: @"HourlyCell"];
    self.hourlyCollectionView.dataSource = self;
    self.hourlyCollectionView.delegate = self;
    [contentView addSubview: self.hourlyCollectionView];
    
    self.sevenDays = [[UILabel alloc] initWithFrame: CGRectMake(5, 360, 130, 60)];
    self.sevenDays.text = @"7日天气预报";
    self.sevenDays.font = [UIFont systemFontOfSize: 18];
    self.sevenDays.textAlignment = NSTextAlignmentCenter;
    self.sevenDays.textColor = [UIColor whiteColor];
    [contentView addSubview: self.sevenDays];
    
    self.sevenDayWeather = [[UITableView alloc] initWithFrame: CGRectMake(0, 420, self.view.bounds.size.width, 350)];
    self.sevenDayWeather.backgroundColor = [UIColor clearColor];
    self.sevenDayWeather.dataSource = self;
    self.sevenDayWeather.delegate = self;
    
    [self.sevenDayWeather registerClass: [UITableViewCell class] forCellReuseIdentifier: @"sevenDayCell"];
    [contentView addSubview: self.sevenDayWeather];
    
    self.bottomView = [[UITableView alloc] initWithFrame: CGRectMake(0, 760, self.view.bounds.size.width, 230)];
    self.bottomView.backgroundColor = [UIColor clearColor];
    self.bottomView.dataSource = self;
    self.bottomView.delegate = self;
    self.bottomView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.bottomView registerClass: [UITableViewCell class] forCellReuseIdentifier: @"bottomViewCell"];
    [contentView addSubview: self.bottomView];
    
}

- (void)addBtnTapped {
    NSString *locationID = [NSString stringWithFormat:@"%.4f%.4f", [self.lat floatValue], [self.lon floatValue]];
    NSDictionary *weatherInfo = @{
        @"cityName": self.cityName ?: @"",
        @"temperature": self.tempc ?: @"--",
        @"iconURL": self.iconURL ?: @"",
        @"code": [self.code stringValue] ?: @"0",
        @"locationID" : locationID
    };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addWeather" object:nil userInfo:weatherInfo];
    // 等待通知回调中判断是否跳转
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.sevenDayWeather) {
        return self.sevenDayData.count;
    } else if (tableView == self.bottomView) {
        return 1;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.sevenDayWeather) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sevenDayCell" forIndexPath:indexPath];
        
        for (UIView *sub in cell.contentView.subviews) {
            [sub removeFromSuperview];
        }

        NSDictionary *dayDict = self.sevenDayData[indexPath.row];
        NSString *fullDate = dayDict[@"date"];
        NSString *date = [fullDate substringFromIndex:5];
        NSDictionary *dayInfo = dayDict[@"day"];
        NSString *iconURL = [NSString stringWithFormat:@"https:%@", dayInfo[@"condition"][@"icon"]];
        NSInteger minTemp = (NSInteger)round([dayInfo[@"mintemp_c"] floatValue]);
        NSInteger maxTemp = (NSInteger)round([dayInfo[@"maxtemp_c"] floatValue]);

        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(23, 5, 60, 40)];
        dateLabel.text = date;
        dateLabel.font = [UIFont systemFontOfSize:18];
        dateLabel.textColor = [UIColor whiteColor];
        [cell.contentView addSubview:dateLabel];

        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((tableView.bounds.size.width - 40) / 2, 7, 40, 40)];
        [self loadWeatherIcon:iconURL intoImageView:iconView];
        [cell.contentView addSubview:iconView];

        UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(tableView.bounds.size.width - 130, 5, 90, 40)];
        tempLabel.text = [NSString stringWithFormat:@"%ld~%ld°C", (long)minTemp, (long)maxTemp];
        tempLabel.font = [UIFont systemFontOfSize:18];
        tempLabel.textColor = [UIColor whiteColor];
        tempLabel.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:tempLabel];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
    if (tableView == self.bottomView) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"bottomViewCell" forIndexPath:indexPath];
        
        for (UIView *sub in cell.contentView.subviews) {
            [sub removeFromSuperview];
        }

        NSArray *titles = @[@"日出", @"日落", @"气压", @"能见度", @"紫外线", @"湿度"];
        NSArray *values = @[
            self.sunrise ?: @"--",
            self.sunset ?: @"--",
            self.pressure ? [NSString stringWithFormat:@"%@ hPa", self.pressure] : @"-- hPa",
            self.visibility ? [NSString stringWithFormat:@"%@ km", self.visibility] : @"-- km",
            self.ulray ?: @"--",
            self.humidity ? [NSString stringWithFormat:@"%@%%", self.humidity] : @"--%"
        ];
        
        CGFloat labelWidth = (tableView.bounds.size.width - 30) / 2;
        CGFloat smallSpacing = 5;
        CGFloat bigSpacing = 70;
        for (int i = 0; i < titles.count; i++) {
            CGFloat originX = 20 + (i % 2) * labelWidth;
            CGFloat originY = 20 + (i / 2) * bigSpacing;

            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, labelWidth, 35)];
            titleLabel.text = titles[i];
            titleLabel.textColor = [UIColor whiteColor];
            titleLabel.font = [UIFont systemFontOfSize:19 weight:UIFontWeightMedium];
            [cell.contentView addSubview:titleLabel];

            UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY + 25 + smallSpacing, labelWidth, 35)];
            valueLabel.text = values[i];
            valueLabel.textColor = [UIColor whiteColor];
            valueLabel.font = [UIFont systemFontOfSize:20];
            [cell.contentView addSubview:valueLabel];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
    return [[UITableViewCell alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.cityName && self.cityName.length > 0) {
        [self fetchWeatherDataForCity:self.cityName];
    }
    self.backImageView.backgroundColor = [UIColor grayColor];
    //self.backImageView.image = [UIImage imageNamed: self.imageName];
    
}

- (void)fetchWeatherDataForCity:(NSString *)city {
    NSString *urlString = [NSString stringWithFormat:@"https://api.weatherapi.com/v1/forecast.json?key=3557d02150d248e6b0735224252907&q=%@&days=7", city];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    self.responseData = [[NSMutableData alloc] init];

    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request];
    [dataTask resume];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        NSLog(@"请求失败: %@", error.localizedDescription);
        return;
    }

    NSError *jsonError = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:self.responseData options:0 error:&jsonError];

    if (jsonError) {
        NSLog(@"解析失败: %@", jsonError.localizedDescription);
        NSLog(@"原始数据: %@", [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding]);
        return;
    }

    NSNumber *tempc = jsonDict[@"current"][@"temp_c"];
    NSString *weatherText = jsonDict[@"current"][@"condition"][@"text"];
    NSString *iconURL = [NSString stringWithFormat:@"https:%@", jsonDict[@"current"][@"condition"][@"icon"]];
    NSNumber *code = jsonDict[@"current"][@"condition"][@"code"];
    
    NSArray *forecastDays = jsonDict[@"forecast"][@"forecastday"];
    
    NSDictionary *day0 = forecastDays[0];
    NSDictionary *dayData0 = day0[@"day"];
    NSInteger min0 = (NSInteger)round([dayData0[@"mintemp_c"] floatValue]);
    NSInteger max0 = (NSInteger)round([dayData0[@"maxtemp_c"] floatValue]);
    
    NSDictionary *astro = day0[@"astro"];
    self.sunrise = astro[@"sunrise"];
    self.sunset = astro[@"sunset"];
    NSDictionary *current = jsonDict[@"current"];
    self.pressure = [NSString stringWithFormat:@"%@", current[@"pressure_mb"]];
    self.visibility = [NSString stringWithFormat:@"%@", current[@"vis_km"]];
    self.ulray = [NSString stringWithFormat:@"%@", dayData0[@"uv"]];
    self.humidity = [NSString stringWithFormat:@"%@", dayData0[@"avghumidity"]];
    self.code = code;
    
    NSDictionary *location = jsonDict[@"location"];
    self.lat = location[@"lat"];
    self.lon = location[@"lon"];
    
    self.imageName = nil;
    if ([code integerValue] == 1000) {
        self.imageName = @"pic1.jpg";
    } else if ([code integerValue] >= 1003 && [code integerValue] <= 1006) {
        self.imageName = @"pic4.jpg";
    } else if ([code integerValue] >= 1009 && [code integerValue] <= 1030) {
        self.imageName = @"pic3.jpg";
    } else if ([code integerValue] >= 1063 && [code integerValue] <= 1195) {
        self.imageName = @"pic2.jpg";
    } else if ([code integerValue] == 1210) {
        self.imageName = @"pic6.jpg";
    } else if ([code integerValue] == 1273) {
        self.imageName = @"pic5.jpg";
    } else {
        self.imageName = @"pic1.jpg";
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger intTemp = [tempc integerValue];
        self.tempc = [NSString stringWithFormat:@"%ld", (long)intTemp];
        self.weatherText = weatherText;
        self.iconURL = iconURL;
        
        self.backImageView.image = [UIImage imageNamed: self.imageName];
        self.curweather.text = self.weatherText;
        self.curtemperature.text = [NSString stringWithFormat:@"%@°C", self.tempc];
        self.curtemround.text = [NSString stringWithFormat:@"%ld~%ld°C", (long)min0, (long)max0];
        NSArray *hourlyArray = jsonDict[@"forecast"][@"forecastday"][0][@"hour"];
        self.hourlyData = hourlyArray;
        [self sortHourlyDataFromCurrentHour];
        [self.hourlyCollectionView reloadData];
        
        self.sevenDayData = forecastDays;
        [self.sevenDayWeather reloadData];
        [self.bottomView reloadData];
    });
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.hourlyData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"HourlyCell" forIndexPath: indexPath];
    for (UIView *sub in cell.contentView.subviews) {
        [sub removeFromSuperview];
    }
    NSDictionary *hourData = self.hourlyData[indexPath.item];
    NSString *time = [hourData[@"time"]substringFromIndex: 11];
    NSNumber *temp = hourData[@"temp_c"];
    NSString *iconURL = [NSString stringWithFormat: @"https:%@", hourData[@"condition"][@"icon"]];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 5, 80, 20)];
    timeLabel.text = time;
    timeLabel.font = [UIFont systemFontOfSize: 12];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.textColor = [UIColor whiteColor];
    [cell.contentView addSubview: timeLabel];
    
    UIImageView *iconView = [[UIImageView alloc] initWithFrame: CGRectMake(10, 17, 60, 60)];
    [self loadWeatherIcon:iconURL intoImageView:iconView];
    [cell.contentView addSubview: iconView];
    UILabel *tempLable = [[UILabel alloc] initWithFrame: CGRectMake(0, 70, 80, 20)];
    tempLable.text = [NSString stringWithFormat:@"%ld°C", (long)[temp integerValue]];
    tempLable.font = [UIFont systemFontOfSize: 12];
    tempLable.textAlignment = NSTextAlignmentCenter;
    tempLable.textColor = [UIColor whiteColor];
    [cell.contentView addSubview: tempLable];
    return cell;
}


- (void)loadWeatherIcon:(NSString *)urlString intoImageView:(UIImageView *)imageView {
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url
        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (data && !error) {
                UIImage *image = [UIImage imageWithData:data];
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        imageView.image = image;
                    });
                }
            }
        }];
    [task resume];
}


- (void)sortHourlyDataFromCurrentHour {
    if (!self.hourlyData || self.hourlyData.count == 0) {
        return;
    }
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger currentHour = [calendar component:NSCalendarUnitHour fromDate:now];

    NSInteger startIndex = 0;
    for (NSInteger i = 0; i < self.hourlyData.count; i++) {
        NSString *timeStr = self.hourlyData[i][@"time"];
        NSString *hourString = [timeStr substringWithRange:NSMakeRange(11, 2)];
        NSInteger hour = [hourString integerValue];
        if (hour >= currentHour) {
            startIndex = i;
            break;
        }
    }

    NSArray *firstPart = [self.hourlyData subarrayWithRange:NSMakeRange(startIndex, self.hourlyData.count - startIndex)];
    NSArray *secondPart = [self.hourlyData subarrayWithRange:NSMakeRange(0, startIndex)];
    NSArray *newOrderedArray = [firstPart arrayByAddingObjectsFromArray:secondPart];

    self.hourlyData = newOrderedArray;
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
