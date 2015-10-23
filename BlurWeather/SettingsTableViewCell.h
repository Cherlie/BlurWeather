//
//  SettingsTableViewCell.h
//  BlurWeather
//
//  Created by koudai_hs on 15-10-22.
//  Copyright (c) 2015年 Charles Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsTableViewCell : UITableViewCell

@property (weak,nonatomic)IBOutlet UILabel* titleLable;
@property (weak,nonatomic)IBOutlet UISwitch* settingSwitch;
@property (weak,nonatomic)IBOutlet UILabel* onOffLabel;

@end
