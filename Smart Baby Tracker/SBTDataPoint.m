//
//  SBTDataPoint.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 2/28/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTDataPoint.h"

@implementation SBTDataPoint

-(double)percentileForMeasurment:(double)measurement
{
    double pct = 0.0;
    double z = 0.0;
    
    if (skew != 0.0){
        z = (pow((measurement/mean), skew)-1)/(skew * stdev);
    }else{
        z = log(measurement/mean)/stdev;
    }
    pct = 0.5 * (1 + erf(z * M_SQRT1_2));
    return pct;
}

@end
