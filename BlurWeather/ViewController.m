//
//  ViewController.m
//  BlurWeather
//
//  Created by WangCherlies on 15-10-16.
//  Copyright (c) 2015年 Charles Wang. All rights reserved.
//

#import "ViewController.h"
#import <UIImageView+LBBlurredImage.h>
#import "WeatherManager.h"
#import <JTHamburgerButton.h>
#import "NirKxMenu.h"
#import "SettingsViewController.h"
#import "AboutViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) CGFloat screenHeight;

@property (nonatomic, strong) NSDateFormatter *hourlyFormatter;
@property (nonatomic, strong) NSDateFormatter *dailyFormatter;

@property (strong, nonatomic)JTHamburgerButton* hamburgerButton;
@property (strong, nonatomic)NSArray* menuArray;
@property OptionalConfiguration options;

@end

@implementation ViewController {
    NSTimer* timer;
}

- (id)init{
    if (self = [super init]) {
        _hourlyFormatter = [[NSDateFormatter alloc]init];
        _hourlyFormatter.dateFormat = @"h a";
        
        _dailyFormatter = [[NSDateFormatter alloc]init];
        _dailyFormatter.dateFormat = @"EEEE";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    UIImage *background = [UIImage imageNamed:@"bg"];
    
    self.backgroundImageView = [[UIImageView alloc] initWithImage:background];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    
    self.blurredImageView = [[UIImageView alloc] init];
    self.blurredImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.blurredImageView.alpha = 0;
    [self.blurredImageView setImageToBlur:background blurRadius:10 completionBlock:nil];
    [self.view addSubview:self.blurredImageView];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
    self.tableView.pagingEnabled = YES; 
    [self.view addSubview:self.tableView];
    
    CGRect headerFrame = [UIScreen mainScreen].bounds;
    CGFloat inset = 20;
    CGFloat temperatureHeight = 110;
    CGFloat hiloHeight = 40;
    CGFloat iconHeight = 30;
    CGRect hiloFrame = CGRectMake(inset,
                                  headerFrame.size.height - hiloHeight,
                                  headerFrame.size.width - (2 * inset),
                                  hiloHeight);
    
    CGRect temperatureFrame = CGRectMake(inset,
                                         headerFrame.size.height - (temperatureHeight + hiloHeight),
                                         headerFrame.size.width - (2 * inset),
                                         temperatureHeight);
    
    CGRect iconFrame = CGRectMake(inset,
                                  temperatureFrame.origin.y - iconHeight,
                                  iconHeight,
                                  iconHeight);
    CGRect conditionsFrame = iconFrame;
    conditionsFrame.size.width = self.view.bounds.size.width - (((2 * inset) + iconHeight) + 10);
    conditionsFrame.origin.x = iconFrame.origin.x + (iconHeight + 10);
    
    UIView *header = [[UIView alloc] initWithFrame:headerFrame];
    header.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = header;
    
    // bottom left
    UILabel *temperatureLabel = [[UILabel alloc] initWithFrame:temperatureFrame];
    temperatureLabel.backgroundColor = [UIColor clearColor];
    temperatureLabel.textColor = [UIColor whiteColor];
    temperatureLabel.text = @"0°";
    temperatureLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:120];
    [header addSubview:temperatureLabel];
    
    // bottom left
    UILabel *hiloLabel = [[UILabel alloc] initWithFrame:hiloFrame];
    hiloLabel.backgroundColor = [UIColor clearColor];
    hiloLabel.textColor = [UIColor whiteColor];
    hiloLabel.text = @"0° / 0°";
    hiloLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:28];
    [header addSubview:hiloLabel];
    
    // top
    UILabel *cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 30)];
    cityLabel.backgroundColor = [UIColor clearColor];
    cityLabel.textColor = [UIColor whiteColor];
    cityLabel.text = @"Loading...";
    cityLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cityLabel.textAlignment = NSTextAlignmentCenter;
    [header addSubview:cityLabel];
    
    //配置弹出菜单
    self.menuArray = @[
                       [KxMenuItem menuItem:NSLocalizedString(@"settings",nil) image:[UIImage imageNamed:@"settings"] target:self action:@selector(settingsClick)],
                       [KxMenuItem menuItem:NSLocalizedString(@"about",nil) image:[UIImage imageNamed:@"about"] target:self action:@selector(aboutClick)]
                       ];
    [KxMenu setTitleFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
    
    OptionalConfiguration op;
    op.arrowSize = 9;  //指示箭头大小
    op.marginXSpacing = 7;  //MenuItem左右边距
    op.marginYSpacing = 9;  //MenuItem上下边距
    op.intervalSpacing = 25;  //MenuItemImage与MenuItemTitle的间距
    op.menuCornerRadius = 6.5;  //菜单圆角半径
    op.maskToBackground = true;  //是否添加覆盖在原View上的半透明遮罩
    op.shadowOfMenu = false;  //是否添加菜单阴影
    op.hasSeperatorLine = true;  //是否设置分割线
    op.seperatorLineHasInsets = false;  //是否在分割线两侧留下Insets
    Color color;
    color.R = 0;
    color.G = 0;
    color.B = 0;
    op.textColor = color;
    Color bgColor;
    bgColor.R = 1;
    bgColor.G = 1;
    bgColor.B = 1;
    op.menuBackgroundColor = bgColor;
    self.options = op;

    //添加汉堡菜单
    self.hamburgerButton = [[JTHamburgerButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width - 50, 20, 30, 30)];
    [[self.hamburgerButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(JTHamburgerButton* para) {
        /*
        if(para.currentMode == JTHamburgerButtonModeHamburger){
            [para setCurrentModeWithAnimation:JTHamburgerButtonModeArrow];
        }
        else{
            [para setCurrentModeWithAnimation:JTHamburgerButtonModeHamburger];
        }*/
        [KxMenu showMenuInView:self.view fromRect:para.frame menuItems:self.menuArray withOptions:self.options];
    }];
    [header addSubview:self.hamburgerButton];
    
    UILabel *conditionsLabel = [[UILabel alloc] initWithFrame:conditionsFrame];
    conditionsLabel.backgroundColor = [UIColor clearColor];
    conditionsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    conditionsLabel.textColor = [UIColor whiteColor];
    [header addSubview:conditionsLabel];
    
    // bottom left
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:iconFrame];
    iconView.contentMode = UIViewContentModeScaleAspectFit; 
    iconView.backgroundColor = [UIColor clearColor]; 
    [header addSubview:iconView];
    //绑定数据变化
    [[RACObserve([WeatherManager sharedManager], currentCondition)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(WeatherCondition *newCondition) {
         UIImage* image =[UIImage imageNamed:[newCondition backgroundImage]];
         if (image != nil) {
             self.backgroundImageView.image = image;
             [self.blurredImageView setImageToBlur:image blurRadius:10 completionBlock:nil];
         }
         
         temperatureLabel.text = [NSString stringWithFormat:@"%.0f°",newCondition.temperature.floatValue];
         conditionsLabel.text = [newCondition.conditionDescription capitalizedString];
         cityLabel.text = [newCondition.locationName capitalizedString];
        
         iconView.image = [UIImage imageNamed:[newCondition imageName]];
     }];
    //用RAC绑定温度
    RAC(hiloLabel,text) = [[RACSignal combineLatest:@[
                        RACObserve([WeatherManager sharedManager], currentCondition.tempHigh),
                        RACObserve([WeatherManager sharedManager], currentCondition.tempLow)
                        ]
                        reduce:^id(NSNumber* high, NSNumber* low){
                            return [NSString stringWithFormat:@"%.0f° / %.0f°",high.floatValue,low.floatValue];
                        }] deliverOn:RACScheduler.mainThreadScheduler];
    
    [[RACObserve([WeatherManager sharedManager], hourlyForecast) deliverOn:RACScheduler.mainThreadScheduler] subscribeNext:^(NSArray* newForecast) {
        [self.tableView reloadData];
    }];
    [[RACObserve([WeatherManager sharedManager], dailyForecast) deliverOn:RACScheduler.mainThreadScheduler] subscribeNext:^(NSArray* newForecast) {
        [self.tableView reloadData];
    }];
    //定时请求数据-30s
    timer = [NSTimer scheduledTimerWithTimeInterval:180.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    [timer fire];
}

- (void)settingsClick{
    SettingsViewController* settingsViewController = [[SettingsViewController alloc]init];
    [self.navigationController pushViewController:settingsViewController animated:NO];
}

- (void)aboutClick{
    AboutViewController* aboutViewController = [[AboutViewController alloc]init];
    [self.navigationController pushViewController:aboutViewController animated:NO];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    
    self.backgroundImageView.frame = bounds;
    self.blurredImageView.frame = bounds;
    self.tableView.frame = bounds;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;

    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    BOOL flag = [defaults boolForKey:@"autoRefresh"];
    if (flag) {
        [timer setFireDate:[NSDate date]];
    }else{
        [timer setFireDate:[NSDate distantFuture]];
    }
}

- (void)timerFired:(id)sender{
    [[WeatherManager sharedManager] findCurrentLocation];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // TODO: Return count of forecast
    if (section == 0) {
        return MIN([WeatherManager sharedManager].hourlyForecast.count, 6) + 1;
    }
    return MIN([WeatherManager sharedManager].dailyForecast.count, 6) + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (! cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:NSLocalizedString(@"Hourly Forecast",nil)];
        }else{
            WeatherCondition* weather = [WeatherManager sharedManager].hourlyForecast[indexPath.row -1];
            [self configureHourlyCell:cell weather:weather];
        }
    }else if (indexPath.section == 1){
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:NSLocalizedString(@"Daily Forecast",nil)];
        } else {
            WeatherCondition* weather = [WeatherManager sharedManager].dailyForecast[indexPath.row - 1];
            [self configureDailyCell:cell weather:weather];
        }
    }
    
    return cell;
}

- (void)configureHeaderCell:(UITableViewCell*)cell title:(NSString*)title{
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = title;
    cell.detailTextLabel.text = @"";
    cell.imageView.image = nil;
}

- (void)configureHourlyCell:(UITableViewCell*)cell weather:(WeatherCondition*)weather{
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = [self.hourlyFormatter stringFromDate:weather.date];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f°",weather.temperature.floatValue];
    cell.imageView.image = [UIImage imageNamed:[weather imageName]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)configureDailyCell:(UITableViewCell*)cell weather:(WeatherCondition*)weather{
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = [self.dailyFormatter stringFromDate:weather.date];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f° / %.0f°",weather.tempHigh.floatValue,weather.tempLow.floatValue];
    cell.imageView.image = [UIImage imageNamed:[weather imageName]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Determine cell height based on screen
    NSInteger cellCount = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    return self.screenHeight / (CGFloat)cellCount;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat height = scrollView.bounds.size.height;
    CGFloat position = MAX(scrollView.contentOffset.y, 0.0);
    CGFloat percent = MIN(position / height, 1.0);
    self.blurredImageView.alpha = percent;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
