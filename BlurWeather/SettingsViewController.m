//
//  SettingsViewController.m
//  BlurWeather
//
//  Created by koudai_hs on 15-10-22.
//  Copyright (c) 2015年 Charles Wang. All rights reserved.
//

#import "SettingsViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "Settings.h"
#import "SettingsTableViewCell.h"

@interface SettingsViewController ()

@property (strong,nonatomic)NSArray* settings;

@end

@implementation SettingsViewController {
    UINib* nib;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = NO;
    self.title = NSLocalizedString(@"settings", nil);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //self.tableView.separatorInset=UIEdgeInsetsMake(0,15, 0, 15);
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.settings = @[
                      [[Settings alloc]initWithTitle:NSLocalizedString(@"tempScale", nil) onText:@"°F" OffText:@"°C" identifyKey:@"tempFormat"],
                      [[Settings alloc]initWithTitle:NSLocalizedString(@"Auto Refresh", nil) onText:NSLocalizedString(@"on", nil) OffText:NSLocalizedString(@"off", nil) identifyKey:@"autoRefresh"]
                      ];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.settings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"CellIdentifier";
    if (nib == nil) {
        nib = [UINib nibWithNibName:@"SettingsTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
    }
    SettingsTableViewCell *cell = (SettingsTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
 
    if (! cell) {
        cell = [[SettingsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    Settings* sts = self.settings[indexPath.row];
    cell.titleLable.text = sts.title;
    //从defaults读取
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    BOOL flag = [defaults boolForKey:sts.identifyKey];
    [cell.settingSwitch setOn:flag animated:YES];
    cell.onOffLabel.text = flag ? sts.onText : sts.offText;
    
    [[cell.settingSwitch rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(UISwitch* sender) {
        //修改并设置defaults
        if (sender.isOn) {
            cell.onOffLabel.text = sts.onText;
            [defaults setBool:YES forKey:sts.identifyKey];
        }else{
            cell.onOffLabel.text = sts.offText;
            [defaults setBool:NO forKey:sts.identifyKey];
        }
    }];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
