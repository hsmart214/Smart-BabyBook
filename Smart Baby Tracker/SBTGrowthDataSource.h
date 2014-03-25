//
//  SBTGrowthChart.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 2/28/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {SBTStature, SBTLength, SBTWeight, SBTHeadCircumference, SBTBMI} SBTGrowthParameter;

typedef enum {P01, P1, P3, P5, P10, P15, P25, P50, P75, P85, P90, P95, P97, P99, P999} SBTPercentile;


// an abstract class meant to be subclassed into various WHO and CDC growth datasources

@interface SBTGrowthDataSource : NSObject

-(NSArray *)filledDataArrayFromFile:(NSString *)fileString;

-(double)percentileOfMeasurement:(double)measurement
                          forAge:(NSInteger)days
                       parameter:(SBTGrowthParameter)parameter
                       andGender:(SBTGender)gender;

-(double)dataForPercentile:(SBTPercentile)percentile
                    forAge:(double)age
                 parameter:(SBTGrowthParameter)parameter
                 andGender:(SBTGender)gender;

-(double)dataAgeRange;
-(double)dataMeasurementRange97PercentForParameter:(SBTGrowthParameter)parameter forGender:(SBTGender)gender;

+(instancetype)sharedDataSource;

@end
