//
//  WeatherCell.m
//  天气预报
//
//  Created by yyyyy on 2025/8/4.
//

#import "WeatherCell.h"

@implementation WeatherCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle: style reuseIdentifier: reuseIdentifier];
    if (self) {
        self.cityLabel = [[UILabel alloc] initWithFrame: CGRectMake(15, 35, 200, 35)];
        self.cityLabel.font = [UIFont boldSystemFontOfSize: 26];
        self.cityLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview: self.cityLabel];
        
        self.detailLabel = [[UILabel alloc]initWithFrame: CGRectMake(15, 84, 200, 30)];
        self.detailLabel.font = [UIFont systemFontOfSize: 19];
        self.detailLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview: self.detailLabel];
        
        self.iconimgView = [[UIImageView alloc] initWithFrame: CGRectMake(self.contentView.frame.size.width - 60, 38, 80, 80)
        ];
        self.layer.cornerRadius = 16;
        self.layer.masksToBounds = YES;
        self.iconimgView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview: self.iconimgView];
        
    }
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
