//
//  Settings.h
//  BlurWeather
//
//  Created by koudai_hs on 15-10-22.
//  Copyright (c) 2015年 Charles Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Settings : NSObject

@property (strong,nonatomic)NSString* title;
@property (strong,nonatomic)NSString* onText;
@property (strong,nonatomic)NSString* offText;
@property (strong,nonatomic)NSString* identifyKey;

- (id)initWithTitle:(NSString*)title onText:(NSString*)onText OffText:(NSString*)offText identifyKey:(NSString*)identifyKey;

@end
