//
//  DetailViewController.h
//  天气预报
//
//  Created by yyyyy on 2025/7/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DetailViewController : UIViewController <NSURLSessionDelegate, NSURLSessionDataDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSString *cityName;
@property (nonatomic, strong) NSString *tempc;
@property (nonatomic, strong) NSString *iconURL;
@property (nonatomic, strong) NSNumber *code;

@end

NS_ASSUME_NONNULL_END
