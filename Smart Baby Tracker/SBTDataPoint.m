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

-(double)percentileForMeasurement:(double)measurement
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

-(double)dataForPercentile:(SBTPercentile)percentile
{
    NSInteger index = [self translatePercentileToIndex:percentile];
    return [percentileData[index] doubleValue];
}

-(NSInteger)translatePercentileToIndex:(SBTPercentile)percentile
{
    if ([percentileData count] == 15) return (NSInteger)percentile;
    if ([percentileData count] == 10){
        switch (percentile) {
            case P3:
            case P5:
            case P10:
                return (NSInteger)percentile - 3;
            default:
                return (NSInteger)percentile - 2;
        }
    }else{
        switch (percentile) {
            case P3:
            case P5:
            case P10:
                return (NSInteger)percentile - 4;
            case P25:
            case P50:
            case P75:
                return (NSInteger)percentile - 3;
            default:
                return (NSInteger)percentile - 2;
        }
    }
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeDouble:ageDays forKey:@"ageDays"];
    [aCoder encodeDouble:ageMonths forKey:@"ageMonths"];
    [aCoder encodeDouble:skew forKey:@"skew"];
    [aCoder encodeDouble:mean forKey:@"mean"];
    [aCoder encodeDouble:stdev forKey:@"stdev"];
    [aCoder encodeObject:percentileData forKey:@"percentileData"];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]){
        ageDays = [aDecoder decodeDoubleForKey:@"ageDays"];
        ageMonths = [aDecoder decodeDoubleForKey:@"ageMonths"];
        skew = [aDecoder decodeDoubleForKey:@"skew"];
        mean = [aDecoder decodeDoubleForKey:@"mean"];
        stdev = [aDecoder decodeDoubleForKey:@"stdev"];
        percentileData = [aDecoder decodeObjectOfClass:[NSArray class] forKey:@"percentileData"];
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
        percentileData = plist[@"percentileData"];
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
             @"percentileData": percentileData,
             };
}

+(BOOL)supportsSecureCoding
{
    return YES;
}

@end
