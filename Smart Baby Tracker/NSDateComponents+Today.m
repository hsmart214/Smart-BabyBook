//
//  NSDateComponents+Today.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 2/2/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "NSDateComponents+Today.h"

@implementation NSDateComponents (Today)

+(instancetype)today
{
    NSDate *date = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSCalendarUnit unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *comps = [cal components:unitFlags fromDate:date];
    comps.calendar = [NSCalendar currentCalendar];

    return comps;
}

@end
