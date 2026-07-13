//
//  WeatherCell.h
//  天气预报
//
//  Created by yyyyy on 2025/8/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WeatherCell : UITableViewCell

@property (nonatomic, strong) UILabel *cityLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIImageView *iconimgView;

@end

NS_ASSUME_NONNULL_END
