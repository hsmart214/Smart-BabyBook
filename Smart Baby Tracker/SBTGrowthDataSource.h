//
//  SBTGrowthChart.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 2/28/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import <Foundation/Foundation.h>

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

-(double)dataAgeRangeForAge:(double)age;
-(double)dataFloorForParameter:(SBTGrowthParameter)parameter;
-(double)baselineForParameter:(SBTGrowthParameter)parameter childChart:(BOOL)child;
-(double)dataMeasurementRange97PercentForParameter:(SBTGrowthParameter)parameter
                                         forGender:(SBTGender)gender
                                          forChild:(BOOL)child; // is this a child (YES) or infant (NO)\

/* this takes an array of SBTPercentile and returns an array of the measurement values (metric) for those percentiles            *
 * at the age specified - to be used for the display of the percentile cues on the graph                                         *
 * this allows the caller to decide which percentiles to ask for - just use the passed array to remember which ones you get back */
-(NSArray *)measurementsAtPercentiles:(NSArray *)percentiles
                               forAge:(double)age
                         forParameter:(SBTGrowthParameter)parameter
                            forGender:(SBTGender)gender;

+(instancetype)sharedDataSource;

+(SBTGrowthDataSource *)growthDataSourceForAge:(NSInteger)ageInDays;
+(double)infantAgeMaximum;
-(double)infantAgeMaximum; // this one returns a cached value
-(void)resetInfantAgeMaximum;
-(BOOL)hasLimitedWeightData;

@end
