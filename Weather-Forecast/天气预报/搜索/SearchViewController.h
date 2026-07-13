//
//  SearchViewController.h
//  天气预报
//
//  Created by yyyyy on 2025/7/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SearchViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, NSURLSessionDelegate, UISearchBarDelegate>
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSMutableArray *cityArray;

@end

NS_ASSUME_NONNULL_END
