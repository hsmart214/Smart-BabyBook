//
//  SBTDataPoint.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 2/28/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBTGrowthDataSource.h"

#define AVG_MONTH 30.4375f //average days in a Gregorian month

// only an object to hold data to be accessed by pointer, eg,  dataPoint->ageDays;
// data points will be able to be stored in NSArrays

@interface SBTDataPoint : NSObject <NSSecureCoding>

{
@public
    double ageDays;
    double ageMonths;
    double skew;
    double mean;
    double stdev;
    NSArray *percentileData;
}

// rounded to the nearest whole day
@property (nonatomic, readonly) double ageInDays;

-(double)percentileForMeasurement:(double)measurement;
-(double)dataForPercentile:(SBTPercentile)percentile;

-(NSDictionary *)propertyList;
-(instancetype)initWithPlist:(NSDictionary *)plist;

@end
