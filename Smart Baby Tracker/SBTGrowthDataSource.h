//
//  SBTGrowthChart.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 2/28/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {SBTStature, SBTLength, SBTWeight, SBTHeadCircumference, SBTBMI} SBTGrowthParameter;

// an abstract class meant to be subclassed into various WHO and CDC growth datasources

@interface SBTGrowthDataSource : NSObject

-(NSArray *)filledDataArrayFromFile:(NSString *)fileString;

-(double)percentileOfMeasurement:(double)measurement
                          forAge:(NSInteger)days
                       parameter:(SBTGrowthParameter)parameter
                       andGender:(SBTGender)gender;

-(double)dataAgeRange;
-(double)dataMeasurementRange97PercentForParameter:(SBTGrowthParameter)parameter forGender:(SBTGender)gender;

+(instancetype)sharedDataSource;

@end
