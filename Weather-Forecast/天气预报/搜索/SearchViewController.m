//
//  SearchViewController.m
//  天气预报
//
//  Created by yyyyy on 2025/7/29.
//

#import "SearchViewController.h"
#import "DetailViewController.h"
@interface SearchViewController () 


@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    _cityArray = [[NSMutableArray alloc] init];
    _searchBar = [[UISearchBar alloc] initWithFrame: CGRectMake(0, 100, self.view.bounds.size.width, 50)];
    _searchBar.delegate = self;
    _searchBar.placeholder = @"请输入城市名称";
    [self.view addSubview: _searchBar];
    _tableView = [[UITableView alloc] initWithFrame: CGRectMake(0, 150, self.view.bounds.size.width, 700) style: UITableViewStylePlain];
    [self.view addSubview: _tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass: [UITableViewCell class] forCellReuseIdentifier: @"111"];
    UIView *view = [[UIView alloc] init];
    _tableView.tableFooterView = view;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer: tap];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
    NSDictionary *city = _cityArray[indexPath.row];
    NSString *cityName = city[@"name"];

    DetailViewController *detailvc = [[DetailViewController alloc] init];
    detailvc.cityName = cityName; 
    [self.navigationController pushViewController:detailvc animated:YES];
}

- (void)creatUrl {
    NSString *urlString = [NSString stringWithFormat: @"https://api.weatherapi.com/v1/search.json?key=3557d02150d248e6b0735224252907&q=%@", _searchBar.text];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURL *url = [NSURL URLWithString: urlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL: url];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration: [NSURLSessionConfiguration defaultSessionConfiguration] delegate: self delegateQueue: [NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest: request];
    
    [dataTask resume];
 }

- (void)URLSession: (NSURLSession *)session dataTask:(nonnull NSURLSessionDataTask *)dataTask didReceiveResponse:(nonnull NSURLResponse *)response completionHandler:(nonnull void (^)(NSURLSessionResponseDisposition))completionHandler {
    if (self.data == nil) {
        self.data = [[NSMutableData alloc] init];
    } else {
        self.data.length = 0;
    }
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(nonnull NSURLSessionDataTask *)dataTask didReceiveData:(nonnull NSData *)data {
    [self.data appendData: data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        NSLog(@"请求失败:%@", error.localizedDescription);
        return;
    }
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:self.data options:kNilOptions error:nil];
    if (![jsonArray isKindOfClass:[NSArray class]]) {
        NSLog(@"返回数据不是数组");
        return;
    }
    [_cityArray removeAllObjects];
    for (NSDictionary *cityInfo in jsonArray) {
        NSString *name = cityInfo[@"name"];
        NSString *region = cityInfo[@"region"];
        NSString *country = cityInfo[@"country"];
        NSString *idStr = [NSString stringWithFormat: @"%@", cityInfo[@"id"] ? :cityInfo[@"location"] ];
        
        NSString *displayStr = [NSString stringWithFormat:@"%@, %@, %@", name, region, country];
        NSDictionary *cityDict = @{
            @"name": name,
            @"region": region,
            @"country": country,
            @"display": displayStr,
            @"id": idStr
        };
        
        [_cityArray addObject:cityDict];
    }
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self->_tableView reloadData];
    }];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        [_cityArray removeAllObjects];
        [_tableView reloadData];
        return;
    }
    [self creatUrl];
}

- (void)dismissKeyboard {
    [self.view endEditing: YES];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"111" forIndexPath:indexPath];

    NSDictionary *city = _cityArray[indexPath.row];
    NSString *displayText = city[@"display"] ?: @"未知城市";

    cell.textLabel.text = displayText;
    cell.textLabel.font = [UIFont systemFontOfSize:20];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;

    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cityArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
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
