//
//  WeatherDailyForecast.m
//  BlurWeather
//
//  Created by WangCherlies on 15-10-16.
//  Copyright (c) 2015年 Charles Wang. All rights reserved.
//

#import "WeatherDailyForecast.h"

@implementation WeatherDailyForecast

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSMutableDictionary *paths = [[super JSONKeyPathsByPropertyKey] mutableCopy];
    paths[@"tempHigh"] = @"temp.max";
    paths[@"tempLow"] = @"temp.min";
    return paths;
}

@end
