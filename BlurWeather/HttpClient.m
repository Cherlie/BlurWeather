//
//  HttpClient.m
//  BlurWeather
//
//  Created by WangCherlies on 15-10-16.
//  Copyright (c) 2015年 Charles Wang. All rights reserved.
//

#import "HttpClient.h"
#import "WeatherCondition.h"
#import "WeatherDailyForecast.h"

@interface HttpClient ()

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation HttpClient

- (id)init {
    if (self = [super init]) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config];
    }
    return self;
}

- (RACSignal *)fetchJSONFromURL:(NSURL *)url {
    NSLog(@"Fetching: %@",url.absoluteString);
    
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (! error) {
                NSError *jsonError = nil;
                id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                if (! jsonError) {
                    [subscriber sendNext:json];
                }
                else {
                    [subscriber sendError:jsonError];
                } 
            } 
            else {
                [subscriber sendError:error]; 
            }
            [subscriber sendCompleted];
        }];
        
        [dataTask resume];
        return [RACDisposable disposableWithBlock:^{
            [dataTask cancel];
        }];
    }] doError:^(NSError *error) {
        NSLog(@"%@",error);
    }]; 
}

- (RACSignal *)fetchCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate {
    NSLocale *currentLocale = [NSLocale currentLocale];
    NSString* lang = [currentLocale objectForKey:NSLocaleLanguageCode];
    
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&appid=bd82977b86bf27fb59a04b61b657fb6f&lang=%@",coordinate.latitude, coordinate.longitude,lang];
    NSURL *url = [NSURL URLWithString:urlString];
    
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
        NSError* error = [[NSError alloc]init];
        RACSignal* signal = [MTLJSONAdapter modelOfClass:[WeatherCondition class] fromJSONDictionary:json error:&error];
        NSLog(@"%@",error.description);
        return signal;
    }];
}

- (RACSignal *)fetchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate {
    NSLocale *currentLocale = [NSLocale currentLocale];
    NSString* lang = [currentLocale objectForKey:NSLocaleLanguageCode];
    
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast?lat=%f&lon=%f&appid=bd82977b86bf27fb59a04b61b657fb6f&lang=%@",coordinate.latitude, coordinate.longitude,lang];
    NSURL *url = [NSURL URLWithString:urlString];
    
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
        RACSequence *list = [json[@"list"] rac_sequence];
        
        return [[list map:^(NSDictionary *item) {
            return [MTLJSONAdapter modelOfClass:[WeatherCondition class] fromJSONDictionary:item error:nil];
        }] array];
    }]; 
}

- (RACSignal *)fetchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate {
    NSLocale *currentLocale = [NSLocale currentLocale];
    NSString* lang = [currentLocale objectForKey:NSLocaleLanguageCode];
    
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&cnt=10&mode=json&appid=bd82977b86bf27fb59a04b61b657fb6f&lang=%@",coordinate.latitude, coordinate.longitude,lang];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // Use the generic fetch method and map results to convert into an array of Mantle objects
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
        // Build a sequence from the list of raw JSON
        RACSequence *list = [json[@"list"] rac_sequence];
        
        // Use a function to map results from JSON to Mantle objects
        return [[list map:^(NSDictionary *item) {
            return [MTLJSONAdapter modelOfClass:[WeatherDailyForecast class] fromJSONDictionary:item error:nil];
        }] array];
    }];
}

@end
