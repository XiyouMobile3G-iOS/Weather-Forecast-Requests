//
//  ScrollViewController.h
//  天气预报
//
//  Created by yyyyy on 2025/8/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScrollViewController : UIViewController

@property (nonatomic, strong) NSArray *cityIDArray;
@property (nonatomic, assign) NSInteger nowPage;

@end

NS_ASSUME_NONNULL_END
