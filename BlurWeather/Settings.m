//
//  Settings.m
//  BlurWeather
//
//  Created by koudai_hs on 15-10-22.
//  Copyright (c) 2015年 Charles Wang. All rights reserved.
//

#import "Settings.h"

@implementation Settings

- (id)initWithTitle:(NSString*)title onText:(NSString*)onText OffText:(NSString*)offText identifyKey:(NSString*)IdentifyKey {
    if (self = [super init]) {
        self.title = title;
        self.onText = onText;
        self.offText = offText;
        self.IdentifyKey = IdentifyKey;
    }
    return self;
}
@end
