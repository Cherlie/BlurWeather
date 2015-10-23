//
//  WeatherCondition.m
//  BlurWeather
//
//  Created by WangCherlies on 15-10-16.
//  Copyright (c) 2015年 Charles Wang. All rights reserved.
//

#import "WeatherCondition.h"

@implementation WeatherCondition

+ (NSDictionary *)imageMap {
    static NSDictionary *_imageMap = nil;
    if (! _imageMap) {
        _imageMap = @{
                      @"01d" : @"weather-clear",
                      @"02d" : @"weather-few",
                      @"03d" : @"weather-few",
                      @"04d" : @"weather-broken",
                      @"09d" : @"weather-shower",
                      @"10d" : @"weather-rain",
                      @"11d" : @"weather-tstorm",
                      @"13d" : @"weather-snow",
                      @"50d" : @"weather-mist",
                      @"01n" : @"weather-moon",
                      @"02n" : @"weather-few-night",
                      @"03n" : @"weather-few-night",
                      @"04n" : @"weather-broken",
                      @"09n" : @"weather-shower",
                      @"10n" : @"weather-rain-night",
                      @"11n" : @"weather-tstorm",
                      @"13n" : @"weather-snow",
                      @"50n" : @"weather-mist"
                      };
    }
    return _imageMap;
}

#define MPS_TO_MPH 2.23694f

+ (NSValueTransformer *)windSpeedJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSNumber *num, BOOL *success, NSError *__autoreleasing *error) {
        return @(num.floatValue*MPS_TO_MPH);
    } reverseBlock:^id(NSNumber *speed, BOOL *success, NSError *__autoreleasing *error) {
        return @(speed.floatValue/MPS_TO_MPH);
    }];
}

+ (NSValueTransformer *)conditionDescriptionJSONTransformer {
    return [self weatherArrayJSONTransformer:@"description"];
}

+ (NSValueTransformer*)weatherArrayJSONTransformer:(NSString*)nodeName{
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSArray *values, BOOL *success, NSError *__autoreleasing *error) {
        NSDictionary* dict = [values firstObject];
        return dict[nodeName];
    } reverseBlock:^id(NSString *str, BOOL *success, NSError *__autoreleasing *error) {
        return @[str];
    }];
}

+ (NSValueTransformer *)conditionJSONTransformer {
    return [self weatherArrayJSONTransformer:@"main"];
}

+ (NSValueTransformer *)iconJSONTransformer {
    return [self weatherArrayJSONTransformer:@"icon"];
}

+ (NSValueTransformer *)dateJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *str, BOOL *success, NSError *__autoreleasing *error) {
        return [NSDate dateWithTimeIntervalSince1970:str.floatValue];
    } reverseBlock:^id(NSDate *date, BOOL *success, NSError *__autoreleasing *error) {
        return [NSString stringWithFormat:@"%f",[date timeIntervalSince1970]];
    }];
}

+ (NSValueTransformer *)sunriseJSONTransformer {
    return [self dateJSONTransformer];
}

+ (NSValueTransformer *)sunsetJSONTransformer {
    return [self dateJSONTransformer];
}


+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"date": @"dt",
             @"locationName": @"name",
             @"humidity": @"main.humidity",
             @"temperature": @"main.temp",
             @"tempHigh": @"main.temp_max",
             @"tempLow": @"main.temp_min",
             @"sunrise": @"sys.sunrise",
             @"sunset": @"sys.sunset",
             @"conditionDescription": @"weather",
             @"condition": @"weather",
             @"icon": @"weather",
             @"windBearing": @"wind.deg",
             @"windSpeed": @"wind.speed"
             };
}

- (NSString*)backgroundImage {
    @try {
        return [WeatherCondition backgroundMap][self.icon];
    }
    @catch (NSException *exception) {
        return @"bg";
    }
}

+ (NSDictionary*)backgroundMap {
    return  @{
              @"01d" : @"bg",
              @"02d" : @"bg",
              @"03d" : @"bg",
              @"04d" : @"day-broken-weather",
              @"09d" : @"day-rain-weather",
              @"10d" : @"day-rain-weather",
              @"11d" : @"day-rain-weather",
              @"13d" : @"day-snow-weather",
              @"50d" : @"day-mist-weather",
              @"01n" : @"night-moon-weather",
              @"02n" : @"night-moon-weather",
              @"03n" : @"night-moon-weather",
              @"04n" : @"night-rain-weather",
              @"09n" : @"night-rain-weather",
              @"10n" : @"night-rain-weather",
              @"11n" : @"night-rain-weather",
              @"13n" : @"night-snow-weather",
              @"50n" : @"night-moon-weather"
              };
}

+ (NSValueTransformer*)temperatureJSONTransformer {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isFahrenheit = [defaults boolForKey:@"tempFormat"];
    
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSNumber* value, BOOL *success, NSError *__autoreleasing *error) {
        if (!isFahrenheit) {
            return @(value.floatValue - 273.0);
        } else {
            return @(9 / 5 * (value.floatValue - 273.0) + 32);
        }
    } reverseBlock:^id(NSNumber* value, BOOL *success, NSError *__autoreleasing *error) {
        if (!isFahrenheit) {
            return @(value.floatValue + 273.0);
        } else {
            return @((value.floatValue - 32) * (5 / 9) +273.0);
        }
    }];
}

+ (NSValueTransformer*)tempHighJSONTransformer {
    return [self temperatureJSONTransformer];
}

+ (NSValueTransformer*)tempLowJSONTransformer {
    return [self temperatureJSONTransformer];
}

- (NSString *)imageName {
    return [WeatherCondition imageMap][self.icon];
}
@end
