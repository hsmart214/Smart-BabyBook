//
//  SBTDataPoint.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 2/28/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTDataPoint.h"

@implementation SBTDataPoint

// some data points will be created with age in days, some in months.
// if they are both zero, it does not matter which we return.
// if days is zero, then there is probably a month value, if not the baby is newborn.
-(double)ageInDays
{
    if (ageDays > 0.0) {
        return floor(ageDays + 0.5);
    }else{
        return floor(ageMonths * AVG_MONTH + 0.5); // this will of course be zero if both are zero
    }
}

-(double)percentileForMeasurment:(double)measurement
{
    double pct = 0.0;
    double z = 0.0;
    
    if (skew != 0.0){
        z = (pow((measurement/mean), skew)-1)/(skew * stdev);
    }else{
        z = log(measurement/mean)/stdev;
    }
    pct = 0.5 * (1 + erf(z * M_SQRT1_2)); // don't ask me where I got this! (StackOverflow)
    return pct * 100.0;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeDouble:ageDays forKey:@"ageDays"];
    [aCoder encodeDouble:ageMonths forKey:@"ageMonths"];
    [aCoder encodeDouble:skew forKey:@"skew"];
    [aCoder encodeDouble:mean forKey:@"mean"];
    [aCoder encodeDouble:stdev forKey:@"stdev"];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]){
        ageDays = [aDecoder decodeDoubleForKey:@"ageDays"];
        ageMonths = [aDecoder decodeDoubleForKey:@"ageMonths"];
        skew = [aDecoder decodeDoubleForKey:@"skew"];
        mean = [aDecoder decodeDoubleForKey:@"mean"];
        stdev = [aDecoder decodeDoubleForKey:@"stdev"];
    }
    return self;
}

-(instancetype)initWithPlist:(NSDictionary *)plist
{
    if (self = [super init]){
        ageDays = [plist[@"ageDays"] doubleValue];
        ageMonths = [plist[@"ageMonths"] doubleValue];
        skew = [plist[@"skew"] doubleValue];
        mean = [plist[@"mean"] doubleValue];
        stdev = [plist[@"stdev"] doubleValue];
    }
    return self;
}

-(NSDictionary *)propertyList
{
    return @{
             @"ageDays": @(ageDays),
             @"ageMonths": @(ageMonths),
             @"skew": @(skew),
             @"mean": @(mean),
             @"stdev": @(stdev),
             };
}

+(BOOL)supportsSecureCoding
{
    return YES;
}

@end
