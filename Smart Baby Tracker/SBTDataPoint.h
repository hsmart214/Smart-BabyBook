//
//  SBTDataPoint.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 2/28/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import <Foundation/Foundation.h>

#define AVG_MONTH 30.4375f //average days in a Gregorian month

// only an object to hold data to be accessed by pointer, eg,  dataPoint->ageDays;
// data points will be able to be stored in NSArrays

@interface SBTDataPoint : NSObject

{
    
    double ageDays;
    double ageMonths;
    double skew;
    double mean;
    double stdev;
    
}

-(double)percentileForMeasurment:(double)measurement;

@end
