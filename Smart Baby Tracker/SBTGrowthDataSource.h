//
//  SBTGrowthChart.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 2/28/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {SBTStature, SBTLength, SBTMass, SBTHeadCircumference, SBTBMI} SBTGrowthParameter;

// an abstract class meant to be subclassed into various WHO and CDC growth datasources

@interface SBTGrowthDataSource : NSObject

-(double)percentileForAge:(NSInteger)days forParameter:(SBTGrowthParameter)parameter;

@end
